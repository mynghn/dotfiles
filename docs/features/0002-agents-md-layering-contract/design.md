# 0002-agents-md-layering-contract — Design

## Architecture

The apply-time merge (the `modify_AGENTS.md` chezmoi modify script) stays the single writer of the shared file's owned half; this round changes its inputs (5 canonical blocks instead of 9), adds a size gate, a retired-tag drop, and terminal-block placement.

```
 dotfiles source (modify_AGENTS.md)             live ~/AGENTS.md --(stdin)--+
 +------------------------------+                                          |
 | DOTFILES_AGENTS_BLOCKS       |                                          v
 |   5 owned blocks (D-1)       |                                 parse <tag> spans
 | OWNED / ORDER / RETIRED      |                                 live_by_tag / extras
 | BUDGET_CHARS = 2000          |                                          |
 +--------------+---------------+                                          |
                v                                                          |
   size gate (D-2) -- over budget --> SystemExit(measured vs budget)       |
                |                       = apply fails, no write            |
                v                                                          v
   merge: owned <- source | known-foreign <- live | RETIRED dropped (D-3)
          unknown tags placed before the terminal block (D-4)
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

### D-3: retired-tag-registry

A new `RETIRED = {"ko_output_quality", "context_discipline", "plan_style", "research_before_planning"}` set in `modify_AGENTS.md`; the merge drops any live span whose tag is in `RETIRED` (never emitted, never treated as unknown) — realizing `Spec#B-3-retired-blocks-leave-the-file`.

- Absorbed blocks are retired tags too: their live spans must vanish, not survive as unknowns (the confirmed merge behavior would otherwise keep them forever — `research.md` → apply-merge-behavior).
- Declarative and idempotent: correct on this machine, any other machine applying later, and any stale live copy.
- WHY (alternative weighed): registry over one-time manual deletion — see [design-rationale.md#D-3-retired-tag-registry](design-rationale.md).

### D-4: terminal-block-placement

The merge emits the terminal owned block (`change_discipline`) last, after unknown tags and extras — unknown spans are inserted before it, not appended at EOF — realizing `Spec#C-4-hard-lines-terminal`.

- Mechanism: emit per ORDER holding back `change_discipline`; append unknown tags and extras (byte-identical content, `Spec#C-3-foreign-span-pass-through`); emit `change_discipline` last.
- This is what keeps the upstream round's future checkpoint block (a tag this script won't know) from landing below the hard lines.
- WHY: the confirmed append-at-EOF behavior would break C-4 the day upstream upserts a new tag — see [design-rationale.md#D-4-terminal-block-placement](design-rationale.md).
