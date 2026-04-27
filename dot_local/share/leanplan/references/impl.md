# LeanPlan Implementation Stage

Edge: TASK → code.

## Inputs

- `<cwd>/docs/features/<KEY>/plan.md` — locate `Task: <task-id>` card. If absent, stop.
- Cited anchors from the card (SPEC O/INV, DESIGN Decisions, optional Guidelines) — JIT-loaded only as needed.
- Current code at the affected paths.
- DESIGN RATIONALE — JIT only, when a stop-the-line trigger is under review.

## Output

- Working software (git commits on a feature branch).
- Distilled WHYs in the strongest durable form available — types, tests, annotations, commit messages, PR body, inline comments.

## Procedure

1. **Load** the selected `Task: <task-id>` card (Goal, Repo, Completion, Dependencies, Guidelines).
2. **JIT-load anchors** — read only the specific `O-<N>` / `INV-<N>` / `Decision-<N>` blocks referenced. Do not eagerly load the whole SPEC / DESIGN.
3. **Inspect current code** at the affected paths. Reality is authoritative.
4. **Re-reason** against current code: does the plan still apply? Any of the six stop-the-line triggers hit? If yes, run the Artifact Update Loop and surface to the user before coding.
5. **Implement** the smallest meaningful change that realizes Goal + passes Completion criteria. No speculative scope; no drive-by refactors beyond what the task requires.
6. **Verify each Completion criterion explicitly** — not "tests pass", but each specific criterion the card named.
7. **Distill WHYs** per the hierarchy below at close-out.
8. **Confirm plan artifacts are non-load-bearing**: the WHYs they carried have migrated; discarding the plan would not lose context for future readers.
9. **Commit** with subject matching the change. Body carries distilled change rationale (alternatives, tradeoffs). For squash-merge teams, populate the PR body with the same content.
10. **Hand off** to the next unblocked task in the DAG, or raise any stop-the-line item that surfaced mid-task.

## Stop-The-Line Triggers

If any of the following surfaces at task entry or mid-implementation, stop and run the Artifact Update Loop before coding:

1. **Current code contradicts DESIGN.** Walk up to DESIGN.
2. **No verification path exists for a Completion criterion.** Walk up to TASK (fix the criterion) or further if the underlying SPEC O / INV lacks an observable signal.
3. **A Dependency is missing or itself invalidated.** Re-evaluate the DAG, not just this task.
4. **Implementation would require changing externally-observable behavior.** Walk up to SPEC; possibly REQUIREMENT.
5. **An Invariant is unprovable by the current test/monitor strategy.** Add a probe mechanism (test harness, monitor, SLO) at TASK level, or push to a continuous-verification mechanism via DESIGN.
6. **Task scope expands beyond the feature boundary.** One-deployment guardrail — pause and surface the split question.

## Artifact Update Loop

On any stop-the-line trigger:

1. **Identify the highest affected layer**:
   - REQUIREMENT for business scope change.
   - SPEC for contract change.
   - DESIGN for realization change.
   - TASK for sequencing / work-navigation change.
2. **Surface to the user** what's wrong and the proposed update.
3. **Update that layer** (edit the artifact).
4. **Re-evaluate downstream artifacts** that referenced the updated layer. They may stay valid, need local update, or trigger re-planning. Default is re-evaluate in place, not fully re-derive.
5. **Resume implementation** only after the walk-up completes.
6. **Scope gate**: if the update pushes REQUIREMENT beyond one-deployment size, pause — the feature should be split, not grown.

## Distillation Hierarchy

At close-out, migrate non-obvious WHYs from plan anchors into the strongest durable form available. Prefer higher tiers:

| Tier | Form | Use when |
|---|---|---|
| 1 | **Types / signatures / module structure** | The WHY is a constraint the compiler or IDE can enforce. |
| 2 | **Tests** (unit, property, integration) | The WHY is a behavioral guarantee; the test name + body carry the reason. |
| 3 | **Enforced annotations** (custom lint, archunit, API linter) | The WHY is a cross-cutting rule. |
| 4 | **Commit message** | Change-scoped WHY — why this commit exists, alternatives considered, tradeoffs accepted. |
| 5 | **PR body** | Change rationale that must survive squash-merge. |
| 6 | **Inline comment** | Last resort — subtle invariant, workaround, non-obvious constraint that requires adjacency to the code. |

### Commit message vs. inline comment

| Commit message | Inline comment |
|---|---|
| "Why this *change* was made" | "Why this *code* is shaped this way" |
| Alternatives rejected, tradeoffs accepted | Constraints the reader needs *while reading*, subtle invariants, workarounds |
| Investigative access (`git blame`, `git log`) | Adjacent access (eyes on the code) |
| Survives refactors | Dies with the line |

### Squash-durability promotion rule

Local commit messages are erased by squash-merge workflows. Persist by rationale kind:

| Rationale kind | Durable target |
|---|---|
| Local ("why this code is shaped this way") | code / tests / types / inline comment |
| Change ("why this commit exists", alternatives considered) | **PR body** or squash-commit message |
| Cross-feature architecture | runbook / org ADR / structural code (types, module boundaries) |

PR body is particularly durable — visible in GitHub history post-squash, linkable from future investigations. Don't rely on local commit messages for change rationale in squash-merge teams.

## Guardrails

- **Re-reason, don't execute.** The task card is intent + constraints; it may be stale against current code. Inspect first.
- **Walk up on upstream wrongness — never patch around silently.** If DESIGN is wrong, fix DESIGN; if SPEC is wrong, fix SPEC; etc. Patching only the current task masks drift from future readers.
- **Default no comments.** A new inline comment is justified only when a WHY cannot be encoded in a higher form (type / test / annotation / commit / PR body).
- **Smallest meaningful change.** No speculative scope, no drive-by refactors.
- **Distillation is not optional.** Every WHY the task relied on must have a durable home before the task is considered complete; don't leave plan docs as the only holder of important WHYs.
