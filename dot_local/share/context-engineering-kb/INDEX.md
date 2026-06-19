# Context Engineering Knowledge Base — Index

Distilled context-engineering concepts, one self-contained entry per file under
`knowledge/`. Read this index first, then load only the entries matching the
query — not the whole corpus.

Each line: `- [<concept-slug>](knowledge/<concept-slug>.md) — <one-line description>`

## Concepts

<!-- one line per concept; appended by capture/refresh via scripts/ce-kb -->

- [attention-sinks](knowledge/attention-sinks.md) — Load when the first few tokens dominate attention scores, when a sliding window / prefix truncation breaks a long-context model or makes perplexity explode, or when designing KV-cache eviction that must preserve the prompt start.
- [lost-in-the-middle](knowledge/lost-in-the-middle.md) — Recall is strong for facts at the top or bottom of a long prompt but weak for facts buried in the middle; or deciding where in the window to place critical instructions and the most relevant retrieved documents.
