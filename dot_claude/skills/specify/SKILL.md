---
name: specify
description: LeanPlan — derive a SPEC (externally-observable contract) from an existing REQUIREMENT. Generic-category tech only; split episodic ACs from continuous Invariants.
argument-hint: "<feature-key>"
allowed-tools: Read, Write, Edit, Grep, Glob, AskUserQuestion, Bash(ls *), Bash(mkdir *), WebFetch, WebSearch
---

# specify

LeanPlan skill. Edge: **REQUIREMENT → SPEC**. Turns the biz WHAT into an externally-observable tech contract that downstream `design` realizes.

## Context

LeanPlan is a lean spec-driven-development framework with staged artifacts (REQUIREMENT → SPEC → DESIGN → TASK → code). SPEC is the **contract**: what the finished system must expose to consumers, using *generic-category* tech vocabulary (message queue, event stream, HTTP API) — never specific stacks (Kafka, Redis, gRPC), which belong to DESIGN. This split preserves abstraction altitude: swapping Kafka → SQS should be a DESIGN change, not a SPEC rewrite. Primary reader is the downstream `design` agent; engineering reviewers share the surface.

## Inputs

- `$ARGUMENTS` — `<feature-key>` (required). Path: `<cwd>/docs/features/<KEY>/`.
- `<cwd>/docs/features/<KEY>/requirement.md` (required). If absent, tell the user to run `/requirement <KEY>` first and stop.
- `<cwd>/docs/features/<KEY>/research.md` (optional, for context reuse if it already exists).

## Output

- `<cwd>/docs/features/<KEY>/spec.md` — required.
- `<cwd>/docs/features/<KEY>/research.md` — append `## <topic>` blocks only when a finding is worth archiving for future reference (codebase pattern, SOTA article, industry convention, org history). Create the file if it doesn't exist yet.

## Artifact shape

```
# <KEY> — SPEC

## Outcome

### AC-1: <kebab-slug>
<one episode-verifiable behavior: "when X, Y happens">

### AC-2: <kebab-slug>
...

## Invariants   (conditional — include only when continuous constraints exist)
- <continuous property that must hold regardless of realization>
- <SLA, non-blocking, idempotency, integrity, environmental binding (backbone compatibility, compliance boundary, deployment envelope)>
- ...

## Non-goals   (conditional — include only when tech-scope edges are ambiguous)
- <explicitly out-of-scope capability>
- ...
```

The research-archive append (when used):

```
# <KEY> — RESEARCH

## <descriptive topic name>
<evidence: codebase grep findings, SOTA article takeaways, industry pattern names, org history. Evidence only — no interpretation.>
```

- Anchor pattern for ACs: `## AC-<N>: <slug>`. `N` is a stable integer (don't renumber on edits — append new ACs with higher numbers; retire with an inline `(retired)` note rather than deleting). Slug is short (≤ 5 words), kebab-case, identity (not restatement of the AC body).
- Declarative present tense; reserve MUST / MUST NOT for true invariants.

## Guardrails

- **AC split — episodic vs. continuous.**
  - Episode-triggered ("when X, Y happens") → `## AC-<N>: <slug>` under **Outcome**. Verifiable by a one-shot test.
  - Continuous property ("p99 < 5s", "non-blocking", "idempotent", "within compliance boundary X") → **Invariants**. Verified downstream by SLO / monitor / CI gate.
- **"What a SPEC is NOT" test.** For every line: can the implementation change without changing this externally-observable behavior? If yes, cut the line or push it to DESIGN.
- **Generic-category tech only.** "Message queue", "event stream", "HTTP API", "distributed cache" stay. Specific names (Kafka, Redis, gRPC, Postgres, Spring) go to DESIGN.
- **No false optionality.** If a property has no real alternative realization, it isn't a DESIGN choice — push it up to an Invariant so DESIGN isn't asked to choose what was never open.
- **Conditional sections must earn their place.** Invariants only when continuous constraints exist; Non-goals only when edges are ambiguous. Skip otherwise.
- **Research archive is evidence-only.** Interpretations belong in RATIONALE (written later by `design`). If a finding can't stand without interpretation, it's not archival — leave it out.

## Procedure

1. **Load REQUIREMENT** from `<cwd>/docs/features/<KEY>/requirement.md`. If absent, stop and point the user at `/requirement`.
2. **Derive Outcome ACs**: for each biz outcome in REQUIREMENT, ask what externally-observable behavior signals it. Write as `## AC-<N>: <slug>`. One AC per behavior; don't fold two into one.
3. **Lift Invariants**: collect continuous constraints — SLAs, non-blocking guarantees, idempotency, integrity rules, environmental bindings (existing backbone compatibility, compliance boundary, deployment envelope). If a constraint has no realization alternative, it's an Invariant, not a DESIGN choice.
4. **Apply the NOT test** on every line: can I swap the implementation without changing this? If yes, cut or push to DESIGN.
5. **Name only generic categories** for any tech referenced. "Message queue" / "event stream" / "HTTP API". Replace any specific stack name with its category; if no category fits, the content probably belongs in DESIGN.
6. **Archive research** worth preserving as `## <topic>` blocks in `research.md`. Evidence only. Create the file if needed.
7. **Write** `<cwd>/docs/features/<KEY>/spec.md`.
8. **Self-check**:
   - Grep the body for tech-stack nouns (Kafka, Redis, Kotlin, Spring, gRPC, Postgres, Flink, etc.) — zero hits expected.
   - Every AC has a `## AC-<N>: <slug>` heading and is episode-verifiable (you could write a one-shot test).
   - Invariants (if present) are all continuous; no sneaky episode-triggered conditions hiding there.
   - Conditional sections are omitted when empty.

## Completion

- File at `<cwd>/docs/features/<KEY>/spec.md`.
- Every AC: anchored heading `## AC-<N>: <slug>`, episode-verifiable.
- Invariants section present iff continuous constraints exist.
- No specific tech-stack names in body.
- `research.md` updated with new `## <topic>` blocks when archival findings emerged.
- Tell the user: next edge is `/design <KEY>`.
