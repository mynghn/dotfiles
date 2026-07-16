# 0001-local-recall-search — Deferrals

## Defer-1: agent-interface-surface (resolved -> Design#D-4-interface-cli-only)

- **Owning stage**: Design.
- **Question**: how do agents invoke the recall layer — command-line invocation only, or additionally a resident server integration (MCP) for the heavy general-purpose engine?
  Surfaced during framing because the two candidate engines differ sharply in weight: the general-purpose engine loads ~2 GB of local models per cold start, which a resident server would keep warm.
- **Forces**: always-on server tool schemas tax every agent request's context window (eager loading), while command-line invocation is pay-on-use but re-pays model cold-start latency per query.
  The portability guarantee favors fewer moving parts.
  The code-side engine is light enough that a server buys it nothing.
- **Option seen (not chosen)**: command-line-first for both engines, with a resident-server integration for the general-purpose engine added later only if cold-start latency proves painful in practice.

## Defer-2: corpus-provenance-ownership (resolved -> Design#D-6-index-lifecycle-refresh-on-invoke)

- **Owning stage**: Design.
- **Resolution**: index the corpora as found — the dotfiles provision the recall *layer* everywhere and register whichever of its named corpora are present, rather than taking ownership of corpora that live in other repositories.
  D-6 now states each collection's provenance and what a fresh machine actually gets, so the conditionality is designed and documented rather than discovered.
  Revisit when a second real machine makes the vault collection's absence cost something concrete; the option below is the change to make then.
- **Question**: should these dotfiles *own* the corpora they search — cloning the knowledge vault themselves, so its collection is present on every machine the setup reaches — or continue to index whichever corpora happen to be there?
  Surfaced by fresh-machine verification (`Understanding#Delta-6-the-layer-is-portable-the-corpora-are-not`): the layer provisions completely and queries offline on a clean machine, but one of its three corpora is a separate repository these dotfiles do not manage, and a second arrives only partially.
- **Forces**: the portability guarantee reads naturally as covering the whole capability, and a machine whose vault collection is simply missing gets less than the one it was provisioned from — an asymmetry the guarantee exists to prevent.
  Against that: the vault is independently versioned content with its own lifecycle, and a dotfiles repo that clones other repositories takes on their staleness, their failure modes, and a network dependency at *setup* time.
  The cost of leaving it is bounded and honest rather than silent — provisioning logs the absent corpus and a query against it exits non-zero with the register-and-index remedy, so the gap is reported to whoever hits it.
- **Option seen (not chosen)**: declare the vault as a chezmoi-managed external clone, making its collection portable at the price of the dotfiles owning another repository's lifecycle.
  Not chosen now because nothing yet shows the gap costing anything on a real second machine, and the surfaced-gap path already tells a user exactly what to run.
