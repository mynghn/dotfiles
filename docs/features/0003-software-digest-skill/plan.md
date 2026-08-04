# software-digest v1 — 실행 계획 (/goal 루프 플레이북)

설계 근거·결정 원장·기각 경로는 [design.md](design.md) — **결정 원장 16개가
스킬의 사양이다.** 이 문서는 루프가 매 턴 참조하는 실행 정본. 루프 원칙 소급
(loop-engineering, F1–F5): F1 상태는 아티팩트에 외재화, F2 무거운 실행은
서브에이전트 격리, F3 턴당 한 변수·진행 래칫, F4 검증은 외부에·done은 동결,
F5 안정 프리픽스·경계에서 압축.

## 목표 상태 (완료 = 전부가 대화의 명령 실행 출력으로 증명됨)

- 스킬 v1: `dot_agents/skills/software-digest/{SKILL.md, references/}` +
  `dot_claude/skills/symlink_software-digest`. 본문 ≤500줄, frontmatter
  `name`/`description`/`argument-hint` 유효.
- 평가 하네스: `evals/{scenarios/, rubric.md, run.sh}` — red-test 통과 직후
  동결 커밋, 이후 무변경.
- 수렴: 연속 2턴의 풀 매트릭스에서 run.sh 전 체크 PASS + L4 저지 전 항목 pass.
- 루프 성공 = **사용자(경도 L5) 검토 준비 완료**이지 품질 확정이 아님.
  평가 레이어 2(독자 시뮬레이터)는 그 후 대개정 시에만.

## 페이즈 A — 구축 (대략 턴 1–5)

1. 로드: skill-design KB(description-as-activation-trigger,
   instructions-body-craft, directory-packaging,
   progressive-disclosure-token-economics), prompt-engineering KB INDEX에서
   맞는 엔트리만. 읽고-증류(로드 금지, borrow-don't-load):
   `~/.claude/skills/illustrated-explainer/`(playbook 포함 — 자기완결 HTML
   다이어그램·페이지 기법), `~/.claude/skills/grill-me/`(형성된 포지션으로
   묻기 — 게이트 질문 스타일).
2. SKILL.md v1 + references/ 저작, symlink 생성(기존 `symlink_*` 선례 방식).
3. 픽스처 3종 핀 고정 — **확정됨**(`evals/README.md` 표가 정본):
   - **델타형** `s1` — charmbracelet/bubbletea PR #1691, 스쿼시 머지 `c60f0c53`.
     PR 본문 + 연결 이슈 #1690은 `evals/fixtures/s1-pr-1691.md`에 스냅샷(런타임
     네트워크·인증 불필요). 기각한 대안이 본문에 명시된 실제 결정 지점을 포함.
     클론은 **depth 2** — depth 1은 부모가 없어 `git show`가 전체 파일을 추가로
     표시하므로 변경 픽스처가 변경이 아니게 된다.
   - **전체형** `s2` — 이 레포 `1de81ed`, `git archive`로 히스토리 없는 트리.
   - **외부형** `s3` — encode/starlette 태그 `1.3.1`.
   - 사내 레포/PR로 교체하려면 `evals/run.sh`의 핀과 `evals/scenarios/`를 수정.
4. 시나리오별 페르소나(목적·베이스라인·예산 — 독자 시뮬 초기화 겸 게이트
   대본), 프로브 ~10문항+정답 키(정답 키는 픽스처 코드 접근을 가진 **별도
   서브에이전트**가 저작 — 메이커와 맹점 분리), `rubric.md`(L4 이진 항목),
   `run.sh`(L1/L2 체커) 작성. 러너 실행은 트랜스크립트가 파일로 남는 방식으로
   (게이트 선행 검사가 가능해야 함).
