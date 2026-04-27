---
name: specify
description: LeanPlan — derive a SPEC (externally-observable contract) from an existing REQUIREMENT. Generic-category tech only; split episodic Outcome items from continuous Invariants.
argument-hint: "<feature-key>"
allowed-tools: Read, Write, Edit, Grep, Glob, AskUserQuestion, Bash(ls *), Bash(mkdir *), WebFetch, WebSearch
---

# specify

LeanPlan **REQUIREMENT → SPEC** edge. Runtime adapter — operational rules live in the canonical references.

Before writing the artifact, load:

- `~/.local/share/leanplan/references/artifact-contract.md` — feature layout, anchor patterns (`O-<N>: <slug>` / `INV-<N>: <slug>`), drift guards, traceability rules including `**GAP**` semantics.
- `~/.local/share/leanplan/references/specify.md` — stage-specific procedure, "what a SPEC is NOT" test, generic-category tech guard, RESEARCH archive rule.

If `<cwd>/docs/features/<KEY>/requirement.md` is missing, stop and tell the user to run `/requirement <KEY>` first. Validate after writing with `python3 ~/.local/share/leanplan/scripts/validate.py <cwd>/docs/features/<KEY> --stage spec`.

After writing, hand off: next edge is `/design <KEY>`.
