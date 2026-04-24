---
name: impl
description: LeanPlan — implement one TASK card against current code. Re-reason at task entry, enforce stop-the-line triggers, distill non-obvious WHYs into durable code forms at close-out.
argument-hint: "<feature-key> <task-id>"
allowed-tools: Read, Write, Edit, Grep, Glob, AskUserQuestion, Agent, Bash(git *), Bash(./gradlew *), Bash(mise *), Bash(ls *), Bash(mkdir *), Bash(gh *), mcp__atlassian__getJiraIssue, mcp__atlassian__addCommentToJiraIssue
---

# impl

LeanPlan skill. Edge: **TASK → code**. Implements one task card from a feature's TASK artifact. Not a task-card script — the impl agent re-reasons against current code, challenges prior artifacts when contradicted, and distills non-obvious WHYs into durable code forms at close-out.

## Context

LeanPlan stages: REQUIREMENT → SPEC → DESIGN → TASK → code. By design, plan artifacts are **transient** — they exist to guide the plan-implement cycle and are discarded once the work lands. Persistence happens by *migration to code*: non-obvious WHYs from plan artifacts get distilled into types, tests, annotations, commit messages, PR bodies, or inline comments at implementation time. This is the impl agent's close-out responsibility.

Task cards carry intent + constraints (Goal, Repo, Completion, Dependencies, optional Guidelines) plus inline anchors to the SPEC / DESIGN content the task realizes. The agent JIT-loads those anchors; it does not load the whole SPEC / DESIGN eagerly.

## Inputs

- `$ARGUMENTS` — `<feature-key> <task-id>` (both required).
- `<cwd>/docs/features/<KEY>/task.md` — locate `## Task: <task-id>` card. If absent, stop.
- Anchors cited in the card:
  - `SPEC#O-<N>-<slug>` or `SPEC#INV-<N>-<slug>` → `<cwd>/docs/features/<KEY>/spec.md` `### O-<N>` or `### INV-<N>` block (under `## Outcome` / `## Invariants` section headers).
  - `DESIGN#Decision-<N>-<slug>` → `<cwd>/docs/features/<KEY>/design.md` `## Decision-<N>` block.
  - Doc-level Guideline references.
- `<cwd>/docs/features/<KEY>/design-rationale.md` — **JIT only**. Load a specific `## Decision-<N>` entry when a stop-the-line trigger is under review and you need the full reasoning behind the original decision.

## Output

- Working software (git commits on a feature branch).
- Distilled WHYs placed in the strongest durable form available (see §Distillation below).
- A populated PR body when the team squash-merges.

## Stop-the-line triggers

If any of the following surfaces at task entry or mid-implementation, **stop and surface to the user** before writing code. Each trigger points at the artifact layer that's wrong:

1. **Current code contradicts DESIGN** — DESIGN is wrong (or stale). Walk up to DESIGN.
2. **No verification path exists for a Completion criterion** — the criterion is unverifiable as written. Walk up to TASK (fix the criterion) or further if the underlying SPEC O / INV lacks an observable signal.
3. **A Dependency is missing or itself invalidated** — re-evaluate the DAG at TASK level, not just this card.
4. **Implementation would require changing an externally-observable behavior** → walk up to SPEC; possibly further to REQUIREMENT if biz scope shifts.
5. **An Invariant is unprovable by the current test strategy** — add a probe mechanism (test harness, monitor, SLO) at TASK level, or push to a continuous-verification mechanism via DESIGN.
6. **Task scope expands beyond the feature boundary** — one-deployment guardrail hit; pause and surface the split question.

For each trigger: state which layer is affected and the minimum update that resolves it. Never silently patch downstream alone — that hides the drift.

## Artifact update loop

On any stop-the-line trigger:

1. **Identify the highest affected layer** — DESIGN for realization errors, SPEC for contract errors, REQUIREMENT for scope changes. Pick the highest one; fixing lower alone masks upstream drift.
2. **Surface to the user** what's wrong and the proposed update.
3. **Update that layer** (edit the artifact).
4. **Re-evaluate downstream artifacts** that referenced the updated layer. They may: (a) stay valid, (b) need local update, or (c) trigger a re-plan. Default is to re-evaluate in place, not fully re-derive.
5. **Resume implementation** only after the walk-up completes.
6. **Scope gate**: if the update pushes REQUIREMENT beyond one-deployment size, pause — the feature should be split, not grown.

Minor refinements that don't invalidate prior artifacts are handled inline at impl time and distilled into code per §Distillation.

## Guardrails

