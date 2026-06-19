---
name: compact-focus
description: Generate a session-tailored `/compact <focus>` line so manual compaction keeps the working set and drops noise, in the context-engineering-knowledge-base spirit. Use when the user asks to compact, clear, or condense the session, before a long context-heavy task, or to hand the user a focused compaction command. The user runs /compact; you cannot.
---

Produce a single ready-to-paste `/compact <focus>` command line that compacts THIS conversation well, following the `<compaction>` policy in the global instructions (load `~/.local/share/context-engineering-knowledge-base/knowledge/compaction-vs-eviction.md` and its siblings if you need the full reasoning).

Tailor it to the actual session — name the real items, do not emit a generic template:

- **Keep** (only what would otherwise be *lost*): goal, live decisions + their load-bearing rationale, constraints, open threads / next steps. Anything reloadable — rationale already in a doc, shipped code, file:line facts — goes under **Refs**, not restated here.
- **Verbatim**: any must-not-lose instructions and the task statement.
- **Refs not payloads**: replace bulky content with file paths, commit SHAs, entry slugs, URLs.
- **Drop**: resolved tangents, dead ends, verbose tool output, superseded attempts.
- Smallest high-signal summary that still lets the work continue.

Lay it out as labeled blocks — `Keep:` / `Verbatim:` / `Refs:` / `Drop:`, each on its own line(s), one directive per line — never a run-on wall. Terse content, explicit structure: a clearly delimited focus is followed more reliably by the summarizer (a dense paragraph forces it to infer section boundaries and risks dropping directives), and stays sanity-checkable at a glance.

Write the prose in the language the user uses in their own prompts (not the session aggregate — model output, loaded docs, and code skew English); keep technical anchors — paths, identifiers, code, SHAs, proto names — verbatim.

Output ONLY the `/compact …` line, in a code block, ready to copy — then one sentence telling the user to paste it (you cannot run `/compact` yourself). If you surfaced this proactively rather than on request, add a short note on why now (e.g. session length, before a heavy task).
