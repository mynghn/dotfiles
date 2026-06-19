---
name: lost-in-the-middle
description: Recall is strong for facts at the top or bottom of a long prompt but weak for facts buried in the middle; or deciding where in the window to place critical instructions and the most relevant retrieved documents.
last_refreshed: 2026-06-19
sources:
  - Liu et al., "Lost in the Middle: How Language Models Use Long Contexts," TACL 2023 — https://arxiv.org/abs/2307.03172
  - Xiao et al., "Efficient Streaming Language Models with Attention Sinks" (StreamingLLM), 2023 — https://arxiv.org/abs/2309.17453
---

**The effect.** Models do not use a long context uniformly. Recall follows a roughly **U-shaped curve**: information at the very start (primacy) or very end (recency) of the input is retrieved reliably, while information in the **middle is recalled far worse**. In the multi-document QA experiments the mid-context dip can approach or fall below the model's own closed-book (no-document) accuracy. The pattern shows up in both multi-document QA and key-value retrieval, and holds even for models marketed as long-context (Liu et al., TACL 2023).

**Why it matters.** The bias is positional, not semantic: the same fact is recalled well or poorly based purely on *where* it sits. A commonly proposed contributing factor is attention-sink behavior — models dump disproportionate attention on the first tokens (Xiao et al., 2023) — but Liu et al. document the U-shape empirically without settling its cause.

**Takeaway for managing your own context.** Treat position as a control you own. Put the highest-stakes instructions, the task statement, and must-not-lose facts at the **start or end** of the window, not mid-stack. When packing retrieved documents, rank the most relevant ones at the edges. If a large middle is unavoidable, compact it: summarize and re-anchor key facts at a boundary rather than trusting the model to dig them out.

Related: [[attention-sinks]], [[three-axes-of-context-degradation]]
