---
name: impl
description: LeanPlan — implement one task card from plan.md against current code. Re-reason at task entry, enforce stop-the-line triggers, distill non-obvious WHYs into durable code forms at close-out.
argument-hint: "<feature-key> <task-id>"
allowed-tools: Read, Write, Edit, Grep, Glob, AskUserQuestion, Agent, Bash(git *), Bash(./gradlew *), Bash(mise *), Bash(ls *), Bash(mkdir *), Bash(gh *), mcp__atlassian__getJiraIssue, mcp__atlassian__addCommentToJiraIssue
---

# impl

LeanPlan **TASK → code** edge. Runtime adapter — operational rules live in the canonical references.

Before acting, load:

- `~/.local/share/leanplan/references/artifact-contract.md` — anchor patterns, traceability rules.
- `~/.local/share/leanplan/references/impl.md` — stage-specific procedure, the 6 stop-the-line triggers, artifact update loop walk-up, distillation hierarchy (types → tests → annotations → commit → PR body → inline), squash-safe PR-body promotion rule.

Inputs: `<cwd>/docs/features/<KEY>/plan.md` and the cited anchors from the chosen `Task: <task-id>` card. JIT-load only the cited `O-<N>` / `INV-<N>` / `Decision-<N>` blocks — do not eagerly load the whole SPEC / DESIGN. Inspect current code before re-reasoning. If a stop-the-line trigger fires, walk up to the highest affected layer and surface to the user before coding.

Project `CLAUDE.md` "default no comments" discipline composes with the distillation hierarchy: rare comments come from distilled WHYs, never invented fresh.
