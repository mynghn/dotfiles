---
name: prompt-chaining
description: Sequencing multiple prompts so each call consumes the prior output (extract → summarize → format, or draft → review → refine); deciding whether to decompose a task across wired-together calls and inspect intermediate outputs, vs. doing it in one prompt.
last_refreshed: 2026-06-20
sources:
  - Anthropic — Prompt engineering: Chain complex prompts — https://platform.claude.com/docs/en/docs/build-with-claude/prompt-engineering/chain-prompts
  - OpenAI — Prompt engineering guide (strategy: Split complex tasks into simpler subtasks) — https://platform.openai.com/docs/guides/prompt-engineering
---

**What it is.** Prompt chaining decomposes a task *across* model calls: you run a sequence of prompts where each consumes the prior call's output, and **the prompter** wires the steps together. The canonical shapes are a pipeline (extract → summarize → format) and self-correction (draft → review against criteria → refine). OpenAI lists "split complex tasks into simpler subtasks" among its core strategies: a complex task can be re-defined as a workflow of simpler ones in which the outputs of earlier tasks construct the inputs to later tasks, and each step can be validated before the next begins.

**Why it works.** Each call carries one clear objective, so the model's attention isn't split across competing instructions, and errors don't compound silently within a single generation. Equally important, the seams become inspectable: you can log, evaluate, branch, or retry at any boundary. Anthropic notes explicit chaining "is still useful when you need to inspect intermediate outputs or enforce a specific pipeline structure," and calls the self-correction chain — "generate a draft → have Claude review it against criteria → have Claude refine based on the review" — the most common pattern, with each step "a separate API call so you can log, evaluate, or branch at any point."

**The boundary (read this).** HARD BOUNDARY: prompter-driven prompt sequencing is prompt-engineering. Autonomous multi-agent orchestration / agent control-flow / tool-using agent loops are the AGENT-ARCHITECTURES sibling, NOT this entry. This is *prompter-driven* sequencing — you, the human or orchestration script, decide the steps and pass output A into prompt B; that is composing the instructions. It is **NOT** the *model* deciding what to call next at runtime. The line is *who* drives the next step: a fixed pipeline you authored (this entry) vs. a model choosing its own path at runtime (the agent-architectures sibling). Note too that this is prompt composition, not context-window management — truncation, retrieval, and compaction live elsewhere.

**How to apply.** Identify natural subtasks with clean handoffs, give each its own focused prompt, and pass only the prior step's relevant output forward (use delimiters/XML tags so each step's input is unambiguous). Have each step emit a structured, parseable output the next step can consume. For self-correction, make the review step's criteria explicit and concrete. Keep the chain as short as the task allows — every added call adds latency, cost, and a new failure point.

**Pitfalls.** Don't chain what one well-structured prompt handles — added calls cost latency and money, and propagate any upstream error downstream. Modern caveat: capable reasoning models now do much multi-step decomposition *internally*, so a chain that merely splits reasoning is often redundant; Anthropic notes "Claude handles most multi-step reasoning internally" and reserves explicit chaining for inspectable intermediates or an enforced pipeline. Reach for chaining when you need a *visible, controllable* seam — not just to break up thinking.

**Takeaway.** Chain when you need to see, gate, or branch at the seam between steps; otherwise prefer one focused prompt and let the model reason internally.

Related: [[task-decomposition-in-prompt]], [[output-format-instruction]], [[delimiters-and-structure]]