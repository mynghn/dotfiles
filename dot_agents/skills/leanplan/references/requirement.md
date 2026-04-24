# LeanPlan Requirement Stage

Edge: standalone input to REQUIREMENT.

## Inputs

- Feature key, for example `NEWCS-1234`.
- User-provided business intent, Jira, PRD, Slack, or similar upstream context.

## Output

`docs/features/<KEY>/requirement.md`

## Procedure

1. Resolve the feature key.
2. Gather upstream context when available.
3. Extract the business problem, not the requested implementation.
4. Draft only durable review surface: Problem, Outcome, optional Non-goals, optional Upstream.
5. Ask the user to correct business framing when Problem or Outcome is uncertain.
6. Write the artifact.

## Guardrails

- No implementation choices: no chosen stack, internal architecture, schema, queue, database, framework, or pattern.
- Business-native channels are allowed: admin tool, partner API, batch integration.
- Outcome folds the success signal into the business future state.
- Conditional sections must earn their place.

## Template

```markdown
# <KEY> - <biz title>

## Problem
<business pain/opportunity, who feels it, what is broken or constrained>

## Outcome
<business future state plus observable success signal>

## Non-goals
- <only when scope edges are ambiguous>

## Upstream
- <Jira / PRD / Slack refs when they exist>
```
