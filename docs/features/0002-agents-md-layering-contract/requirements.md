# 0002-agents-md-layering-contract — dotfiles-owned instruction blocks stay lean and cannot regrow

## Problem

Every agent session on this machine preloads the shared standing-instruction file, so the operator pays its attention tax before any work begins.
An audit measured that always-loaded layer at roughly 2,200 tokens, about half of it restating guidance that already lives one hop away in skill descriptions, skill bodies, or the knowledge vault.
The dotfiles-owned half — 9 blocks, ~72 lines — carries its share of the duplication: three blocks state the same context discipline, two block pairs restate each other's engineering rules, and one block re-enumerates triggers its skill already advertises.
Duplicated near-relevant standing prose is the distractor class that degrades long sessions: the operator feels it as the agent attending to stale doctrine instead of live work.
The paired activation study made the waste concrete — the heavy always-loaded blocks did not even buy the skill activation they exist for.
And nothing blocks regrowth: the dotfiles apply whatever blocks are defined, with no size discipline, so the next well-meaning addition re-inflates the tax silently.

## Outcome

The dotfiles-owned half of the shared instruction file carries only deduplicated invariants — each fact stated once, in one block — under an enforced size budget, and stays that way mechanically.

User stories:

- **Consolidated invariants** — the nine owned blocks collapse to about five, each retained fact stated exactly once.
  The context frame absorbs the working-set discipline; implementation absorbs plan style; investigation absorbs research sourcing and the branch-base definition; the Korean-output block retires because its skill's own description already carries the trigger list and timing.
- **Hard lines keep the edge** — the must-never-violate rules sit at the head of the file, immediately after the context frame: the file is preloaded at the window's start, so its head is the recall hot spot it can actually reach — its tail never borders the live conversation (`Understanding#Delta-3-recency-misattributed-to-file-tail`).
- **Regrowth blocked at apply time** — when the owned blocks exceed their budget, applying the dotfiles fails with a message naming the overage, so growth becomes a conscious decision instead of drift.

Success signal: the owned-block footprint drops by at least half (~72 → ~35 lines, ~1,050 → ≤ ~500 tokens), a search for any retained invariant finds one prose home, and a deliberately over-budget edit is rejected at apply time.

## Guarantee

- **One fact, one block** — no invariant is stated in two owned blocks; the ask-before-acting rule, the primary-sources rule, and the working-set discipline each get a single home.
  Why: every restatement is a near-miss distractor competing with live instructions in every session.
- **Foreign spans pass through untouched** — blocks owned by the upstream framework survive this round and every future apply unmodified.
  Why: two writers share one file safely only if each edits nothing beyond its own spans.

## Non-goals

- The four framework-owned anchor blocks — the paired upstream round owns their retirement and replacement.
- Re-measuring skill activation — the upstream round owns the measurement harness; this round's single activation-touching change (retiring the Korean-output block) is accepted as residual risk because that skill is surface-cued and its description already carries enumeration and timing.
- Changing what any skill or knowledge entry says.

## Upstream

- Paired upstream round: `~/.local/share/metacognition/docs/features/0008-agents-md-layering-contract/handoff.md` (records the shared contract, grill decisions, and evidence).
- Activation evidence: metacognition worktree `0001-self-initiated-skill-activation`, `configs/VERDICT.md` (baseline 0.09 with heavy blocks loaded; generic checkpoint promoted; trigger-first descriptions held).
