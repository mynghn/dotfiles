---
name: attention-sinks
description: Load when the first few tokens dominate attention scores, when a sliding window / prefix truncation breaks a long-context model or makes perplexity explode, or when designing KV-cache eviction that must preserve the prompt start.
last_refreshed: 2026-06-19
sources:
  - StreamingLLM / Efficient Streaming Language Models with Attention Sinks — Xiao et al., 2023 — https://arxiv.org/abs/2309.17453
---

Transformers dump a disproportionate share of attention onto the first few tokens of the sequence — the "attention sink" — largely regardless of those tokens' semantic relevance. The mechanism is structural: SoftMax forces attention weights to sum to one, so when a query has no strong match among visible tokens, the model parks the leftover probability mass on the earliest, always-visible positions. Those initial tokens become a stable dumping ground.

This explains a key failure mode. Naively evict or truncate the prompt prefix (e.g. a sliding window that drops the oldest tokens) and the sink is lost, the attention distribution destabilizes, and long-context perplexity blows up.

StreamingLLM (Xiao et al., 2023) shows that keeping the KV of just a few initial tokens (~4 suffice) alongside a recent-token window restores stable generation out to 4M+ tokens with no fine-tuning, running up to 22.2x faster than sliding-window-with-recomputation.

Takeaway for an agent managing its own context: never blindly drop the prefix. Preserve the opening tokens (system prompt / framing) when compacting or evicting — they anchor the model's attention.

Related: [[compaction-vs-eviction]], [[lost-in-the-middle]], [[three-axes-of-context-degradation]]
