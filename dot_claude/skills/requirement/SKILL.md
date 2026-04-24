---
name: requirement
description: LeanPlan — author a REQUIREMENT artifact for a feature. Interactive extraction of biz-only Problem + Outcome; standalone edge (not derived from a prior artifact).
argument-hint: "[jira-key | brief biz intent]"
allowed-tools: Read, Write, Edit, AskUserQuestion, Bash(mkdir *), Bash(ls *), mcp__atlassian__getJiraIssue, mcp__atlassian__searchJiraIssuesUsingJql, mcp__claude_ai_Slack__slack_read_thread, mcp__claude_ai_Slack__slack_read_channel
---

# requirement

LeanPlan skill. Edge: **(standalone) → REQUIREMENT**. Authors the biz WHAT for a feature — the artifact downstream `specify` turns into a tech contract.

## Context

LeanPlan is a lean spec-driven-development framework with staged artifacts (REQUIREMENT → SPEC → DESIGN → TASK → code). REQUIREMENT is the origin: high-abstraction, biz-framed, non-technical. Primary reader is PM / biz stakeholders; downstream LeanPlan skills use it only as evaluation criteria.

## Inputs

- `$ARGUMENTS` — optional. One of:
  - Jira key matching `[A-Z]+-\d+` (e.g. `NEWCS-3526`) — fetch upstream via `mcp__atlassian__getJiraIssue`.
  - Short biz-intent sentence — use as seed, ask for a key.
  - Empty — ask for both key and intent via `AskUserQuestion`.

## Output

`<cwd>/docs/features/<KEY>/requirement.md`. Create the dir if absent.

## Artifact shape

```
# <KEY> — <short biz-framed title>

## Problem
<what biz pain or opportunity drives this? who feels it? what is currently broken, missing, or constrained?>

## Outcome
<biz future state *and* the signal that confirms it, folded into one paragraph. Not split into separate "Success metric" section.>

## Non-goals   (conditional — include only when biz scope edges are genuinely ambiguous)
- <explicitly out-of-scope item 1>
- ...

## Upstream   (conditional — include only when Jira / PRD / Slack refs exist)
- Jira: <KEY> — <link or title>
- PRD / Slack / other: <ref>
```

Declarative present tense throughout.

## Guardrails

- **No implementation choices.** No specific tech stack (Kafka, Redis, Postgres, gRPC, Spring), no internal architecture, no chosen pattern. Biz-vocabulary channels — "admin tool", "partner API", "batch integration" — are fine; they name channels, not choices.
- **Outcome folds the success signal.** One paragraph, biz future state + observable signal. Don't split.
- **Conditional sections must earn their place.** Non-goals only when scope is ambiguous; Upstream only when refs exist. Otherwise omit — empty sections dilute the review surface.
- **Biz-native vocabulary.** Reviewers are PMs / stakeholders. Avoid internal system names unless they *are* the biz context (e.g. a product line).

## Procedure

1. **Resolve `<KEY>`**: parse `$ARGUMENTS`. If it matches a Jira key, fetch the issue for upstream context (description, summary, linked Slack/PRD). Otherwise `AskUserQuestion` for the key + a short biz-intent sentence.
2. **Load upstream** (when present): Jira description, linked PRD, linked Slack thread. Harvest the biz *problem*, not any requested implementation.
3. **Draft interactively.** Review each section with the user — misframed Problem is the single largest source of downstream rework:
   - Problem — the pain / opportunity, who feels it, what's currently broken or missing.
   - Outcome — biz future state + observable signal, folded.
   - Non-goals — only if scope edges are ambiguous.
   - Upstream — only if refs exist.
4. **Write** the file at `<cwd>/docs/features/<KEY>/requirement.md` (`mkdir -p` the dir).
5. **Self-check**:
   - Grep body for tech-stack nouns (Kafka, Redis, Kotlin, Spring, gRPC, Postgres, Flink, etc.) — zero hits expected.
   - Outcome names a biz-observable signal.
   - No empty or single-bullet conditional sections.

## Completion

- File at `<cwd>/docs/features/<KEY>/requirement.md`.
- Problem + Outcome non-empty, biz-framed.
- No specific tech stack names in body.
- Tell the user: next edge is `/specify <KEY>` — but iterating on REQUIREMENT first is fine.
