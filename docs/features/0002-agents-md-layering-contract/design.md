# 0002-agents-md-layering-contract — Design

## Architecture

The apply-time merge (the `modify_AGENTS.md` chezmoi modify script) stays the single writer of the shared file's owned half; this round changes its inputs (5 canonical blocks instead of 9), adds a size gate, and leads the file with the frame + hard-lines head.

```
 dotfiles source (modify_AGENTS.md)             live ~/AGENTS.md --(stdin)--+
 +------------------------------+                                          |
 | DOTFILES_AGENTS_BLOCKS       |                                          v
 |   5 owned blocks (D-1)       |                                 parse <tag> spans
 | OWNED / ORDER (D-5)          |                                 live_by_tag / extras
 | BUDGET_CHARS = 2000          |                                          |
 +--------------+---------------+                                          |
                v                                                          |
   size gate (D-2) -- over budget --> SystemExit(measured vs budget)       |
                |                       = apply fails, no write            |
                v                                                          v
   merge: emit ORDER (head: frame, hard lines) | owned <- source | known-foreign <- live
          unknown tags + extras append at the tail (D-5)
                |
                v
   stdout --> chezmoi writes ~/AGENTS.md <--symlink-- ~/.claude/CLAUDE.md, ~/.codex/AGENTS.md
```

### D-1: five-block-owned-set

The owned set collapses 9 → 5 blocks, keeping the existing tag names `operating_frame`, `document_brevity`, `implementation`, `code_investigation`, `change_discipline`.
The fact-to-block mapping below gives each fact its single home (satisfies `Spec#C-2-single-prose-home`).
The size envelopes sum to ≤ 2,000 chars with tag lines (satisfies `Spec#C-1-owned-size-budget`):

| block | ≤ chars | carries (sole home of) |
|---|---|---|
| `operating_frame` | 600 | finite-attention frame; four levers (select / compress / write / isolate); read-widely-retain-narrowly; 3–5-fact working summary + current-step slice (absorbs `context_discipline`) |
| `document_brevity` | 295 | the same four facts it carries today, wording tightened to fit: conclusion-first, stop when it lands, segregate depth, conventions outrank these defaults |
| `implementation` | 450 | plans-as-intent; feature branch off branch base; surface tradeoffs; autonomy through straightforward chunks with pause-at-decision-points (**the** ask-before-acting home); abstract-plans default, numbered lists only when the sequence is obvious (absorbs `plan_style`) |
| `code_investigation` | 415 | **the** branch-base definition (moves in from `operating_frame`); investigate from branch base; read enough to be defensible; verify implementations, not names; **the** primary-sources rule — repo-local: code/tests/docs; external/current: primary docs (absorbs `research_before_planning`) |
| `change_discipline` | 240 | pure hard lines: inspect local changes first; scoped patches; never revert unrelated or user-authored work; verify with the smallest meaningful check — its ask-before-X sentence is removed (that concern's home is `implementation`) |

- `ko_output_quality` retires (see `D-3`); `context_discipline`, `plan_style`, `research_before_planning` are absorbed as mapped above.
- "Why:" lines survive only where the reason changes runtime behavior; provenance-only Whys (entry-slug lists) are dropped.
- Exact wording is authored at implement time against the per-block envelopes; the gate (D-2) is the backstop.
- The envelopes are a design-time allocation, reconciled against the authored prose at implement time (`Understanding#Delta-1-d-1-envelopes-were-a-pre-prose-estimate`); they still sum to exactly 2,000, so the reconciliation moved chars between blocks without touching `Spec#C-1-owned-size-budget`.
- WHY: grill decisions D1/D3 of this round's framing, grounded in the measured activation evidence — see [design-rationale.md#D-1-five-block-owned-set](design-rationale.md).

### D-2: apply-time-size-gate

`modify_AGENTS.md` enforces the budget itself: `BUDGET_CHARS = 2000`; `canonical_blocks()` (already the validation choke point) additionally sums `len(block)` over the OWNED set and raises `SystemExit(f"owned blocks {measured} chars > budget {BUDGET_CHARS}")` — realizing `Spec#B-1-over-budget-apply-fails` and enforcing `Spec#C-1-owned-size-budget`.

- Measured over the canonical source spans exactly as embedded (tag lines included), matching C-1's definition.
- A `SystemExit` from a modify script aborts that target's update — chezmoi writes nothing (the no-partial-write half of B-1).
- WHY (alternative weighed): apply-time gate over a pre-commit hook — see [design-rationale.md#D-2-apply-time-size-gate](design-rationale.md).

### D-3: retired-tag-registry (retired)

Retired per `Understanding#Delta-2-retired-tags-need-no-registry`: the resurrection premise was overstated (a fresh apply cannot resurrect; a hand-deleted span stays deleted), and the registry accretes forever.
Retirement is now a one-time manual deletion per machine, sequenced in `Tasks#T:M4`; the merge carries no `RETIRED` set.

Original decision: a `RETIRED = {"ko_output_quality", "context_discipline", "plan_style", "research_before_planning"}` set in `modify_AGENTS.md`; the merge drops any live span whose tag is in `RETIRED` — realizing `Spec#B-3-retired-blocks-leave-the-file` (retired).
Original WHY: [design-rationale.md#D-3-retired-tag-registry](design-rationale.md).

### D-4: terminal-block-placement (retired)

Retired per `Understanding#Delta-3-recency-misattributed-to-file-tail`: the recency it defended belongs to the window, not the file — a preloaded file's tail never borders the live conversation, so the mechanism spent code guarding the slot that matters least.
Superseded by `D-5`.

Original decision: emit the terminal owned block (`change_discipline`) last, after unknown tags and extras — realizing `Spec#C-4-hard-lines-terminal` (retired).
Original WHY: [design-rationale.md#D-4-terminal-block-placement](design-rationale.md).

### D-5: head-lead-emitter

`ORDER` is reshaped to lead with the head — `operating_frame`, then `change_discipline`, then the four upstream anchors, then the remaining owned blocks — and the emitter is a plain forward pass: emit `ORDER` (owned from source, known-foreign from live), then append unknown tags and extras at the tail — realizing `Spec#C-5-hard-lines-lead`.

- The head needs no guard: every non-`ORDER` emitter path is an append, so no span another writer adds can render above `ORDER[0]` — the structural guarantee replaces D-4's held-back terminal block (no `TERMINAL` constant, no skip guard, no special-case append, no `owned[TERMINAL]` coupling).
- `operating_frame` keeps slot 1 over the hard lines: a frame conditions only what follows it, while the hard lines are self-contained imperatives — they need a hot slot but precede nothing; slot 2 keeps them in the primacy neighborhood.
- Stated tradeoff: the upstream round's future checkpoint block (a tag this script won't know) appends at the tail until its name is added to `ORDER` — acceptable because the tail is now the least-valued slot and intra-file position effects at this file size are weak (`Understanding#Delta-3-recency-misattributed-to-file-tail`); adding the tag to `ORDER` once known remains a cosmetic refinement.
- Ownership is unchanged: `ORDER` sequences known-foreign tags but their content always passes through from the live file byte-identical (`Spec#C-3-foreign-span-pass-through`).
- WHY: [design-rationale.md#D-5-head-lead-emitter](design-rationale.md).
