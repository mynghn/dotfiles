---
name: compaction-vs-eviction
description: Deciding how to free context budget: compaction (summarize-and-reinitialize) vs. eviction (drop old tokens); hitting window limits, lossy history truncation, what the agent forgot after compacting.
last_refreshed: 2026-06-19
sources:
  - LLMLingua: Compressing Prompts for Accelerated Inference of Large Language Models — 2023 — https://arxiv.org/abs/2310.05736
  - Effective Context Engineering for AI Agents — Anthropic — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
---

When the context window fills, you have two ways to reclaim budget, and they lose different things.

Eviction drops tokens: truncate the oldest turns, slide the window, or discard whole messages. It is cheap and keeps whatever survives verbatim, but the dropped content is simply gone, and the model gets no signal it ever existed. Anthropic's *Effective Context Engineering* describes a safe variant, clearing raw tool results once they have been processed.

Compaction summarizes-and-reinitializes: an LLM pass distills the running history into a dense summary, then the agent continues from that reset state. It preserves semantic continuity across far more history than fits raw. Anthropic calls compaction the first lever for long-horizon coherence, but warns that overly aggressive compaction can drop subtle context whose importance surfaces only later. Prompt compression applies the same idea in-place: LLMLingua reports up to 20x compression with little performance loss.

Practical rule for an agent managing its own context: evict only what is provably stale or reconstructible (re-readable from disk or tools); compact when continuity matters but raw history will not fit. Compaction trades fidelity for reach, so pair it with external notes that let dropped detail be recovered rather than merely summarized.

Related: [[structured-note-taking]], [[context-as-working-set]], [[explore-then-compact-handoff]], [[jit-loading]]
