# Prompt Engineering Knowledge Base

A small, personal, version-controlled store of distilled **prompt-engineering** knowledge — how to compose the instruction itself: stating intent clearly, structuring the prompt, showing few-shot exemplars, eliciting reasoning, shaping the output, and decomposing the task.

It is built to be **picked up when needed**: an agent (Claude Code or Codex) reads the index, loads only the one entry relevant to the question, and gets back to work. You can read every file here yourself — it is all plain markdown.

## Why this exists

Useful prompt-engineering lessons tend to evaporate at the end of a session. This store keeps them:

- **Durable** — survives across sessions; lives in git, not in a conversation.
- **Retrievable** — a one-line index turns "what do I know about X?" into loading a single file.
- **Self-correcting** — entries can be refreshed against current state-of-the-art, in place, with the old version recoverable from history.
- **Shared** — one corpus serves both Claude Code and Codex.

## Layout

```
~/.local/share/prompt-engineering-knowledge-base/
├── README.md            ← you are here
├── INDEX.md             ← one line per technique; the retrieval entry point
├── knowledge/
│   └── <technique>.md   ← one self-contained, sourced, dated entry per technique
└── scripts/
    └── pe-kb            ← the only tool that writes to the store
```

Two thin adapters point agents at this core (same body, provider-specific frontmatter):

- `~/.claude/skills/prompt-engineering-knowledge-base/SKILL.md` (Claude Code)
- `~/.codex/skills/prompt-engineering-knowledge-base/SKILL.md` (Codex)

## How it works

Three actions, all described in full inside the `SKILL.md` body:

| Action | What happens |
|---|---|
| **Retrieve** | Read `INDEX.md`, match the question against the one-line triggers, open **only** the matching `knowledge/<technique>.md`. Never read the whole folder. |
| **Capture** | `pe-kb capture <slug>` — write a new entry, deploy, and commit in one step. |
| **Refresh** | `pe-kb refresh <slug>` — research current SOTA, overwrite the canonical entry in place, restamp date and sources. |

Inside Claude Code or Codex you usually don't run anything by hand: ask a prompt-engineering question — or notice you are *composing* a prompt mid-task — and the skill surfaces, then does the index → entry lookup for you.

### Adding or updating an entry by hand

```sh
~/.local/share/prompt-engineering-knowledge-base/scripts/pe-kb capture my-technique <<'EOF'
---
name: my-technique
description: one line — a retrieval trigger, "load when…"
last_refreshed: 2026-06-20
sources:
  - Author, "Title", Year — https://example.com
---

A distilled, self-contained explanation that stands on its own.

Related: [[some-other-technique]]
EOF
```

`pe-kb` writes the chezmoi source, runs `chezmoi apply`, updates the index line, and makes exactly one git commit. It refuses an entry that has no `sources` or `last_refreshed`, and refuses to clobber an existing technique (use `refresh` to supersede one).

## What's inside

12 seed entries, each grounded in and cited to primary sources, grouped by the lever each technique pulls.

**Clarity & structure — compose a clear directive**

| Technique | In one line |
|---|---|
| `explicit-instruction` | Replace a vague ask with a precise directive: output, format, constraints, audience, success criteria. |
| `delimiters-and-structure` | Fence the parts of a prompt with XML tags / sections / delimiters so each role is parsed unambiguously. |
| `role-and-system-framing` | Set persona, expertise, and standing behavior in the system layer before the task. |
| `positive-instruction` | Say what to do (affirmative) rather than what not to do. |

**Exemplars — few-shot**

| Technique | In one line |
|---|---|
| `few-shot-prompting` | Show worked input→output demonstrations to steer format and behavior (in-context learning). |
| `exemplar-selection` | Choose *which* examples and in *what order* — diversity, consistency, label/recency bias. |

**Reasoning elicitation**

| Technique | In one line |
|---|---|
| `chain-of-thought` | Elicit step-by-step reasoning before the answer; self-consistency; the reasoning-model caveat. |
| `reasoning-scaffolds` | Impose a reasoning shape (reason-then-answer, plan-then-execute) within one call. |

**Output shaping**

| Technique | In one line |
|---|---|
| `output-format-instruction` | Describe the output shape in the prompt — vs. enforcing it with a machine schema. |
| `response-prefill` | Seed the start of the answer to constrain format/style. |

**Prompt-level decomposition**

| Technique | In one line |
|---|---|
| `task-decomposition-in-prompt` | Break a complex ask into ordered sub-steps within one prompt. |
| `prompt-chaining` | Sequence prompts so each call consumes the prior output. |

## Design principles

The store enforces these as structure, not just intent:

- **Persists across sessions** — every change is a git commit; nothing is lost when a conversation ends.
- **Human-readable** — plain markdown, no database or decoding step.
- **Self-contained entries** — each file is usable on its own, not a transcript dump.
- **Changes only on explicit invocation** — no schedule, no background process, no auto-refresh.
- **Internally consistent** — one canonical entry per technique; `pe-kb` is the single write path.
- **Sourced and dated** — every entry cites its sources and records when it was last verified.

## Boundary

This store is about **composing the instruction**. Managing what *fills* the context window — truncation, retrieval, compaction, prefix-cache, lost-in-the-middle — is its sibling, the `context-engineering-knowledge-base`. A prompt-composition need routes here; a window-management need routes there.

## How it's stored

The store is managed by [chezmoi](https://chezmoi.io) and lives in its git repo as `dot_local/share/prompt-engineering-knowledge-base/`. Edits are made to the chezmoi **source**, then `chezmoi apply` deploys them here — the deployed copy is never hand-edited. That makes the store reproducible on any machine and gives every change a recoverable history.
