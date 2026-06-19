---
name: compaction-vs-eviction
description: Freeing context budget — compaction (summarize-and-reinitialize) vs. eviction (drop tokens) — and WHEN to compact. Window limits, lossy truncation, what the agent forgot; plus timing: task boundaries / observed degradation / ~70-80%-used backstop, and why a bigger window (1M) moves the backstop, not the quality-optimal point.
last_refreshed: 2026-06-19
sources:
  - LLMLingua: Compressing Prompts for Accelerated Inference of Large Language Models — 2023 — https://arxiv.org/abs/2310.05736
  - Effective Context Engineering for AI Agents — Anthropic — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
  - Context Rot — Chroma, 2025 — https://www.trychroma.com/research/context-rot
  - RULER — 2024 — https://arxiv.org/abs/2404.06654
  - Prompt Caching — Anthropic — https://claude.com/blog/prompt-caching
---

When the context window fills, you have two ways to reclaim budget, and they lose different things.

Eviction drops tokens: truncate the oldest turns, slide the window, or discard whole messages. It is cheap and keeps whatever survives verbatim, but the dropped content is simply gone, and the model gets no signal it ever existed. Anthropic's *Effective Context Engineering* describes a safe variant, clearing raw tool results once they have been processed.

Compaction summarizes-and-reinitializes: an LLM pass distills the running history into a dense summary, then the agent continues from that reset state. It preserves semantic continuity across far more history than fits raw. Anthropic calls compaction the first lever for long-horizon coherence, but warns that overly aggressive compaction can drop subtle context whose importance surfaces only later. Prompt compression applies the same idea in-place: LLMLingua reports up to 20x compression with little performance loss.

Which to use: evict only what is provably stale or reconstructible (re-readable from disk or tools); compact when continuity matters but raw history will not fit. Compaction trades fidelity for reach, so pair it with external notes that let dropped detail be recovered rather than merely summarized.

**When to compact** is not primarily a *% of window* decision — degradation is gradual and driven by absolute token count and noise (context rot), and effective context sits well below the advertised size. Compact at the first of three triggers: a **task boundary** (best — the working set genuinely shrinks, so the summary is honest), **observed degradation** (forgotten instructions, mis-recall — often well before the window is full), or a **~70-80%-used capacity backstop** (leave 20-30% headroom for the compaction pass and the next turns; what auto-compaction does — a last resort, not a target). A bigger window (e.g. 1M) moves the *backstop*, not the quality-optimal point: effective context stays well below advertised and rot is roughly absolute-token-driven, so do not equate a 1M window with keeping ~700K — keep the working set lean regardless. Cost guard: each compaction invalidates the prefix/KV cache from the edit point, so favor task boundaries over a tight %-timer.

Related: [[structured-note-taking]], [[context-as-working-set]], [[explore-then-compact-handoff]], [[jit-loading]], [[context-rot]], [[effective-vs-advertised-context]], [[prefix-cache-economics]]
