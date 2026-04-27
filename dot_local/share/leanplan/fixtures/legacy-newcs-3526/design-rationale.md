# NEWCS-3526 — 예약 이상 탐지 v1 · 설계 결정 근거

> 본 문서는 `design.md` 의 **각 결정에 대한 근거·대안·트레이드오프** 모음이다. design.md 가 "무엇" 이라면 이 문서는 "왜". 구현 중 결정 재검토 시 여기부터 읽는다.
>
> 일반 Kafka 개념 지식 백업은 `research.md` §8.

---

## 1. 이벤트 key = `reservation_id` — 순서 아닌 "동시 처리 직렬화"

**결정 출처**: `design.md` §3.5.

이 이벤트는 **상태를 담지 않는 trigger** (reservation_id + Site 만 존재). 소비자는 수신 시점에 DB 에서 현재 상태를 다시 읽어 분류한다. 따라서 같은 예약의 이벤트 A/B 가 어떤 순서로 와도 분류 결과는 동일 — **순서 보장이 키의 목적이 아니다**.

키의 실제 이유는 `CarTakeoverRequestHandler` 가 **check-then-write** 멱등:

```
read memos → FORCE_EXTEND_JIRA_MEMO_PREFIX 없음
create Jira issue
write memo with prefix
```

동일 예약에 대한 두 이벤트가 **서로 다른 consumer 인스턴스에서 동시 처리**되면:
- T1 이 memo 읽음(없음) → T2 가 memo 읽음(없음) → T1 Jira 생성 → T2 Jira 생성 → **중복 티켓**.

`reservation_id` 를 key 로 두면:
- 같은 예약의 이벤트들은 같은 partition 에 쌓이고,
- 같은 partition 은 consumer group 안에서 **단일 consumer 인스턴스** 가 소유하며,
- Spring Kafka 의 `@KafkaListener` 기본값은 파티션당 단일 스레드 소비,
- 따라서 같은 예약의 두 이벤트는 **순차 처리** 되고 두 번째는 T1 이 쓴 memo 를 보고 skip.

별도 분산 락·DB 유니크 제약 없이 handler 의 check-then-write 가 race-free 하게 동작하도록 **partition 단위 직렬화를 무료로** 얻는 것이 이 키 선택의 핵심.

**잔여 취약창** (v1 에서 수용):
- **Consumer group rebalance 중**: 파티션 소유권 이전 시점에 old/new consumer 가 같은 메시지를 잠깐 겹쳐 처리할 수 있음. Cooperative rebalancing 으로 창은 짧고, handler 의 memo 체크가 대부분을 흡수.
- **수동 DLT redrive 와 원본 소비가 동시**: 매우 드묾. 발생해도 memo 체크가 흡수.
- **`@KafkaListener(concurrency = N > 1)` 로 파티션당 병렬화**: 이 보장을 깸. 기본값 유지 (override 금지).

이 세 가지는 확률이 낮고, handler 의 memo 체크가 완전 idempotent 하지는 않더라도 99%+ 케이스를 잡아주므로 v1 에서 수용. 드문 중복 티켓 1 건은 운영팀이 수기로 닫을 수 있다.

---

## 2. `partitions = 3` — 작게 시작하고 유지하기

**고려한 대안**:
- `1`: 처리량 포뮬러상 충분(T ~0.01 msg/s, per-partition capacity ~50 MB/s). 하지만 worker replica N≥2 중 1 개만 bind → 나머지 idle + fail-over 지연.
- `6+`: 현재 사용량 대비 과잉. metadata 크기·rebalance 시간 증가 대비 이득 없음.
- `3`: replica 분산 + scale-out 여유 + 팀 선례(`INFRAREQ-3870`) 일치.

**늘리기 어려운 이유** (보수적 출발 이유): partition 수 증가는 가능하지만, **같은 key 가 다른 partition 으로 이동** 한다 (`hash(key) % N` 에서 N 변경). 이는 §1 의 동시처리 직렬화 계약을 깬다. 늘려야 한다면 기존 consumer drain + offset reset + 잠시의 직렬화 손실을 감수해야 함. 따라서 초기값은 **실제 필요보다 약간 여유 있게** 잡고 그 안에서 버티는 전략.

**10×/100× 시나리오**: 10× (100/day) 까지는 3 partition 으로 여유. 100× (1K/day) 도 처리량으론 여유지만 consumer lag 이 눈에 띄면 그때 `@KafkaListener(concurrency)` 상향 검토 (단, serialization 영향 주의). partition 수 변경은 최후 수단.

