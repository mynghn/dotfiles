# 0002-agents-md-layering-contract — Design Rationale

## D-1: five-block-owned-set

Forces: every owned char is paid in every session of every agent reading the shared file; the paired activation study showed the heavy blocks bought no skill activation (baseline 0.09 with them loaded), so mass has measured cost and no measured benefit.

Alternatives considered in this round's grill (recorded in the upstream handoff, `~/.local/share/metacognition/docs/features/0008-agents-md-layering-contract/handoff.md`):

- Per-skill routing table (one line per skill) — rejected.
  Linear regrowth with the skill count; re-describing skills is the mechanism family that measured *harmful* (C3: 0.09 → 0.00).
- Slimming all nine blocks in place — rejected.
  It keeps the duplicated homes (ask-before-acting in two blocks, sourcing rules in two) that the dedup exists to remove.
- Keeping `ko_output_quality` as a one-liner — rejected as default.
  The skill's own description already carries the full trigger enumeration and the from-the-first-sentence timing.
  Korean output is a surface-cued moment (the cue is in the task itself), not the no-cue class that needs a standing anchor.
  Accepted as residual risk in Requirements Non-goals.
  Invalidation trigger: observed ko-quality misses on cued Korean output → reopen with a one-line block or a checkpoint category mention.

Tag names are kept (no renames) so diffs stay reviewable and any external reference to a surviving tag stays valid.
Consolidation appears as content change plus retirement, not renames.

Envelope choice (600/300/450/400/250) reflects each block's residual fact load after dedup, summing to 2,000 with tag lines.
The envelopes are deliberately tight so the budget means something from day one.

## D-2: apply-time-size-gate

Forces: the regrowth mechanism is "any future well-meaning edit"; the gate must sit where every such edit inevitably passes.

- Chosen: inside `modify_AGENTS.md` at apply time.
  The script is the sole writer of the owned half, already validates (missing-block `SystemExit`), and a modify-script failure aborts the target write — giving B-1's no-partial-write for free.
- Alternative — pre-commit hook (the repo already ships `chezmoi-guard.sh`-style hooks): rejected as the primary gate.
  Commits can bypass hooks (`--no-verify`, other machines, direct pushes), and the harm happens at *apply*, not commit.
  A hook may be added later as advisory UX; it would duplicate, not replace, the gate.
- Character count over token count: deterministic, dependency-free, and stable across tokenizer versions; ≈ 500 tokens at the ~4 chars/token rate the audit used.
  Invalidation trigger: if a future tokenizer diverges wildly from ~4 chars/token for this text, revisit the constant, not the mechanism.

## D-3: retired-tag-registry (retired)

> Retired per `Understanding#Delta-2-retired-tags-need-no-registry` — the "one-time manual deletion" alternative rejected below won: the rejection's resurrection scenario ("any other machine applying the dotfiles… resurrects the span") was wrong for fresh applies (empty stdin carries no spans) and for hand-deleted spans (nothing re-adds them); only a backup restore resurrects, accepted at this operator's device count.

Forces: the merge preserves unknown tags by design (that is what protects upstream spans), so a retired owned tag is indistinguishable from a foreign span unless the script is told otherwise — confirmed behavior, `research.md` → apply-merge-behavior.

- Chosen: a declarative `RETIRED` set the merge drops.
  Idempotent across machines and stale live copies, and a self-documenting history of what was retired.
  Upstream tags do NOT enter the set — the installer removes its own spans; ours covers only formerly-chezmoi-owned tags.
- Alternative — one-time manual deletion from the live file: rejected.
  Any other machine applying the dotfiles, or any restore from backup, resurrects the span forever (the merge would re-preserve it as unknown).
- Invalidation trigger: if the upstream framework ever standardizes a cross-writer retirement protocol for the shared file, fold this set into it.

## D-4: terminal-block-placement (retired)

> Retired per `Understanding#Delta-3-recency-misattributed-to-file-tail` — the force itself dissolved: C-4's premise ("final block, where session recall is strongest") confused position-in-file with position-in-window.
> Superseded by D-5.

Forces: `Spec#C-4-hard-lines-terminal` must hold against spans this script cannot know — the upstream round will upsert a checkpoint block under a tag that does not exist yet.

- Chosen: structural guarantee in the emitter — hold the terminal block, place unknowns/extras before it, emit it last.
  It holds for any future tag without coordination.
- Alternative — add the future checkpoint tag to ORDER once known: rejected as the mechanism (requires knowing the name, breaks for the tag after that); ORDER placement remains available as cosmetic refinement for *known* tags.
- Placement-vs-integrity note: C-3 guarantees span *content* byte-exact; position is C-4's to own — moving an unknown span above the terminal block is required behavior, not a pass-through violation.

## D-5: head-lead-emitter

Forces: the sourced grounding (`context-engineering/knowledge/lost-in-the-middle.md`, Liu et al., TACL 2023) places the recall hot spots at the edges of the *window*; `~/AGENTS.md` is preloaded, so the whole file sits in the primacy zone and its tail never borders the live conversation — last-in-file buys nothing, while the file's head is the one hot spot it can reach.

- Chosen: reshape `ORDER` (frame first, hard lines second) and delete the terminal machinery; the head is structurally safe because every non-`ORDER` path appends, so the guarantee costs zero code.
- Alternative — keep the terminal mechanism, invert it (emit `change_discipline` first by held-back rule): rejected; a rule-based head guard would re-create the constant/guard/coupling for a position the plain forward pass already guarantees.
- Alternative — hard lines in slot 1, frame second: rejected; a frame conditions only what follows it, the hard lines precede nothing, and across ~2,000 chars slot 1 vs slot 2 is marginal — reading function breaks the tie, not recall position.
- Evidence-standard note: D-4 was adopted on mechanism-plausibility while D-1 demanded measured evidence; this decision re-aligns the round to one standard by resting on the sourced entry and on mechanism-cost, with the recall-delta claim explicitly not relied on (Delta-3's caveats).
- Invalidation trigger: if the assembled system prompt is ever shown to place `AGENTS.md` deep enough that its tail borders the live conversation, or an activation study measures a real terminal-position benefit, reopen placement.
