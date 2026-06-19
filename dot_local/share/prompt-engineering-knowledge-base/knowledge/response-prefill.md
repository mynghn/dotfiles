---
name: response-prefill
description: Forcing output format/style by seeding the start of the answer — prefill "{" for JSON, a fixed opening phrase, or in-character text to skip preambles; and what to do now that last-turn prefill is deprecated on newer models.
last_refreshed: 2026-06-20
sources:
  - Anthropic, "Prefill Claude's response for greater output control," Claude Docs (2025) — https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prefill-claudes-response
  - Anthropic, "Prompting best practices" (Migrating away from prefilled responses), Claude Docs (2026) — https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
  - OpenAI, "Best practices for prompt engineering with the OpenAI API" (leading words), OpenAI Help Center — https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
---

**What it is.** Seed the *beginning* of the assistant's reply so the model continues from your text instead of starting fresh. The classic form is API assistant-turn prefill: you supply the opening of the answer in an `assistant` message and the model takes it from there. Anthropic's framing — you "include the desired initial text in the Assistant message" to "direct Claude's actions, skip preambles, enforce specific formats like JSON or XML, and even help Claude maintain character" in role-play. The canonical move: prefill `{` so the model "skip[s] the preamble and directly output[s] the JSON object," cleaner and easier to parse.

**Why it works.** Generation is next-token continuation: whatever already sits at the front of the response constrains everything after it. An open brace makes prose-then-JSON nearly impossible to continue into; a fixed phrase ("The answer is") forecloses the "Sure, here's…" preamble; an in-character first line locks tone before the model can break frame. The prompt-side analog needs no API turn — OpenAI's "leading words" tactic ends the prompt with a cue like `import` (Python) or `SELECT` (SQL) to "nudge the model toward" that pattern.

**How to apply.** Prefill the shortest token that pins the format: `{` or `[` for JSON, a tag like `<analysis>`, a header, or the literal first words you want. Pair with a format instruction rather than relying on prefill alone. One hard constraint on API prefill: the text **cannot end with trailing whitespace** (`"As an AI assistant, I "` errors).

**Pitfall — deprecation on newer models.** Anthropic: "Starting with Claude 4.6 models … prefilled responses on the last assistant turn are no longer supported. Requests with prefilled assistant messages to these models return a 400 error." Migrate to the prompt side: use **Structured Outputs** (or tool calls with an enum) to force JSON/schema; instruct directly — "Respond directly without preamble. Do not start with phrases like 'Here is…'" — to kill preambles; wrap output in XML tags; and strip any stray preamble in post-processing. Earlier models and non-final assistant turns still accept prefill.

**Takeaway.** Constraining the *first* tokens is the cheapest lever on output shape — but on current models reach for it through structured outputs and direct format instructions, not a last-turn prefill the API now rejects.

Related: [[output-format-instruction]], [[role-and-system-framing]]