---

## 3. RF=3 + `min.insync.replicas=2` + `acks=all` — durability triangle

세 값은 **한 세트** 다. 하나만 건드리면 다른 둘의 의도가 깨진다.

| 파라미터 | 역할 |
|---|---|
| `replication.factor=3` | 데이터 복제본 3 개 (leader 1 + follower 2). 2 broker 손실까지 데이터 존재. |
| `min.insync.replicas=2` | leader + ≥1 follower 가 sync 상태여야 **쓰기 수락**. `acks=all` 과 결합 시 효력. |
| `acks=all` (producer) | ≥ `min.insync.replicas` follower 가 fsync 한 뒤에만 producer 에 ack 반환. |

**실패 시나리오 비교**:

| 상황 | RF=3/ISR=2/acks=all | RF=3/ISR=1/acks=1 (대안) |
|---|---|---|
| 1 broker 장애 | ISR=2 충족, 쓰기 계속, 유실 없음 | 쓰기 계속, 잠재적 last-ms 유실 |
| 2 broker 동시 장애 | ISR=2 미충족 → 쓰기 차단 (fail-fast) | 쓰기 계속, 단일 broker 에 의존 |
| leader crash 직후 follower 승급 | 이미 2 brokers fsync → 승격된 follower 에 데이터 있음 | leader 만 ack → follower 는 최신 아닐 수 있음 → **유실** |

**왜 ISR=1 이 아닌가**: `acks=all` + `ISR=1` 은 사실상 `acks=leader`. leader crash 시 follower 승격 전 ack 된 메시지가 유실 가능.

**왜 ISR=3 이 아닌가**: 어떤 broker 라도 ISR 이탈하면 쓰기 차단. 가용성 저하가 너무 크다. availability 와 durability 를 **동등 비중** 으로 본다.

---

## 4. `retention.ms = 3d` (원본) — 디버깅 창 vs 저장 비용

**무엇이 삭제되는가**: 개별 메시지가 아니라 **segment 파일 전체**. 한 segment 는 "마지막 메시지 timestamp + retention.ms < 현재 시각" 일 때 삭제 후보가 된다. active segment (현재 쓰기 대상) 는 절대 삭제되지 않음 — §5 참고.

**3d 의 근거**:
- 실시간 소비 lag: 최악 분 단위. replay 필요 없음.
- 운영 리뷰 패턴: 금요일 저녁 이슈 발생 → 월요일 오전 리뷰. 48h + 오전 여유 = 3d.
- 저장 비용: 150 B × 100 msg/day × 3 = 45 KB. 무시 가능. 더 길게 잡아도 비용은 문제가 아님.
- 더 길게 잡지 않는 이유: 재현 디버깅은 Datadog 로그·DB 스냅샷으로 한다. raw 이벤트 replay 가 일상적 도구는 아님.

**Consumer offset retention 고려**: `offsets.retention.minutes` 기본 7d. topic retention(3d) 보다 커서 consumer lag 상태에서도 offset 안전. MSK 기본값 유지 전제.

---

## 5. `segment.ms = 1d` — 초저용량 토픽의 함정

**Kafka log 구조**: partition 당 연속된 segment 파일. 하나는 active (쓰기), 나머지는 closed (읽기 전용).

**segment 가 닫히는 조건** (OR):
- 크기 도달 (`segment.bytes`, 기본 1GB)
- 시간 경과 (`segment.ms`, 기본 7d)
- index/timeindex 파일 full

**저용량 함정**: 150 B × 100 msg/day = 15 KB/day. `segment.bytes` 1GB 는 영영 안 채워진다 → `segment.ms` 만 기준 → 기본 7d 내내 active segment 상태 유지 → 그 동안 retention 으로 삭제 불가.

| 설정 | 실효 retention |
|---|---|
| segment.ms=7d, retention.ms=3d | 실효 **최대 10d** (segment 7d 열림 + retention 3d) |
| segment.ms=1d, retention.ms=3d | 실효 최대 **~4d** (segment 1d 열림 + retention 3d) |

1d 롤을 강제하면 의도한 3d 에 수렴. 부작용은 file handle 증가 — 우리 규모(3 partition × 3~4 segment) 에선 무시 가능.

---

## 6. `cleanup.policy = delete` (compact 아님)

