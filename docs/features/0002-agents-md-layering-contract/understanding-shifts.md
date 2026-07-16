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
