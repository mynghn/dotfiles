---
name: leanplan
description: Use LeanPlan, a portable LLM-aware spec-driven-development framework, to author or validate feature artifacts through requirement, specify, design, plan, and impl stages.
---

# LeanPlan

Use this skill when the user asks to create, refine, validate, or implement a LeanPlan feature plan.

LeanPlan is a transient, code-facing SDD workflow for one-deployment-sized feature work. It keeps the review surface small and loads deeper rationale only when needed.

## Dispatch

Parse the user's intent and load only the matching bundled reference:

| Intent | Load |
|---|---|
| `requirement <KEY>` | `references/requirement.md` |
| `specify <KEY>` | `references/specify.md` |
| `design <KEY>` | `references/design.md` |
| `plan <KEY>` | `references/plan.md` |
| `impl <KEY> <task-id>` | `references/impl.md` |
| `validate <feature-path>` | Run `scripts/validate.py` |

For any artifact-writing stage, also load `references/artifact-contract.md`.

If the current repo has `docs/leanplan.md`, read it only as repo-local context. This skill is portable; bundled references remain sufficient when no repo-local framework doc exists.

## Validation

Run:

```bash
python3 ~/.agents/skills/leanplan/scripts/validate.py docs/features/<KEY>
```

Use `--json` for machine-readable output and `--stage requirement|spec|design|plan|full` for partial checks.

## Operating Rules

- Do not turn TASK into a script. Give intent, constraints, anchors, and completion criteria.
- Do not bulk-load every reference. Load only the stage reference needed now.
- Do not create living canonical specs. Plan artifacts are in-feature, transient, and migrated into code/tests/types/PR body at implementation close-out.
- When implementation contradicts a prior artifact, walk up to the highest affected layer and update there instead of patching downstream drift.
