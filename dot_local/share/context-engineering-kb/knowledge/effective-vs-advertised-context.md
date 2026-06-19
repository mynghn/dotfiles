---
name: effective-vs-advertised-context
description: Load when a model passes needle-in-haystack but degrades on real long-context tasks (multi-hop, aggregation), or when deciding how much of an advertised window (32K/128K/1M) to actually fill.
last_refreshed: 2026-06-19
sources:
  - RULER: What's the Real Context Size of Your Long-Context Language Models? — Hsieh et al., 2024 — https://arxiv.org/abs/2404.06654
---

A model's *effective* context length — the length at which it still performs reliably — is far shorter than its *advertised* length. Vendors quote the size the model can technically ingest (32K, 128K, 1M tokens); accuracy on substantive tasks collapses long before that ceiling.

**Why the advertised number misleads.** The popular needle-in-haystack (NIAH) test is a superficial probe: it asks the model to retrieve a single planted fact, so models score near-perfect and the spec number looks earned. RULER stresses harder behaviors — multi-needle variation plus new multi-hop-tracing and aggregation tasks — across 13 task types and 17 models. Result: almost all models drop sharply as input grows, and **only half of the models that claim a 32K+ window still perform satisfactorily at 32K**. Passing vanilla NIAH says nothing about effective length.

**Takeaway for an agent managing its own context.** Treat the advertised window as a hard ceiling, not a working budget. Don't fill it just because it fits — recall degrades with input length well before the limit. Aggressively select and compact so the live working set stays inside the effective zone, and never trust a marketing token count as a usability guarantee.

Related: [[context-rot]], [[three-axes-of-context-degradation]], [[context-as-working-set]]
