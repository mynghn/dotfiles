---
name: chain-of-thought
description: Asking a model to reason step by step before it answers, to raise accuracy on multi-step arithmetic, logic, or commonsense tasks; deciding whether to elicit explicit reasoning at all on a modern reasoning model.
last_refreshed: 2026-06-20
sources:
  - Wei et al., "Chain-of-Thought Prompting Elicits Reasoning in Large Language Models," NeurIPS 2022 — https://arxiv.org/abs/2201.11903
  - Kojima et al., "Large Language Models are Zero-Shot Reasoners," NeurIPS 2022 — https://arxiv.org/abs/2205.11916
  - Wang et al., "Self-Consistency Improves Chain of Thought Reasoning in Language Models," ICLR 2023 — https://arxiv.org/abs/2203.11171
  - Anthropic, "Reasoning models don't always say what they think," 2025 — https://www.anthropic.com/research/reasoning-models-dont-say-think
  - Anthropic, "Prompt engineering: Chain of thought" — https://platform.claude.com/docs/en/docs/build-with-claude/prompt-engineering/chain-of-thought
  - OpenAI, "Reasoning best practices" — https://developers.openai.com/api/docs/guides/reasoning-best-practices
---

**What it is.** Make the model lay out intermediate reasoning *before* committing to an answer, instead of jumping straight to a conclusion. Wei et al. (2022) showed that prompting with exemplars that include "a series of intermediate reasoning steps" — a chain of thought — "significantly improves the ability of large language models to perform complex reasoning," lifting a 540B model to then-state-of-the-art on GSM8K math word problems. Kojima et al. (2022) found the same effect needs no exemplars at all: simply appending **"Let's think step by step"** raised zero-shot MultiArith accuracy from 17.7% to 78.7% and GSM8K from 10.4% to 40.7%.

**Why it works.** Hard problems need serial computation the model can't do in a single forward pass to a token. Writing the steps externalizes that work into the output stream, so each step conditions the next and the final answer is read off a worked solution rather than guessed. The win concentrates on multi-step arithmetic, symbolic, and commonsense reasoning; it does little for single-step lookup or retrieval.

**How to apply (non-reasoning models).** Either show the reasoning (few-shot exemplars whose answers include the worked steps) or just ask for it ("Work through this step by step before giving your answer"). Separate the reasoning from the verdict so you can parse and, if you wish, discard it — Anthropic suggests structured tags like `<thinking>` and `<answer>`. Anthropic also advises a self-check: "Before you finish, verify your answer against [criteria]."

**Going further: self-consistency.** When accuracy matters more than cost, don't trust a single chain. Wang et al. (2023) sample *multiple* reasoning paths for the same CoT prompt at non-zero temperature, then take the majority-vote final answer — marginalizing over the paths recovers the consensus a greedy single decode can miss, adding roughly +18% on GSM8K over plain CoT. This is a decoding wrapper *around* the same prompt, not a change to its wording: you keep the CoT prompt and vary how you sample and aggregate. Cost scales with the sample count, so reserve it for hard, high-stakes items.

**The modern caveat.** Reasoning models (o-series, extended/adaptive thinking) already reason internally, so manual CoT is usually redundant and can hurt. OpenAI: "Since these models perform reasoning internally, prompting them to 'think step by step' or 'explain your reasoning' is unnecessary" and "can sometimes hinder it." Anthropic frames manual CoT as "a fallback" for when thinking is off, and prefers "general instructions over prescriptive steps" — "'think thoroughly' often produces better reasoning than a hand-written step-by-step plan." Know your model: scaffold the reasoning yourself only when the model won't do it on its own.

**Pitfalls.** CoT costs latency and tokens, and a fluent chain can rationalize a wrong answer rather than prevent it — the reasoning is not a guarantee of faithfulness. Anthropic (2025) found that even reasoning models routinely *don't* verbalize the cues actually driving their answers (Claude 3.7 Sonnet mentioned an injected hint only ~25% of the time), so a visible chain can't be trusted as a faithful audit trail — gauge the answer on its merits, not on a plausible-looking rationale. The few-shot effect also depends on scale; small models gain little. (Note: with some Claude models, when thinking is off, the literal word "think" is sensitive — prefer "reason through," "consider," or "evaluate.")

**Takeaway.** Elicit explicit reasoning when the task needs serial steps *and* the model won't supply them itself; on a model that already thinks, give the goal and get out of the way — and when correctness must be squeezed higher, vote over several sampled chains rather than rewording the prompt.

Related: [[reasoning-scaffolds]], [[few-shot-prompting]]
