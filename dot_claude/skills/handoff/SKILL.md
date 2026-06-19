---
name: handoff
description: Generate a goal-scoped handoff brief (+ a fresh-session kickoff line) so work crosses a session boundary cleanly, in the context-engineering-knowledge-base spirit. Use at an explore→execute / plan→impl boundary, after a major pivot, or when a long session should depart for an explicit NEW goal in a fresh context. Distinct from /compact-focus, which leans the SAME session in place.
argument-hint: "<the new goal the fresh session will pursue>"
---

Produce a durable handoff brief for a FRESH session departing toward an explicit new goal — NOT a summary of this session. Ground it in the KB (load `~/.local/share/context-engineering-knowledge-base/knowledge/explore-execute-boundary.md` and its siblings if you need the full reasoning).

**Goal first.** The new goal is the organizing input. If `$ARGUMENTS` names it, use it; otherwise ask for it before writing — selection is meaningless without a destination. If the "new goal" is really "keep doing the same thing," stop and recommend `/compact-focus` instead (continuity, not departure).

**Gate.** Hand off only if a fresh frame beats staying: execution needs a cold load this session lacks, the session has rotted, or it is a clean explore→execute boundary. If everything the goal needs is already warm and near-continuous, say so and suggest staying / `/compact-focus` — don't manufacture a handoff.

**Select against the goal, not the session.** Carry ONLY what the new goal consumes — the test is "does the destination need this?", never "was this important here?". Drop the rest, however central it was. Carry volume scales with goal-proximity (near-continuous → carries the plan; sharp departure → almost nothing). A faithful session recap is wrong: it re-imports this session's noise into the clean frame.

Write the brief to a durable file (a handoff trapped in chat is lost across the boundary), as labeled blocks, one directive per line:

- **Goal**: the explicit destination, verbatim.
- **Carry**: locked decisions + load-bearing rationale, live constraints, the artifacts/paths the goal builds on.
- **Negatives**: rejected paths + why — the guardrail that stops the fresh session re-wandering. A summary drops these; a handoff must keep them.
- **First moves**: what to load/do first in the fresh session.
- **Refs**: paths, SHAs, entry slugs, URLs — reloadable, JIT, not inlined.
- **Drop**: what the goal does not need (named, so the omission is deliberate).

Then emit a ready-to-paste fresh-session kickoff: `@`-mention the brief (material) at the FRONT, the action/instruction at the END (recency); JIT the bulk — never `@`-dump heavy refs (lost-in-the-middle, prefix-cache-economics).

Write prose in the language the user uses in their own prompts; keep technical anchors — paths, identifiers, slugs, SHAs — verbatim. Output: the brief's file path, then the kickoff line in a code block, then one sentence telling the user to open a fresh session (you cannot do it for them). If you surfaced this proactively, add one line on why now (e.g. boundary reached, session length).
