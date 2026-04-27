# LeanPlan Specify Stage

Edge: REQUIREMENT → SPEC.

## Inputs

- `<cwd>/docs/features/<KEY>/requirement.md` (required). If absent, stop and tell the user to run `/requirement <KEY>` (or `requirement <KEY>` for Codex) first.
- `<cwd>/docs/features/<KEY>/research.md` (optional, for context reuse).

## Outputs

- `<cwd>/docs/features/<KEY>/spec.md` — required.
- `<cwd>/docs/features/<KEY>/research.md` — append `## <topic>` blocks only when a finding is durable evidence worth archiving for future reference (codebase pattern discovery, SOTA article takeaway, industry convention, org history).

## Procedure

1. **Load REQUIREMENT** + the artifact contract (`artifact-contract.md`).
2. **Derive Outcome items**: for each biz outcome in REQUIREMENT, ask what externally-observable behavior signals it. Write as `O-<N>: <slug>` under `## Outcome`. One item per behavior; don't fold two into one.
3. **Lift Invariants**: collect continuous constraints — SLAs, non-blocking guarantees, idempotency, integrity rules, environmental bindings (existing backbone compatibility, compliance boundary, deployment envelope). Write as `INV-<N>: <slug>` under `## Invariants`. If a constraint has no realization alternative, it's an Invariant — not a DESIGN choice.
4. **Apply the SPEC test** on every line: can the implementation change without changing this externally-observable behavior? If yes, cut the line or push to DESIGN.
5. **Use generic-category tech only**: "message queue", "event stream", "HTTP API", "distributed cache". Specific names (Kafka, Redis, gRPC, Postgres, Spring) belong in DESIGN.
6. **Archive research findings** worth preserving as `## <topic>` blocks in `research.md`. Evidence only — interpretations belong in RATIONALE (written later by `design`).
7. **Write** `spec.md`.
8. **Self-check**:
   - Grep body for tech-stack nouns — zero hits expected.
   - Every O is episode-verifiable (you could write a one-shot test).
   - Every INV is continuous (no episode-triggered conditions hiding as Invariants).
   - Conditional sections (Invariants, Non-goals) omitted when empty.

## Guardrails

- **O/INV split — episodic vs. continuous.**
  - Episode-triggered ("when X, Y happens") → `O-<N>: <slug>` under **Outcome**. Verifiable by a one-shot test.
  - Continuous property ("p99 < 5s", "non-blocking", "idempotent", "within compliance boundary X") → `INV-<N>: <slug>` under **Invariants**. Verified downstream by SLO / monitor / CI gate.
- **What a SPEC is NOT** test: implementation can change without observable change → cut or push to DESIGN.
- **Generic-category tech only.** Specific stack names → DESIGN.
- **No false optionality.** If a property has no real alternative realization, it's an Invariant, not a DESIGN choice. Don't fake optionality.
- **Stable IDs.** `N` is stable across slug edits. Append new items with higher numbers; retire by inline `(retired)` note rather than deleting.
- **Research archive is evidence-only.** Interpretations belong in RATIONALE.

## Template

```markdown
# <KEY> — SPEC

## Outcome

### O-1: <slug>
<when X, externally observable Y happens>

## Invariants

### INV-1: <slug>
<continuous property that must always hold>

## Non-goals
- <only when tech scope is ambiguous>
```

Heading levels are flexible (H2 / H3 / H4) per the artifact contract — items can be at H2 (flat) or H3 (nested under section header) as long as the heading text matches `O-<N>: <slug>` / `INV-<N>: <slug>` exactly.

## Hand-off

Next edge: `/design <KEY>` (Claude) or `design <KEY>` (Codex).
