---
name: requirement
description: LeanPlan — author a REQUIREMENT artifact for a feature. Interactive extraction of biz-only Problem + Outcome; standalone edge.
argument-hint: "[jira-key | brief biz intent]"
allowed-tools: Read, Write, Edit, AskUserQuestion, Bash(mkdir *), Bash(ls *), mcp__atlassian__getJiraIssue, mcp__atlassian__searchJiraIssuesUsingJql, mcp__claude_ai_Slack__slack_read_thread, mcp__claude_ai_Slack__slack_read_channel
---

# requirement

LeanPlan **(standalone) → REQUIREMENT** edge. Runtime adapter — operational rules live in the canonical references.

Before writing the artifact, load:

- `~/.local/share/leanplan/references/artifact-contract.md` — feature layout, anchor patterns, drift guards, traceability rules.
- `~/.local/share/leanplan/references/requirement.md` — stage-specific procedure, guardrails, and template.

Tools above are Claude Code-specific. Apply Jira / Slack MCP tools per `requirement.md` Procedure step 2 ("Load upstream") when `$ARGUMENTS` is a Jira key. Validate at any time with `python3 ~/.local/share/leanplan/scripts/validate.py <cwd>/docs/features/<KEY> --stage requirement`.

After writing, hand off: next edge is `/specify <KEY>`.
