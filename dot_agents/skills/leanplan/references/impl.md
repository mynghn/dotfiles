# LeanPlan Implementation Stage

Edge: TASK to code.

## Inputs

- `plan.md`
- Selected task ID
- Cited SPEC, DESIGN, RATIONALE, and RESEARCH anchors loaded only as needed
- Current code

## Procedure

1. Load the selected task card.
2. Load cited anchors, not the whole archive by default.
3. Inspect current code before editing.
4. Re-reason against current reality; do not blindly follow old instructions.
5. Stop on challenge triggers.
6. Implement the task.
7. Verify completion criteria.
8. Distill durable WHYs into code, tests, types, annotations, inline comments, commit message, or PR body.

## Stop-The-Line Triggers

- Current code contradicts DESIGN.
- No verification path exists for a completion criterion.
- A dependency is missing or invalidated.
- Implementation requires changing SPEC behavior.
- An invariant is unprovable by the current test/monitor strategy.
- Task scope expands beyond the feature boundary.

When triggered, walk up to the highest affected layer:

- REQUIREMENT for business scope change.
- SPEC for contract change.
- DESIGN for realization change.
- TASK for sequencing/work navigation change.

## Distillation Targets

Prefer durable forms:

1. Types, signatures, structure
2. Tests and property tests
3. Enforced annotations
4. PR body or squash commit message for change rationale
5. Inline comments only for local code-shape rationale

Do not leave plan docs as the only holder of important WHYs.
