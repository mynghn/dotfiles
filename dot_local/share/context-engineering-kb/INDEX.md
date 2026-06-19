# Context Engineering Knowledge Base — Index

Distilled context-engineering concepts, one self-contained entry per file under
`knowledge/`. Read this index first, then load only the entries matching the
query — not the whole corpus.

Each line: `- [<concept-slug>](knowledge/<concept-slug>.md) — <one-line description>`

## Concepts

<!-- one line per concept; appended by capture/refresh via scripts/ce-kb -->

- [attention-sinks](knowledge/attention-sinks.md) — Load when the first few tokens dominate attention scores, when a sliding window / prefix truncation breaks a long-context model or makes perplexity explode, or when designing KV-cache eviction that must preserve the prompt start.
- [context-rot](knowledge/context-rot.md) — Load when accuracy drops as the prompt gets longer even on simple tasks, or when "more context made it worse" / long-context reliability is in question.
- [distractor-sensitivity](knowledge/distractor-sensitivity.md) — Load when retrieval accuracy drops even though the answer is present in the window; when topically-related-but-wrong content sits near the target; when padding prompts with "might-be-useful" RAG chunks or long context seems to hurt rather than help — the noise axis of context degradation.
- [effective-vs-advertised-context](knowledge/effective-vs-advertised-context.md) — Load when a model passes needle-in-haystack but degrades on real long-context tasks (multi-hop, aggregation), or when deciding how much of an advertised window (32K/128K/1M) to actually fill.
- [literal-vs-latent-matching](knowledge/literal-vs-latent-matching.md) — Load when retrieval finds a fact only if the query reuses the source's exact wording, but fails on paraphrases or semantic implications with no shared keywords; or when long-context recall collapses specifically for inference-based (latent) lookups rather than literal keyword matches.
- [lost-in-the-middle](knowledge/lost-in-the-middle.md) — Recall is strong for facts at the top or bottom of a long prompt but weak for facts buried in the middle; or deciding where in the window to place critical instructions and the most relevant retrieved documents.
- [three-axes-of-context-degradation](knowledge/three-axes-of-context-degradation.md) — Map of long-context failure modes by axis (position, length, noise); use to route a symptom — where a fact sits, how long the input is, or how much irrelevant content surrounds it — to the matching degradation phenomenon and fix.