- `delete`: 시간·크기 기준 segment 삭제. 대부분 event topic.
- `compact`: 키별 **최신 메시지만** 유지 (오래된 key-value 는 tombstone 후 삭제). state topic·KTable changelog 용.
- `delete,compact` 혼합: 기한도 삭제, 키별로도 압축.

우리 이벤트는 **1 회성 trigger**. 같은 reservation 의 과거 이벤트가 "최신" 에 의해 덮이면 안 된다 (각 이벤트가 각자 처리되어야 함). `delete` 만 사용.

---

## 7. Producer `enable.idempotence = true` + `acks = all`

**왜 필요한가**: producer 는 ack timeout 시 재시도한다. 재시도가 broker 에 도달했을 때 이미 첫 시도가 저장됐다면 → **중복 저장**. Consumer 입장에서 같은 이벤트 2 회 도착.

**idempotent producer 의 동작**:
- producer 는 broker 와 세션 시작 시 PID (producer ID) 발급받음.
- 각 메시지에 `(PID, partition, sequence_number)` 를 붙임.
- broker 는 partition 별로 마지막 (PID, seq) 를 기억. 중복 오면 "이미 받음" 으로 OK 반환하되 로그에 쓰지 않음.
- 결과: producer 재시도가 있어도 topic 에는 1 회만 저장.

**요구 사항** (Spring Kafka 기본값으로 자동 충족되는 경우 많음):
- `acks = all` (필수)
- `max.in.flight.requests.per.connection ≤ 5` (기본값 5)
- `retries > 0` (기본값 Integer.MAX_VALUE)

**exactly-once 는 아님**: 이건 producer→broker 구간 중복만 방지. consumer 측 at-least-once 는 별도 문제 — handler 의 check-then-write + §1 직렬화로 처리.

---

## 8. DLT `retention.ms = 14d` — 선례 7d 보다 늘린 이유

**redrive 시점 결정 요인**:
- 조사·원인 파악: 1~수 시간.
- 담당자 부재: 주말 3d + 연휴 5d (Seollal/Chuseok) = 최대 8d.
- 연차·백업 담당자 공백 포함하면 +며칠.

**7d 한계**: 연휴 + 조사지연 조합에서 가장자리 유실 가능.

**14d 비용**: 예상 DLT 발화 < 10/day × 150B × 14d = 21 KB. 저장 비용 무의미.

**왜 더 길게 (30d+) 안 잡는가**: 2 주 안에 redrive 가 안 된다면 **그 메시지는 이미 의미가 희석됨** — 해당 reservation 의 서비스 시점이 지났거나, 근본 버그 수정이 더 적절. 길게 잡는 건 YAGNI.

---

## 9. DLT `replication.factor = 3` — 선례 (RF=2) 이탈 근거

**선례 `INFRAREQ-2849`** (marketing DLT): RF=2. 다른 팀·다른 contexts.

**우리 DLT 의 특수성**:
- main topic 유실보다 **더 치명적**. Main 은 mission fail-safe + handler 멱등 덕에 일부 유실도 흡수됨. DLT 는 "미처리 incident 의 **마지막** 가시화 채널".
- DLT 메시지 유실 = incident 미감지 = 고객 영향 가능.

**RF=2 + ISR=2**: 한 broker 나가면 ISR=2 미충족 → 쓰기 차단. DLT 가 가장 필요할 때 (broker 불안정 + 다운스트림 실패 동시 발생) 정작 안 써지는 최악 시나리오.

**RF=3 + ISR=2**: 한 broker 나가도 2 brokers 로 ISR 충족 → 쓰기 계속.

**추가 비용**: DLT 크기 자체가 극소 → RF 1.5× 비용 무시 가능. 보수적 선택이 명확히 낫다.

---

## 10. Publisher 패턴 — `whenComplete` async callback

**대안들**:
- **Fire-and-forget** (`send()` 후 반환값 버림): 실패 surface 불가능. spec invariant #8 위반.
- **Blocking sync** (`send().get()`): mission 스레드 블로킹. 저지연 탐지 경로에서 부적절.
- **`suspend fun` + `CoroutineScope` launch**: 업계에서도 쓰이지만 코드베이스 전례 없음. Publisher 인터페이스가 suspend 가 되면 호출 측(탐지 지점) 도 suspend 컨텍스트로 전파 — 변경 범위 확대.
- **`whenComplete` async callback** (채택): `kafkaTemplate.send(...)` 는 enqueue 후 즉시 반환. 실패는 callback 에서 surface. 코드베이스 선례(`CarOccupationIntegrationEventKafkaPublisher`) 와 일치.

