# LLM-Agent Knowledge Bases — Family Registry

The "should I add a sibling?" decision record for a **federated** family of agent-practice knowledge bases. Each sibling is its own focused KB skill following the `context-engineering-knowledge-base` pattern.

## Model

Federated focused skills, not one broad KB. Each sibling = one coherent, closeable agent-practice topic, realized as the proven pattern: a provider-neutral shared core (`~/.local/share/<topic>-knowledge-base/`: INDEX + `knowledge/` + a `ce-kb`-style helper) with thin Claude + Codex `SKILL.md` adapters; entries distilled, self-contained, sourced + dated; retrieval is INDEX → JIT; mutation is source-write → `chezmoi apply` → commit.

Why federated: small coherent units retrieve precisely (a skill auto-invokes on its `description` — a narrow description is a sharp trigger), avoid the broad-index scaling cost, and isolate by topic.

**Admission test for a new sibling:** coherent + closeable + backed by primary sources + non-overlapping with existing siblings. Don't extract a shared pattern/generator until ≥3 siblings exist (rule of three) — `context-engineering-knowledge-base` is the de-facto template until then.

## Naming convention

Spelled-out everywhere: skill name, both adapter dirs (`~/.claude/skills/…`, `~/.codex/skills/…`), and the core dir (`~/.local/share/…`) all use `<topic>-knowledge-base` — confirmed on `context-engineering-knowledge-base`. `-kb` is not used in user-facing names. The family-table entries below are topic **stems**; the realized skill/dir name appends `-knowledge-base` (e.g. `prompt-engineering` → `prompt-engineering-knowledge-base`).

This registry root is `llm-agent-knowledge-base` and is a **registry, not a skill** — it has no `SKILL.md` and is never auto-invoked. The siblings are the skills; this is their map.

## Validated layering

The field's own stack (Osmani, 2026): **prompt → context → harness → loop**. The bottom layers are built/planned siblings; the top two are named by the 2026 "harness/loop engineering" vocabulary (see Vocabulary).

## Family

Ordered by **universality** — how many agent tasks the knowledge benefits. Universality fixes the **discovery-wiring** rule — an **Everyday** concern earns an always-loaded `AGENTS.md` Layer-1 trigger block; **Common** and **Situational** ones rely on the `SKILL.md` description (which costs nothing until the work matches) — and sets the **default build priority**. Build-order may deviate from tier when a topic's primary sources are especially ripe or it is hit unusually often. Build status is inline; the `prompt → context → harness → loop` stack lens lives under *Validated layering* above.

### Everyday — universal, ~every agent turn (warrants a Layer-1 trigger block)
| Sibling stem | Status | Scope | Boundary |
|---|---|---|---|
| **context-engineering** | built (14) | what occupies the window + long-context degradation (lost-in-the-middle, context-rot, distractors) + write/select/compress/isolate | the window now |
| **prompt-engineering** | built (12, `0002-prompt-engineering-knowledge-base`) | composing the instruction: clarity & structure, few-shot exemplars, reasoning elicitation (CoT), output-format wording, prompt-level decomposition | wording vs the window |

### Common — whenever you build or operate an agent
| Sibling stem | Status | Scope | Boundary |
|---|---|---|---|
| **agent-architectures** | planned | Control flow & orchestration — workflows vs autonomous loop, ReAct, reflection, routing, single/multi-agent, sub-agent design; absorbs loop-engineering's control envelope | control flow vs runtime *execution* (agent-runtime) |
| **evaluation-observability** | planned | Eval-driven dev, LLM-as-judge, eval harnesses, tracing | measuring vs runtime *enforcement* (guardrails) |
| **agent-runtime** *(alias: agent-harness / harness)* | planned | The execution layer — loop driver/runtime, tool dispatch, retries/idempotency, state & restart-survival, sandboxing, session persistence, triggers/budgets/runaway-guards | runtime *execution* vs control-flow *patterns* (architectures) & window mgmt (context) |

### Situational — only when the specific need arises (SKILL.md description-only discovery)
| Sibling stem | Status | Scope | Boundary |
|---|---|---|---|
| **tool-design** | built (10, `0003-tool-design-knowledge-base`) | the tool/function contract — descriptions, input/output schemas, granularity & consolidation, naming/namespacing, high-signal & token-efficient returns, error design, structured output, tool evals; absorbs structured-output | the tool contract vs instruction-wording (prompt-engineering) & what occupies the window (context-engineering); tool surface vs how tools are sequenced (architectures) |
| **skill-design** | planned · next build | the skill abstraction (SKILL.md) — progressive disclosure / three-tier token economics, directory packaging (scripts/references/assets), in-context activation, description-as-activation-trigger, one-capability granularity, instructions-body craft; the skill vs tool vs prompt vs sub-agent boundary | description/naming/selection-among-many delegated to tool-design (shared seam, single owner); the body's instruction-wording → prompt-engineering; sub-agent design → agent-architectures |
| **memory-state** | planned | Cross-session persistence + recall — short/long-term, semantic/episodic/procedural, write/consolidation | *across windows* vs *this window* (context) |
| **retrieval-rag** | planned | Fetch + rank external knowledge — chunking, embeddings, hybrid, rerank, contextual retrieval | *fetch* vs *place in window* (context) |
| **guardrails-safety-security** | planned | I/O validation, prompt-injection defense, permissions/sandboxing, excessive-agency (OWASP LLM Top 10) | runtime *enforcement* vs *measurement* (eval) |
| **cost-latency** | planned | Model routing, cache economics, token budgeting, batching, streaming | cache-as-*cost-lever* vs cache-as-*context-stability* (context) |

`agent-runtime` was **promoted from "deferred"** once the 2026 harness-engineering literature supplied the primary sources it had lacked.

