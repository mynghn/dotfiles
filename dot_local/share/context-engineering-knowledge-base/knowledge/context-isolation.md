---
name: context-isolation
description: Load when one agent's context is overflowing with parallel sub-tasks, or when deciding whether to spawn sub-agents / split work into separate context windows and condense results before returning to the parent.
last_refreshed: 2026-06-19
sources:
  - How We Built Our Multi-Agent Research System — Anthropic — https://www.anthropic.com/engineering/multi-agent-research-system
  - Context Engineering for Agents (write/select/compress/isolate) — LangChain — https://www.langchain.com/blog/context-engineering-for-agents
---

**ISOLATE**: give each sub-task its own context window, and have it condense results to the few high-signal tokens before returning them to the parent. This is the *isolate* primitive in LangChain's write/select/compress/isolate partition.

**Mechanism.** A sub-agent explores a slice of the problem in a fresh window — the parent never sees the raw intermediate tokens (search dumps, dead ends, verbose tool output), only the distilled answer. Per Anthropic: "Subagents facilitate compression by operating in parallel with their own context windows, exploring different aspects of the question simultaneously before condensing the most important tokens for the lead research agent." So isolation buys *parallelism* and *compression* at once, and keeps the parent window lean against distractors and rot.

**Evidence.** Anthropic's multi-agent research system (Opus 4 lead + Sonnet 4 subagents) beat a single-agent Opus 4 baseline by **90.2%**; token usage alone explained **80%** of performance variance — isolation effectively scales usable tokens past one window's limit. The cost: multi-agent setups burn **~15x** the tokens of a plain chat, so reserve isolation for work that genuinely exceeds a single window.

**Takeaway.** When breadth exceeds one window, fan out into isolated sub-tasks and return only condensed findings — never the raw exploration.

Related: [[explore-then-compact-handoff]], [[context-as-working-set]], [[compaction-vs-eviction]], [[context-rot]]
