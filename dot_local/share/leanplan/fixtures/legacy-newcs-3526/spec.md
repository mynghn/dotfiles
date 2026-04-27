# NEWCS-3526 — 예약 이상 탐지 v1 · 스펙

> 상위 맥락과 코드 분석은 `./research.md` 참고. 본 문서는 **v1 에 한정한 고수준 사양** 만 다룬다. 구현 상세는 후속 `design.md` 에서.

---

## Goal

수락된 예약이 라이프사이클 도중 외부 규칙·환경 변화로 무효해지는 상황을, **진행 중 임무(mission) 를 중단시키지 않으면서** 별도 이벤트 스트림으로 보고하고, 스트림 하단에서 일관되게 분류·처리하는 체계를 v1 으로 구축한다.

구체적으로 v1 범위:
1. **차량 점유(occupation) 중심**의, 하지만 구조적으로 다른 이상 카테고리(회원·결제·쿠션 drift 등)로 확장 가능한 일반 이벤트 스키마를 정의.
2. 두 mission-critical 지점에 **최소한의 탐지 hook** 을 심는다:
   - `IdleZeroService.kt:274-277` — `handleCarOccupationConfirmFailures` 호출 시점.
   - `ReservationCarOccupationEventHandlingService.kt:196-205` — `reconcileWith` 의 `ConflictingReservationPreExistingException` catch.
3. 이상 스트림 하단에 **소비자 레이어**를 두어 (a) 현재 상태 재판정(Classification) 과 (b) 분류별 처리(Handler) 를 담당한다. v1 은 점유 이상 → 대차 요청 한 경로에 집중.
4. 기존 임시 대응 수단(아래 Deprecation 대상)을 **동등 이상으로 흡수**하고, 이후 정리할 수 있는 상태를 만든다.

---

## Non-goals

- **쿠션/타임테이블 drift 의 근본 reconciliation 자동화** (`syncCarOccupation` 자동 호출 포함) — 별도 트랙.
- **회원 자격·결제·가격·쿠폰 계열 이상** 탐지 — v2+. 스키마는 확장 가능하게만 열어둔다.
- **배차 핸들 생성 단계 이후의 사후 탐지** — 이미 늦은 시점으로 간주.
- **최종 사용자(customer) 직접 알림** — 운영·내부 시스템 대응만.
- **예약 생성·수정 로직 자체의 재설계**.
- **새 재검증(predicate) 로직의 신규 작성** — production 에서 이미 쓰고 있는 로직을 재사용.

---

## Invariants

1. **Mission fail-safe 전환**: 두 탐지 지점은 이상을 감지해도 호출자에게 예외를 전파하지 않는다. 흡수(swallow) 후 예약 상태를 최선의 일관성으로 커밋하고, 흡수 사실을 anomaly event 로 외부에 드러내 소비자가 후처리(대차)를 이어받는다. 예약은 라이프사이클 안에서 조용히 실패하지 않는다.
2. **best-effort publish**: 이상 이벤트 발행 실패가 mission 을 실패시키지 않는다. (catch + log; 임무 결과에 영향 없음.)
3. **탐지 지연 상한**: 이상 이벤트는 **차량 확정 데드라인(`reservation.interval.start − 55min`) 이전 또는 해당 시점까지** 최소 1회 발행된다. 출고(export) 이후 발행 경로는 v1 범위에서 금지.
4. **스키마 전진 호환**: 이벤트 스키마는 field 번호·enum value 를 **추가만** 하는 방향으로 진화한다. 삭제가 필요해지면 그 시점에 `reserved` 로 봉인. v1 은 flat 구조(`reservation_id` + `Site` enum) 이지만 카테고리가 늘어날 때 `oneof detail` 로 확장 가능하도록 번호 여유를 남긴다.
5. **Handler 멱등성 + 동시성 직렬화**: 소비자 파이프라인 전체 dedup 은 요구하지 않는다. Side-effect handler 는 기존 idempotency 수단(`FORCE_EXTEND_JIRA_MEMO_PREFIX` check-then-write) 을 재사용하거나 동등 이상의 중복 방지를 갖춘다. 이 check-then-write 는 **동시 실행 시 race-prone** 하므로, 같은 예약의 이벤트는 **동시 처리되지 않도록 직렬화** 되어야 한다. 직렬화 수단은 Kafka 키(`reservation_id`) 기반 partition 배정 + consumer group 내 partition 단독 소유 + 파티션당 단일 스레드 소비 (`@KafkaListener` 기본). 별도 분산 락은 요구하지 않는다.
6. **Operational 출력 재현성 + 운영 합의 필드**: 신규 소비자 레이어가 생성하는 Jira 티켓·Slack 메시지 등 운영 산출물은 Deprecation 대상(기존 `FailureNotifier` / `createForceExtendConflictJiraIssueIfApplicable`) 이 만들던 산출물과 **내용·형식에서 동등 이상** 이어야 한다. 추가로, 2026-04-16 운영팀(앤디)과의 합의에 따라 **대차 요청 Jira 티켓 본문에 다음 두 항목이 반드시 포함** 된다 — CS 센터가 티켓을 직접 참조해 조기 대응하기 위함:
   - (a) **현재 문제 예약에 점유 확정된 차량 번호**.
   - (b) **해당 차량에 대해 문제 예약과 현재 충돌 중인 다른 예약(복수) 목록**. 단일 id 가 아닌 list 형태.
