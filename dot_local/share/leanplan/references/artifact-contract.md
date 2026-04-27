# LeanPlan Artifact Contract

## Feature Layout

Feature artifacts live under `docs/features/<KEY>/`.

Surface artifacts:

- `requirement.md`
- `spec.md`
- `design.md`
- `plan.md`

Archive artifacts, created when useful:

- `design-rationale.md`
- `research.md`

## Stage Ownership

| Artifact | Owns |
|---|---|
| REQUIREMENT | Biz WHAT |
| SPEC | Tech WHAT, externally observable contract |
| DESIGN | Tech HOW, finished system shape |
| DESIGN RATIONALE | Tech WHY |
| RESEARCH | Evidence |
| TASK (`plan.md`) | Time-ordered work navigation |

## Anchors

Anchor headings live at any of H2 / H3 / H4 to fit document structure. The text after the heading marker must match exactly:

- `O-<N>: <slug>` — Outcome item (episode-verifiable)
- `INV-<N>: <slug>` — Invariant (continuous property)
- `Decision-<N>: <slug>` — DESIGN decision
- `Task: <id>` — TASK card

Use kebab-case slugs. IDs are stable; do not renumber existing anchors after edits.

Citation forms:

- `SPEC#O-1-detected-anomaly-published`
- `SPEC#INV-1-mission-fail-safe`
- `DESIGN#Decision-2-direct-kafka-publisher`
- `TASK#Task:A1`

## Required Shapes

### REQUIREMENT

- `## Problem`
- `## Outcome`
- `## Non-goals` only when biz scope is ambiguous
- `## Upstream` only when Jira, PRD, Slack, or similar sources exist

### SPEC

- `## Outcome` containing one or more `O-<N>: <slug>` items (episode-verifiable behaviors)
- `## Invariants` containing one or more `INV-<N>: <slug>` items, only when continuous properties exist
- `## Non-goals` only when tech scope is ambiguous

Episode-triggered behavior belongs in O. Continuous properties belong in INV.

### DESIGN

- `## Architecture` with a Mermaid diagram
- One `Decision-<N>: <slug>` block per material choice
- Non-trivial decisions link to a matching block in `design-rationale.md`

### DESIGN RATIONALE

Use matching `Decision-<N>: <slug>` anchors. Body is **free-form prose** — typically forces, alternatives considered, chosen path, invalidation triggers. **No prescribed inner-section schema**: capture reasoning, don't fill a form.

### RESEARCH

Use descriptive topic headings. Store evidence only. Interpretation belongs in rationale.

### TASK (`plan.md`)

- Optional `## Guidelines` for feature-wide work-stance rules
- `## Dependency DAG` (or `## DAG`) with Mermaid; track subgraphs and prefixed task IDs (e.g. `P1`, `A1`, `D1`, `I1`) when coordination matters
- One `Task: <id>` block per land-able work item

Each task card must include:

- **Goal** — WHAT + HOW (when non-obvious), with inline `SPEC#…` or `DESIGN#…` anchors colocated with the supported sentence
- **Repo** — where the work lives
- **Completion** — observable verification + method (test / monitor / SLO / one-shot observation)
- **Dependencies** — prior task IDs as enablers (not gates)
- **Guidelines** — only when task-local stance matters

## Traceability

- Every SPEC O and INV maps to at least one task completion criterion or task body citation.
- Every task cites at least one SPEC O, SPEC INV, DESIGN decision, or explicit guideline reason.
- TASK dependencies are enablers, not rigid gates. Implementation agents re-evaluate them at task entry.

### `**GAP**` acknowledgment

A SPEC O or INV item may be deliberately uncovered (no task verifies it directly) when the team has accepted the gap. Annotate it on a line containing `**GAP**` inside `plan.md` (typically in a forward-coverage table). The validator treats such items as acknowledged — not coverage errors. Use sparingly and document the acceptance rationale next to the marker.

## Drift Guards

- REQUIREMENT has no implementation choices.
- SPEC has no chosen stack or internal realization. Generic categories (message queue, event stream, HTTP API) only.
- DESIGN has no work ordering, no INFRAREQ / DBREQ procedure, no PR stacking — those belong in TASK.
- TASK has no line-by-line edit script. Implementation agents re-derive against current code at task entry.
- MUST and MUST NOT are reserved for true invariants.
- Mermaid is used for diagrams; no ASCII fallback.
- Frontmatter is discouraged on plan artifacts; the artifact type is implied by filename.
