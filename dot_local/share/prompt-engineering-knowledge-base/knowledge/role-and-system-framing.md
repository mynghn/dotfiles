---
name: role-and-system-framing
description: Composing the system/developer message to set persona, expertise, stance, and standing behavior before the task; deciding what belongs in the system layer vs. the user turn; making a role earn its tokens instead of cosmetic "you are an expert" filler.
last_refreshed: 2026-06-20
sources:
  - Anthropic, "Prompting best practices — Give Claude a role" (Claude Docs), 2026 — https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/system-prompts
  - OpenAI, "Text generation — message roles and instruction following" (API Docs), 2025 — https://developers.openai.com/api/docs/guides/text
  - OpenAI, "Model Spec — chain of command," 2025 — https://model-spec.openai.com/2025-02-12.html
---

**What it is.** Use the dedicated system/developer message to establish *who the model is and how it should behave* before any task arrives — persona, domain expertise, stance, tone, and standing rules that hold across every turn. It is the standing-instruction layer, distinct from the per-task ask in the user turn. Anthropic: "Setting a role in the system prompt focuses Claude's behavior and tone for your use case. Even a single sentence makes a difference" — e.g. `system="You are a helpful coding assistant specializing in Python."`

**Why it works.** The role is processed first and conditions everything after it, so it biases vocabulary, depth, and what the model treats as relevant. It also sits at higher authority than the user turn: OpenAI's analogy is that you "think about `developer` and `user` messages like a function and its arguments" — `developer` messages "provide the system's rules and business logic, like a function definition," while `user` messages "provide inputs ... like arguments to a function" — and the developer message is "prioritized ahead of user messages." OpenAI's Model Spec formalizes this as a *chain of command*: platform/system instructions outrank developer instructions, which outrank user requests. That makes the system layer the right home for invariants you don't want a single user turn to override.

**How to apply.**
- Put *standing* behavior in the system layer (persona, expertise, output conventions, refusal/safety stance, format defaults); keep the *specific* request and its data in the user turn. Don't restate the task in both.
- Make the role load-bearing and specific — a "senior security reviewer who flags severity and cites the exact line" steers more than a generic "expert." A role earns its tokens only if it changes the output.
- State stance and constraints, not just a title: audience, depth, what to prioritize, what to refuse. The title alone rarely shifts behavior; the attached behavior does.
- Keep it concise. A bloated persona competes with the task for attention; cut adjectives that don't change a decision.

**Pitfalls.** A persona is steering, not knowledge — "act as a cardiologist" tunes tone and framing but does not make claims more factually true, so pair it with grounding for correctness-critical work. Cosmetic flattery ("you are a world-class genius") adds tokens without changing behavior. Over-engineered or contradictory personas can fight the actual instruction; recent instruction-following models are sensitive to forceful system language, so prefer "Use this tool when…" over "CRITICAL: you MUST…" to avoid over-triggering. And a role is a default, not a hard guarantee — for true invariants, state the rule explicitly rather than trusting the persona to imply it.

**Takeaway.** Frame the standing behavior once, in the highest-authority layer, with a role that does real steering work; leave the per-task request to the user turn.

Related: [[explicit-instruction]], [[delimiters-and-structure]], [[output-format-instruction]]