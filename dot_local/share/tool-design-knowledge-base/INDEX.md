# Tool Design Knowledge Base — Index

Distilled tool-design practices, one self-contained entry per file under
`knowledge/`. Read this index first, then load only the entries matching the
query — not the whole corpus.

Each line: `- [<practice-slug>](knowledge/<practice-slug>.md) — <one-line description>`

## Practices

<!-- one line per practice; appended by capture/refresh via scripts/td-kb -->

- [structured-output-shaping](knowledge/structured-output-shaping.md) — Use when deciding whether a tool's return (or a model's final answer) should be constrained by an enforced JSON Schema vs left free, choosing strict mode / response_format / json_schema / MCP outputSchema, and designing a schema for reliable machine parsing.
- [tool-description-writing](knowledge/tool-description-writing.md) — Use when writing or reviewing the description/docstring of a tool an agent calls — stating its purpose, an explicit "use when", per-parameter meaning, in-description examples and usage limits, or disambiguating it from a near-twin tool.
- [tool-naming-and-namespacing](knowledge/tool-naming-and-namespacing.md) — Use when naming a tool or function, choosing verbs/prefixes, grouping tools by service or resource, or fixing wrong-tool selection and name collisions in a crowded or multi-server (MCP) tool set.
