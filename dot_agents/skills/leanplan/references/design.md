# LeanPlan Design Stage

Edge: SPEC to DESIGN.

## Inputs

- `spec.md`
- Current code and repo conventions
- Existing `research.md` when relevant

## Outputs

- `design.md`
- `design-rationale.md` entries for non-trivial decisions
- `research.md` entries for durable evidence

## Procedure

1. Load SPEC and artifact contract.
2. Inspect current code before choosing architecture.
3. Draw finished system shape with Mermaid.
4. Record chosen realizations as Decision anchors.
5. Put non-trivial WHYs in DESIGN RATIONALE, not in the surface.
6. Put raw evidence in RESEARCH, not in rationale.
7. Stop if the design changes the SPEC contract; update SPEC first.

## Guardrails

- DESIGN is time-independent finished-system shape.
- No work ordering, PR stacking, INFRAREQ procedure, or migration sequence; those belong in TASK.
- Trivial decisions get a short inline why. Non-trivial decisions get rationale entries.
- External boundaries appear as labeled diagram nodes or edges.

## Rationale Block Shape

```markdown
## Decision-<N>: <slug>

### Context
...

### Choice
...

### Forces
...

### Alternatives Rejected
...

### Invalidation Triggers
...

### Evidence Links
...
```
