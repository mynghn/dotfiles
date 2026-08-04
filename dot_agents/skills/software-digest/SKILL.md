---
name: software-digest
description: "Produces a single self-contained HTML digest that makes a completed piece of software work fast and accurately understandable, and runs the short understanding session around it: a brief elicitation of the reader's purpose, prior knowledge, and reading budget before writing, then self-check prompts after. Takes delivered work as input — a pull request or set of PRs, a repository or checkout, a diff or commit range, an issue or ticket carrying the work's context, or any mix. Use when completed work is handed over to be understood: reviewing a colleague's finished PR, onboarding to an unfamiliar service, picking up a handoff, or sizing up an open-source project before adopting it; and on requests like digest this PR, understand this repo, walk me through this codebase, get me up to speed, or what does this change actually do. For explaining one already-identified concept, or a quick answer about a single known function, answer directly instead."
argument-hint: "[PR link | repo path | diff range | issue key] [what you need it for]"
---

# software-digest

Turn delivered software work into a reader's understanding — fast, accurate, and whole.

## What "understood" means here

Done is not "a document exists." Done is that the reader, within the purpose they stated, can:

- **predict** — given an input or a condition, say what the thing does;
- **explain** — say why a behavior happens, and why the work is shaped this way;
- **locate** — say where to look to change or check any particular thing.

Every step below serves those three. They are also what the digest's own self-check questions test.

## 1. Read the work before asking anything

Facts come from the artifact; only decisions come from the person. Establish from the source first:

- **Input shape.** A *change* (pull request, diff, commit range): the subject is the delta — the prior
  state, what moved, and how far the effect reaches. A *system* (repository, checkout, service): the
  subject is the whole — what it is, what it does, how it is shaped. Given both, the system is the
  ground and the change is the figure on it.
- **The written record.** Descriptions, linked issues or tickets, commit messages, design notes,
  README, tests. These carry intent, which code cannot show.
- **What you cannot reach** — a private link, missing history, a codebase too large to read whole.
  Note it now; the digest will say so plainly and work with what is available.

## 2. Fix the reader contract before writing

Three variables govern everything downstream:

| Variable | Question it answers | What it governs |
|---|---|---|
| **Purpose** | What will the reader do once they understand this? | Which layers earn depth |
| **Baseline** | What do they already know — this codebase, this stack, this domain? | What counts as new; which terms get defined |
| **Budget** | How much reading time is on offer? | Scope — never accuracy |

How to fill them:

- **Investigate first, then ask.** Never ask what you could have read.
- **Bring a formed position.** Each question arrives with your own recommended answer and its reason.
- **Prefer a default with a veto window over a question**: "I'll assume you are on the backend team,
  new to this service, and want about ten minutes — say the word if that is off."
- **Ask one question at a time**, and only where the answer changes what you build and where
  defensible answers genuinely diverge.
- **With no signal at all**, proceed on: general orientation, a competent engineer new to this
  codebase but fluent in its main language, about ten minutes of reading.

Record the resolved contract in the digest itself — it tells the reader who the map was drawn for
and where it stops. Question craft is in `references/session-craft.md`.

## 3. Decide what earns space

**Cover the layers the purpose needs.** When unsure of order, use this one — each layer gives the
next a place to attach:

1. **Why it exists** — the problem, the situation, the constraint. Mined from issues, descriptions,
   and history.
2. **What it does** — observable behavior and contract from the outside, including what it
   deliberately does not do.
3. **How it is shaped** — structure, data model, and runtime flow. Static shape and dynamic behavior
   are two different pictures; a subject with moving parts usually needs both.
4. **How it works exactly** — the code that carries the weight.
5. **Why this way** — the decisions where a real alternative existed, and what was traded for what.
   Attach each to the layer it belongs to rather than collecting them at the end.

**Select rather than summarize.** The core move is deciding what matters, and saying so: what carries
the load (break it and the thing breaks), what is routine and safely skimmed, and what is
deliberately unusual and therefore surprising.

**Spend the baseline.** The cheapest true explanation names what the reader already knows and
describes only the departures — "a standard worker queue, with three departures: …". Recognition
costs a reader far less than construction.

**Let the budget cut scope, not accuracy.** A narrow digest that is exactly right beats a broad one
that wobbles. Say what you left out.

**Triangulate.** Intent (the issue), claim (the description), and actual (the code) sometimes
disagree. That gap is among the most valuable things you can hand a reader: show all three and state
the difference.

**Describe, and leave the verdict to the reader.** Report what is there, what it costs, and which
alternatives were live at each decision — the reader forms the judgment.

## 4. Write the digest

Deliver **one self-contained HTML file**; craft is in `references/page-craft.md`. Write it in the
language the user is working in.

**Derive the structure from this subject.** Before building, ask: *would this same outline, and this
same palette, fit any other work of this kind?* A yes on either means you have reached for a
template — re-derive both from what is actually in front of you. Catching that now is cheap.

**Ordering constraints** — a partial order, not a script: thesis near the top · define a term before
using it · the problem before its fix · the evidence after the mechanism.

**Hold the fidelity contract.** Compression is legitimate as *encapsulation*: name a part, state its
contract, defer its internals — as long as every claim at the current level stays true when that box
is opened. Detail whose omission would change what is true at the current level stays in. The hard or
surprising part is the one thing that always stays; it is what the reader came for.

