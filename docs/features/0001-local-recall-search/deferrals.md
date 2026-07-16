# 0001-local-recall-search — Deferrals

## Defer-1: agent-interface-surface (resolved -> Design#D-4-interface-cli-only)

- **Owning stage**: Design.
- **Question**: how do agents invoke the recall layer — command-line invocation only, or additionally a resident server integration (MCP) for the heavy general-purpose engine?
  Surfaced during framing because the two candidate engines differ sharply in weight: the general-purpose engine loads ~2 GB of local models per cold start, which a resident server would keep warm.
- **Forces**: always-on server tool schemas tax every agent request's context window (eager loading), while command-line invocation is pay-on-use but re-pays model cold-start latency per query.
  The portability guarantee favors fewer moving parts.
  The code-side engine is light enough that a server buys it nothing.
- **Option seen (not chosen)**: command-line-first for both engines, with a resident-server integration for the general-purpose engine added later only if cold-start latency proves painful in practice.
