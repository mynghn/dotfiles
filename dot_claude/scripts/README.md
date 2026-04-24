# LeanPlan Phase 2 tooling

Bash validators + scaffold + opt-in pre-commit hook. All scripts land at `~/.claude/scripts/` via chezmoi and operate on `<cwd>/docs/features/<KEY>/` artifacts.

## Scripts

| Script | Purpose | Exit codes |
|---|---|---|
| `leanplan-check-anchors` | Every `SPEC#O-<N>-…` / `SPEC#INV-<N>-…` / `DESIGN#Decision-<N>-…` reference resolves to an existing heading. | 0 clean / 2 unresolved |
| `leanplan-check-coverage` | Bidirectional: every SPEC O/INV cited ≥1 in a task Completion; every Task Goal cites ≥1 anchor. `**GAP**` markers acknowledge uncovered items. | 0 clean / 2 gap or orphan |
| `leanplan-check-drift` | Regex scan for tech-stack names in REQUIREMENT/SPEC and step-by-step edit patterns in TASK. Warn by default; `LEANPLAN_STRICT=1` escalates to error. | 0 clean / 1 warn / 2 strict |
| `leanplan-check` | Runs all three validators; aggregates `max(exit)`; prints per-validator status to stderr. | 0 / 1 / 2 |
| `leanplan-new <KEY>` | Scaffolds `<cwd>/docs/features/<KEY>/{requirement,spec,design,design-rationale,task}.md` with section stubs. Refuses to overwrite. | 0 / 2 |
| `leanplan-selftest` | Ephemeral defect-injection test battery against LPSYNC-1 fixture. | pass count on stdout / fail count as exit |

## Pre-commit hook

`~/.claude/hooks/pre-commit-leanplan` is installable but **not** auto-activated (would replace per-repo hooks globally if set as `core.hooksPath`). Install per repo with:

```bash
ln -s ~/.claude/hooks/pre-commit-leanplan  <repo>/.git/hooks/pre-commit
```

Warn mode by default; `LEANPLAN_STRICT=1` makes it blocking. Only runs when staged paths match `docs/features/*/...md`.

## Conventions the validators enforce

See `~/.claude/leanplan.md` §5 (artifact shapes), §6 (bidirectional verification), §7 (drift guards), §8 (anchor patterns). If a framework rule changes there, the corresponding validator here must change too — they share ground-truth, not ground-up inheritance.
