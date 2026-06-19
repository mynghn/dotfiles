---
name: compaction-timing
description: Load when deciding WHEN to compact or clear context — what token/percent threshold, whether to wait, whether a bigger window (e.g. 1M) means compacting later. Trigger on task boundaries + observed degradation, with a ~70-80%-used capacity backstop; a larger window moves the backstop, not the quality-optimal point.
last_refreshed: 2026-06-19
sources:
  - Context Rot — Chroma, 2025 — https://www.trychroma.com/research/context-rot
  - RULER — 2024 — https://arxiv.org/abs/2404.06654
  - Effective Context Engineering for AI Agents — Anthropic — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
  - Prompt Caching — Anthropic — https://claude.com/blog/prompt-caching
---

**When to compact is not primarily a "% of window" decision.** Degradation is gradual and driven by *absolute* token count and noise, not by how full the window is (context-rot; effective context sits well below the advertised size), so a fixed "compact at X%" optimizes the wrong axis.

Compact at the **first** of three triggers to bite:
- **Task boundary** (best): a sub-task finishes and its detail is no longer load-bearing — the working set genuinely shrinks, so the summary is honest rather than lossy.
- **Observed degradation**: the model starts forgetting earlier instructions, mis-recalling, or conflating threads — on hard tasks this can happen well before the window is full.
- **Capacity backstop**: ~70-80% of the window *used* (≈20-30% headroom left). Compaction runs inside the window and you need room for the following turns, so treat this as a last-resort safety net (what auto-compaction does), not a target.

**Bigger windows move the backstop, not the quality-optimal point.** A 1M window buys runway — you can defer forced compaction — but effective context stays well below advertised and rot is roughly absolute-token-driven, so do not equate "1M window" with "keep ~700K of context." Keep the working set lean regardless of window size; the optimal compaction point barely scales with the window.

**Cost guard:** each compaction invalidates the prefix/KV cache from the edit point forward (prefix-cache-economics), so avoid eager %-timer compaction; prefer task boundaries, where the cached prefix would turn over anyway.

Related: [[compaction-vs-eviction]], [[context-rot]], [[effective-vs-advertised-context]], [[prefix-cache-economics]], [[context-as-working-set]], [[structured-note-taking]]
