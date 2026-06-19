---
name: three-axes-of-context-degradation
description: Map of long-context failure modes by axis (position, length, noise); use to route a symptom — where a fact sits, how long the input is, or how much irrelevant content surrounds it — to the matching degradation phenomenon and fix.
last_refreshed: 2026-06-19
sources:
  - Chroma, 2025 — Context Rot — https://www.trychroma.com/research/context-rot
  - NoLiMa: Beyond Literal Matching — 2025 — https://arxiv.org/abs/2502.05167
  - Anthropic — Effective Context Engineering for AI Agents — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
---

An organizing frame that indexes long-context failure modes by which axis they exploit, so a symptom maps to a known phenomenon and fix:

- **Position** — recall depends on *where* a fact sits, not just whether it's present. Covers `lost-in-the-middle` (U-shaped bias: ends beat the middle; Liu et al. 2023) and `attention-sinks` (initial tokens absorb disproportionate attention).
- **Length** — accuracy decays as input grows, even on simple tasks. Covers `context-rot` and `effective-vs-advertised-context` (the usable window sits well below the advertised size).
- **Noise** — irrelevant content lowers accuracy. Covers `distractor-sensitivity` and `literal-vs-latent-matching` (recall collapses when retrieval needs semantic inference, not lexical overlap).

Evidence: Chroma's *Context Rot* (2025), across 18 models, finds all three — accuracy degrades with length, a single distractor already hurts and compounds with more, and items placed early are located more reliably. NoLiMa (2025) reports GPT-4o falling from a 99.3% baseline to 69.7% at 32K once lexical cues are removed.

Takeaway for an agent managing its own context: the window is not uniform free space, and more tokens is not more signal. Curate to "the smallest possible set of high-signal tokens" (Anthropic), keep critical facts at the edges, and strip distractors.

Related: [[lost-in-the-middle]], [[attention-sinks]], [[context-rot]], [[distractor-sensitivity]], [[literal-vs-latent-matching]], [[effective-vs-advertised-context]]
