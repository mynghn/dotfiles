# s1 — change delta: bubbletea PR #1691

Follow `RUNNER-PROTOCOL.md`.

**Fixture (pinned):** `$SD_EVAL_CACHE/bubbletea` — charmbracelet/bubbletea at merge commit
`c60f0c53042238305ec13b486326588f12aea0ec`. The change itself is that commit; `git -C <fixture> show
c60f0c53` and `git -C <fixture> show --stat c60f0c53` give you the diff.

**Written record (snapshot):** `evals/fixtures/s1-pr-1691.md` — the PR description and the linked
issue #1690. Anchors must be repository-relative paths within the fixture.

**Work directory:** `evals/work/s1-bubbletea-pr/`

## Invocation

> 이 PR 좀 파악해야 해: charmbracelet/bubbletea #1691. 리뷰 들어가기 전에 뭘 한 건지 정확히 알고 싶어.

## Persona (answer the gate as this person)

- **Purpose** — 이 변경을 리뷰하러 들어갈 참이다. 무엇을 왜 바꿨고 어디가 핵심인지 먼저 잡고 싶다.
- **Baseline** — Go 3년차. 뮤텍스·고루틴·`-race` 같은 동시성 도구는 편하게 쓴다. bubbletea는
  써본 적 없고 렌더러 구조도 처음 본다.
- **Budget** — 15분.
- Anything the persona does not specify: let the skill's own default stand.
