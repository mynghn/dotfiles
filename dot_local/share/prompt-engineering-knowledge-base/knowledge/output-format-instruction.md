---
name: output-format-instruction
description: Steering the shape of a response by describing it in the prompt — lists, JSON, length caps, headings, tone — rather than enforcing it with response_format/json_schema; deciding between a format instruction and a machine-enforced schema.
last_refreshed: 2026-06-20
sources:
  - Anthropic, Prompting best practices (Claude), 2026 — https://platform.claude.com/docs/en/docs/build-with-claude/prompt-engineering/claude-prompting-best-practices
  - OpenAI, Structured Outputs guide, 2026 — https://developers.openai.com/api/docs/guides/structured-outputs
  - OpenAI, Prompt engineering guide, 2026 — https://developers.openai.com/api/docs/guides/prompt-engineering
---

**What it is.** Specify the output's shape inside the instruction itself: the container (bulleted list, numbered steps, JSON, table, headings), the length ("in two sentences", "≤200 words"), and the tone. It is the cheapest lever for steerability — Anthropic's clarity guidance leads with "be specific about the desired output format and constraints." The instruction is a soft request the model usually honors, not a guarantee.

**HARD BOUNDARY — the instruction to format is prompt-engineering; the enforced schema is not.** This entry covers the *instruction* to format: words in the prompt that describe the shape you want. Machine-enforced structured output — OpenAI Structured Outputs / `response_format` with a `json_schema`, Anthropic's Structured Outputs feature, constrained decoding, and tool/function-call schemas — is the separate TOOL-DESIGN sibling and is out of scope here. The line is sharp: Structured Outputs "ensures the model will **always** generate responses that adhere to your supplied JSON Schema" (OpenAI); a prompt that merely *asks* for JSON makes no such promise, which is why OpenAI's prompt-engineering guide points you to the Structured Outputs feature when you need guaranteed JSON. When you need a guaranteed-parseable contract, reach for the schema feature; when you need a readable shape (prose vs. bullets, a length cap, a heading layout) or a quick draft, instruct it in the prompt. Anthropic's own migration guidance mirrors this: for forced formats, prefer Structured Outputs, but "try simply asking the model to conform to your output structure first, as newer models can reliably match complex schemas when told to."

**How to apply.** State the format positively — say what TO produce, not what to avoid. Anthropic: instead of "Do not use markdown," try "Your response should be composed of smoothly flowing prose paragraphs." Pair the description with a tiny example or a format indicator (an XML tag like `<summary>…</summary>`, or a filled template), since "examples are one of the most reliable ways to steer Claude's output format, tone, and structure." Match your prompt's own style to the target — "removing markdown from your prompt can reduce the volume of markdown in the output." For length, give a concrete bound (sentence/word/item count), not a vague "short."

**Pitfalls.** A format instruction is best-effort: under load it can slip, so for parsing pipelines validate and retry, or escalate to the schema feature. Over-constraining shape can degrade content — an overly rigid template or a hard length cap can crowd out reasoning, so let the model think before it formats. And don't conflate the two levers: asking for JSON in prose is not the same guarantee as `json_schema`, and skipping that distinction is the usual cause of unparseable output.

**Takeaway.** Describe the shape you want, positively and with an example, when a readable or draft format suffices; switch to a machine-enforced schema the moment correctness depends on the structure parsing every time.

Related: [[explicit-instruction]], [[delimiters-and-structure]], [[few-shot-prompting]]
