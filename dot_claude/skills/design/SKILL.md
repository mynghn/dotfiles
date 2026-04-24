---
name: design
description: LeanPlan — realize a SPEC into a DESIGN (chosen components, stack, decisions). Architecture diagram + per-decision blocks; archive rationale for non-trivial decisions.
argument-hint: "<feature-key>"
allowed-tools: Read, Write, Edit, Grep, Glob, AskUserQuestion, Agent, Bash(ls *), Bash(mkdir *), Bash(git *), WebFetch, WebSearch, mcp__atlassian__getJiraIssue, mcp__atlassian__searchJiraIssuesUsingJql
---

# design

LeanPlan skill. Edge: **SPEC → DESIGN**. Turns the tech contract into the shape of the finished system — components, chosen stack, schemas, boundaries — plus archived rationale for non-trivial decisions.

## Context

LeanPlan stages: REQUIREMENT → SPEC → DESIGN → TASK → code. DESIGN is the **realization**: the chosen tech stack and structure that fulfills the SPEC's generic-category contract. SPEC says "message queue"; DESIGN picks Kafka and explains why. Rationale is archived separately (not in the surface DESIGN) and loaded JIT only when a reader challenges a decision. This keeps the DESIGN review surface short enough for reliable human review. Primary reader is the downstream `plan` agent; engineering reviewers share the surface.

## Inputs

- `$ARGUMENTS` — `<feature-key>` (required). Path: `<cwd>/docs/features/<KEY>/`.
- `<cwd>/docs/features/<KEY>/spec.md` (required). If absent, stop and point the user at `/specify`.
- `<cwd>/docs/features/<KEY>/research.md` (optional, reused for context if it exists).

## Output

- `<cwd>/docs/features/<KEY>/design.md` — required. Architecture + per-decision blocks.
- `<cwd>/docs/features/<KEY>/design-rationale.md` — write entries for *non-trivial* decisions only. Create if needed.
- `<cwd>/docs/features/<KEY>/research.md` — append `## <topic>` blocks when SPEC→DESIGN exploration turned up findings worth archiving. Create if needed.

## Artifact shape

**DESIGN** (`design.md`):

```
# <KEY> — DESIGN

## Architecture
<brief caption: what this diagram shows>

```mermaid
<flowchart / sequence / component diagram showing chosen components, boundaries, data or control flow. External systems appear as labeled nodes/edges.>
```

## Decision-1: <kebab-slug>
<one-line WHAT — the choice made.>
<one-line WHY if trivial. If non-trivial: "See rationale at [design-rationale.md#Decision-1-<slug>]."
Schemas, interfaces, signatures fold inline here when the decision involves them.>

## Decision-2: <kebab-slug>
...
```

**RATIONALE** (`design-rationale.md`), per non-trivial decision:

```
# <KEY> — DESIGN RATIONALE

## Decision-1: <kebab-slug>
<free-form prose. Typical content (not required structure): forces at play, alternatives considered, why the chosen one, invalidation hints (what would make us revisit). No schema — capture reasoning, don't fill a form.>
```

**RESEARCH** append (`research.md`):

```
## <descriptive topic name>
<evidence only — codebase grep findings, SOTA article takeaways, industry pattern names, org history. Interpretation belongs in RATIONALE.>
```

- Anchor patterns: `## Decision-<N>: <slug>` (identical heading in both DESIGN and RATIONALE so anchors resolve). `N` is stable; slug is short (≤ 5 words), kebab-case, identity.

## Guardrails

- **Chosen realization only.** DESIGN describes the finished system. No work ordering, no INFRAREQ / DBREQ procedure, no PR stacking, no rollout sequencing — those live in TASK.
- **Schemas fold into Decisions.** No top-level `## Schemas` or `## Interfaces` section. The diagram + per-decision blocks carry structure.
- **Architecture is mandatory.** Even a trivial one-component feature gets a diagram — it forces clarity about boundaries.
- **Non-trivial decisions anchor to RATIONALE.** Trivial decisions stay inline with a one-line why. A decision with *no* real alternative isn't a decision — fold its content into the diagram or reference the SPEC Invariant it satisfies.
- **No duplicate Invariants.** If SPEC says "must be non-blocking", DESIGN doesn't re-state it. Reference the SPEC anchor if a Decision is derived from it (e.g. "satisfies SPEC#INV-3-non-blocking-handover").
- **RATIONALE is free-form.** No prescribed inner sections. Capture reasoning (forces, alternatives, invalidation triggers), but don't invent a template to fill.
- **RESEARCH is evidence-only.** Interpretations belong in RATIONALE.

## Procedure

1. **Load SPEC** + any existing `research.md` at `<cwd>/docs/features/<KEY>/`.
2. **Draft Architecture**: Mermaid diagram + brief caption. Show chosen components, boundaries, and data / control flow. External systems as labeled nodes/edges.
3. **Enumerate Decisions**: for each externally-observable behavior in SPEC and each realization choice that emerged, open a `## Decision-<N>: <slug>` block.
   - One-line WHAT.
   - WHY: one line if trivial and inlined; anchor to RATIONALE if non-trivial (real alternatives existed, tradeoffs accepted, invalidation triggers worth recording).
4. **Write RATIONALE entries** for non-trivial decisions in `design-rationale.md`. Same `## Decision-<N>: <slug>` heading; free-form body.
5. **Archive research findings** worth preserving as `## <topic>` blocks in `research.md`. Evidence only.
6. **Coverage check** — walk each SPEC `### O-<N>` and `### INV-<N>`. Each must be realized by ≥ 1 of: a Decision block, an Architecture element, **or** (for trivial realization not worth a Decision block) a directly-cited TASK Completion criterion that the downstream `plan` skill will add. Surface any uncovered items that *no* path realizes, and resolve before finishing; do not force-create a Decision for a trivial realization that the TASK layer handles directly.
7. **Self-check** against guardrails:
   - No work ordering / INFRAREQ / rollout text.
   - No top-level Schema section; schemas live inside Decisions.
   - Non-trivial decisions have resolvable rationale anchors.
   - SPEC Invariants are referenced, not re-stated.

## Completion

- `design.md` contains Architecture (Mermaid) + at least one `## Decision-<N>: <slug>` block.
- Non-trivial decisions have resolvable `design-rationale.md#Decision-<N>-<slug>` targets.
- Every SPEC O + INV is realized by a Decision, an Architecture element, or is deferred to a TASK Completion criterion (for trivial realizations).
- No TASK-level content (work ordering, INFRAREQ procedure, PR stacking notes) in DESIGN.
- `research.md` updated with new `## <topic>` blocks if archival findings emerged.
- Tell the user: next edge is `/plan <KEY>`.
