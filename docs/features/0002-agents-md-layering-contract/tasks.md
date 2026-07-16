# 0002-agents-md-layering-contract — Tasks

## Guidelines

- Work on a feature branch off `main`; the live `~/AGENTS.md` changes only through the dotfiles source + apply, never by hand-editing.
- `modify_AGENTS.md` stays a stdlib-only python3 script in its existing idiom (regex block parser, `SystemExit` on violation, stdin → stdout).
- Verify merge behavior by piping fixture input to the script directly; do not run a real apply against `$HOME` before M4.

## Dependency DAG

```mermaid
flowchart LR
    subgraph M [merge / owned blocks]
      M1[M1 five-block content] --> M2[M2 retirement + terminal placement]
      M1 --> M3[M3 size gate]
      M2 --> M4[M4 live apply + acceptance]
      M3 --> M4
    end
```

Single track: everything lands in one repo and one deployment (one apply); M2 and M3 are parallel after M1.

## T: M1

- **Goal**: Collapse the owned source to the five consolidated blocks per `Design#D-1-five-block-owned-set` — author the block texts within their per-block envelopes, update the owned set and order accordingly, so an apply renders exactly the defined blocks (`Spec#B-2-apply-renders-owned-set`).
- **Repo**: `~/.local/share/chezmoi` (`modify_AGENTS.md` embedded source)
- **Completion**:
  - (a) combined owned source, tag lines included, ≤ 2,000 chars (`Spec#C-1-owned-size-budget`), each block within its D-1 envelope;
  - (b) single prose home verified for the formerly duplicated rules — ask-before-acting, primary-sources, working-set discipline, branch-base definition each match exactly one block (`Spec#C-2-single-prose-home`);
  - (c) piping the current live file into the script yields output whose owned half is exactly the five blocks in defined order (`Spec#B-2-apply-renders-owned-set`).
- **Dependencies**: none

## T: M2

- **Goal**: Make retirement and placement structural in the merge — drop retired-tag spans per `Design#D-3-retired-tag-registry` (`Spec#B-3-retired-blocks-leave-the-file`) and emit the hard-lines block last per `Design#D-4-terminal-block-placement` (`Spec#C-4-hard-lines-terminal`), without disturbing foreign spans (`Spec#C-3-foreign-span-pass-through`).
- **Repo**: `~/.local/share/chezmoi` (`modify_AGENTS.md` merge logic)
- **Completion**:
  - (a) fixture live file containing the four retired-tag spans → none survive in output (`Spec#B-3-retired-blocks-leave-the-file`);
  - (b) fixture with an unknown tag (e.g. a future checkpoint block) → its span renders before `change_discipline`, which is the file's final block (`Spec#C-4-hard-lines-terminal`);
  - (c) all never-owned spans (the four upstream anchors, the unknown tag, untagged extras) byte-identical between fixture and output (`Spec#C-3-foreign-span-pass-through`).
- **Dependencies**: M1 lands the shrunken owned set that makes the retired tags real fixtures.

## T: M3

- **Goal**: Enforce the budget at apply time per `Design#D-2-apply-time-size-gate`, so an over-budget owned source fails the apply with the measured size and the budget named (`Spec#B-1-over-budget-apply-fails`, standing ceiling `Spec#C-1-owned-size-budget`).
- **Repo**: `~/.local/share/chezmoi` (`modify_AGENTS.md` validation path)
- **Completion**:
  - (a) source inflated past 2,000 chars → script exits non-zero, stdout empty (no partial write), stderr names measured chars and the 2,000 budget (`Spec#B-1-over-budget-apply-fails`);
  - (b) unmodified (within-budget) source → exit 0, normal render.
- **Dependencies**: M1 lands the within-budget content that makes the gate's green path real.

## T: M4

- **Goal**: Adopt on the live machine and accept the round — a real apply regenerates `~/AGENTS.md` under the new contract, proving the Requirements success signal (footprint halved, one home per invariant, breach rejected).
- **Repo**: `~/.local/share/chezmoi` → live `$HOME`
- **Completion**:
  - (a) real apply succeeds; live file's owned half is the five blocks, `change_discipline` terminal (`Spec#B-2-apply-renders-owned-set`, `Spec#C-4-hard-lines-terminal`);
  - (b) diff against the pre-apply file shows upstream anchor spans byte-identical (`Spec#C-3-foreign-span-pass-through`) and retired spans gone (`Spec#B-3-retired-blocks-leave-the-file`);
  - (c) empty-stdin (bootstrap) run renders all five blocks (`Spec#B-2-apply-renders-owned-set`);
  - (d) deliberate over-budget edit on a scratch copy fails the apply (`Spec#B-1-over-budget-apply-fails`);
  - (e) `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` symlinks still resolve to the regenerated file.
- **Dependencies**: M2 and M3 land the mechanisms this acceptance run exercises.
