# s3 — unfamiliar project: starlette 1.3.1

Follow `RUNNER-PROTOCOL.md`.

**Fixture (pinned):** `$SD_EVAL_CACHE/starlette` — encode/starlette at tag `1.3.1`. Anchors must be
repository-relative paths within the fixture.

**Work directory:** `evals/work/s3-starlette/`

## Invocation

> starlette 도입 검토 중이야. 요청이 들어와서 응답이 나갈 때까지 안에서 무슨 일이 일어나는지
> 알고 싶어.

## Persona (answer the gate as this person)

- **Purpose** — 팀 서비스에 도입할지 판단한다. 판단하려면 요청 처리 경로가 어떻게 생겼고 어디에
  손댈 수 있는지를 알아야 한다.
- **Baseline** — Python은 강하다. Flask와 Django로 서비스를 만들어 봤다. ASGI가 WSGI와 다르다는
  것 정도는 알지만 그 내부는 모른다.
- **Budget** — 20분.
- Anything the persona does not specify: let the skill's own default stand.
