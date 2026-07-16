#!/usr/bin/env python3
"""Partially manage ~/AGENTS.md.

Chezmoi owns the local operating-policy blocks below. Metacognition owns its
installed AGENTS.md trigger blocks (for example context_engineering,
prompt_engineering, compaction, and handoff), so this modifier preserves those
blocks from the live file instead of carrying their content in dotfiles.

Unrecognized blocks are preserved, which is what keeps the other writer's
spans safe -- so dropping a block from OWNED is not enough to remove it from
the live file, and RETIRED names the tags to delete instead of preserve.

Every char here is preloaded by every agent session, so the owned blocks carry
each fact exactly once and stay under BUDGET_CHARS.
"""
import re
import sys

ORDER = (
    "operating_frame",
    "context_engineering",
    "prompt_engineering",
    "compaction",
    "handoff",
    "document_brevity",
    "implementation",
    "code_investigation",
    "change_discipline",
)

OWNED = {
    "operating_frame",
    "document_brevity",
    "implementation",
    "code_investigation",
    "change_discipline",
}

RETIRED = {
    "context_discipline",
    "ko_output_quality",
    "plan_style",
    "research_before_planning",
}

TERMINAL = "change_discipline"

BUDGET_CHARS = 2000

BLOCK_RE = re.compile(r"^<([a-z_]+)>\n.*?^</\1>\n?", re.MULTILINE | re.DOTALL)


def blocks(text):
    out = []
    pos = 0
    for match in BLOCK_RE.finditer(text):
        if match.start() > pos:
            out.append((None, text[pos:match.start()]))
        out.append((match.group(1), match.group(0).rstrip("\n")))
        pos = match.end()
    if pos < len(text):
        out.append((None, text[pos:]))
    return out


def canonical_blocks():
    found = {tag: body for tag, body in blocks(DOTFILES_AGENTS_BLOCKS) if tag in OWNED}
    missing = sorted(OWNED - set(found))
    if missing:
        raise SystemExit("modify_AGENTS.md missing owned blocks: " + ", ".join(missing))
    measured = sum(len(body) for body in found.values())
    if measured > BUDGET_CHARS:
        raise SystemExit(
            "modify_AGENTS.md owned blocks measure {} chars, over the {} budget "
            "by {}".format(measured, BUDGET_CHARS, measured - BUDGET_CHARS)
        )
    return found


def main():
    live_parts = blocks(sys.stdin.read())
    live_by_tag = {}
    extras = []
    for tag, text in live_parts:
        if tag is None:
            if text.strip():
                extras.append(text.strip("\n"))
            continue
        if tag in RETIRED:
            continue
        if tag not in live_by_tag:
            live_by_tag[tag] = text
        elif tag not in OWNED:
            extras.append(text)

    owned = canonical_blocks()
    emitted = set()
    output = []
    for tag in ORDER:
        if tag == TERMINAL:
            continue
        if tag in owned:
            output.append(owned[tag])
            emitted.add(tag)
        elif tag in live_by_tag:
            output.append(live_by_tag[tag])
            emitted.add(tag)

    for tag, text in live_parts:
        if tag and tag not in emitted and tag not in OWNED and tag not in RETIRED:
            output.append(text)
            emitted.add(tag)

    output.extend(extras)
    output.append(owned[TERMINAL])
    sys.stdout.write("\n\n".join(part.rstrip("\n") for part in output if part.strip()).rstrip() + "\n")


DOTFILES_AGENTS_BLOCKS = r"""
<operating_frame>
Context is finite working memory: low-value tokens tax later reasoning.
Curate with four levers: select only what the step needs; compress to
conclusions, not raw material; write plan/state/decisions to a file so they
survive compaction or a new session; isolate breadth-heavy work (wide
research, broad code/web scans) in a sub-agent returning conclusions, not
trails. Read as widely as correctness needs; retain narrowly, a 3-5 fact
summary driving the next step; re-read on demand. Take only a spec or plan's
current-step slice; skip stale or superseded parts.
</operating_frame>

<document_brevity>
Write brief by default; stop when the point lands. Lead with the conclusion,
then distill support into points that stand alone. Put genuinely required
depth in a separate linked file, not the main one. A document's own
conventions outrank these defaults.
</document_brevity>

<implementation>
Plans and specs are intent, not scripts: re-derive each chunk from current
code, tests, and constraints. Plan as goals + constraints; number tasks only
when the full sequence is obvious upfront. Feature-branch off the branch base
by default. Move autonomously; pause and surface at decision points —
irreversible or far-reaching changes, rival approaches, unclear intent, a
tradeoff or ambiguity you'd settle alone.
</implementation>

<code_investigation>
Branch base (what ships): main → master → repo default, synced with remote,
unless the user names one; investigate from it. Read what makes an answer or
change defensible: trace call sites, dataflow, tests, config, project docs.
Verify implementations, not names or signatures. On non-trivial external or
current facts, claim and plan from primary sources, not memory.
</code_investigation>

<change_discipline>
Inspect relevant local changes before editing. Keep patches scoped to the
task; never revert unrelated or user-authored work. Verify with the smallest
meaningful test, typecheck, lint, or diff.
</change_discipline>
"""


if __name__ == "__main__":
    main()
