---
name: leanplan
description: Use LeanPlan, a portable LLM-aware spec-driven-development framework, to author or validate feature artifacts through requirement, specify, design, plan, and impl stages.
---

# LeanPlan

Use this skill when the user asks to create, refine, validate, or implement a LeanPlan feature plan.

LeanPlan is a transient, code-facing SDD workflow for one-deployment-sized feature work. It keeps the review surface small and loads deeper rationale only when needed.

Canonical assets (shared between Claude Code and Codex runtimes) live at `~/.local/share/leanplan/`. This skill is the Codex-side adapter; the Claude Code runtime exposes the same content via per-stage slash commands.

## Dispatch

Parse the user's intent and load only the matching reference from the canonical tree:

| Intent | Load |
|---|---|
| `requirement <KEY>` | `~/.local/share/leanplan/references/requirement.md` |
| `specify <KEY>` | `~/.local/share/leanplan/references/specify.md` |
| `design <KEY>` | `~/.local/share/leanplan/references/design.md` |
| `plan <KEY>` | `~/.local/share/leanplan/references/plan.md` |
| `impl <KEY> <task-id>` | `~/.local/share/leanplan/references/impl.md` |
| `validate <feature-path>` | Run `python3 ~/.local/share/leanplan/scripts/validate.py` |

For any artifact-writing stage, also load `~/.local/share/leanplan/references/artifact-contract.md`.

The framework doc at `~/.local/share/leanplan/leanplan.md` is for humans evolving the framework; this skill does not load it at runtime.

If the current repo has its own `docs/leanplan.md` (e.g. carsharing-backend), read it as repo-local context only. The canonical references remain authoritative.

## Validation

```bash
python3 ~/.local/share/leanplan/scripts/validate.py docs/features/<KEY>
```

Flags:

- `--stage requirement|spec|design|plan|full` — partial check while iterating.
- `--json` — machine-readable output.
- `--strict` (or `LEANPLAN_STRICT=1`) — escalates the one-deployment guardrail to error and makes any warning exit non-zero. Suitable for CI / pre-commit.
- `--allow-large` — explicit override for legitimately oversized DAGs.

A SPEC O / INV item annotated on a line containing `**GAP**` (typically in plan.md's forward-coverage table) is treated as deliberately uncovered — see the artifact contract.

## Operating Rules

- Do not turn TASK into a script. Give intent, constraints, anchors, and completion criteria.
- Do not bulk-load every reference. Load only the stage reference needed now.
- Do not create living canonical specs. Plan artifacts are in-feature, transient, and migrated into code/tests/types/PR body at implementation close-out.
- When implementation contradicts a prior artifact, walk up to the highest affected layer and update there instead of patching downstream drift.
