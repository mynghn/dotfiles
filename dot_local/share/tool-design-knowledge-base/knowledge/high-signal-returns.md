---
name: high-signal-returns
description: Use when designing what a tool hands back to the agent — choosing which fields to return, surfacing semantic names over opaque IDs, returning act-on-able data instead of raw API dumps, or fixing agents that hallucinate IDs or stall on noisy tool output.
last_refreshed: 2026-06-20
sources:
  - Anthropic, "Writing effective tools for agents — with agents", 2025 — https://www.anthropic.com/engineering/writing-tools-for-agents
  - Anthropic, "Building effective agents" (Appendix 2: Prompt engineering your tools), 2024 — https://www.anthropic.com/engineering/building-effective-agents
---

**What it is.** The return is read by the model, so design it for the model. A tool should hand back high-signal information the agent can act on next — not the raw upstream API response. That means three moves: return semantic, human-meaningful identifiers over opaque ones; include exactly the context the next step consumes; and suppress everything else. Anthropic (2025): "prioritize contextual relevance over flexibility."

**Why / Evidence.** Agents reason over natural language far better than over cryptic tokens. Anthropic (2025) found that "merely resolving arbitrary alphanumeric UUIDs to more semantically meaningful and interpretable language (or even a 0-indexed ID scheme) significantly improves Claude's precision in retrieval tasks by reducing hallucinations." Raw API payloads leak fields the model never needs — `uuid`, `256px_image_url`, `mime_type` — when `name`, `image_url`, and `file_type` are "much more likely to directly inform agents' downstream actions." The deeper rationale (Anthropic 2024, Appendix 2): keep formats "close to what the model has seen naturally occurring in text," and invest in the agent-computer interface as much as a human one — the rule of thumb is to "think about how much effort goes into human-computer interfaces (HCI), and plan to invest just as much effort in creating good agent-computer interfaces (ACI)."

**How to apply.** Don't pass the upstream JSON through; project it down to the fields that drive the next action. Resolve opaque IDs server-side to names (or a small 0-indexed scheme) before returning. When a later call genuinely needs a technical handle (search by name, then act by ID), expose both rather than forcing the agent to carry an opaque blob — or gate verbosity behind a `response_format` enum (`concise` vs `detailed`); Anthropic's Slack example contrasts a 206-token detailed return carrying thread IDs against a 72-token concise one. Audit returns against a noise test: every field present should plausibly inform a downstream step; if it never does, drop it. Push wide reasoning over rich detail (e.g. a judgement) into the structured fields the model will read, not into prose it must re-parse.

**Takeaway.** Treat the return as a message to the model, not a database row: semantic identifiers, the next step's context, nothing else.

**Boundary.** Trimming and paginating a return for size is the adjacent concern [[token-efficient-returns]]; enforcing the return's machine shape is [[structured-output-shaping]]; compacting or evicting returns that already sit in the window is the context-engineering sibling's `compaction-vs-eviction`. This entry is about *which* information to put in the return in the first place.

Related: [[token-efficient-returns]], [[structured-output-shaping]], [[tool-error-design]], [[input-schema-design]], [[tool-description-writing]]
