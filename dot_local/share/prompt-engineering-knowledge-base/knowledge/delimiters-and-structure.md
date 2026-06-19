---
name: delimiters-and-structure
description: Wording a prompt that mixes several roles — instructions, context, reference data, examples, the user's input — and the model blurs them or follows the wrong part; deciding how to fence each section (XML tags, markdown headings, delimiters) so each role is parsed unambiguously.
last_refreshed: 2026-06-20
sources:
  - Anthropic, "Structure prompts with XML tags" (prompt engineering guide) — https://platform.claude.com/docs/en/docs/build-with-claude/prompt-engineering/use-xml-tags
  - OpenAI, "Prompt engineering" — Markdown + XML structure, and the Identity → Instructions → Examples → Context order — https://developers.openai.com/api/docs/guides/prompt-engineering
---

**What it is.** A single prompt usually carries several roles at once — task instructions, background context, reference data, examples, and the user's raw input. Delimiters and structure fence each role so the model can tell them apart instead of reading one undifferentiated wall of text. The two dominant conventions are **XML-style tags** (`<instructions>`, `<context>`, `<example>`, `<document>`) and **markdown sections** (headings + lists); plain delimiters (triple backticks, `---`, triple quotes) are the lightweight fallback.

**Why it works.** Tags give each span an explicit, named role the model can attend to and refer back to. Anthropic: "XML tags help Claude parse complex prompts unambiguously, especially when your prompt mixes instructions, context, examples, and variable inputs. Wrapping each type of content in its own tag... reduces misinterpretation." OpenAI is symmetric: "Markdown headers and lists can be helpful to mark distinct sections of a prompt, and to communicate hierarchy to the model," and "XML tags can help delineate where one piece of content (like a supporting document used for reference) begins and ends." A labeled boundary also hardens the line between *your* instructions and *untrusted* pasted data, so the model treats fenced user content as data to act on rather than instructions to obey.

**How to apply.**
- Wrap each distinct role in its own tag or section: instructions, context, data, examples, output target. Fence pasted/user content especially — that boundary is where the model most often confuses data for instruction.
- Be consistent: reuse the same descriptive tag names across a prompt, and reference them in the instructions ("Using the contract in `<contract>`, ..."). Anthropic: "Use consistent, descriptive tag names."
- Nest when content is hierarchical: multiple docs as `<documents>` → `<document index="n">` with `<source>` and `<document_content>` subtags; examples as `<examples>` → `<example>`.
- Order sections deliberately. OpenAI's default developer-message order is Identity → Instructions → Examples → Context; for long inputs Anthropic puts bulk data **first** and the query last (reported up to ~30% quality lift on multi-doc tasks).
- Match prompt style to desired output: structuring the prompt in markdown nudges markdown output; XML format indicators (e.g. `<answer>` tags) cleanly separate reasoning from the final result.

**Pitfalls.** Tags are a parsing aid, not magic — content still has to be clear. Don't over-fragment a simple prompt into ceremonial tags it doesn't need. Keep the convention uniform; mixing `<context>` here and `### Context` there reintroduces the ambiguity you were removing. And ease off shouty wrappers: on current models, aggressive `CRITICAL: You MUST...` framing can cause *over*triggering — prefer plain, well-scoped tag names.

**Takeaway.** Give every role its own labeled box; name the boxes consistently and refer to them by name, so the model never has to guess which span is the instruction, which is the data, and which is the example.

Related: [[explicit-instruction]], [[few-shot-prompting]], [[output-format-instruction]]