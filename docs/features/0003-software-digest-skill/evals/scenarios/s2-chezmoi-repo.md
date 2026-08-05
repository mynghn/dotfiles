# s2 — whole system: chezmoi dotfiles repository

Follow `RUNNER-PROTOCOL.md`.

**Fixture (pinned):** `$SD_EVAL_CACHE/chezmoi` — the dotfiles repository at commit
`1de81edb10bdb0a088e409fd660cd43b5e95c152`, materialized as a plain tree (no git history). Treat it
as a checkout handed to you. Anchors must be paths within this tree.

**Work directory:** `evals/work/s2-chezmoi-repo/`

## Invocation

> 이 dotfiles 레포를 내가 이어받게 됐어. 전체적으로 어떻게 돌아가는 건지 파악하게 해줘.

## Persona (answer the gate as this person)

- **Purpose** — 인수인계받아 앞으로 이 레포를 직접 고치고 유지보수한다.
- **Baseline** — 셸 스크립트와 git은 능숙하다. chezmoi는 이름만 들어봤고 소스 상태/템플릿/apply
  개념은 모른다.
- **Budget** — 10분.
- Anything the persona does not specify: let the skill's own default stand.

## Variant persona B (optional — not part of the required matrix)

Run only when there is budget to spare. Same fixture, same invocation shape, different purpose — the
digests should differ in what they give depth to, which is the mechanism worth testing.

- **Purpose** — 이 레포를 참고해서 내 dotfiles를 같은 방식으로 옮길지 판단하려 한다. 유지보수할
  생각은 없다.
- **Baseline** — 위와 같다.
- **Budget** — 5분.
