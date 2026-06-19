---
name: literal-vs-latent-matching
description: Load when retrieval finds a fact only if the query reuses the source's exact wording, but fails on paraphrases or semantic implications with no shared keywords; or when long-context recall collapses specifically for inference-based (latent) lookups rather than literal keyword matches.
last_refreshed: 2026-06-19
sources:
  - NoLiMa: Long-Context Evaluation Beyond Literal Matching, 2025 — https://arxiv.org/abs/2502.05167
---

Long-context recall degrades far worse when locating the relevant fact requires **semantic inference** rather than **lexical overlap**. When the query and the buried "needle" share keywords, attention can lock onto the surface match; remove that literal cue and force the model to infer a latent association, and accuracy drops sharply as context grows. The type of match alone drives the collapse — the haystack needs no irrelevant clutter to trigger it.

NoLiMa (2025) built a needle-in-a-haystack benchmark with minimal lexical overlap between question and needle. GPT-4o scored **99.3%** at short context (<1K tokens) but fell to **69.7% at 32K tokens**; at 32K, **11 of the tested models dropped below 50%** of their own short-length baselines. Conventional needle-in-a-haystack tests mask this effect because they leak keyword cues.

Practical takeaway for an agent managing its own context: don't assume a fact is "available" just because it sits in the window. If retrieval depends on paraphrase or implication, pull that fact to a literal position near the query — restate it in the prompt or store it as an explicit note — instead of trusting the model to bridge the semantic gap across tens of thousands of tokens.

Related: [[distractor-sensitivity]], [[context-rot]], [[three-axes-of-context-degradation]]
