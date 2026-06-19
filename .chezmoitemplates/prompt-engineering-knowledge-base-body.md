# Prompt Engineering Knowledge Base

A personal, version-controlled store of distilled **prompt-engineering** knowledge — how to compose the instruction itself: clarity and structure, few-shot exemplars, reasoning elicitation, output-format wording, and prompt-level task decomposition. Use it to **retrieve** a technique on demand, **capture** a new distilled lesson, or **refresh** an entry against current state-of-the-art.

The corpus is provider-neutral and shared; this skill is a thin entry point into it. The store lives at:

- Index:   `~/.local/share/prompt-engineering-knowledge-base/INDEX.md`
- Entries: `~/.local/share/prompt-engineering-knowledge-base/knowledge/<technique-slug>.md`
- Helper:  `~/.local/share/prompt-engineering-knowledge-base/scripts/pe-kb`

**One mutation channel.** Read entries directly, but never hand-edit them to change the store. Every write goes through `pe-kb`, which edits the chezmoi source, runs `chezmoi apply`, and commits — so each change is one recoverable commit and the store stays self-consistent. The store changes only when you invoke `pe-kb`; nothing mutates it automatically or on a schedule.

## Retrieve (the default action)

Progressive disclosure — load the smallest relevant slice, never the whole corpus:

1. Read `INDEX.md`. Each line is `- [<slug>](knowledge/<slug>.md) — <one-line trigger>`.
2. Match the question against the trigger lines; pick the one entry (or few) that fit.
3. Read only those `knowledge/<slug>.md` file(s). Each entry is self-contained — you do not need its neighbours. Follow a `Related: [[other-slug]]` link only if the question genuinely needs it.

Do not read the entire `knowledge/` directory. The INDEX exists so you load one entry, not all of them.

## Capture (add a new distilled lesson)

When a reusable prompt-engineering technique is worth keeping:

1. Pick a kebab-case `<slug>`. Check `INDEX.md` first — if the technique already exists, **refresh** it instead of adding a duplicate.
2. Author the entry and pipe it to the helper on stdin:

   ```sh
   ~/.local/share/prompt-engineering-knowledge-base/scripts/pe-kb capture <slug> <<'EOF'
   ---
   name: <slug>
   description: <one line — a retrieval trigger: "load when…">
   last_refreshed: <YYYY-MM-DD>
   sources:
     - <citation or url>
   ---

   <distilled, self-contained explanation — usable without any other entry>

   Related: [[<other-slug>]]
   EOF
   ```

3. The helper validates the frontmatter (it refuses an entry with no `sources` or `last_refreshed`), writes the source, applies, upserts the INDEX line, and makes one commit. The entry is now retrievable by the steps above.

A good entry is distilled (not a transcript), self-contained, grounded in ≥1 authoritative source, and dated.

## Refresh (reconcile an entry against current SOTA)

Refresh is manual and explicit — there is no automatic staleness check; the decision to refresh is always yours.

1. Pick the target `<slug>` from `INDEX.md`.
2. Research current state-of-the-art **with citations** (web search, or the `deep-research` skill).
3. Distill and **reconcile in place**: rewrite the single canonical entry so it supersedes stale claims — do not append a competing view. Restamp `last_refreshed`; refresh `sources`.
4. Apply via the helper (it requires the entry to already exist):

   ```sh
   ~/.local/share/prompt-engineering-knowledge-base/scripts/pe-kb refresh <slug> < updated-entry.md
   ```

`refresh` overwrites the one canonical entry, keeping the slug stable, and commits. There is never a duplicate, and the prior version stays recoverable from git history.
