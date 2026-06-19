---
description: Suggest a session-tailored /compact focus line, in the context-engineering-knowledge-base spirit
---

Produce a single ready-to-paste `/compact <focus>` command line that compacts THIS conversation well, following the `<compaction>` policy in the global instructions (load `~/.local/share/context-engineering-knowledge-base/knowledge/compaction-vs-eviction.md` and siblings if you need the full reasoning).

Tailor it to the actual session — name the real items, do not emit a generic template:

- **Keep**: current goal, key decisions + rationale, live constraints, open threads / next steps.
- **Verbatim**: any must-not-lose instructions and the task statement.
- **Refs not payloads**: replace bulky content with file paths, commit SHAs, entry slugs, URLs.
- **Drop**: resolved tangents, dead ends, verbose tool output, superseded attempts.
- Smallest high-signal summary that still lets the work continue.

Output ONLY the `/compact …` line, in a code block, ready to copy — then one sentence reminding the user to paste it (you cannot run it yourself).
