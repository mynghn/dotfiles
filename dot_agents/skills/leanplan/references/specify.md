# LeanPlan Specify Stage

Edge: REQUIREMENT to SPEC.

## Inputs

- `docs/features/<KEY>/requirement.md`
- Optional existing `research.md`

## Outputs

- `docs/features/<KEY>/spec.md`
- Optional `research.md` evidence entries

## Procedure

1. Load REQUIREMENT and artifact contract.
2. Derive externally observable behaviors as AC anchors.
3. Lift continuous properties into INV anchors.
4. Apply the SPEC test: if implementation can change without changing observable behavior, cut it or move it to DESIGN.
5. Use generic-category tech only: event stream, message queue, HTTP API, distributed cache.
6. Archive durable evidence in RESEARCH only when it will help future challenge or design.

## Guardrails

- Specific stack names belong in DESIGN, not SPEC.
- ACs are episode-verifiable.
- INVs are continuous and need ongoing proof such as CI, monitor, SLO, or system mechanism.
- If there was no real alternative, do not fake a design choice; make it an invariant.

## Template

```markdown
# <KEY> - SPEC

## Outcome

### AC-1: <slug>
<when X, externally observable Y happens>

## Invariants

### INV-1: <slug>
<continuous property that must always hold>

## Non-goals
- <only when tech scope is ambiguous>
```
