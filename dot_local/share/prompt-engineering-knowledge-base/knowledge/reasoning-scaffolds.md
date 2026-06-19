---
name: reasoning-scaffolds
description: Structuring HOW a model reasons inside one prompt — reason-then-answer, plan-then-execute, decompose-then-solve — to lift accuracy on multi-step problems beyond a bare "think step by step"; also when to drop the scaffold for reasoning models.
last_refreshed: 2026-06-20
sources:
  - Anthropic, "Prompting best practices" (chain-of-thought & thinking guidance) — https://platform.claude.com/docs/en/docs/build-with-claude/prompt-engineering/chain-of-thought
  - OpenAI, "Reasoning best practices" — https://developers.openai.com/api/docs/guides/reasoning-best-practices
  - Zhou et al., "Least-to-Most Prompting Enables Complex Reasoning in Large Language Models," ICLR 2023 — https://arxiv.org/abs/2205.10625
  - Wang et al., "Plan-and-Solve Prompting," ACL 2023 — https://arxiv.org/abs/2305.04091
---

**What it is.** A reasoning scaffold prescribes *how* the model works through a problem inside a **single call** — not just "show your reasoning" (bare CoT), but a named structure: **reason-then-answer**, **plan-then-execute**, or **decompose-then-solve**. You impose the shape in the prompt; the model fills it in one generation.

**Boundary.** Stay single-call and in-prompt. Sequencing the shape across multiple API calls is the sibling [[prompt-chaining]], not this; an autonomous agent loop that re-plans across tool calls is agent-architectures, out of scope here. Distinct, too, from [[task-decomposition-in-prompt]]: that splits the *deliverable* into ordered sub-steps that each feed the output, whereas a scaffold shapes the *reasoning* that precedes the answer and is often discarded (the `<thinking>` span). This entry is only about structuring reasoning *within one prompt*.

**Why it works.** Forcing intermediate structure before the answer gives the model room to compute rather than guess the final token directly. Two canonical scaffolds: *least-to-most* "break[s] down a complex problem into a series of simpler subproblems and then solve[s] them in sequence," each subproblem building on prior answers, which lets the model generalize to "more difficult problems than those seen in the prompts" (Zhou et al., 2023). *Plan-and-solve* splits the work in two — "first, devising a plan to divide the entire task into smaller subtasks, and then carrying out the subtasks according to the plan" (Wang et al., 2023) — beating plain zero-shot CoT by separating planning from execution.

**How to apply.** Pick the scaffold to the task: *reason-then-answer* for analysis/judgment (reason in `<thinking>`, answer in `<answer>`); *plan-then-execute* when order or completeness matters; *decompose-then-solve* for compositional problems with dependent parts. Make the boundary explicit with delimiters so the reasoning is separable from the deliverable. Anthropic's manual-CoT guidance: "encourage step-by-step reasoning by asking Claude to think through the problem. Use structured tags like `<thinking>` and `<answer>` to cleanly separate reasoning from the final output." Add a self-check step — "Before you finish, verify your answer against [test criteria]" — which "catches errors reliably, especially for coding and math."

**Pitfalls — and the reasoning-model caveat.** Over-scripting can *hurt*. A hand-written step list flattens cross-cutting structure and can lock the model onto a worse path than it would find itself; Anthropic now advises "prefer general instructions over prescriptive steps… 'think thoroughly' often produces better reasoning than a hand-written step-by-step plan." For models that reason internally the advice inverts: OpenAI says to "avoid chain-of-thought prompts… prompting them to 'think step by step' or 'explain your reasoning' is unnecessary" and "can sometimes hinder" them — treat such a model "like a senior co-worker," give the goal, not the procedure. Also: a scaffold the prompt never reads back is wasted tokens; keep the reasoning span bounded and tied to the answer.

**Takeaway.** Scaffold the reasoning when the task is multi-step and the model is a non-reasoning (or lightly-reasoning) one; give the goal and a light structure, not a rigid script; and on internal-reasoning models, drop the scaffold and state the objective plainly.

Related: [[chain-of-thought]], [[task-decomposition-in-prompt]], [[prompt-chaining]]
