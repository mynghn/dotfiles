---
name: context-rot
description: Load when accuracy drops as the prompt gets longer even on simple tasks, or when "more context made it worse" / long-context reliability is in question.
last_refreshed: 2026-06-19
sources:
  - Context Rot: How Increasing Input Tokens Impacts LLM Performance — Chroma, 2025 — https://www.trychroma.com/research/context-rot
---

**Context rot** is the finding that model performance grows increasingly unreliable as input length grows — even on trivial tasks — rather than staying flat as the "uniform token processing" assumption predicts. It is the canonical name for the *length axis* of context degradation.

**Evidence.** Chroma (2025) evaluated **18 LLMs** (GPT-4.1, Claude 4 Opus/Sonnet, Gemini 2.5, Qwen3, and others) over **194,480 total LLM calls**. In a deliberately trivial "repeated words" task — replicate a sequence with one unique word inserted — input scaled from **25 to 10,000 words**, and accuracy declined across models as context grew, often non-uniformly. Degradation worsened when matching required semantic inference rather than lexical overlap, and when distractors were present. Chroma's conclusion: models do not use their context uniformly.

**Takeaway.** Longer input isn't free; tokens are not processed uniformly, so padding the window degrades the whole task, not just the buried needle. For an agent managing its own context, this is the core argument against "stuff everything in just in case": keep the working set lean and high-signal, prune aggressively, and treat added length as a reliability cost — not a safety margin.

Related: [[three-axes-of-context-degradation]], [[effective-vs-advertised-context]], [[distractor-sensitivity]], [[literal-vs-latent-matching]]
