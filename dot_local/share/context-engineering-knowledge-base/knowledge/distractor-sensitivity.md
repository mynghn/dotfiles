---
name: distractor-sensitivity
description: Load when retrieval accuracy drops even though the answer is present in the window; when topically-related-but-wrong content sits near the target; when padding prompts with "might-be-useful" RAG chunks or long context seems to hurt rather than help — the noise axis of context degradation.
last_refreshed: 2026-06-19
sources:
  - Context Rot — Chroma, 2025 — https://www.trychroma.com/research/context-rot
---

Distractor-sensitivity is one half of the noise axis of context degradation: near-relevant tokens measurably lower accuracy even when the correct answer is fully present in the window. Chroma's *Context Rot* (2025) separates **distractors** (topically related to the target but not actually answering the question) from purely irrelevant filler. It finds that even a *single* distractor reduces performance versus a clean needle-only baseline — and the hit grows as input length increases. Adding all four distractors compounds the decline further.

Impact is non-uniform: some distractors hurt far more than others, and the worst offenders appear most frequently in hallucinated answers across models. Behavior also differs by model — Claude (Sonnet 4, Opus 4) showed the lowest hallucination rates and tended to abstain when uncertain, while GPT models hallucinated most, producing confident wrong answers when distractors were present.

Mechanism: near-miss content competes for attention with the true target, and longer contexts amplify the confusion. Practical takeaway for an agent managing its own context: more retrieved context is not safer. Curate aggressively — prefer a small, high-signal set over padding, since each near-relevant passage you add can pull accuracy down, not up.

Related: [[literal-vs-latent-matching]], [[three-axes-of-context-degradation]], [[context-rot]]