`skill-design` is **Situational** by universality (build-time, not every-turn → description-only discovery) yet the **recommended next build**: its spec is mature now (`agentskills.io` + Anthropic Agent Skills docs) and fast-moving, so best captured current, and skill-authoring is a high-frequency activity here — which lifts its build-order above the higher-universality Common siblings. The shared description/naming/selection seam stays owned by `tool-design` (cross-reference, don't duplicate). Admission grounded in a 2026-06-20 SOTA pass (Anthropic Agent Skills docs + agentskills.io open standard + arXiv:2602.20867 SoK, which formalizes a skill as a 4-tuple) — confirmed coherent, closeable, primary-source-backed, and non-overlapping with tool-design and prompt-engineering.

### Excluded
- **fine-tuning / model-adaptation** — model training, not agent building.
- **structured-output** — folds into tool-design (thin slice into prompt-engineering).

### Watch / reassess
- **human-in-the-loop / agent-UX** — most defensible *future* sibling if it grows (approvals, interruptibility, steering).
- **computer-use / GUI agents** — a *sub-topic of tool-design* (an action modality), not a sibling.
- **loop-engineering as a standalone** — reassess ~2026-09; currently folded into agent-architectures.

## Boundary rulings (the tricky seams)
- **prompt vs context** — wording the instruction vs managing the window.
- **retrieval vs context** — fetch + rank vs select + place what's fetched.
- **memory vs context** — cross-session store + recall policy vs this one window; loading a recalled item *into* the window is context-engineering.
- **architectures vs context-isolation** — same sub-agent mechanism, two lenses: control flow → architectures; isolation-as-window-tactic stays a pointer in context-engineering.
- **cost vs prefix-cache** — cost-lever framing → cost-latency; stable-prefix-as-context-structure → context-engineering. Cross-link.
- **harness — broad vs narrow** — "harness" is used *broadly* (everything non-model: an umbrella over the whole family) and *narrowly* (the execution/runtime layer). We adopt the **narrow** sense as `agent-runtime`; the broad sense is cross-cutting vocabulary, not its own page.
- **loop vs architectures** — loop-engineering's control envelope (termination/budgets/verification/stacking) → agent-architectures; its production/unattended aspects → agent-runtime.

## Vocabulary routing (aliases → sibling)
- harness · agent harness · harness engineering · scaffold/scaffolding → **agent-runtime** — consolidated H1 2026 (OpenAI/LangChain/Fowler/METR); sources disagree broad vs narrow.
- loop engineering · loopcraft · the agent loop → **agent-architectures** — coined ~June 2026 (Steinberger/Cherny/swyx/Osmani); reassess as standalone ~2026-09.
- orchestration → **agent-architectures**.
- lost-in-the-middle · context rot · JIT · compaction · prefix cache → **context-engineering**.

## Source shelf

Canonical decompositions (load-bearing):
- Anthropic — Building Effective Agents — https://www.anthropic.com/engineering/building-effective-agents
- OpenAI — A Practical Guide to Building Agents — https://cdn.openai.com/business-guides-and-resources/a-practical-guide-to-building-agents.pdf
- LangChain — What Is an Agent? — https://www.langchain.com/blog/what-is-an-agent
- Wang et al. — A Survey on LLM-based Autonomous Agents — https://arxiv.org/abs/2308.11432
- Prompting Guide — LLM Agents — https://www.promptingguide.ai/research/llm-agents

Per-topic primaries (also seed each sibling's first entries):
- prompt-engineering — OpenAI Prompt Engineering guide — https://developers.openai.com/api/docs/guides/prompt-engineering
- tool-design — Anthropic, Writing Tools for AI Agents — https://www.anthropic.com/engineering/writing-tools-for-agents
- agent-architectures — Anthropic, Multi-agent research system — https://www.anthropic.com/engineering/multi-agent-research-system
- evaluation-observability — Hamel Husain, Your AI Product Needs Evals — https://hamel.dev/blog/posts/evals/
- retrieval-rag — Anthropic, Contextual Retrieval — https://www.anthropic.com/engineering/contextual-retrieval
- memory-state — LangMem conceptual guide — https://langchain-ai.github.io/langmem/concepts/conceptual_guide/
- guardrails-safety-security — OWASP Top 10 for LLM Applications — https://owasp.org/www-project-top-10-for-large-language-model-applications/
- cost-latency — Anthropic, Prompt Caching — https://claude.com/blog/prompt-caching
- agent-runtime / harness — OpenAI, Harness engineering (Codex) — https://openai.com/index/harness-engineering/ · LangChain, The Anatomy of an Agent Harness — https://www.langchain.com/blog/the-anatomy-of-an-agent-harness · Martin Fowler, Harness engineering for coding agent users — https://martinfowler.com/articles/harness-engineering.html · METR (eval-harness lineage)

Loop vocabulary (sources, not a sibling):
- LangChain — The Art of Loop Engineering — https://www.langchain.com/blog/the-art-of-loop-engineering
- swyx / Latent.Space — Loopcraft — https://www.latent.space/p/ainews-loopcraft-the-art-of-stacking
- Oracle — What Is the AI Agent Loop — https://blogs.oracle.com/developers/what-is-the-ai-agent-loop

Standard: agentskills.io — SKILL.md spec, Claude + Codex — https://agentskills.io

## Provenance
Family validated by a holistic SOTA pass (2026-06-19). harness/loop terms verified by a 2-worker discovery pass (2026-06-19) using a WebSearch fallback (mgrep web quota exhausted). Caveat: harness/loop sourcing skews vendor/influencer, and loop-engineering was ~2 weeks old at capture — treat as live vocabulary, not settled canon.