**Show, don't assert.** Every load-bearing claim earns one concrete thing — a diagram, a traced
example, a code excerpt. The hardest claim earns the most vivid one.

**Make each diagram answer one question**, and caption it with the takeaway rather than a
description of the drawing. Anything with structure — a flow, a before/after, a state machine, a
dependency graph, a sequence — earns a figure; anything linear does not need one. One figure carries
the page: the one showing the hardest claim gets the weight, and the others stay quiet so it reads as
the signal. See `references/diagram-craft.md`.

**Guide the reading of the code** with whichever of these the purpose calls for — a reading path · an
end-to-end trace of one representative scenario · a dissection of the core mechanism · a map of the
decision points · a dictionary of the local idioms · the fragile assumptions and invariants. Details
and worked shapes in `references/code-guide-types.md`.

**Organize by intent, not by file.** A reader who wanted a file list would run `git diff --stat`.
Group by what the work is trying to accomplish, and let the files fall where the intent puts them.

## 5. Verify before you deliver

A wrong map is worse than no map, because the reader cannot check it — that is precisely why they
asked. Re-open the source and confirm, claim by claim:

Do this by listing, then checking — not by re-reading and trusting the re-read. Sweep the finished
draft once for each kind of claim below, write down every instance you find, and clear the list one
entry at a time. The failures that survive a verification pass are almost never the claim you
doubted; they are the one you never put on the list.

Check each claim at the span it covers, not at the span you happened to read:

- a claim about **one place** — the anchor resolves to that file and line, and that place says what
  you claim. When you name the symbol it belongs to, confirm that symbol's own boundaries enclose the
  line: a line sitting in a neighbouring helper or class reads as confirmation while saying something
  else;
- a claim about **the whole source** is settled by an exhaustive search before it is written,
  documentation included. These wear two disguises: the negative one — "only here", "nowhere else",
  "not in this repository" — and the enumeration, which claims completeness without a negative word
  in it. "The three places that read this field", "these are the call sites", "the four states it can
  be in": each is a claim about everywhere you did not look. Scope taken from where you expected the
  answer to live, rather than from looking, sends the reader away from a source that held it;
- every quantity — a count of files, a number of lines, a size, a range — was recomputed from the
  source as you wrote it. A number carried over from earlier reading is the easiest thing in a digest
  to get wrong and the hardest for a reader to think to doubt;
- every edge in every diagram corresponds to a real call, import, or data path;
- every claim marked `stated` traces to the passage that states it — re-read that passage rather than
  citing a section by the name you remember it having, and mark every inference as one;
- every place you compressed still holds true with the box opened — read each deferred box back
  against the sentence that introduces it, as a reader arriving from that sentence would. A summary
  and its own detail contradicting each other is the one error a careful reader is guaranteed to find.

Fix what fails. Where you cannot confirm something, mark it as inference or leave it out.

## 6. Deliver, then close the loop

1. Save it in the session's working directory as `<subject-slug>-digest.html`, and say where it is.
2. Put a distilled summary in the conversation — the thesis and the mechanism in a few paragraphs —
   so the thread carries the substance without opening the file.
3. The digest carries its own self-check questions, so a reader alone can test their understanding.
4. With the reader present, close with one or two prediction prompts drawn from the hardest part
   ("a request arrives with an expired token — walk me through where it goes"), and clear up what
   their answer reveals. Offer this; do not impose it.

## Output contract

The digest is a complete standalone document: `<!doctype html>`, `<html lang="…">`, a `<head>` with
charset, viewport, and `<title>`, all CSS and any JS inline, and no external fonts, stylesheets,
scripts, or images. It opens correctly from a local file with no network.

Four markup hooks are exact, because a reader and a checker both rely on them.

**Reader contract** — once, near the top:

```html
<section class="reader-contract">
  … who this is for and what they want from it · what it assumes is already known ·
  the reading budget · what it covers, and what it leaves out …
</section>
```

**Code anchors** — every reference to a specific place in the code:

```html
<code class="anchor" data-path="source/routing.py" data-line="142">source/routing.py:142</code>
```

`data-path` is repository-relative and `data-line` is a line number that exists in the source you
read. The visible text is yours to choose.

**Basis markers** — on every load-bearing claim that the code alone cannot prove:

```html
<p data-basis="stated" data-source="PR #1691 description">…</p>
<p data-basis="inferred">…</p>
```

`verified` — read from the code at a cited anchor · `stated` — asserted by a written source, named in
`data-source` · `inferred` — your own reasoning from the evidence.

**Self-check** — once, near the end; at least three questions spanning predict, explain, and locate,
each answerable from the digest:

```html
<section class="self-check"> … </section>
```

## References

- `references/page-craft.md` — the standalone-page skeleton, theming, type and layout, in-page
  progressive disclosure, and the generic look to steer away from
- `references/diagram-craft.md` — deriving a palette from the subject's own states, which figure
  answers which question, and inline-SVG primitives
- `references/code-guide-types.md` — the six ways to guide a reader through code, and when each fits
- `references/session-craft.md` — question craft for the reader contract, self-check question
  patterns, and the closing ledger
