# 0002-agents-md-layering-contract — Spec

## Behavior

### B-1: over-budget-apply-fails
When the owned-block source exceeds the size budget (C-1), applying the dotfiles fails for the shared instruction file — non-zero exit, no partial write — and the failure message names the measured size and the budget.

### B-2: apply-renders-owned-set
When the owned-block source is within budget, an apply renders the shared file's owned half as exactly the defined blocks in their defined order — including on a machine with no prior shared file.

### B-3: retired-blocks-leave-the-file
When a block is retired from the owned set (this round: the Korean-output block and the three blocks absorbed into surviving ones), the next apply removes its span from the shared file instead of leaving it behind as an unrecognized span.

## Constraint

### C-1: owned-size-budget
The combined owned-block source text, tag lines included, totals at most 2,000 characters (≈ 500 tokens) — the standing ceiling the apply gate enforces.

### C-2: single-prose-home
Each retained invariant has exactly one prose home among the owned blocks; the formerly duplicated rules — ask-before-acting, primary-sources, working-set discipline, and the branch-base definition — each appear in exactly one block.

### C-3: foreign-span-pass-through
Spans that were never part of the owned set — upstream-recognized or unknown — are byte-identical before and after every apply.

### C-4: hard-lines-terminal
After every apply, the hard-lines block renders as the shared file's final block, regardless of spans other writers added between applies.

## Non-goals

- The content, count, or naming of upstream-owned spans (four anchors today, a checkpoint block after the upstream round) — this contract guarantees only their safe passage (C-3) and their placement relative to the terminal block (C-4).
