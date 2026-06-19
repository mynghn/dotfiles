---
name: context-as-working-set
description: Load when deciding what an agent keeps, drops, stores, or splits in its context window — treating context as a finite "attention budget" to curate, not a free buffer to fill.
last_refreshed: 2026-06-19
sources:
  - Anthropic — Effective Context Engineering for AI Agents — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
  - LangChain — Context Engineering for Agents — https://www.langchain.com/blog/context-engineering-for-agents
---

The parent frame for every context-management decision: the context window is **finite working memory to be actively curated**, not a free buffer to fill. Anthropic frames it as an "attention budget" — "Like humans, who have limited working memory capacity, LLMs have an 'attention budget' that they draw on when parsing large volumes of context" — and every new token depletes that budget. The governing goal is "finding the smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome." The budget is real because of context rot: as the token count grows, a model's ability to accurately recall information from context decreases (a gradient that varies by model, not a hard cliff), so low-value tokens spent now tax reasoning later.

LangChain gives the systems analogy — the LLM is the CPU, the context window is RAM — and partitions management into four operations: **write** (save context outside the window), **select** (pull in only what the task needs), **compress** (retain only required tokens), and **isolate** (split work across separate windows/agents). Anthropic's tactics map onto these: just-in-time retrieval, structured note-taking, compaction, and sub-agent architectures.

Takeaway for an agent managing its own context: treat tokens as a finite resource. Default to a lean, high-signal working set, and reach for write / select / compress / isolate before letting the window fill.

Related: [[jit-loading]], [[structured-note-taking]], [[compaction-vs-eviction]], [[context-isolation]], [[context-rot]]
