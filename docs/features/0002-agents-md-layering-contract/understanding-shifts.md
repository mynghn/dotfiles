# 0002-agents-md-layering-contract — Understanding Shifts

## Delta-1: d-1-envelopes-were-a-pre-prose-estimate

D-1's per-block character envelopes were allocated before any consolidated prose existed, and authoring proved the `code_investigation` split infeasible without dropping mapped facts.

What moved: the envelope column was written as a design-time estimate of each block's residual fact load, and read as if it were a measured allocation.
Authoring the blocks (M1) measured the real load — `code_investigation` needs 411 chars to carry the branch-base definition, the investigate-from-base rule, the defensible-read rule with its trace list, the verify-implementations rule, and the absorbed primary-sources rule.
Three independent review lenses and the synthesizing author converged on the same finding: 400 forces a fact drop, not a wording tightening.
Holding 400 already cost the external primary-source enumeration (official docs, SOTA, engineering guides), and the block still overran once four review-restored facts landed.

Why it is a Design correction, not a task-level trim: the gate-enforced contract is the 2,000-char total (`Spec#C-1-owned-size-budget`), and the authored set measures 1,988 — the contract holds with 12 chars spare.
Only the internal per-block split is wrong.
Trimming `code_investigation` to 400 would shave meaning to satisfy an estimate, degrading standing instructions that condition every session.

A second, smaller imprecision in the same table: `document_brevity`'s carries-column reads "current content as-is" while its envelope (300) is below the block's current size (314).
The four facts do stay; only the wording tightens, so the phrase overstates it.

Scope of impact: `Design#D-1-five-block-owned-set` (envelope column + the `document_brevity` carries phrase).
`Spec#C-1-owned-size-budget` is unaffected — the 2,000 total is unchanged, and the reallocated envelopes still sum to exactly 2,000.
`Tasks#T:M1` criterion (a) cites the D-1 envelopes by reference, so it follows the corrected table without its own edit.

Resolution: reallocate within the unchanged 2,000 total — `code_investigation` 400 → 415, funded by `document_brevity` 300 → 295 and `change_discipline` 250 → 240; `operating_frame` (600) and `implementation` (450) unchanged, both authored to their cap.

## Delta-2: retired-tags-need-no-registry

Retiring an owned block needs no apply-time registry: a one-time manual deletion from each machine's live file is the whole mechanism, and the merge carries no `RETIRED` set.

What it kills: D-3's resurrection premise — that without a mechanical drop, a retired span "persists forever" on any machine or restore.
Overstated on both counts: a fresh apply cannot resurrect a span (no live file → empty stdin → no live spans), and a hand-deleted span stays deleted because its only source was the live file itself — nothing re-adds it.
The one true resurrection path is a file-level backup restore predating the deletion, accepted as residual risk at this operator's device count.
Against that residual risk, the registry's cost is structural: it accretes forever (every future retirement appends a tag that can never be removed), and it adds a merge branch to the sole writer.

Sequencing consequence: the deletion must precede or accompany the first apply of the registry-free script on each machine — applied first, the stale spans survive as unknown tags with a clean `chezmoi diff` (silent).
Owned by `Tasks#T:M4`.

Scope of impact: `Spec#B-3-retired-blocks-leave-the-file`, `Design#D-3-retired-tag-registry`, `Tasks#T:M2`, `Tasks#T:M4`.

## Delta-3: recency-misattributed-to-file-tail

The recency claim behind terminal placement confused position-in-file with position-in-window: lost-in-the-middle's U-curve (vault entry `context-engineering/knowledge/lost-in-the-middle.md`, Liu et al., TACL 2023) is over the whole input window, and `~/AGENTS.md` is preloaded at the window's head — the entire file lives in the primacy zone, while the window's recency zone belongs to the live conversation, which no block of this file ever borders.
Last-in-file therefore buys no recency; the hot spot the file can actually reach is its head.

What it kills: Requirements' "final block, where session recall is strongest" premise, and with it D-4's terminal-placement mechanism (constant + skip guard + special-case append + the `owned[TERMINAL]` KeyError coupling) — machinery defending the slot that matters least.

The head needs no guard at all: every non-ORDER emitter path is an append, so nothing another writer adds can render above `ORDER[0]`.
Resolution: `change_discipline` moves to the second slot — after `operating_frame`, because a frame only conditions what follows it, while the hard lines are self-contained imperatives that need a hot slot but precede nothing; unknown tags and extras append at the tail, now the least-valued position.

Honest caveats, recorded: the exact depth of `AGENTS.md` in the assembled system prompt is unverified, and across a ~2,000-char span the intra-file position effect is weak in either direction — which is why the deciding force is mechanism cost versus a zero-cost structural head, not recall deltas.

Scope of impact: Requirements → Outcome user story "Hard lines keep the edge" (prose, unanchored), `Spec#C-4-hard-lines-terminal`, `Design#D-4-terminal-block-placement`, `Tasks#T:M2`, `Tasks#T:M4`.
