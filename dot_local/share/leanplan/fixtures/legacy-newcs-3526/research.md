# NEWCS-3526 — 예약 이상 탐지 · 코드 맥락

> v1 스코프(`./spec.md`·`./design.md`·`./plan.md`) 구현에 필요한 현행 코드 맥락만 남겼다.
> 경로는 달리 명시하지 않는 한 `services/carsharing-reservation/subprojects/reservation/core/src/main/kotlin/kr/socar/carsharing/reservation/` 이하. 축약 표기: `…/domain/…`.

---

## 1. 배경

**[NEWCS-2695 "생성 이후, 이미 받아놓은 예약에 문제가 생겼을 때의 대응 체계 구축"](https://socarcorp.atlassian.net/browse/NEWCS-2695)** (Epic, reporter: 니오, status: Backlog, 2025-08-13 생성).

예약은 등록 시점 스냅샷 위에서 수락된다. 시간이 지나며 외부 이벤트(관리자 정책 변경, 차량 존 이동, 강제 연장 등)로 스냅샷 전제가 깨지면, 라이프사이클의 특정 "임무 종결 지점"에서 조용히 실패가 누적된다. v1 은 이 중 **점유(occupation) 관점의 이상** 을 별도 이벤트 스트림으로 가시화하고 대차로 귀결시킨다.

---

## 2. 두 탐지 지점

### 2.1 `IdleZeroService.kt:274-277` — confirmCarOccupation 최종 실패

```kotlin
?: handleCarOccupationConfirmFailures(
    failures = attempts.filterIsInstance<ConfirmCarOccupationResult.Failure>(),
    currOccupation = currReservationCarOccupation,
)
```

- 여러 `ConfirmCarOccupationResult` 시도가 모두 실패한 terminal 처리 지점.
- 확정 데드라인(interval.start - 55min) 직전에 `ConfirmCarOccupationAtDeadlineTask` 가 확정을 강제한다 — 이 지점이 실질적 "마지막 방어선".

### 2.2 `ReservationCarOccupationEventHandlingService.kt:196-205` — 점유→예약 sync 실패

```kotlin
} catch (e: ConflictingReservationPreExistingException) {
    reservationDoRepository.save(it) // 중첩 체크 없이 일단 저장
    runCatching {
        failureNotifier.notifyOccupationToReservationReconciliationFailure(
            it,
            confirmedCarOccupation,
            conflictingReservationIds = e.reservationIds,
        )
    }.onFailure { notifyEx ->
        logger.error("[ReservationDo.reconcileWith] 점유 -> 예약 정합성 불일치 알림 실패", notifyEx)
    }
}
```

- 양보(`onReservationCarOccupationYielded`) 이벤트 수신 후 `reconcileWith` 내부. 점유가 CONFIRMED 로 승격됐는데 다른 예약이 같은 구간을 이미 차지하고 있는 경우.
- 현재는 중첩 체크 없이 강제 저장 + FailureNotifier 로 운영 알림. 판정·후속 처리는 수동 의존.

---

## 3. 소비자 판정에 필요한 현행 로직

### 3.1 차량 점유 도메인 — 최소 지식

**`CarOccupationDo`** 아이템 invariant (`…/domain/aggregate/occupation/CarOccupationDo.kt:60-77`):
- 크기 ∈ {1, 2}
- size=1 → 유일 아이템은 `CONFIRMED`
- size=2 → 둘 다 `TENTATIVE`, carId 서로 다름

**조회**: `CarOccupationService.findOne(ReservationOccupant(reservationId)): CarOccupationDto?`. 현재 점유 상태 스냅샷을 반환. v1 classifier 가 예약의 현재 점유가 정상인지 판단할 때 바로 사용.

**Occupant 종류**: `ReservationOccupant(reservationId)` / `BlockOccupant(blockId)` (차량 존 이동, 정비, 사고 블락 등).

### 3.2 예약 상태 & 그룹 상수

`ReservationStateDo` (`…/domain/aggregate/reserve/ReservationDo.kt`):
- `ACTIVE_RESERVATION_STATES = {READY, DRIVING, PREPARING, RETURN_DELAYED}` — 활성 예약.
- `CANCELED_STATES = {CANCELED, CREATION_FAILURE}` — 소비자에서 즉시 skip 대상.

### 3.3 idle-zero & confirmDeadline

- **`IdleZeroService.isIdleZeroTarget`** (private, `IdleZeroService.kt:415-435`) — 예약이 idle-zero 대상인지 판정 (부름 배달, 타겟 지역, 제외 유형 체크). 소비자에서 공개 호출이 필요하므로 `public` 으로 전환 예정.
- **`confirmDeadline`** (`…/domain/aggregate/reserve/ReservationDomainContextOverOccupations.kt`): 상수 `RESERVATION_CAR_OCCUPATION_CONFIRM_DEADLINE_BUFFER_SIZE = 55min`. `interval.start - 55min` 으로 계산되며, 소비자의 재시도 중단 시점 기준.

### 3.4 예약 측 overlap 쿼리

**`ReservationDoRepository.findByCarIdsAndOccupationInterval(carIds, interval)`** (interface L51, L161; 이미 존재). 차량 ID × 점유 구간으로 겹치는 예약을 조회. v1 classifier 의 예약 테이블 검사에 그대로 사용.

### 3.5 Benign overlap helpers

`ReservationCarOccupationEventHandlingService` 의 `resolveIfPossible` 내부에서 이미 "무해한 중첩" 4 가지를 판별한다:

- `isParentReservationOverwritten()` — RELATIVE 관계 부모-자식.
- `isReturningMemberCancelledHandleOverwrittenByHandlerMember()` — 취소된 회송 멤버 핸들.
- `isAlreadyCompletedReservationOverwritten()` — 완료/취소 예약.
- `awaitResolution()` — 짧은 대기 후 해소 확인.

v1 classifier 가 benign 중첩을 걸러낼 때 재사용. 소비자에서 호출 가능하도록 visibility 조정 또는 별도 service 분리 필요 (범위 결정은 구현 시점).

---

## 4. Deprecation 대상 (v1 이 흡수)

### 4.1 `FailureNotifier.notifyOccupationToReservationReconciliationFailure`
`ReservationCarOccupationEventHandlingService.kt:503-510` 인터페이스. 유일 호출처는 `reconcileWith` (L198). v1 탐지 지점 2번의 publisher 호출로 대체.

### 4.2 `createForceExtendConflictJiraIssueIfApplicable` + `sendForceExtendJiraFailureMessage`
같은 파일 L281-348. 강제 연장 덮어쓰기 충돌을 Jira 티켓으로 만들고, 실패 시 Slack 알림. **이 로직 본문** 은 새 `CarTakeoverRequestHandler` 로 이식한다.

### 4.3 유지해야 할 기존 로직

- `FORCE_EXTEND_JIRA_MEMO_PREFIX` 기반 Jira 중복 방지 체크 — handler 내부에서 그대로 사용.
- `resolveIfPossible` 의 4 가지 auto-resolve 분기 (§3.5 helpers 기반) — v1 탐지 지점이 아니므로 손대지 않는다. 다만 classifier 는 같은 판별 로직을 재사용.

---

## 5. 관련 이력 (NEWCS-2695 하위)

| Key | 제목 | 상태 |
|---|---|---|
| NEWCS-3526 | 부름 예약 데드라인에 차량 점유 확정하다가 늘어난 쿠션 타임으로 뒤늦게 실패 시 일단 처리 + 대차 요청 | **In Progress** (본 작업) |
| NEWCS-3284 | 차량변경 이벤트를 받아서 잠정점유를 몰아내기 | Done |
| NEWCS-3098 | 잠정 차량 점유의 양보 반영 및 데드라인 확정 시점에 차량 변경(-1→확정) 처리 실패 케이스 대응 | Done |
| NEWCS-2887 | 쿠션타임이 변경될 때 점유에 정상적으로 반영되도록 수정 | Cancelled (필요성은 유효, 보류됨) |
| 그 외 | 2651 / 2674 / 2757 / 3056 / 3097 | 다수 Cancelled |

Epic 하위 8 개 취소 + 2 개 완료 + 1 개 진행중 이력이 **점적 대응의 한계** 를 보여준다. v1 은 점유 이상 전반에 대한 일관된 보고·처리 체계로 전환.

---

## 6. 추가 확정 사항 (Q&A 결과)

이상 탐지 시스템의 전제가 되는 사실 몇 가지:

- `syncCarOccupation` RPC 는 기대된 자동 전파 용도로 쓰이지 **않는다**. 쿠션 drift 근본 해결은 v1 범위 밖.
- `socar-request` 는 예약 gRPC 호출을 최대 **10회 재시도** (exponential backoff, 모든 exception 대상, ~50s window). 동일 사건이 10번 재발화 가능 → 소비자측 dedup 또는 handler 내부 idempotency 로 대처 (v1 은 후자 — 기존 Jira memo prefix 재사용).
- Kafka 이벤트 경로 (v1): publisher → topic → consumer (direct, fire-and-forget). 같은 예약의 partition 내 순서만 보장, 교차 순서 보장 없음. 전송 실패 시 Slack 알림으로 surface.

## 7. 운영팀 합의 — 대차 요청 Jira 티켓 내용 (2026-04-16)

슬랙 스레드 (`C0178E8BGSJ`, thread root `1775182574.712969`, 주요 메시지 `1776315619.964829`). 상담센터 앤디와 합의된 사항:

- 이번 작업으로 자동 생성되는 **대차 요청 Jira 티켓을 CS 센터가 직접 참조**하기로 함 (어드민 UI 개선 아님).
- 조기 대응을 가능하게 하기 위해 티켓 본문에 두 항목을 반드시 포함:
  - 현재 문제 예약에 점유 확정된 차량 번호.
  - 해당 차량에 대해 문제 예약과 현재 충돌 중인 다른 예약들(**복수**).
- 이후 옥스트라/어드민 UI 개선은 실제 업무 플로우 불편 발생 시 별도로 발의.

> 기존 `createForceExtendConflictJiraIssueIfApplicable` 가 만드는 티켓은 충돌 상대 예약을 단일 id(`overwriter.reservationId`) 로만 기록한다. v1 handler 는 이 부분을 **복수** 로 확장해 티켓 본문에 렌더링해야 합의를 만족한다.

---

## 8. Kafka 토픽 설정 · 배경 지식

`design.md` §3 의 물리 설정 결정에서 참조하는 일반 개념 정리. 본 프로젝트에 국한되지 않는 reference 성격의 내용이라 design 문서에서 분리.

### 8.1 Partition 사이징 이론

**포뮬러** (LinkedIn 원조, 이후 표준):
```
partitions ≥ max(T/W, T/R)
  T: target throughput (MB/s or msg/s)
  W: measured single-producer per-partition throughput
  R: measured single-consumer per-partition throughput
```

**현대 Kafka** (3.0+): 파티션당 ~50–100 MB/s 처리 가능 (튜닝 전제, conservative 50).

**핵심 제약들**:
- **Consumer 병렬성 상한**: 한 consumer group 내 한 partition 은 한 consumer 인스턴스만 소유. 즉 partition 수 = 최대 병렬성.
- **Partition 순서**: Kafka 는 partition 내부에서만 순서 보장. 전역 순서가 필요하면 partition=1 필수 (병렬성 0).
- **증가만 가능**: partition 은 감소 불가. 증가 시 `hash(key) % N` 의 N 이 바뀌어 **key 분배 재배치** → key 기반 직렬화·compaction 의미론 영향.
- **오버파티셔닝 비용**: metadata size ↑, controller rebalance 시간 ↑, ZK/KRaft 부담. 공짜 아님.

**실무 가이드**:
- 시작은 **작게**, 성장 시 늘림.
- worker replica N 기준으로 `partitions ≥ N` 이상이면 load 분산 가능.
- Ordering·idempotency serialization 이 key 기반이면, 초기 partition 수 변경이 가장 큰 비용이므로 신중.

### 8.2 Durability triangle: RF / ISR / acks

| 설정 | 위치 | 효과 |
|---|---|---|
| `replication.factor` | topic | 데이터 복제본 수 |
| `min.insync.replicas` | topic (broker default 도 있음) | `acks=all` 일 때 쓰기 수락 최소 sync replica 수 |
| `acks` | producer | `0` / `1` / `all` — 쓰기 ack 타이밍 |

**`acks` 값별 의미**:
- `acks=0`: producer 는 네트워크 전송만 하고 ack 안 기다림. 비동기. 재현 불가능한 유실.
- `acks=1` (Kafka 클라이언트 기본, Spring Kafka 도 동일): leader 만 fsync 후 ack. leader crash 후 follower 승급 전 마지막 메시지 유실 가능.
- `acks=all` (= `acks=-1`): ISR 전원 fsync 후 ack. min.insync.replicas 와 결합해 강한 내구성.

**조합 평가**:
| 조합 | 내구성 | 가용성 | 용례 |
|---|---|---|---|
| RF=1 | 브로커 1 손실 = 데이터 유실 | (당연히) 낮음 | test only |
| RF=2 + ISR=1 + acks=1 | last-ms 유실 가능 | 1 broker 장애 견딤 | 저가치 이벤트 |
| RF=2 + ISR=2 + acks=all | 강함 | 1 broker 장애 시 쓰기 차단 | DLT 조심스러운 선택 |
| **RF=3 + ISR=2 + acks=all** | 강함 | 1 broker 장애 견딤 | **대부분의 프로덕션 이벤트 표준** |
| RF=3 + ISR=3 + acks=all | 최강 | 1 broker 장애 시 쓰기 차단 | 금융·정산 |

**주의**: producer 의 `acks` 설정은 topic 의 `min.insync.replicas` 와 **반드시 한 쌍으로** 봐야 함. `min.insync.replicas=2` 인 topic 에 `acks=1` 로 쓰면 ISR 계약은 무의미해진다. Spring Kafka 의 Kafka 클라이언트 기본값이 `acks=1` 인 점을 기억.

### 8.3 Retention 과 segment — the active segment rule

**Kafka log 물리 구조**:
- partition = 연속된 **segment 파일** 들.
- 한 segment 가 "active" (쓰기 대상), 나머지는 closed (read-only, 삭제 후보).
- Retention/compaction 은 **segment 단위** 로 작동. 개별 메시지 단위가 아님.

**Segment 닫힘 조건** (OR 조건 중 하나 만족 시):
- `segment.bytes` 도달 (기본 1GB)
- `segment.ms` 경과 (기본 7d)
- index/timeindex 파일 full

**Active segment 는 절대 삭제되지 않음**. 이게 저용량 토픽 함정의 원천.

**저용량 gotcha**:
- 하루 15KB 도 못 쌓는 토픽은 1GB segment 영영 못 채움.
- 기본 `segment.ms=7d` 까지 active 상태 유지.
- `retention.ms` 가 아무리 짧아도 active segment 안의 메시지는 삭제 안 됨.
- 실효 retention = `segment.ms` + `retention.ms`.

**해결 공식**: `segment.ms ≤ retention.ms / 2` 정도로 override. 저용량 토픽의 대표적 override.

**부수 비용**: segment 수 증가 = file handle 증가 = broker open files 증가. 일반 업무 토픽 규모에선 무시 가능, 초고속 또는 초대량에선 주의.

### 8.4 Cleanup policy

- `delete`: 시간·크기 기준으로 whole segment 삭제. event topic 기본.
- `compact`: 키별 **최신 메시지만** 유지. tombstone (null value) 로 키 삭제 표시. state topic, KTable changelog, CDC 등.
- `delete,compact` 혼합: 시간 기준 삭제 + 남은 것 중 키별 압축.

**선택 기준**:
- 이벤트가 "상태 snapshot" → compact.
- 이벤트가 "변화 trigger" → delete.
- "최신 state 가 필요하지만 과거 이력도 일정 기간 유지" → 혼합.

### 8.5 Idempotent producer

**목적**: producer 재시도로 인한 **중복 저장 방지** (broker side 에서).

**내부 메커니즘**:
- 세션 시작 시 broker 가 producer 에 **PID** (producer id) 발급.
- 메시지마다 `(PID, partition, sequence_number)` 부착.
- broker 는 partition 별 마지막 `(PID, seq)` 기억. 중복 도달 시 저장 생략 + OK 반환.

**요구 조건**:
- `enable.idempotence=true`
- `acks=all` (필수 — idempotence 가 요구)
- `max.in.flight.requests.per.connection ≤ 5` (순서 보장)
- `retries > 0`

Spring Kafka 3.x 부터 `enable.idempotence=true` 가 기본값. 명시하면 안전.

**주의: exactly-once 아님**. producer→broker 구간 **중복** 만 방지. end-to-end exactly-once 는 Kafka transactions (`transactional.id`) + consumer isolation level 필요. 우리처럼 handler 측 idempotency 로 충분하면 굳이 transaction 까지 가지 않는다.

### 8.6 AWS MSK 차이점 (vanilla Kafka 대비)

- **인증**: IAM SASL 지원 (Confluent Cloud 의 API key 와 유사한 AWS-native 방식). 기존 SASL/SCRAM 과 mTLS 도 가능.
- **Schema Registry**: Confluent SR 대신 **AWS Glue Schema Registry** 사용 가능. API 는 호환, deps 는 `software.amazon.awssdk:glue` 기반.
- **토픽 auto-creation**: broker-level `auto.create.topics.enable` 설정에 따름. Spring Kafka `@RetryableTopic(autoCreateTopics="true")` 는 broker 허용 시만 작동.
- **업그레이드**: 롤링 업그레이드. 브로커 교체 시 순간 leader re-election 발생. producer `retries` 로 흡수.
- **관리 콘솔**: AWS Console UI + kafka-ui (운영팀 제공) + 표준 Kafka CLI 모두 사용 가능.
- **모니터링**: CloudWatch + JMX. Datadog 통합.

### 8.7 References

- AWS MSK 활용 가이드: `https://socarcorp.atlassian.net/wiki/spaces/CPDO/pages/3207828044`
- Apache Kafka topic-configs: `https://kafka.apache.org/41/configuration/topic-configs/`
- Confluent, "Kafka retention": `https://www.confluent.io/learn/kafka-retention/`
- Conduktor, "Partitioning strategies": `https://conduktor.io/glossary/kafka-partitioning-strategies-and-best-practices`
- Datadog engineering blog (low-throughput segment gotcha): `https://www.datadoghq.com/blog/kafka-at-datadog/`
- Kafka idempotent producer (KIP-98): `https://cwiki.apache.org/confluence/display/KAFKA/KIP-98+-+Exactly+Once+Delivery+and+Transactional+Messaging`
