---
name: structured-note-taking
description: Load for persisting plans/state/progress to durable storage outside the context window so it survives compaction, summarization, or context resets on long-horizon tasks; the write-side complement of JIT loading. Covers NOTES.md / to-do files, scratchpads vs. cross-session memories, agentic memory.
last_refreshed: 2026-06-19
sources:
  - Anthropic — Effective Context Engineering for AI Agents — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
  - Anthropic — How We Built Our Multi-Agent Research System — https://www.anthropic.com/engineering/multi-agent-research-system
  - LangChain — Context Engineering for Agents — https://www.langchain.com/blog/context-engineering-for-agents
---

**Structured note-taking** (agentic memory) is the *write* operation in context engineering: the agent regularly persists notes, plans, and state to durable storage *outside* the context window, then pulls them back in on demand. It is the write-side complement of just-in-time (JIT) loading — JIT reads lightweight references into context only when needed; note-taking writes them out so they survive context loss.

**Mechanism.** Anthropic frames it as an agent maintaining a `NOTES.md` file or a to-do list. LangChain splits it into *scratchpads* (session-scoped — a tool that writes to a file, or a field in runtime state) and *memories* (cross-session, as in ChatGPT/Cursor/Windsurf, with roots in Reflexion and Generative Agents). When context is summarized, compacted, or reset, the agent re-reads its own notes and resumes.

**Evidence.** Claude playing Pokémon keeps precise tallies across thousands of steps, maps of explored regions, and strategic combat notes; after context resets it reads them back and continues multi-hour sequences. Anthropic's multi-agent LeadResearcher saves its plan to memory because context past 200K tokens is truncated. Anthropic ships a file-based memory tool (public beta).

**Takeaway.** Externalize anything you must not forget — plans, decisions, progress — to a stable file, and treat the window as scratch. This makes long-horizon coherence durable against compaction and resets.

Related: [[jit-loading]], [[context-as-working-set]], [[compaction-vs-eviction]], [[explore-then-compact-handoff]]
