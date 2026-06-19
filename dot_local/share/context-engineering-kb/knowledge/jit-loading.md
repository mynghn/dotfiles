---
name: jit-loading
description: Deciding whether to dump full files/docs into context upfront vs. keep references and fetch on demand; context bloated by preloaded data the agent may not need; choosing between eager retrieval and runtime loading.
last_refreshed: 2026-06-19
sources:
  - Effective Context Engineering for AI Agents — Anthropic — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
  - Equipping Agents for the Real World with Agent Skills — Anthropic — https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
---

**Just-in-time loading.** Instead of pre-processing all relevant data up front, an agent can "maintain lightweight identifiers (file paths, stored queries, web links, etc.) and use these references to dynamically load data into context at runtime using tools." Anthropic calls this the "just in time" approach, in service of the guiding goal: "find the smallest set of high-signal tokens that maximize the likelihood of your desired outcome." It is the runtime read-side of treating context as a curated working set — and the same idea behind progressive disclosure in Agent Skills, where a one-line description is matched first and full content loads only on activation.

**When to use.** Default to JIT when the corpus is large, browsable, or only partly relevant to any single step. Holding an index of identifiers and pulling the matching item on demand keeps the working set lean and avoids the recall decay of a stuffed window.

**The tradeoff.** "Runtime exploration is slower than retrieving pre-computed data," and without guidance an agent "can waste context by misusing tools, chasing dead-ends." Hence Anthropic's hybrid: retrieve some data up front for speed, leave the rest behind references for on-demand loading.

**Takeaway.** Carry pointers, not payloads; resolve a reference to full content only at the moment of need.

Related: [[context-as-working-set]], [[structured-note-taking]]