**왜 코드베이스 convention 을 따르는가**: 같은 패턴이 여러 곳에 있으면 읽기·디버깅 비용이 낮고, 장애 대응 경험이 축적된다. 새 패턴 도입은 그에 상응하는 이득이 있어야 정당화되는데, v1 에서는 없다.

---

## 11. Graceful shutdown — v1 엔 추가 작업 없음

**기본 동작으로 커버되는 범위**:
- `KafkaTemplate.send(...)` 는 producer buffer 에 enqueue 하고 즉시 리턴 (mission 스레드를 막지 않음).
- Spring Kafka 가 shutdown 시 `DefaultKafkaProducerFactory.destroy()` 에서 `producer.close(timeout)` 를 호출 — buffer 에 남은 레코드를 flush 하고 pending `whenComplete` callback 도 실행.
- `server.shutdown: graceful` + `spring.lifecycle.timeout-per-shutdown-phase: 30s` 만 확인하면 HTTP 드레인·Kafka producer close 가 여유 있게 진행됨.

**남는 유실 경로** (빈도 낮지만 0 은 아님):
- Producer buffer 에 들어갔으나 `producer.close(timeout)` 안에 broker ack 못 받은 레코드.
- 마지막 순간 `send()` 호출 자체가 producer closed 예외를 내는 케이스 — callback 이 돌지 않아 Slack surface 누락. outer `runCatching` 의 fallback log 만 남음.

**nice-to-have hardening** (빈도·영향이 문제로 드러나면 도입):
- `SmartLifecycle` drainer 를 둬서 Kafka listener stop ↔ Kafka producer close 사이에 "producer 아직 살아 있는지 체크" / "최근 send 완료 대기" 를 삽입.
- 또는 더 근본적으로 §12 outbox 승격.

v1 은 유실 빈도를 관측한 뒤 판단.

---

## 12. Direct Kafka vs transactional outbox — v1 은 direct

**v1 선택**: direct Kafka publish + Slack surface 로 실패 가시화. 간단하고 기존 인프라 그대로.

**direct 의 약점**:
- DB 트랜잭션과 Kafka publish 가 분리 → 둘 중 하나만 성공 가능.
- Kafka outage 동안엔 Slack 알림으로 surface 되지만 실제 복구는 수동.

**outbox 의 이점**:
- 예약 DB commit 과 outbox row 삽입을 한 트랜잭션에 묶음 → publish 책임이 DB 로 이전.
- CDC 파이프라인이 outbox → Kafka 를 비동기 내구성 있게 처리.

**outbox 의 비용**:
- outbox 테이블 + CDC 인프라 추가.
- migration·teardown 절차 복잡.

**v1 에서 direct 로 출발한 이유**: 예상 유실 빈도가 낮고 (발행 건수 자체가 적음), Slack 알림으로 수동 대응 가능. outbox 의 이득이 비용을 초과하지 않는 단계.

**v2 승격 경로**: `KafkaReservationAnomalyPublisher` 를 `TransactionalOutboxReservationAnomalyPublisher` 로 교체 → outbox 테이블 + CDC 인프라 추가. 인터페이스·proto·토픽·소비자·호출 측은 모두 불변. 마이그레이션 중에는 양 구현 공존 가능 (소비자 handler-level idempotency 가 중복을 흡수).

---

## 13. Consumer `@RetryableTopic(attempts = "1")` — retry 토픽 미생성

**결정**: 자동 재시도 없음. 예외가 listener 를 벗어나면 즉시 DLT.

**retry 토픽이 있는 패턴의 이점** (일반론):
- HOL blocking 회피 (실패 메시지가 partition 의 다음 메시지들을 막지 않음).
- `max.poll.interval.ms` 이내에서 retry 불가능한 긴 backoff 를 별도 스레드로 위임.
- Pod 재시작에도 retry 상태가 persist.

