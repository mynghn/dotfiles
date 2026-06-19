# Tool Design Knowledge Base

A small, personal, version-controlled store of distilled **tool-design** knowledge — how to shape the tools an agent calls: their descriptions, input/output schemas, granularity and consolidation, naming and namespacing, what they return, error messages, structured output, and tool evaluations.

It is built to be **picked up when needed**: an agent (Claude Code or Codex) reads the index, loads only the one entry relevant to the question, and gets back to work. You can read every file here yourself — it is all plain markdown.

## Why this exists

Useful tool-design lessons tend to evaporate at the end of a session. This store keeps them:

- **Durable** — survives across sessions; lives in git, not in a conversation.
- **Retrievable** — a one-line index turns "what do I know about X?" into loading a single file.
- **Self-correcting** — entries can be refreshed against current state-of-the-art, in place, with the old version recoverable from history.
- **Shared** — one corpus serves both Claude Code and Codex.

## Layout

```
~/.local/share/tool-design-knowledge-base/
├── README.md            ← you are here
├── INDEX.md             ← one line per practice; the retrieval entry point
├── knowledge/
│   └── <practice>.md    ← one self-contained, sourced, dated entry per practice
└── scripts/
    └── td-kb            ← the only tool that writes to the store
```

Two thin adapters point agents at this core (same body, provider-specific frontmatter):

- `~/.claude/skills/tool-design-knowledge-base/SKILL.md` (Claude Code)
- `~/.codex/skills/tool-design-knowledge-base/SKILL.md` (Codex)

## How it works

Three actions, all described in full inside the `SKILL.md` body:

| Action | What happens |
|---|---|
| **Retrieve** | Read `INDEX.md`, match the question against the one-line triggers, open **only** the matching `knowledge/<practice>.md`. Never read the whole folder. |
| **Capture** | `td-kb capture <slug>` — write a new entry, deploy, and commit in one step. |
| **Refresh** | `td-kb refresh <slug>` — research current SOTA, overwrite the canonical entry in place, restamp date and sources. |

Inside Claude Code or Codex you usually don't run anything by hand: ask a tool-design question — or notice you are *designing a tool* mid-task — and the skill surfaces, then does the index → entry lookup for you.

### Adding or updating an entry by hand

```sh
~/.local/share/tool-design-knowledge-base/scripts/td-kb capture my-practice <<'EOF'
---
name: my-practice
description: one line — a retrieval trigger, "use when…"
last_refreshed: 2026-06-20
sources:
  - Author, "Title", Year — https://example.com
---

A distilled, self-contained explanation that stands on its own.

Related: [[some-other-practice]]
EOF
```

`td-kb` writes the chezmoi source, runs `chezmoi apply`, updates the index line, and makes exactly one git commit. It refuses an entry that has no `sources` or `last_refreshed`, and refuses to clobber an existing practice (use `refresh` to supersede one).

## What's inside

10 seed practices, each grounded in and cited to primary sources, grouped by the design surface each one shapes.

**Tool definition & description**

| Practice | In one line |
|---|---|
| `tool-description-writing` | The description/docstring the model reads like a prompt: what the tool does, when to use it, what each parameter means. |
| `input-schema-design` | Parameters shaped to be hard to call wrong — clear names, types, enums over free text, defaults, constraints. |
| `structured-output-shaping` | A tool's enforced output contract (`json_schema` / `response_format` / function-call schema). |
| `tool-naming-and-namespacing` | Names and prefixes that disambiguate, group by service, and aid selection. |

**Granularity & consolidation**

| Practice | In one line |
|---|---|
| `tool-granularity-and-consolidation` | Few high-value tools vs. many thin wrappers; build for the agent's task, not the raw API surface. |
| `tool-set-size-and-selection` | Keep the tool set small enough for reliable selection. |

**Return design**

| Practice | In one line |
|---|---|
| `high-signal-returns` | Return what the agent needs to act on — semantic identifiers, meaningful context — not raw API dumps. |
| `token-efficient-returns` | Bound, paginate, truncate, filter; the return spends the agent's context budget. |

**Errors**

| Practice | In one line |
|---|---|
| `tool-error-design` | Actionable, agent-readable error messages that steer self-correction toward the valid call. |

**Evaluation**

| Practice | In one line |
|---|---|
| `tool-evaluation` | Eval-driven tool design: measure selection + argument-construction accuracy, iterate descriptions/schemas from transcripts. |

## Design principles

The store enforces these as structure, not just intent:

- **Persists across sessions** — every change is a git commit; nothing is lost when a conversation ends.
- **Human-readable** — plain markdown, no database or decoding step.
- **Self-contained entries** — each file is usable on its own, not a transcript dump.
- **Changes only on explicit invocation** — no schedule, no background process, no auto-refresh.
- **Internally consistent** — one canonical entry per practice; `td-kb` is the single write path.
- **Sourced and dated** — every entry cites its sources and records when it was last verified.

## Boundary

This store is about **the tool contract an agent calls** — a tool's description, input/output schema, granularity, naming, what it returns, and its error messages. Two siblings own the adjacent territory:

- Composing the **instruction** itself — wording, exemplars, reasoning elicitation, the prose "format as JSON" ask — is the `prompt-engineering-knowledge-base`.
- Managing what already **fills the context window** — truncation, retrieval, compaction, tool *results* already in the window — is the `context-engineering-knowledge-base`.

A tool-contract need routes here; an instruction-wording need routes to prompt-engineering; a window-management need routes to context-engineering.

## How it's stored

The store is managed by [chezmoi](https://chezmoi.io) and lives in its git repo as `dot_local/share/tool-design-knowledge-base/`. Edits are made to the chezmoi **source**, then `chezmoi apply` deploys them here — the deployed copy is never hand-edited. That makes the store reproducible on any machine and gives every change a recoverable history.
