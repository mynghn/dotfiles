# 0002-agents-md-layering-contract — Research

## owned-block-size-baseline

Measured on the live shared file, 2026-07-16 (tags included):

| block | chars |
|---|---|
| operating_frame | 792 |
| context_discipline | 193 |
| ko_output_quality | 835 |
| document_brevity | 314 |
| implementation | 603 |
| plan_style | 236 |
| code_investigation | 444 |
| research_before_planning | 338 |
| change_discipline | 312 |
| **total** | **4,067** (~1,016 tokens) |

Whole file: 8,879 chars (~2,200 tokens); owned half ≈ 46% of it.

## apply-merge-behavior

From the current apply-time merge logic (read 2026-07-16):

- Owned blocks are emitted from the dotfiles source; known non-owned tags are emitted from the live file at their position in the fixed order tuple.
- First occurrence of any tag wins; duplicate non-owned tags are appended at the end as extras.
- A tag present in the live file but absent from both the owned set and the order tuple is re-emitted as an unknown span — so a retired owned block would persist in the file indefinitely without an explicit removal mechanism (basis for Spec B-3).
- Unknown tags are appended after all order-tuple output — a new upstream tag (e.g. a future checkpoint block) would render after the final owned block absent counter-handling (basis for Spec C-4).
- The merge writes to stdout consumed by the dotfiles manager; a raised error aborts the target update (no partial write — basis for Spec B-1).

## activation-evidence-pointer

Upstream measurement (metacognition worktree `0001-self-initiated-skill-activation`, `configs/VERDICT.md`):

- C0 baseline: no-cue handoff self-use 0.09 with the heavy always-loaded blocks present.
- C1 generic checkpoint: promoted at 0.39/0.58 across two runs, zero false-fires.
- C3 trigger-first descriptions: held at 0.00 — measured evidence against description-reordering as an activation fix.
- Model of record for those runs: Opus 4.8.
