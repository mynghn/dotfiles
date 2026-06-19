# Context Engineering Knowledge Base — Index

Distilled context-engineering concepts, one self-contained entry per file under
`knowledge/`. Read this index first, then load only the entries matching the
query — not the whole corpus.

Each line: `- [<concept-slug>](knowledge/<concept-slug>.md) — <one-line description>`

## Concepts

<!-- one line per concept; appended by capture/refresh via scripts/ce-kb -->

- [attention-sinks](knowledge/attention-sinks.md) — Load when the first few tokens dominate attention scores, when a sliding window / prefix truncation breaks a long-context model or makes perplexity explode, or when designing KV-cache eviction that must preserve the prompt start.
- [compaction-timing](knowledge/compaction-timing.md) — Load when deciding WHEN to compact or clear context — what token/percent threshold, whether to wait, whether a bigger window (e.g. 1M) means compacting later. Trigger on task boundaries + observed degradation, with a ~70-80%-used capacity backstop; a larger window moves the backstop, not the quality-optimal point.
- [compaction-vs-eviction](knowledge/compaction-vs-eviction.md) — Deciding how to free context budget: compaction (summarize-and-reinitialize) vs. eviction (drop old tokens); hitting window limits, lossy history truncation, what the agent forgot after compacting.
- [context-as-working-set](knowledge/context-as-working-set.md) — Load when deciding what an agent keeps, drops, stores, or splits in its context window — treating context as a finite "attention budget" to curate, not a free buffer to fill.
- [context-isolation](knowledge/context-isolation.md) — Load when one agent's context is overflowing with parallel sub-tasks, or when deciding whether to spawn sub-agents / split work into separate context windows and condense results before returning to the parent.
- [context-rot](knowledge/context-rot.md) — Load when accuracy drops as the prompt gets longer even on simple tasks, or when "more context made it worse" / long-context reliability is in question.
- [distractor-sensitivity](knowledge/distractor-sensitivity.md) — Load when retrieval accuracy drops even though the answer is present in the window; when topically-related-but-wrong content sits near the target; when padding prompts with "might-be-useful" RAG chunks or long context seems to hurt rather than help — the noise axis of context degradation.
- [effective-vs-advertised-context](knowledge/effective-vs-advertised-context.md) — Load when a model passes needle-in-haystack but degrades on real long-context tasks (multi-hop, aggregation), or when deciding how much of an advertised window (32K/128K/1M) to actually fill.
- [explore-then-compact-handoff](knowledge/explore-then-compact-handoff.md) — Load when a step needs wide, token-heavy reading (research, broad file/web scan) but only a narrow conclusion matters downstream: how much an explorer/researcher sub-agent should return to the parent, and why its raw search hits and dead ends must stay out of the main window. Breadth-first reading is the trigger (vs. the general isolate primitive in context-isolation, and not tight sequential work).
- [jit-loading](knowledge/jit-loading.md) — Deciding whether to dump full files/docs into context upfront vs. keep references and fetch on demand; context bloated by preloaded data the agent may not need; choosing between eager retrieval and runtime loading.
- [literal-vs-latent-matching](knowledge/literal-vs-latent-matching.md) — Load when retrieval finds a fact only if the query reuses the source's exact wording, but fails on paraphrases or semantic implications with no shared keywords; or when long-context recall collapses specifically for inference-based (latent) lookups rather than literal keyword matches.
- [lost-in-the-middle](knowledge/lost-in-the-middle.md) — Recall is strong for facts at the top or bottom of a long prompt but weak for facts buried in the middle; or deciding where in the window to place critical instructions and the most relevant retrieved documents.
- [prefix-cache-economics](knowledge/prefix-cache-economics.md) — prompt/context ordering for cost and latency; what to put first in a prompt; KV/prefix cache reuse; a small edit unexpectedly spiking token cost or time-to-first-token; order stable-to-volatile
- [structured-note-taking](knowledge/structured-note-taking.md) — Load for persisting plans/state/progress to durable storage outside the context window so it survives compaction, summarization, or context resets on long-horizon tasks; the write-side complement of JIT loading. Covers NOTES.md / to-do files, scratchpads vs. cross-session memories, agentic memory.
- [three-axes-of-context-degradation](knowledge/three-axes-of-context-degradation.md) — Map of long-context failure modes by axis (position, length, noise); use to route a symptom — where a fact sits, how long the input is, or how much irrelevant content surrounds it — to the matching degradation phenomenon and fix.