**이 중 어느 것도 우리 케이스에서 지배적 이슈가 아니다**:
- **Handler 는 이미 `FORCE_EXTEND_JIRA_MEMO_PREFIX` 로 멱등** — 사람 redrive 안전.
- **`probeWithRetry` 가 "아직 안정화 안 됨" 케이스를 listener 안에서 polling 으로 이미 다룸** — 프레임워크 재시도로 덮을 필요 없음.
- **Anomaly 이벤트 volume 이 낮아**(실제 이상 발생 시에만), partition head-of-line blocking 회피 이득이 작고 retry 토픽 운영 부담이 상대 비용 초과.
- **예외는 대부분 외부 의존(DB/Jira/Slack) 전파**. 자동 재시도로 운 좋게 회복해도 근본 원인 파악은 필요하므로, DLT + Slack 알림 + 사람 redrive 가 오히려 **투명**.

**v2 승격 신호**: DLT Slack 알림이 하루 여러 건, 그리고 대부분이 transient 네트워크/DB glitch 로 판명되면 `attempts > 1` + retry 토픽 도입을 검토. v1 에서는 불필요.

---

## 14. `probeWithRetry` — 값 기반 retry util (`retryUntil`) 도입 근거

`services/carsharing-reservation/subprojects/common/lib/src/main/kotlin/kr/socar/carsharing/util/Retry.kt` 에 사내 표준 retry util (`retryWhen` / `retryOn`) 이 존재한다. 다만 이 util 은 **예외 기반** — block 이 throw 하는 exception 의 클래스/조건에 따라 재시도. 반면 probe 는 **값 기반 폴링** — `classify()` 의 반환값(`RequiresCarTakeover`)에 따라, 그리고 중간에 상태가 바뀌었을 수 있는 **외부 gate**(`isIdleZeroApplied && now < confirmDeadline`) 에 따라 재시도 여부가 결정된다. 두 의미론은 다르므로 기존 util 을 그대로 쓰면 sentinel exception 같은 control-flow 남용이 되어 읽기 어렵다.

**결정**: `common/lib` 의 `Retry.kt` 에 **값 기반 sibling `retryUntil`** 을 추가한다 (`retryWhen` / `retryOn` 과 동일 스타일, backoff 파라미터 규약 공유). 기존 caller 에 영향 없는 strictly additive 변경. Probe 는 그 util 을 사용한다.

**대안**: util 미확장 + probe 파일 안에 private loop 으로 유지해도 동작은 같다. 위 안을 택한 이유는 사내 retry 파라미터 규약(`initialDelay`/`backoffFactor`/`maxDelay`) 과 일관성.

---

## 15. Handler — Jira 티켓 본문 확장 (legacy 단일 id 보완)

**배경**: 2026-04-16 CS 팀(앤디) 합의 — 대차 요청 티켓 본문에 다음 두 필드 필수:
- (a) 점유 확정 차량 번호
- (b) 같은 차량·구간에 현재 충돌 중인 예약 **목록(복수)**

legacy `ForceExtendConflictIssueRequest` 는 충돌 상대 예약을 단일 id(`overwriter.reservationId`) 로만 표현 → (b) 를 담을 수 없음. v1 handler 는 **요청 구조를 확장하거나 body text 를 렌더링해서** 복수 예약 정보를 포함해야 한다.

**"그냥 legacy 재사용" 이 왜 안 되는가**: 합의 사항을 만족하지 못함. CS 팀은 이번 작업을 "조기 대응" 의 계기로 보고 있고, 티켓 본문을 직접 참조해 상황 인지한다고 합의했다. 본문 형식을 합의 이전으로 돌리면 합의 파기.

**Slack fallback 은 그대로**: 실패 fallback 은 Jira 외에도 운영팀이 보는 통로 중 하나이지만, 1순위는 Jira. Slack 에 동등 수준 정보를 실을 필요 없음 — CS 참조 창구가 티켓이므로.

**입력 조립**: classifier 가 이미 계산한 `overlaps - benignOverlaps` 결과를 handler 에 그대로 전달. 재조회 중복 금지.

---

## 16. Canary 없음 — legacy 직접 교체

- Legacy Slack/Jira 코드는 **동일 팀 소유**. A/B 운영 중 혼선 비용이 크고, 통제 가능.
- 이상 사건은 실제로는 **드물게** 발생 → A/B 둘 다 돌려도 관측 가능한 샘플이 부족.
- 대신 dev 에서 충분히 검증 후 즉시 prod 반영, 문제 시 rollback PR 1 개.

더 복잡한 canary (같은 이벤트를 legacy/new 양쪽에 흘리고 결과 비교) 는 변경 대비 이득이 낮다.
