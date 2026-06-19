# Tool Design Knowledge Base — Index

Distilled tool-design practices, one self-contained entry per file under
`knowledge/`. Read this index first, then load only the entries matching the
query — not the whole corpus.

Each line: `- [<practice-slug>](knowledge/<practice-slug>.md) — <one-line description>`

## Practices

<!-- one line per practice; appended by capture/refresh via scripts/td-kb -->

- [high-signal-returns](knowledge/high-signal-returns.md) — Use when designing what a tool hands back to the agent — choosing which fields to return, surfacing semantic names over opaque IDs, returning act-on-able data instead of raw API dumps, or fixing agents that hallucinate IDs or stall on noisy tool output.
- [input-schema-design](knowledge/input-schema-design.md) — Use when designing or reviewing a tool's input parameters — naming, types, required vs optional, enums vs free-text, defaults, constraints, formats — to make invalid calls hard or impossible for the agent to represent.
- [structured-output-shaping](knowledge/structured-output-shaping.md) — Use when deciding whether a tool's return (or a model's final answer) should be constrained by an enforced JSON Schema vs left free, choosing strict mode / response_format / json_schema / MCP outputSchema, and designing a schema for reliable machine parsing.
- [token-efficient-returns](knowledge/token-efficient-returns.md) — Use when a tool can return large or verbose results and you're deciding how to bound, paginate, truncate, filter, or summarize the return — or to add concise/detailed response modes or return references instead of full payloads — so each returned token earns its context cost.
- [tool-description-writing](knowledge/tool-description-writing.md) — Use when writing or reviewing the description/docstring of a tool an agent calls — stating its purpose, an explicit "use when", per-parameter meaning, in-description examples and usage limits, or disambiguating it from a near-twin tool.
- [tool-error-design](knowledge/tool-error-design.md) — Use when designing what a tool returns on failure — validation errors, API failures, empty/over-limit results — so the agent can self-correct: deciding error wording, suggesting the fix, surfacing valid inputs, or choosing between raising vs returning the error.
- [tool-evaluation](knowledge/tool-evaluation.md) — Use when deciding whether a tool's description/schema is good enough, debugging why an agent picks the wrong tool or fills arguments wrong, or setting up a measurement loop to iterate tool contracts on observed failures instead of intuition.
- [tool-granularity-and-consolidation](knowledge/tool-granularity-and-consolidation.md) — Use when deciding how coarse or fine a tool should be — whether to expose raw API endpoints as thin wrappers or fold multi-step sequences into one workflow tool, and how to scope a tool around the agent's task rather than the API surface.
- [tool-naming-and-namespacing](knowledge/tool-naming-and-namespacing.md) — Use when naming a tool or function, choosing verbs/prefixes, grouping tools by service or resource, or fixing wrong-tool selection and name collisions in a crowded or multi-server (MCP) tool set.
- [tool-set-size-and-selection](knowledge/tool-set-size-and-selection.md) — Use when deciding how many tools to expose at once, when an agent picks the wrong tool or thrashes between near-identical ones, or when weighing gating/grouping tools by context vs splitting into multiple agents.
