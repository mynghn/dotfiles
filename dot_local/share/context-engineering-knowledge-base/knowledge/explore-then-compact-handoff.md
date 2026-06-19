---
name: explore-then-compact-handoff
description: Load when a step needs wide, token-heavy reading (research, broad file/web scan) but only a narrow conclusion matters downstream: how much an explorer/researcher sub-agent should return to the parent, and why its raw search hits and dead ends must stay out of the main window. Breadth-first reading is the trigger (vs. the general isolate primitive in context-isolation, and not tight sequential work). The spatial (sub-agent→parent) variant; for the temporal (session→fresh-session) one see explore-execute-boundary.
last_refreshed: 2026-06-19
sources:
  - How We Built Our Multi-Agent Research System — Anthropic — https://www.anthropic.com/engineering/multi-agent-research-system
---

Explore-then-compact-handoff spawns a sub-agent to do wide, token-heavy reading inside its **own** context window, then has it return only a compacted result — the answer, not the raw trail — to the parent. The parent's window never sees the dozens of pages, search hits, and dead ends the explorer waded through; it sees the distilled finding. This isolates noisy intake so the parent stays lean and on-task.

**Mechanism.** Anthropic notes subagents "facilitate compression by operating in parallel with their own context windows, exploring different aspects of the question simultaneously before condensing the most important tokens for the lead research agent." Each explorer burns its own budget; the parent pays only for the summary.

**Evidence.** A multi-agent system (Claude Opus 4 lead, Claude Sonnet 4 subagents) outperformed single-agent Opus 4 by **90.2%** on Anthropic's internal research eval. On BrowseComp, token usage alone explained **80%** of the performance variance. The cost: multi-agent runs use roughly **15x** the tokens of a chat interaction — so reserve this for tasks valuable enough to justify the spend.

**Takeaway.** When a step needs wide reading but only a narrow conclusion matters downstream, explore in a disposable window, compact, return the conclusion. Parallel breadth-first work is the trigger, not tight sequential dependencies. This is the **spatial** handoff (sub-agent → parent, within one session); for the **temporal** one — handing a whole session off to a fresh context at an explore→execute boundary — see [[explore-execute-boundary]].

Related: [[context-isolation]], [[compaction-vs-eviction]], [[structured-note-taking]], [[explore-execute-boundary]]
