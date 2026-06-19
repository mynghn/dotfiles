---
name: token-efficient-returns
description: Use when a tool can return large or verbose results and you're deciding how to bound, paginate, truncate, filter, or summarize the return — or to add concise/detailed response modes or return references instead of full payloads — so each returned token earns its context cost.
last_refreshed: 2026-06-20
sources:
  - Anthropic, "Writing effective tools for agents — with agents", 2025 — https://www.anthropic.com/engineering/writing-tools-for-agents
  - Anthropic, "Building effective agents" (Appendix 2: Prompt engineering your tools), 2024 — https://www.anthropic.com/engineering/building-effective-agents
  - Model Context Protocol specification (2025-06-18), 2025 — https://modelcontextprotocol.io/specification/2025-06-18
---

**What it is.** Designing a tool's *return* so it spends as few context tokens as the task allows: bound the payload by default, paginate or range-select large result sets, truncate runaway output, filter to the fields that matter, and offer the agent a way to ask for more only when it needs it. The unit of concern is the response shape and size the agent receives back — not the call arguments, and not the cleanup of results already sitting in the window.

**Why / Evidence.** Anthropic (2025) frames this directly: "optimizing the quality of context is important. But so is optimizing the *quantity* of context returned back to agents in tool responses." Every returned token is consumed from the agent's finite attention budget and re-billed on every subsequent turn, so a fat return taxes the rest of the trajectory, not just the current step. Their concrete guidance is to implement "some combination of pagination, range selection, filtering, and/or truncation with sensible default parameter values for any tool responses that could use up lots of context," and Claude Code itself caps tool responses at 25,000 tokens by default. They expect effective context windows to grow over time "but the need for context-efficient tools to remain" — the discipline doesn't expire as windows enlarge. Anthropic (2024, Appendix 2) observes a related format-overhead point — writing code inside JSON requires extra escaping versus plain markdown; the source frames this as tool usability, but the same overhead is also wasted return tokens.

**How to apply.**
- *Bound by default.* Give every potentially-large return a default cap (row limit, byte/token ceiling, depth limit) rather than dumping the full result and hoping it fits. Make the cap a parameter the agent can raise deliberately.
- *Paginate and range-select.* For lists and large bodies, return one page plus a cursor/offset (the MCP spec, 2025, standardizes opaque-cursor pagination for list operations); for files or logs, accept an explicit line/byte range so the agent fetches the slice it needs.
- *Project at the source.* Return a narrow field set rather than the full record, and expose a field selector so the caller asks only for what it needs. The lever here is *that* the tool projects instead of dumping; *which* fields count as high-signal is [[high-signal-returns]].
- *Offer concise vs detailed modes.* Expose a `response_format` enum (`"concise"` / `"detailed"`). Anthropic's Slack example shows the concise mode dropping low-value technical identifiers cut a response from ~206 to ~72 tokens — about 65%, roughly one-third the original — with no loss of usable function.
- *Return references, not payloads.* When the agent doesn't need the bytes inline, return an identifier, path, or handle it can resolve on demand; this keeps bulk out of the window until (and unless) it's needed.
- *Truncate loudly.* When you cut a response, say so and steer the next step — e.g. pair truncation with a hint to make several small, targeted searches instead of one broad one. The design move is to *include* such a steer; its exact wording is prompt-engineering.

**Takeaway.** Treat the return as a budget line: cap it by default, page/slice/filter the rest, hand back references over payloads, and let the agent opt into verbosity — never make it the agent's job to skim a return you could have trimmed at the source.

**Boundary.** Choosing *which* fields and signal to keep in a return is its own concern — [[high-signal-returns]]. Managing results *already in the window* (truncation of accumulated history, compaction, eviction, just-in-time re-fetch) belongs to the context-engineering sibling KB, not here; this entry stops at the moment the tool emits its response. How to *word* a truncation/steering message in general is prompt-engineering.

Related: [[high-signal-returns]], [[structured-output-shaping]], [[input-schema-design]], [[tool-granularity-and-consolidation]], [[tool-error-design]]
