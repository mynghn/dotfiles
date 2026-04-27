# LeanPlan Design Stage

Edge: SPEC → DESIGN.

## Inputs

- `<cwd>/docs/features/<KEY>/spec.md` (required). If absent, stop and point user at `specify`.
- Current code and repo conventions (inspect before choosing architecture).
- `<cwd>/docs/features/<KEY>/research.md` (optional, for context reuse).

## Outputs

- `<cwd>/docs/features/<KEY>/design.md` — required. Architecture + per-decision blocks.
- `<cwd>/docs/features/<KEY>/design-rationale.md` — write entries for **non-trivial** decisions only. Create if needed.
- `<cwd>/docs/features/<KEY>/research.md` — append `## <topic>` blocks when SPEC→DESIGN exploration turned up durable evidence. Create if needed.

## Procedure

1. **Load SPEC** + artifact contract + any existing `research.md`.
2. **Inspect current code** before choosing architecture. Reality is authoritative — don't pick components without seeing what already exists.
3. **Draft Architecture**: Mermaid diagram + brief caption showing chosen components, boundaries, and data / control flow. External systems appear as labeled nodes / edges.
4. **Enumerate Decisions**: for each realization choice that emerged, open a `Decision-<N>: <slug>` block.
   - One-line WHAT — the choice made.
   - WHY: one line if trivial; anchor to RATIONALE if non-trivial. Schemas, interfaces, signatures fold inline within the relevant Decision.
5. **Write RATIONALE entries** for non-trivial decisions in `design-rationale.md`. Same `Decision-<N>: <slug>` heading. **Free-form prose** — typically forces, alternatives considered, chosen path, invalidation triggers. **No prescribed inner-section schema**.
6. **Archive durable research** as `## <topic>` blocks in `research.md`. Evidence only.
7. **Coverage check** — walk each SPEC `O-<N>` and `INV-<N>`. Each must be realized by ≥ 1 of:
   - a Decision block,
   - an Architecture element,
   - **or** (for trivial realization not worth a Decision block) a directly-cited TASK Completion criterion that the downstream `plan` skill will add.
   Surface any uncovered items that *no* path realizes. Do not force-create a Decision for a trivial realization that the TASK layer handles directly.
8. **Stop** if a design choice changes the SPEC contract — update SPEC first per the artifact update loop.
9. **Self-check** before exit:
   - No work ordering / INFRAREQ / rollout text (those belong in TASK).
   - No top-level `## Schemas` or `## Interfaces` section — schemas live inside their Decisions.
   - Non-trivial decisions have resolvable rationale anchors in `design-rationale.md`.
   - SPEC Invariants are referenced (not re-stated).

## Guardrails

- **Chosen realization only.** DESIGN is the time-independent finished-system shape. No work ordering, PR stacking, INFRAREQ procedure, or migration sequence — those belong in TASK.
- **Architecture is mandatory.** Even a trivial one-component feature gets a diagram — it forces clarity about boundaries.
- **Trivial vs. non-trivial.** Trivial decisions get a one-line inline why. Non-trivial decisions (real alternatives existed, tradeoffs accepted, invalidation triggers worth recording) anchor to RATIONALE.
- **No fake decisions.** A choice with no real alternative isn't a decision — fold its content into the diagram or reference the SPEC Invariant it satisfies.
- **No duplicate Invariants.** If SPEC says "must be non-blocking", DESIGN doesn't re-state it. Reference the SPEC anchor (e.g. `satisfies SPEC#INV-3-non-blocking-handover`).
- **RATIONALE is free-form.** No prescribed inner sections. Capture reasoning, don't fill a form.
- **RESEARCH is evidence-only.** Interpretations belong in RATIONALE.

## Hand-off

Next edge: `/plan <KEY>` (Claude) or `plan <KEY>` (Codex).