7. **Probe 재사용**: 소비자의 재판정 probe 는 기존 `ReservationDoRepository.findByCarIdsAndOccupationInterval`, `CarOccupationService.findOne`, 그리고 `ReservationCarOccupationEventHandlingService` 의 benign overlap helper 들을 재사용한다. 신규 검증 로직 작성 금지.
8. **Publish 실패 surface 의무**: 이벤트 발행 실패(Kafka 전송 실패 등)는 조용히 삼키지 않는다. 모든 실패는 최소한 **error log + 운영 Slack 알림** 으로 드러나 사람이 관측 가능해야 한다.

---

## Acceptance criteria

- [ ] 두 mission-critical 지점의 실패 분기에서 호출자는 예외를 받지 않으며(fail-safe 성공), 흡수된 사건마다 최소 1건의 anomaly event 가 발행된다.
- [ ] 이상 이벤트 발행이 실패해도 해당 mission 은 정상 결과를 낸다.
- [ ] 소비자 handler 의 side-effect(Jira 티켓, Slack 메시지 등) 는 동일 이벤트가 재배송·재시도로 중복 도착해도 중복 생성되지 않는다 (handler-level idempotency).
- [ ] Deprecation 대상(기존 `FailureNotifier` + 강제 연장 Jira/Slack 체인) 이 생성하던 모든 운영·관측 산출물이 신규 소비자 레이어를 통해 동등 이상으로 재생된다 — 등가성 체크리스트 통과.
- [ ] **대차 요청 Jira 티켓 본문**에 (a) 점유 확정 차량 번호, (b) 동일 차량·구간에 현재 충돌 중인 예약 목록(복수) 이 반드시 포함된다 — CS 운영팀 합의사항(2026-04-16).
- [ ] 소비자 레이어의 재판정 probe 는 production-in-use 로직을 호출한다 (신규 predicate 를 작성하지 않는다).
- [ ] 이벤트 스키마는 사내 proto 컨벤션과 AIP 를 따르고, field 번호·enum value 추가만으로 확장 가능하며, 기존 값/번호의 수정·재할당이 금지되어 있다.
- [ ] Publisher 는 Kafka 전송을 fire-and-forget 으로 수행하며, 전송 실패 시 error log + Slack 운영 알림이 모두 발생하고 mission 에는 영향이 없다.
- [ ] 탐지 이벤트는 확정 데드라인(`interval.start − 55min`) 이전 또는 해당 시점까지 발행되며, 출고 이후 발행 경로는 존재하지 않는다.

---

## Risks

- **Handler 중복 side-effect**: 동일 anomaly 가 socar-request 재시도 / Kafka 재배송으로 여러 번 소비되면 Jira 티켓·Slack 메시지가 중복 생성될 수 있음. 대응: handler 내부에 기존 `FORCE_EXTEND_JIRA_MEMO_PREFIX` 체크 같은 idempotency 수단 유지/확장.
- **기존 운영 산출물과의 품질 격차**: Jira/Slack 본문의 한국어 메시지·필드 구성을 완전히 재현하지 못하면 운영팀 혼란. 대응: 스테이징에서 legacy vs 신규 경로 산출물 수기 비교 · 등가성 체크리스트(Acceptance criteria 참조).
- **Kafka outage 중 유실**: v1 은 direct Kafka publish 라 브로커·네트워크 장애 동안 발행된 anomaly 는 사라진다. 대응: 실패 시 Slack 알림으로 surface → 운영 수동 대응. 유실 빈도가 의미 있어지면 transactional outbox + CDC 로 승격(`design.md` §5.5).
- **Probe 지연**: 소비자의 재판정 쿼리가 느리면 handler 호출이 지연. 대응: v1 probe 는 repository 조회 + 단순 helper 재사용 (외부 RPC 금지) — 지연 상한은 DB 응답 시간 수준.
- **이벤트 시점과 재판정 시점의 skew**: 소비자 수신 시점에 대상 상태가 이미 변했을 수 있음 — 설계 의도 자체 (idle-zero 배경 relax 로 자연 해소되는 케이스 포함). 대응: Classifier 는 현재 상태를 권위로 사용하고, 해소된 경우 Resolved 로 drop.
- **FeaturePhase 가드 스킵**: `allOccupationsSynced=false` 로 인한 조용한 스킵은 마이그레이션 아티팩트. v1 에선 이상 범위에서 **제외** (현재 프로덕션은 sync 완료 전제).
- **소비자 단일 장애점**: 단일 컨슈머 프로세스가 장애나면 handler 모두 정지. 대응: 소비자 replica N≥2, 실패 메시지는 DLT 로 격리(`design.md` §7.6) — 수동 redrive 가능.
- **Wire format 호환 파괴**: proto field 번호·enum value 를 수정·재할당하면 기존 바이너리 디코딩이 깨짐. 대응: 추가만 허용, 삭제 시 reserved 로 봉인 (invariant #4).
- **Deprecation 지연**: canary 가 없는데도 legacy 제거가 미뤄지면 중복 알림이 장기화. 대응: legacy 제거 PR 을 신규 경로 가동 직후 후속 티켓으로 즉시 발행.
