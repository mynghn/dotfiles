---
name: tool-evaluation
description: Use when deciding whether a tool's description/schema is good enough, debugging why an agent picks the wrong tool or fills arguments wrong, or setting up a measurement loop to iterate tool contracts on observed failures instead of intuition.
last_refreshed: 2026-06-20
sources:
  - Anthropic, "Writing effective tools for agents — with agents", 2025 — https://www.anthropic.com/engineering/writing-tools-for-agents
  - Anthropic, "Building effective agents" (Appendix 2: Prompt engineering your tools), 2024 — https://www.anthropic.com/engineering/building-effective-agents
---

**What it is.** Treating the tool contract as something you *measure and iterate*, not something you write once and trust. You build a small evaluation suite of realistic tasks, run an agent against your tools, and read the resulting transcripts to find where the agent picks the wrong tool, fills arguments wrong, or burns calls — then fix the description/schema and re-measure. Evals, not intuition, drive each refinement.

**Why / Evidence.** Anthropic (2025) reports its team "repeatedly optimiz[ed] our internal tool implementations" via an eval loop, and that "even small refinements to tool descriptions can yield dramatic improvements." Concrete failures only surface under measurement: at web-search launch they found Claude "needlessly appending `2025` to the tool's `query` parameter, biasing search results and degrading performance" — fixed by editing the tool description. The same failure-to-fix mapping is explicit: "lots of tool errors for invalid parameters might suggest tools could use clearer descriptions or better examples"; lots of redundant tool calls suggests rightsizing pagination/limit parameters. Anthropic (2024, Appendix 2) urges you to test how the model uses your tools — run many example inputs to see what mistakes the model makes, and iterate — and notes the team spent more time optimizing tool descriptions than the overall prompt, evidence the tool contract is where the eval budget pays off.

**How to apply.**
- *Source tasks from reality.* "Prompts should be inspired by real-world uses and be based on realistic data sources" (Anthropic 2025) — and prefer multi-step tasks needing several tool calls over single-tool toys, which don't exercise selection or argument-construction under pressure.
- *Make each task verifiable.* Pair every prompt with a checkable outcome (exact match, or LLM-as-judge), but "avoid overly strict verifiers that reject correct responses due to spurious differences like formatting" (Anthropic 2025). You may note expected tool calls, but don't overfit — multiple valid paths exist.
- *Measure the tool-specific signals:* tool-selection accuracy (right tool chosen), argument-construction correctness (invalid-parameter error rate is a useful proxy — an argument can be schema-valid yet semantically wrong), redundant/extra calls, tokens per call and per task, plus top-level success. These map directly to fixes — selection errors → sharper descriptions and clearer distinctions from sibling tools; argument errors → schema constraints, examples, or poka-yoke (Anthropic 2024: mandating absolute paths in their SWE-bench agent made a class of errors unrepresentable).
- *Read transcripts, not just scores.* Turn on interleaved thinking to probe why agents do or don't call certain tools, then read the raw tool calls and responses; "what agents omit ... can often be more important than what they include."
- *Close the loop.* Concatenate transcripts, feed them back ("Claude is an expert at analyzing transcripts and refactoring lots of tools at once"), apply edits, re-run. Hold out a test set to catch overfitting to your eval tasks.

**Takeaway.** Don't argue about whether a description is clear — build a handful of realistic, verifiable tasks, run them, and let the failure modes (wrong tool, bad args, wasted calls) name the exact edit. Iterate the contract against numbers and transcripts.

**Boundary.** Tool-specific evals — does the agent select and call *this* tool correctly — live here. The general evaluation harness, LLM-as-judge methodology, and observability tooling are a separate evaluation sibling KB (not yet built — forward reference). Authoring the description/schema text itself is [[tool-description-writing]] and [[input-schema-design]]; how to word a prompt in general is the prompt-engineering KB; managing tool *results* already in the window is the context-engineering KB.

Related: [[tool-description-writing]], [[input-schema-design]], [[tool-error-design]], [[structured-output-shaping]], [[tool-set-size-and-selection]], [[tool-granularity-and-consolidation]]
