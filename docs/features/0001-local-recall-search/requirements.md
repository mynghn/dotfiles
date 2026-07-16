# 0001-local-recall-search — Coding agents have no meaning-based search over local files

## Problem

The coding agents used daily can find local content only by exact text match — when the searcher does not know the exact words, there is no recall path at all.
A meaning-based search capability existed but was removed: it depended on a hosted service, so every query made a network call.
That dependency failed inside network-restricted agent sandboxes and sent file content and queries to a third party.
Since its removal the gap is felt most in the prose knowledge corpora — the knowledge vault, agent skill instructions, and managed docs — where the words in a query rarely match the words in the target.
It also appears when an agent explores an unfamiliar codebase and knows the behavior it seeks but not the names the code uses.

## Outcome

Agents gain a fully-offline recall layer that complements exact-match search rather than replacing it.
Exact search stays the precision instrument for known tokens; the recall layer answers the queries exact search structurally cannot.

User stories:

- **Meaning-based lookup** — an agent finds the right knowledge-base entry, skill instruction, or doc from a natural-language description, without knowing its exact wording.
- **Unfamiliar-code exploration** — an agent locates code by describing its behavior or concept, in a repository it has not seen before.
- **Intent-guided routing** — a single entry point steers the agent to exact search when the token is known and to recall search when it is not, so the agent does not weigh tools per query.
- **Works in sandboxes from the first query** — searches succeed in network-restricted agent sandboxes, including the very first query on a machine; everything the capability needs is provisioned at machine-setup time.

Success signal: a small held-out set of natural-language queries over the named corpora returns the right target, offline, with no keyword overlap between query and target.

## Guarantee

- **No hosted dependency at query time** — a search never requires a network call, account, or third-party service.
  The previous capability died exactly this way, and leaked content besides.
- **Never silently stale** — results reflect current file contents, or their staleness is surfaced to the searcher.
  A plausible-but-outdated result is worse than an honest miss.
- **Portable out of the box** — the standard dotfiles setup alone yields the full capability on any machine it reaches.
  No machine-specific manual steps, and no dependence on pre-existing local environment beyond that setup; the experience is identical across machines.

## Non-goals

- Replacing exact-match search — it remains the default for known tokens; meaning-first routing for all searches was considered and rejected.
- A formal evaluation harness for search quality — the held-out query set is the whole measurement.
