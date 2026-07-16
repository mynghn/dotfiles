# 0001-local-recall-search — Spec

## Behavior

### B-1: prose-recall-lookup

When an agent queries the prose corpora — the knowledge vault, agent skill instructions, managed docs — with a natural-language description of content, the matching entries are returned, ranked by relevance.
This holds even with zero keyword overlap between query and target — the condition the Requirements success signal tests one-shot.

### B-2: code-recall-lookup

When an agent describes a behavior or concept over a code tree — including a repository seen for the first time — the code locations realizing it are returned.

### B-3: query-type-routing

Given a query whose target token is already known, the single entry point directs the agent to exact-match search; given a meaning-only query, it directs the agent to recall search.
The agent consults one entry point and never weighs search tools per query.

### B-4: first-query-readiness

On a machine provisioned by the standard dotfiles setup, the very first recall query succeeds — under C-1's no-network condition, with nothing fetched or built at query time.

### B-5: unindexed-corpus-surfaced

When a query targets content not yet indexed, the response states that explicitly and names the remedy.
It is never a bare empty result indistinguishable from "no matches".

## Constraint

### C-1: zero-network-at-query-time

Recall operations — querying, and any index maintenance a query triggers — function identically with networking disabled.

### C-2: staleness-surfaced

A result set is computed from corpus content as it stands at query time, or the response carries an explicit staleness indication.
One-shot check: mutate a file, query, observe either fresh results or the indication.

### C-3: uniform-across-machines

The capability behaves identically on every machine the standard dotfiles setup reaches.
No machine-specific configuration, paths, or manual steps distinguish one machine's behavior from another's.

### C-4: actionable-result-locations

Every result identifies its file and the span within it, precisely enough for the agent to open the match directly.
