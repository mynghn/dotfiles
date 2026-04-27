# LeanPlan Requirement Stage

Edge: standalone input → REQUIREMENT.

## Inputs

- Feature key (e.g. `NEWCS-1234`).
- Optional upstream context: Jira issue, PRD, Slack thread, or user-provided business intent.

## Output

`<cwd>/docs/features/<KEY>/requirement.md`

## Procedure

1. **Resolve `<KEY>`**: parse `$ARGUMENTS`. If it matches a Jira-style key (`[A-Z]+-\d+`), fetch the issue (description, summary, linked PRD/Slack) for upstream context. Otherwise ask the user for the key + a short biz-intent sentence.
2. **Load upstream** (when present): Jira description, linked PRD, linked Slack thread. Harvest the biz *problem*, not the requested implementation — upstream often arrives mixed with solution suggestions; strip them.
3. **Draft interactively**. Misframed Problem is the single largest source of downstream rework. Confirm framing with the user before writing:
   - **Problem** — what biz pain or opportunity drives this? Who feels it? What is currently broken, missing, or constrained?
   - **Outcome** — biz future state + observable success signal, folded into one paragraph (don't split signal into a separate "Success metric" section).
   - **Non-goals** — only if scope edges are genuinely ambiguous.
   - **Upstream** — only if refs exist; short list.
4. **Write** the artifact at `<cwd>/docs/features/<KEY>/requirement.md` (`mkdir -p` the dir).
5. **Self-check** before exiting:
   - Grep body for tech-stack nouns (Kafka, Redis, Kotlin, Spring, gRPC, Postgres, Flink, Kubernetes, Docker, etc.) — zero hits expected.
   - Outcome names a biz-observable signal.
   - Conditional sections are omitted when empty (don't ship empty Non-goals or Upstream sections).

## Guardrails

- **No implementation choices.** No specific stack (Kafka, Redis, Postgres, gRPC), no internal architecture, no chosen pattern. Biz-vocabulary channels — "admin tool", "partner API", "batch integration" — are fine; they name channels, not choices.
- **Outcome folds the success signal.** One paragraph, biz future state + observable signal. Don't split.
- **Conditional sections must earn their place.** Non-goals only when scope is ambiguous; Upstream only when refs exist. Otherwise omit — empty sections dilute the review surface.
- **Biz-native vocabulary.** Reviewers are PMs / stakeholders. Avoid internal system names unless they *are* the biz context (e.g. a product line).

## Template

```markdown
# <KEY> — <short biz-framed title>

## Problem
<business pain/opportunity, who feels it, what is broken or constrained>

## Outcome
<business future state + observable success signal, folded>

## Non-goals
- <only when scope edges are ambiguous>

## Upstream
- <Jira / PRD / Slack refs when they exist>
```

## Hand-off

Tell the user: next edge is `/specify <KEY>` (Claude) or `specify <KEY>` (Codex). Iterating on REQUIREMENT first is fine — `specify` re-derives from REQUIREMENT each invocation.
