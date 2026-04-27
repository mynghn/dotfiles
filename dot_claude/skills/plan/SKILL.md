---
name: plan
description: LeanPlan — produce a TASK plan.md from a DESIGN. Track subgraphs, prefixed task IDs, bidirectional verification against SPEC + DESIGN.
argument-hint: "<feature-key>"
allowed-tools: Read, Write, Edit, Grep, Glob, AskUserQuestion, Bash(ls *), Bash(mkdir *), Bash(git *)
---

# plan

LeanPlan **DESIGN → TASK** edge. Runtime adapter — operational rules live in the canonical references.

Before writing the artifact, load:

- `~/.local/share/leanplan/references/artifact-contract.md` — TASK shape (Guidelines, Dependency DAG, Task cards), `Task: <id>` anchor pattern, traceability rules with `**GAP**` ack semantics.
- `~/.local/share/leanplan/references/plan.md` — stage-specific procedure, track-prefixed task IDs (P/A/D/I), enabler-not-gate dependency wording, bidirectional verification, advisory one-deployment guardrail.

Output: `<cwd>/docs/features/<KEY>/plan.md` (filename is `plan.md`, not `task.md`). Validate after writing with `python3 ~/.local/share/leanplan/scripts/validate.py <cwd>/docs/features/<KEY> --stage plan`.

After writing, hand off: for each independently startable task, `/impl <KEY> <task-id>`.
