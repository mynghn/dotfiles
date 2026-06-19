# Context Engineering Knowledge Base

A small, personal, version-controlled store of distilled **context-engineering** knowledge — how to manage what goes into a language model's context window, why long contexts degrade, and the operations that counter it.

It is built to be **picked up when needed**: an agent (Claude Code or Codex) reads the index, loads only the one entry relevant to the question, and gets back to work. You can read every file here yourself — it is all plain markdown.

## Why this exists

Useful context-engineering lessons tend to evaporate at the end of a session. This store keeps them:

- **Durable** — survives across sessions; lives in git, not in a conversation.
- **Retrievable** — a one-line index turns "what do I know about X?" into loading a single file.
- **Self-correcting** — entries can be refreshed against current state-of-the-art, in place, with the old version recoverable from history.
- **Shared** — one corpus serves both Claude Code and Codex.

## Layout

```
~/.local/share/context-engineering-knowledge-base/
├── README.md            ← you are here
├── INDEX.md             ← one line per concept; the retrieval entry point
├── knowledge/
│   └── <concept>.md     ← one self-contained, sourced, dated entry per concept
└── scripts/
    └── ce-kb            ← the only tool that writes to the store
```

Two thin adapters point agents at this core (same body, provider-specific frontmatter):

- `~/.claude/skills/context-engineering-knowledge-base/SKILL.md` (Claude Code)
- `~/.codex/skills/context-engineering-knowledge-base/SKILL.md` (Codex)

## How it works

Three actions, all described in full inside the `SKILL.md` body:

| Action | What happens |
|---|---|
| **Retrieve** | Read `INDEX.md`, match the question against the one-line triggers, open **only** the matching `knowledge/<concept>.md`. Never read the whole folder. |
| **Capture** | `ce-kb capture <slug>` — write a new entry, deploy, and commit in one step. |
| **Refresh** | `ce-kb refresh <slug>` — research current SOTA, overwrite the canonical entry in place, restamp date and sources. |

Inside Claude Code or Codex you usually don't run anything by hand: ask a context-engineering question and the skill surfaces automatically, then does the index → entry lookup for you.

### Adding or updating an entry by hand

```sh
~/.local/share/context-engineering-knowledge-base/scripts/ce-kb capture my-concept <<'EOF'
---
name: my-concept
description: one line — a retrieval trigger, "load when…"
last_refreshed: 2026-06-19
sources:
  - Author, "Title", Year — https://example.com
---

A distilled, self-contained explanation that stands on its own.

Related: [[some-other-concept]]
EOF
```

`ce-kb` writes the chezmoi source, runs `chezmoi apply`, updates the index line, and makes exactly one git commit. It refuses an entry that has no `sources` or `last_refreshed`, and refuses to clobber an existing concept (use `refresh` to supersede one).

## What's inside

14 seed entries, each grounded in and cited to primary sources, grouped as **phenomena** (why context degrades) and **operations** (what to do about it).

**Phenomena — why context degrades**

| Concept | In one line |
|---|---|
| `lost-in-the-middle` | Facts in the middle of a long input are recalled worse than those at the start or end (U-shaped). |
| `attention-sinks` | Models dump attention on the first tokens; cut the prefix carelessly and generation destabilizes. |
| `context-rot` | Accuracy drops as input grows longer, even on trivial tasks (the length axis). |
| `distractor-sensitivity` | Even one irrelevant token lowers accuracy (the noise axis). |
| `literal-vs-latent-matching` | Recall collapses when it needs semantic inference instead of shared keywords (the noise axis). |
| `effective-vs-advertised-context` | The usable window is far smaller than the advertised size. |
| `three-axes-of-context-degradation` | An index frame grouping the above by position / length / noise. |

**Operations — what to do** (LangChain's write / select / compress / isolate)

| Concept | In one line |
|---|---|
| `context-as-working-set` | Treat context as finite working memory to curate, not a free buffer to fill (the parent frame). |
| `jit-loading` | *select* — hold references, load full content only at the moment of need. |
| `structured-note-taking` | *write* — persist plans/state outside the window and re-read on demand (the write-side of JIT). |
| `compaction-vs-eviction` | *compress* — summarize-and-reinitialize vs. simply dropping tokens. |
| `context-isolation` | *isolate* — give sub-tasks their own windows; condense results before returning. |
| `explore-then-compact-handoff` | The canonical instance of isolation: explore wide, hand back only the compacted result. |
| `prefix-cache-economics` | Order stable content first so reused tokens hit the cache — cheaper and faster. |

## Design principles

The store enforces these as structure, not just intent:

- **Persists across sessions** — every change is a git commit; nothing is lost when a conversation ends.
- **Human-readable** — plain markdown, no database or decoding step.
- **Self-contained entries** — each file is usable on its own, not a transcript dump.
- **Changes only on explicit invocation** — no schedule, no background process, no auto-refresh.
- **Internally consistent** — one canonical entry per concept; `ce-kb` is the single write path.
- **Sourced and dated** — every entry cites its sources and records when it was last verified.

## How it's stored

The store is managed by [chezmoi](https://chezmoi.io) and lives in its git repo as `dot_local/share/context-engineering-knowledge-base/`. Edits are made to the chezmoi **source**, then `chezmoi apply` deploys them here — the deployed copy is never hand-edited. That makes the store reproducible on any machine and gives every change a recoverable history.
