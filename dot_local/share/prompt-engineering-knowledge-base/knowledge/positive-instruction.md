---
name: positive-instruction
description: Writing a directive as a prohibition ("don't use markdown", "never ask for X") and the model violates or ignores it; converting negative constraints into affirmative "do this instead" instructions to steer behavior more reliably.
last_refreshed: 2026-06-20
sources:
  - Anthropic, "Prompting best practices" — Control the format of responses ("Tell Claude what to do instead of what not to do") and Add context to improve performance — https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
  - DAIR.AI, "General Tips for Designing Prompts," Prompt Engineering Guide (adapting OpenAI's prompt-engineering best practices) — https://www.promptingguide.ai/introduction/tips
---

**What it is.** State the behavior you *want* (an affirmative directive) instead of only forbidding the behavior you don't. A prohibition tells the model which region of output to avoid but leaves the rest of the space open; a positive instruction names the target directly. Anthropic's first rule for steering output format is literally "**Tell Claude what to do instead of what not to do**": instead of `"Do not use markdown in your response"`, try `"Your response should be composed of smoothly flowing prose paragraphs."`

**Why it works.** A negation forces the model to hold the unwanted thing in mind and infer an acceptable alternative — and the forbidden token, now present in the prompt, can prime the very behavior you banned. OpenAI's best-practices guidance (via the Prompt Engineering Guide) shows the failure: a movie-recommendation bot told `"DO NOT ASK FOR INTERESTS. DO NOT ASK FOR PERSONAL INFORMATION."` kept asking anyway; rewriting it to describe the *desired* action — recommend a movie from the top global trending list, refrain from asking for preferences — fixed it. The affirmative form removes the inference step and gives the model a positive target to generate toward.

**How to apply.**
- For each "don't / never / avoid" in your prompt, ask "then what *should* it do?" and write that instead. `"Don't be verbose"` → `"Answer in 2-3 sentences."`
- Pair the directive with a brief reason when one exists — it generalizes better than a bare rule. Anthropic's example: not `"NEVER use ellipses"` but `"Your response will be read aloud by a text-to-speech engine, so never use ellipses since the text-to-speech engine will not know how to pronounce them."`
- When a positive phrasing is awkward, add a structural anchor instead of a ban: an XML format indicator like `"Write the prose sections of your response in <prose> tags"` steers format better than `"no markdown."`
- Reserve hard prohibitions for genuine safety/compliance lines; even then, state the allowed path alongside.

**Pitfalls.** Don't overcorrect into a wall of imperatives that buries the one that matters — keep the affirmative directive specific and singular. A positive instruction still has to be *concrete*: `"be helpful"` is affirmative but vacuous. And capitalized negations (`NEVER`, `DO NOT`) read as emphasis but don't fix the underlying inference cost; rephrasing beats shouting.

**Takeaway.** Convert prohibitions into targets: name the behavior to produce, not just the one to suppress.

Related: [[explicit-instruction]], [[output-format-instruction]]