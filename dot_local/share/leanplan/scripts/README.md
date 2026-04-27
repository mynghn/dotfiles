# LeanPlan canonical scripts

All LeanPlan tooling lives at `~/.local/share/leanplan/scripts/`, applied via chezmoi from `dot_local/share/leanplan/scripts/`. Both Claude Code (`~/.claude/skills/{requirement,specify,design,plan,impl}`) and Codex (`~/.agents/skills/leanplan/`) adapters dereference this canonical path.

## Tools

| Tool | Purpose | Exit codes |
|---|---|---|
| `validate.py` | Comprehensive validator for `<feature-dir>`. Anchor integrity, bidirectional coverage, drift regex, duplicate-anchor + broken-citation + frontmatter + MUST/MUST NOT misuse + ASCII-diagram + checkbox + design ↔ rationale consistency, advisory one-deployment guardrail. `**GAP**` ack accepted. | 0 clean / 1 errors (or warnings under `--strict`) |
| `leanplan-new <KEY>` | Scaffolds `<cwd>/docs/features/<KEY>/{requirement,spec,design,design-rationale,task}.md`. Stubs pass `validate.py` clean on a fresh feature dir. | 0 / 2 (existing dir) |
| `leanplan-selftest` | Defect-injection battery against the LPSYNC-1 fixture (override via `LEANPLAN_FIXTURE`). Verifies validator catches the expected drift in each scenario. | pass count on stdout / fail count as exit |
| `pre-commit-leanplan` | Installable per-repo git pre-commit hook. Warn-only by default; `LEANPLAN_STRICT=1` blocks on errors. Install via `ln -s ~/.local/share/leanplan/scripts/pre-commit-leanplan <repo>/.git/hooks/pre-commit`. | 0 / non-zero in strict mode on validator errors |

## Validator quick reference

```bash
python3 ~/.local/share/leanplan/scripts/validate.py docs/features/<KEY>
python3 ~/.local/share/leanplan/scripts/validate.py docs/features/<KEY> --stage spec
python3 ~/.local/share/leanplan/scripts/validate.py docs/features/<KEY> --json
python3 ~/.local/share/leanplan/scripts/validate.py docs/features/<KEY> --strict   # CI / pre-commit
python3 ~/.local/share/leanplan/scripts/validate.py docs/features/<KEY> --allow-large
```

## Conventions enforced

The contract validators uphold lives in `~/.local/share/leanplan/references/artifact-contract.md`. If a rule needs to change, update the contract first; validators must mirror it. The framework doc at `~/.local/share/leanplan/leanplan.md` is the source for evolving the framework itself.
