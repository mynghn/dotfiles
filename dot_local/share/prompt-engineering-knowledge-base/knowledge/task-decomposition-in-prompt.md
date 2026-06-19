---
name: task-decomposition-in-prompt
description: Wording one complex ask as ordered sub-steps or explicit sub-questions inside a single prompt so the model works through each in sequence; a multi-part request that the model half-answers, skips steps on, or muddles into one pass.
last_refreshed: 2026-06-20
sources:
  - OpenAI, Prompt engineering guide — "Split complex tasks into simpler subtasks," 2024 — https://platform.openai.com/docs/guides/prompt-engineering
  - Anthropic, Prompting best practices, 2026 — https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/claude-prompting-best-practices
  - Zhou et al., "Least-to-Most Prompting Enables Complex Reasoning in Large Language Models," ICLR 2023 — https://arxiv.org/abs/2205.10625
---

**What it is.** Break one complex ask into an ordered set of sub-steps or explicit sub-questions *within a single prompt*, so the model addresses each in sequence instead of collapsing the whole thing into one undifferentiated pass. The unit is the instruction itself — "First do X. Then, using that, do Y. Finally, produce Z." — not multiple API calls. (Sequencing across separate calls is the sibling technique [[prompt-chaining]]; keep them distinct.)

**Why it works.** "Complex tasks tend to have higher error rates than simpler tasks" (OpenAI), and decomposition is the software-engineering move of splitting a system into modular parts applied to a prompt. Naming the steps does two things: it forces coverage (each sub-question is a slot the model must fill, so multi-part asks stop getting half-answered), and it orders the work so later steps can build on earlier ones. Anthropic's first principle is to "provide instructions as sequential steps using numbered lists or bullet points when the order or completeness of steps matters." The decomposition literature shows the same gain: least-to-most prompting "first reduces a complex problem into a list of subproblems, and then sequentially solves the subproblems, whereby solving a given subproblem is facilitated by the model's answers to previously solved subproblems," generalizing to problems harder than the exemplars (Zhou et al., ICLR 2023).

**How to apply.** Write the steps as an explicit numbered list, each step one concrete action. Order them by dependency — outputs of earlier steps feed later ones — so the model can't get ahead of itself. Keep each step single-purpose; if a step still hides several actions, split it. Make the hand-off visible ("Using the list from step 2, ...") and pin the final step to the deliverable. Pair with [[output-format-instruction]] when you want only the last step returned, or with [[delimiters-and-structure]] / [[response-prefill]] to label each step's output. For genuinely separable stages you need to inspect or branch on, escalate to [[prompt-chaining]].

**Pitfalls.** Over-decomposing a simple task adds rigid scaffolding that wastes tokens and can box the model in — reserve it for genuinely multi-part asks. A prescribed sequence is only as good as its ordering: a wrong or redundant step propagates downstream. And on modern reasoning models the calculus shifts — Anthropic notes that with extended/adaptive thinking, "a prompt like 'think thoroughly' often produces better reasoning than a hand-written step-by-step plan," and OpenAI advises giving reasoning models "a goal to achieve" over precise step-by-step logic. So hand-author steps when you need a *specific* path or guaranteed coverage; let the model plan when you only need a correct answer and it can reason internally.

**Takeaway.** When one prompt carries a multi-part job, enumerate the parts as ordered, dependency-chained steps so the model covers each in turn — but on reasoning models, decompose only when the path or completeness must be enforced, not by reflex.

Related: [[prompt-chaining]], [[chain-of-thought]], [[output-format-instruction]]