5. **red-test(검증기 증명)**: 불량 다이제스트(파일 단위 조직·앵커 없음·자기
   점검 없음)를 심어 run.sh FAIL + 저지 FAIL 원출력 확인. 통과 시 evals/
   동결 커밋(메시지 `freeze: evals`). **이후 evals/ 수정 금지.**

## 페이즈 B — 수렴 (이후 턴)

턴 형태: 실패 체크 1클러스터만 수정 → 해당 시나리오만 run.sh 부분 재실행 →
원출력 표시 → 커밋. 전 체크 green 도달 시 풀 매트릭스를 2턴 연속 실행해 종료
조건을 증명. 시나리오 러너(스킬 장착 프레시 인스턴스)와 L4 저지는 **항상
프레시 서브에이전트로 격리**(F2, F4 메이커≠체커).

## 체커의 사다리 배치

| 경도 | 체커 | 항목 |
|---|---|---|
| L1/L2 (자율) | run.sh | frontmatter 유효 / 본문 ≤500줄 / symlink 정합 / 본문이 참조하는 references 파일 실재 / 산출 HTML 실재·자기완결(외부 리소스 로드 grep 부재) / 인라인 SVG ≥1 / 자기 점검 섹션 존재 / **다이제스트의 `path:line` 앵커 전수 실재 검증**(접지 연극의 기계적 차단) / 러너 트랜스크립트에서 게이트 선행 확인 |
| L4 (보조) | 저지 서브에이전트 (동결 rubric.md) | 의도 단위 조직(파일 단위 아님) / 선별 표시 유의미성 / 인식론 라벨 정합 / 판정 언어 부재 / 다이어그램-코드 대응 |
| L5 (인간) | 사용자 | 최종 수용 + evals/ 무결성 diff 확인 |

## 종말 상태와 가드

- **성공** / **정체**(같은 체크 3턴 연속 실패 → 중단·원인 보고) /
  **차단**(픽스처 접근 불가 → 중단·보고) / **소진**(35턴).
- done의 진짜 동결본은 design.md 결정 원장(루프 이전에 사용자 비준) — evals/는
  그 조작화다. 루프가 rubric을 스스로 저작하는 잔여 위험은 red-test + 동결
  커밋 + L5의 evals/ diff 확인으로 완충.
- 매 턴 커밋 = 래칫(F3). 어느 턴이 죽어도 git log + 이 문서로 콜드 부트(F1).

## /goal 프롬프트 (정본)

```
docs/features/0003-software-digest-skill/plan.md를 실행 정본으로 삼아 software-digest 스킬 v1을 완성하라. 완료 조건 — 아래 전부가 이 대화의 명령 실행 출력으로 증명되어야 한다:
(1) evals/run.sh 출력에 전 시나리오 전 L1/L2 체크 PASS가 표시되고, L4 저지 서브에이전트(동결된 rubric.md 기준, 메이커와 분리된 컨텍스트)의 전 항목 pass 원출력이 표시되는 풀 매트릭스가 서로 다른 2턴에서 연속으로 확인됨.
(2) 그 이전에, 심은 불량 다이제스트에 run.sh와 저지가 FAIL을 낸 red-test 출력이 한 번 표시되었고, 직후 evals/가 동결 커밋됨(메시지 freeze: evals).
(3) 동결 커밋 이후 evals/ 하위 무변경 — git log --oneline -- evals/ 와 git diff --stat <동결커밋SHA>..HEAD -- evals/ 출력으로 증명.
(4) 매 턴 최소 1회 커밋 — git log 출력 표시.
진행 규칙: 턴당 실패 클러스터 하나만 수정하고 관련 체크를 재실행해 원출력을 보여라. 시나리오 러너와 L4 저지는 항상 프레시 서브에이전트로 실행하라.
중단 조건: 같은 체크가 3턴 연속 실패하면 "정체"로 중단하고 원인을 보고하라. 픽스처 접근이 불가하면 "차단"으로 중단하고 보고하라. 또는 35턴을 초과하면 "소진"으로 중단하라.
```