- **Re-reason, don't execute.** The task card is intent + constraints; it may be stale against current code. Inspect first.
- **Walk up on upstream wrongness — never patch around silently.** If DESIGN is wrong, fix DESIGN; if SPEC is wrong, fix SPEC; etc. Patching only the current task masks the drift from future readers.
- **Default no comments.** A new inline comment is justified only when a WHY cannot be encoded in a higher form (type / test / annotation / commit / PR body). Most tasks should add zero comments.
- **Smallest meaningful change.** No speculative scope, no drive-by refactors beyond what the task requires.
- **Distillation is not optional.** The plan artifacts must be *non-load-bearing* before the task is considered done. Every WHY the task relied on has either been encoded into durable code / tests / messages, or has been verified as already present in one of those forms.
- **Verify each Completion criterion explicitly** — not "tests pass", but each specific criterion the card named.

## Distillation hierarchy

At close-out, migrate non-obvious WHYs from plan anchors into the strongest durable form available. Prefer higher tiers; use lower tiers only when the WHY cannot be encoded structurally.

| Tier | Form | Use when |
|---|---|---|
| 1 | **Types / signatures / module structure** | The WHY is a constraint the compiler or IDE can enforce (required field, disallowed combination, module boundary). |
| 2 | **Tests** (unit, property, integration) | The WHY is a behavioral guarantee; the test name + body carry the reason. Property tests capture invariants especially well. |
| 3 | **Enforced annotations** (custom lint, archunit, API linter) | The WHY is a cross-cutting rule ("all handlers must be idempotent", "no direct DB access from presentation"). |
| 4 | **Commit message** | Change-scoped WHY — why this commit exists, alternatives considered, tradeoffs accepted. Survives as long as the commit does. |
| 5 | **PR body** | Change rationale that must survive **squash-merge**. Teams that squash lose commit messages; the PR body is the durable home. |
| 6 | **Inline comment** | Last resort — subtle invariant, workaround, non-obvious constraint that must sit adjacent to the code. Rots with the code; use sparingly. |

**Commit message vs. inline comment** — complementary, not substitutes:

| Commit message | Inline comment |
|---|---|
| "Why this *change* was made" | "Why this *code* is shaped this way" |
| Alternatives rejected, tradeoffs accepted | Constraints the reader needs *while reading*, subtle invariants, workarounds |
| Investigative access (`git blame`, `git log`) | Adjacent access (eyes on the code) |
| Survives refactors (history independent of file structure) | Dies with the line |

**Squash-durability promotion rule** — for teams that squash-merge, local commit messages are erased. Persist by rationale kind:

| Rationale kind | Durable target |
|---|---|
| Local ("why this code is shaped this way") | code / tests / types / inline comment |
| Change ("why this commit exists", alternatives considered) | **PR body** or squash-commit message |
| Cross-feature architecture | runbook / org ADR / structural code (types, module boundaries) |

PR body is particularly durable — visible in GitHub history post-squash, linkable from future investigations. Don't rely on local commit messages for change rationale in squash-merge teams.

## Procedure

1. **Locate the card** `## Task: <task-id>` in `task.md`. Extract Goal (with inline anchors), Repo, Completion criteria, Dependencies, any Guidelines.
2. **JIT-load anchors** — read only the specific `### O-<N>` / `### INV-<N>` / `## Decision-<N>` sections referenced. Do not eagerly load entire SPEC / DESIGN.
3. **Inspect current code** at affected paths. Build a short working model of what exists today. Reality is authoritative.
4. **Re-reason**: does the plan still apply? Any of the six stop-the-line triggers hit? If yes, run the Artifact update loop and surface to the user.
5. **Implement** the smallest meaningful change that realizes Goal + passes Completion criteria.
6. **Verify each Completion criterion explicitly.** Episodic → one-shot test or observable result. Continuous → SLO / monitor / CI gate wired. Don't substitute "all tests pass" for the specific criterion.
7. **Distill WHYs** per the hierarchy:
   - For each WHY the task relied on (from SPEC anchors, DESIGN anchors, Guidelines), pick the highest tier it can be encoded in.
   - Prefer Tier 1–3 (compiler-, test-, or lint-enforced) when possible.
   - Change rationale → commit message body. If the team squashes, also put change rationale in the PR body (the squash will preserve the PR body, not local commits).
   - Inline comments only as last resort. Never invent comments that restate code behavior — only distilled WHYs qualify.
8. **Confirm plan artifacts are non-load-bearing.** Walk the task's anchors one more time: is the WHY they carried now reachable from code / tests / messages? If yes, the plan artifact could be discarded without information loss.
9. **Commit**. Subject matches the change; body carries distilled change rationale (alternatives considered, tradeoffs). For squash-merge teams, populate the PR body with the same content.
10. **Hand-off**: suggest the next unblocked task in the DAG, or raise any stop-the-line item that surfaced mid-task.

## Completion

- Completion criteria for this task all verified explicitly (each specific criterion checked, not just "CI green").
- Every load-bearing WHY from the task's cited anchors has a durable home (types / tests / annotations / commit / PR body / inline).
- No orphan comments (comments that restate code behavior rather than carry distilled WHY).
- If a stop-the-line trigger fired: the affected layer was updated (not just downstream patched), and the user approved the walk-up.
- Commit landed; PR body populated if the team squashes.
