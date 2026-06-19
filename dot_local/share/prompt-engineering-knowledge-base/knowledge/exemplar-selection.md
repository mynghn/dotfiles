---
name: exemplar-selection
description: Choosing WHICH few-shot examples to include and in what ORDER — picking representative, diverse, correct, consistently-formatted exemplars, and countering majority-label/recency/order bias from a bad selection.
last_refreshed: 2026-06-20
sources:
  - Anthropic, Prompt engineering — Use examples effectively (multishot prompting), 2026 — https://platform.claude.com/docs/en/docs/build-with-claude/prompt-engineering/multishot-prompting
  - OpenAI, Prompt engineering guide — Few-shot learning, 2026 — https://developers.openai.com/api/docs/guides/prompt-engineering
  - Lu et al., "Fantastically Ordered Prompts and Where to Find Them: Overcoming Few-Shot Prompt Order Sensitivity," ACL 2022 — https://arxiv.org/abs/2104.08786
  - Zhao et al., "Calibrate Before Use: Improving Few-Shot Performance of Language Models," ICML 2021 — https://arxiv.org/abs/2102.09690
---

**What it is.** Once you've decided to use few-shot examples, *which* examples you pick and in *what order* you place them is itself a lever — often a bigger one than how many you include. The exemplars are training signal: the model induces the task from them, so a biased, narrow, or inconsistently-formatted set teaches the wrong pattern even when each example is individually correct.

**The four properties to select for.** OpenAI's guidance: "show a diverse range of possible inputs with the desired outputs." Anthropic's: make examples **relevant** ("mirror your actual use case closely"), **diverse** ("cover edge cases and vary enough that Claude doesn't pick up unintended patterns"), and **structured** (wrap each in `<example>` tags so it's distinguishable from instructions). Add a fourth that both assume: **correctness and consistent formatting** — every exemplar's output must be right and follow the exact shape you want back, because the model copies format and labels as faithfully as content.

**Order matters, measurably.** Lu et al. (ACL 2022) found example order alone "can make the difference between near state-of-the-art and random guess performance: essentially some permutations are 'fantastic' and some not." The sensitivity persists across model sizes and doesn't transfer between models, so there's no universal "good order" to memorize. Zhao et al. (ICML 2021) name two of the biasing forces: **majority-label bias** (the model favors a label that's frequent among the examples) and **recency bias** (it favors labels appearing near the *end* of the prompt). Both are artifacts of selection/ordering, not the task.

**How to apply.** Curate a small set (Anthropic suggests 3-5) that spans the real input distribution and includes the edge/hard cases you actually care about. **Balance the labels** across examples so the set doesn't silently vote for one class. Keep output format byte-consistent across every example. For classification especially, watch the **last** example — recency bias means it tilts the default; don't end on an unrepresentative case. If you can evaluate, treat order as a tunable and try a few permutations rather than trusting the first. Modern caveat: strong reasoning models are more robust to order than the GPT-3-era models these papers studied, but the selection properties (representative, diverse, correct, balanced, consistent) still hold.

**Pitfalls.** Cherry-picking easy/typical examples teaches a model that fails on the tail; near-duplicate examples waste slots and amplify one pattern; a class-imbalanced set induces majority-label bias; one mis-formatted or wrong-labeled exemplar can corrupt the whole induced pattern. A representative, balanced, consistently-formatted handful beats a larger arbitrary pile.

**Takeaway.** Examples are demonstrations the model imitates — curate them like training data: representative, diverse, correct, label-balanced, identically formatted, and ordered deliberately (mind the last one).

Related: [[few-shot-prompting]], [[output-format-instruction]], [[delimiters-and-structure]]