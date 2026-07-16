# 0001-local-recall-search — Design Rationale

## D-1: prose-recall-engine-qmd

The prose engine carries the feature's primary demonstrated pain (vocabulary drift in the vault, skills, docs), so maturity and retrieval quality outweighed footprint.
qmd is the only fully-local candidate that is simultaneously past-1.0, mass-adopted (~27.9k★, v2.5.3, 582 commits), and running the strongest local pipeline (BM25 + vector + query expansion + LLM rerank).
Alternatives weighed (facts in `research.md`): cocoindex-code — active but v0.2.x with a cloud-defaulting slim install (`[full]` footgun) and ~1 GB torch; grepai — requires a resident Ollama daemon (more moving parts, tensions portability); chunkhound — semantic search inert without a self-configured provider.
Accepted costs: bun/node runtime + ~2 GB models, paid once at provision time per the install-time decision; code support secondary (5 languages) — irrelevant here since D-2 owns code.
Invalidation: if qmd's code-side chunking matures to cover `Spec#B-2-code-recall-lookup` well, revisit collapsing D-2 into a single-engine design.

## D-2: code-recall-engine-ck

ck is the only code-first candidate whose embeddings run in-process with no daemon, no account, and no cloud fallback to misconfigure — the README states no code or queries leave the machine — while keeping grep-shaped ergonomics agents already know.
Alternatives weighed (facts in `research.md`): codanna — fully local but pre-1.0 with breaking re-index most releases and a solo maintainer, and MCP-first (D-4 chose CLI-only); probe — robust but embedding-free, so zero-keyword-overlap recall (the B-1/B-2 hard case) is out of reach, and its NL layer wants a cloud key; cocoindex-code — see D-1 costs.
Accepted risks: pre-1.0 (v0.7.x) and cargo-only install today (drives the rust toolchain requirement in D-5).
Invalidation: if ck stalls or a breaking change lands, codanna is the next candidate; if the code path sees no real use by the time a maintenance burden appears, demote it per the original asymmetric option.

## D-3: routing-skill-local-search

The skill's content choices are grounded in the consulted knowledge bases, correcting the predecessor's documented pathologies.
Description-as-trigger: the predecessor's "substantially better… always use instead of anything else" is the over-forceful claim that over-triggers modern models; a load-when description scoped to "meaning-only queries" triggers at the right moment and cedes known-token lookups to rg.
Positive routing: the predecessor's "Do not use grep" is a prohibition that primes the banned tool and names no target; the routing table states what to do in each regime, each rule carrying its why (models generalize from reasons).
Few-shot: 4 identically-formatted Do/Don't examples covering the routing edges, per the 3–5 relevant-diverse-consistent guidance.
Single skill over two: one entry point owns the routing decision (`Spec#B-3-query-type-routing`); two skills would each claim "search" and force the agent to weigh tools per query — the exact failure B-3 forbids.

## D-4: interface-cli-only

Forces (from `Deferrals#Defer-1-agent-interface-surface`): an MCP server's tool schemas load into every agent request — a standing context tax for an occasional capability — while CLI-in-skill is pay-on-use (description line only until triggered); a resident qmd server would hold ~2 GB warm and need per-agent config kept in sync; a second entry surface would compete with the skill's routing.
Chosen: CLI-only; the skill is the sole entry point, and both engines are invoked as shell commands.
The parked option (CLI-first, MCP later) was re-derived, not replayed: inspection added the facts that Claude-side MCP is currently unmanaged in this repo (new machinery to build) and the codex managed-MCP section exists but is append-style — wiring both adds real surface for a latency win not yet shown to matter.
Invalidation trigger: recall queries become frequent and measured per-query latency is painful (≳10 s felt drag on the qmd path) → register qmd's MCP server (`query`/`get`/`multi_get`/`status`) in both agents and narrow the skill to routing + fallback.

## D-5: provisioning-run-after-brew

The repo's convention (assume runtimes, skip gracefully — `run_after_npx-skills.sh`) was weighed against the portability guarantee and lost, by explicit planner decision: a silent skip on a fresh machine violates `Spec#C-3-uniform-across-machines` and `Spec#B-4-first-query-readiness`, exactly the guarantee this feature exists to give.
Chosen: install-missing-via-brew with a loud named-remedy failure only when brew itself is absent — the one prerequisite the setup treats as the platform floor.
Version pinning is part of the same decision: unpinned `bun install -g` / `cargo install` would drift machines apart over time, eroding C-3 silently; pins live in the script and are bumped deliberately.
Model pre-pull at provision time is what moves the network moment out of the query lane entirely (`Spec#C-1-zero-network-at-query-time`, `Spec#B-4-first-query-readiness`) — the predecessor's fatal flaw was precisely a query-lane network dependency.

## D-6: index-lifecycle-refresh-on-invoke

Alternatives weighed for keeping results fresh (`Spec#C-2-staleness-surfaced`):
a resident watcher (launchd service / `qmd watch`-style daemon) keeps indexes hot but adds a per-machine moving part that can silently die — a stale index with no surfaced staleness is the exact C-2 violation, plus portability cost;
scheduled reindex (cron) has the same silent-death mode with staler windows;
refresh-on-invoke pays a small incremental-update cost per query but is structurally incapable of serving stale results silently — the update either runs (fresh branch) or its failure/slowness is visible in the invocation itself and the skill surfaces it (stale-indication branch).
Chosen: refresh-on-invoke, with the explicit-staleness prefix as the fallback branch.
Invalidation: if incremental updates prove slow enough to drag every query (large corpora growth), revisit the watcher with a health check that satisfies C-2's surfacing requirement.
