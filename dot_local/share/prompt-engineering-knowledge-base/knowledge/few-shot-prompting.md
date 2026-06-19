---
name: few-shot-prompting
description: Steering output format, labels, tone, or a hard-to-describe task by showing worked input/output demonstrations in the prompt; deciding between zero/one/few examples or whether to add examples at all.
last_refreshed: 2026-06-20
sources:
  - Anthropic, "Use examples (multishot prompting) to guide Claude's behavior" — https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/multishot-prompting
  - OpenAI, "Prompt engineering" guide (Few-shot learning) — https://developers.openai.com/api/docs/guides/prompt-engineering
  - Brown et al., "Language Models are Few-Shot Learners" (GPT-3), NeurIPS 2020 — https://arxiv.org/abs/2005.14165
---

**What it is.** Put a handful of worked input→output demonstrations in the prompt so the model infers the pattern and applies it — no fine-tuning. Brown et al. named the regime: tasks and demonstrations are "specified purely via text interaction with the model," applied "without any gradient updates or fine-tuning" (GPT-3, 2020). This is *in-context learning*. Counting by demonstrations: **zero-shot** (instruction only), **one-shot** (a single example), **few-shot** (several). OpenAI frames it as steering "toward a new task by including a handful of input/output examples in the prompt."

**Why it works.** A demonstration encodes the target shape — schema, label set, tone, length, edge-case handling — far more precisely than prose can. Anthropic: "Examples are one of the most reliable ways to steer Claude's output format, tone, and structure... A few well-crafted examples... can dramatically improve accuracy and consistency." Examples earn their keep most when the task is easier to *show* than to *describe*: idiosyncratic formatting, classification with subtle label boundaries, or a style you can't fully articulate.

**How to apply.** Anthropic's defaults: **include 3-5 examples**, and make them **relevant** (mirror your real inputs), **diverse** (cover edge cases; vary them so the model "doesn't pick up unintended patterns"), and **structured** (wrap each in `<example>` tags, the set in `<examples>`, so they're distinguishable from instructions). OpenAI adds: "show a diverse range of possible inputs with the desired outputs." Keep formatting *identical* across every example — the same `Input:`/`Output:` shape — so the demonstrated pattern is the only signal. Which examples to choose, and in what order, belongs to [[exemplar-selection]].

**Pitfalls.** Too few or too-similar examples teach a spurious shortcut (e.g. all positive labels → the model just echoes "positive"). Inconsistent formatting across examples sends mixed signals. Examples leak: a stray detail or biased label distribution propagates into outputs. Long example blocks cost tokens and can bury the instruction. For reasoning/thinking models, demonstrating *reasoning* needs care — show the thinking pattern with `<thinking>` tags inside examples rather than a bare answer if you want the model to generalize the reasoning style, not just the final format.

**Takeaway.** Reach for examples when showing beats telling; use 3-5 relevant, diverse, identically-formatted demonstrations in delimited tags, and audit them for the labels and shortcuts they silently teach.

Related: [[exemplar-selection]], [[output-format-instruction]], [[delimiters-and-structure]]
