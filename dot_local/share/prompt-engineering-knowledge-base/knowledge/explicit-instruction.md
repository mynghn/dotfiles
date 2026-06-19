---
name: explicit-instruction
description: Replacing a vague ask with a precise directive — stating exactly what is wanted: the desired output, format, constraints, intended audience, and success criteria, instead of relying on the model to infer intent.
last_refreshed: 2026-06-20
sources:
  - Anthropic, "Be clear and direct" (Prompting best practices) — https://platform.claude.com/docs/en/docs/build-with-claude/prompt-engineering/be-clear-and-direct
  - OpenAI, "Prompt engineering" guide — https://developers.openai.com/api/docs/guides/prompt-engineering
---

**What it is.** The highest-leverage prompt move: say exactly what you want instead of gesturing at it. Be specific about the desired output, its format, the constraints, the intended audience, and what "done" looks like. Anthropic's framing: "Claude responds well to clear, explicit instructions... If you want 'above and beyond' behavior, explicitly request it rather than relying on the model to infer this from vague prompts." OpenAI puts the same idea as a definition — prompt engineering is "the process of writing effective instructions for a model, such that it consistently generates content that meets your requirements."

**Why it works.** A vague prompt forces the model to guess the missing specification, and it fills the gap with its most generic, on-distribution default. Every unstated requirement is a coin flip. Stating the requirement removes the guess and collapses the output distribution toward what you actually meant. Anthropic's mental model: "Think of Claude as a brilliant but new employee who lacks context on your norms and workflows. The more precisely you explain what you want, the better the result."

**How to apply.**
- Name the deliverable, its format, and its bounds: audience, length, tone, what to include and exclude. "Create an analytics dashboard" → "Create an analytics dashboard. Include as many relevant features and interactions as possible. Go beyond the basics to create a fully-featured implementation."
- State the constraints explicitly and give the reason — models generalize from the *why*: not "NEVER use ellipses" but "Your response will be read aloud by a text-to-speech engine, so never use ellipses since the engine will not know how to pronounce them."
- Define success criteria up front so the model can check its own work ("verify your answer against [criteria] before finishing").
- When order or completeness matters, give sequential numbered steps.
- **Golden rule (Anthropic):** "Show your prompt to a colleague with minimal context on the task and ask them to follow it. If they'd be confused, Claude will be too."

**Pitfalls.** Specific is not the same as verbose — pad with irrelevant detail and you bury the directive. Over-forceful phrasing ("CRITICAL: You MUST...") can over-trigger newer, more instruction-sensitive models; Anthropic advises dialing such language back to plain "Use this tool when...". And the precision dial is model-dependent: OpenAI casts a GPT-class model as "a junior coworker" that performs best "with explicit instructions" — one that benefits from "precise instructions that explicitly provide the logic and data required" — whereas a reasoning model is "like a senior co-worker" you "give a goal" and trust to work out the details, one that "will provide better results on tasks with only high-level guidance." Over-specifying *how* can constrain a reasoning model that would do better with the goal and room to plan. Specify the *what* and the constraints; let a reasoning model choose the *how*.

**Takeaway.** Replace every vague ask with a precise directive — deliverable, format, constraints, audience, success criteria — but pin the *what*, not necessarily the *how*, especially for reasoning models.

Related: [[output-format-instruction]], [[delimiters-and-structure]], [[positive-instruction]], [[role-and-system-framing]]