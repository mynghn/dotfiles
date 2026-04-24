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

Anchor headings may be level 2 or 3 to fit the surrounding document structure, but the text must be exact:

- `AC-<N>: <slug>`
- `INV-<N>: <slug>`
- `Decision-<N>: <slug>`
- `Task: <id>`

Use kebab-case slugs. IDs are stable; do not renumber existing anchors after edits.

Citation forms:

- `SPEC#AC-1-detected-anomaly-published`
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

- `## Outcome` with anchored AC entries
- `## Invariants` with anchored INV entries when continuous properties exist
- `## Non-goals` only when tech scope is ambiguous

Episode-triggered behavior belongs in AC. Continuous properties belong in INV.

### DESIGN

- `## Architecture` with a Mermaid diagram
- Decision anchors for each material choice
- Non-trivial decisions link to matching `design-rationale.md` entries

### DESIGN RATIONALE

Use matching decision anchors. Each non-trivial block should contain:

- Context
- Choice
- Forces
- Alternatives Rejected
- Invalidation Triggers
- Evidence Links

### RESEARCH

Use descriptive topic headings. Store evidence only. Interpretation belongs in rationale.

### TASK (`plan.md`)

- Optional `## Guidelines`
- `## Dependency DAG` with Mermaid
- Task cards as `## Task: <id>`

Each task card must include:

- Goal
- Repo
- Completion criteria
- Dependencies
- Guidelines only when task-local stance matters

## Traceability

- Every SPEC AC and INV maps to at least one task completion criterion or task body citation.
- Every task cites at least one SPEC AC, SPEC INV, DESIGN decision, or explicit guideline reason.
- TASK dependencies are enablers, not rigid gates. Implementation agents re-evaluate at task entry.

## Drift Guards

- REQUIREMENT has no implementation choices.
- SPEC has no chosen stack or internal realization.
- DESIGN has no work ordering.
- TASK has no line-by-line edit script.
- MUST and MUST NOT are reserved for true invariants.
- Mermaid is used for diagrams; no ASCII fallback.
