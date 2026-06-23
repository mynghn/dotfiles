#!/usr/bin/env python3
"""Partially manage ~/AGENTS.md.

Chezmoi owns the local operating-policy blocks below. Metacognition owns its
installed AGENTS.md trigger blocks (for example context_engineering,
prompt_engineering, compaction, and handoff), so this modifier preserves those
blocks from the live file instead of carrying their content in dotfiles.
"""
import re
import sys

ORDER = (
    "operating_frame",
    "context_discipline",
    "context_engineering",
    "prompt_engineering",
    "compaction",
    "handoff",
    "document_brevity",
    "implementation",
    "plan_style",
    "code_investigation",
    "research_before_planning",
    "change_discipline",
)

OWNED = {
    "operating_frame",
    "context_discipline",
    "document_brevity",
    "implementation",
    "plan_style",
    "code_investigation",
    "research_before_planning",
    "change_discipline",
}

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
        if tag not in live_by_tag:
            live_by_tag[tag] = text
        elif tag not in OWNED:
            extras.append(text)

    owned = canonical_blocks()
    emitted = set()
    output = []
    for tag in ORDER:
        if tag in owned:
            output.append(owned[tag])
            emitted.add(tag)
        elif tag in live_by_tag:
            output.append(live_by_tag[tag])
            emitted.add(tag)

    for tag, text in live_parts:
        if tag and tag not in emitted and tag not in OWNED:
            output.append(text)
            emitted.add(tag)

    output.extend(extras)
    sys.stdout.write("\n\n".join(part.rstrip("\n") for part in output if part.strip()).rstrip() + "\n")


DOTFILES_AGENTS_BLOCKS = r"""
<operating_frame>
Context is finite working memory, not a free buffer: every token you carry
spends an attention budget that low-value tokens tax later. Curate with four
levers — select (pull in only what the step needs), compress (carry the
distilled conclusion, not the raw material), write (persist
plan/state/decisions to a durable file so they survive compaction or a fresh
session), isolate (push breadth-heavy work the window shouldn't hold — wide
research, broad code/web scans — into a sub-agent that returns its conclusion,
not its raw trail). Read as widely as correctness demands; retain narrowly and
re-read on demand.
Branch base (referenced below): latest production branch, synced with remote —
`main` → `master` → repo default — unless the user names one.
</operating_frame>

<context_discipline>
Keep a 3-5 fact working summary driving the next step. From a spec or plan,
take only the current step's slice — ignore stale or superseded sections.
</context_discipline>

<document_brevity>
Write brief by default; stop when the point lands. Lead with the conclusion,
then distill support into points that stand alone. When depth is genuinely
required, segregate it into a separate linked file rather than inflating the
main one. Respect the document's conventions.
</document_brevity>

<implementation>
Treat plans and specs as intent + constraints, not scripts: re-derive the
implementation from current code, tests, and constraints at each chunk. Work
on a feature branch off the branch base unless the user specifies one. Surface
tradeoffs and ambiguities for the user rather than resolving them silently.
Move autonomously through straightforward chunks; pause at decision points —
irreversible changes, multiple valid approaches, unclear intent.
Why: mechanical execution strips nuance, but pausing every chunk wastes flow
— interact at decisions, not on a cadence.
</implementation>

<plan_style>
Default to abstract plans (goals + constraints). Use concrete numbered task
lists only when the full sequence is obvious before starting.
Why: task lists flatten cross-cutting concerns into independent items.
</plan_style>

<code_investigation>
Investigate from the branch base so "current behavior" is what's shipped.
Read the paths needed to make the answer or change defensible — trace call
sites, data flow, tests, and config where they affect behavior. Verify
actual implementations, not behavior inferred from names or signatures.
Why: assumptions compound into wrong answers; targeted reading is cheap,
exhaustive reading is not the goal.
</code_investigation>

<research_before_planning>
For non-trivial decisions on external or current facts, fetch primary
sources (official docs, SOTA, engineering guides) before planning; for
repo-local decisions, treat code, tests, and project docs as the primary
sources. Don't rely on training knowledge for time-sensitive claims.
</research_before_planning>

<change_discipline>
Before editing, inspect relevant local changes. Keep patches scoped. Never
revert unrelated or user-authored work. Ask before broad refactors, contract
changes, migrations, or ambiguous behavior shifts. Verify with the smallest
meaningful test, typecheck, lint, or diff.
</change_discipline>
"""


if __name__ == "__main__":
    main()
