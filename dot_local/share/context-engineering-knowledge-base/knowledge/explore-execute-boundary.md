---
name: explore-execute-boundary
description: Load when deciding whether to keep working in the current session or hand off to a fresh one — at an explore→execute / plan→implement transition, after a major pivot, or when a long session should depart for an explicit new goal. The temporal/session sibling of explore-then-compact-handoff (the sub-agent/spatial one).
last_refreshed: 2026-06-19
sources:
  - Effective Context Engineering for AI Agents — Anthropic — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
  - How We Built Our Multi-Agent Research System — Anthropic — https://www.anthropic.com/engineering/multi-agent-research-system
---

The boundary between an exploratory/planning phase and an execution phase is the highest-leverage moment to compact — and often the right move is a hard hand-off to a fresh context, not in-place compaction.

**Why the boundary is special.** An exploratory/planning session maxes all three degradation axes at once: length (everything read), noise (dead ends, superseded branches, rejected hypotheses — active distractors), and buried conclusions (the live decisions scattered mid-trajectory). The successor phase — execution — is precision-sensitive and must not re-explore. Worst context meets most-sensitive task.

**Keep the phase continuous; cut at the boundary.** Within one planning/exploration episode, stay in a warm session — cross-stage reasoning back-propagates cheaply while context is live, and the prefix cache is caching signal. Make the hard cut at the phase boundary, where the artifact stabilizes and the work-nature flips.

**Handoff is goal-first, not a session summary.** You depart toward an explicit new goal, so select what the goal needs, not what the session did. The test flips from compaction's "what would be lost?" to "what does the destination need?" Most of the session — however central — fails that test and is dropped. Minimalism is correctness, not laziness: a faithful summary re-imports the old session's noise into the fresh frame, defeating the reason you went fresh.

**Volume scales with goal-proximity.** A near-continuous handoff (plan→impl of the same feature) carries a lot — the plan is exactly what the goal needs. A sharp departure carries almost nothing. The constant is goal-driven selection, never volume.

**The gate.** Hand off when a fresh frame's clean slate exceeds the cost of re-acquiring what is already warm: execution needs a large cold load this session lacks, or the session has rotted. If everything execution needs is warm and the goal is near-continuous, a fresh frame only re-acquires what is here — compact in place or continue instead. Externalize the goal-scoped brief to a durable file so it survives the boundary; order the kickoff material-first / instruction-last and JIT the bulk.

Related: [[explore-then-compact-handoff]], [[compaction-vs-eviction]], [[structured-note-taking]], [[context-isolation]]
