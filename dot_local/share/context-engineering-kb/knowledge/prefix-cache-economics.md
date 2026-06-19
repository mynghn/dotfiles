---
name: prefix-cache-economics
description: prompt/context ordering for cost and latency; what to put first in a prompt; KV/prefix cache reuse; a small edit unexpectedly spiking token cost or time-to-first-token; order stable-to-volatile
last_refreshed: 2026-06-19
sources:
  - Prompt Caching — Anthropic — https://claude.com/blog/prompt-caching
---

**Effect.** A repeated prompt prefix can be served from the KV cache instead of recomputed. On Anthropic's API, cache reads cost ~10% of the base input price (a ~90% discount) and cut latency substantially — e.g. chatting with a cached 100K-token book drops time-to-first-token from 11.5s to 2.4s (~80% faster). The catch: the first write to cache costs ~25% more than base input, so caching pays off only when a prefix is reused.

**Mechanism.** The cache matches on an exact token prefix. Any edit invalidates the cache from the changed token forward — everything after a modified token is recomputed and re-written. So the cost of a change scales with how early it sits in the prompt.

**When to use.** Order content stable-to-volatile: put durable, reused material first (system prompt, tool definitions, the curated knowledge index) and volatile material last (the live query, fresh retrievals, scratch notes). Avoid editing or reordering the stable prefix between turns.

**Takeaway for a self-managing agent.** Treat prompt layout as a cost surface. A stable, append-mostly prefix keeps reused tokens cache-warm; mutating early content silently forfeits the ~90% read discount on everything downstream.

Related: [[context-as-working-set]], [[jit-loading]]
