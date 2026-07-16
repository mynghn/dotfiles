---
name: illustrated-explainer
description: "Produces a faithful, easy-to-follow explanation of an unfamiliar concept, system, algorithm, or mechanism for a smart stranger, in whichever medium best fits the content — a self-contained visual page when the subject is structural or has moving parts, a tighter inline answer when it's linear. Grounds the visuals in the subject's own states (color encodes meaning, not decoration), derives structure from the subject rather than a fixed template, shows the hard part at full resolution, and pairs it with a distilled summary in chat. Use when the user asks to explain, illustrate, teach, or walk through how something works; wants a full-resolution, from-scratch, easy-to-read, or explain-to-a-stranger explanation; says they couldn't follow or couldn't see something; or for teaching, onboarding, and architecture or mechanism walkthroughs. Composes with a page-craft skill (on Claude Code, artifact-design) for visual craft; discovers specialized craft skills as needed. Not for quick factual answers, one-liners, or code-only replies."
---

# Illustrated explainer

Make an unfamiliar concept, system, algorithm, or mechanism understandable to a **smart stranger**, at **full fidelity**, in **whichever medium best serves the content** — then pair it with a distilled summary in the conversation. The skill owns the **medium choice, the fidelity contract, the pedagogy, the subject-grounding, and the diagrams**; it *composes* craft skills rather than re-implementing them (see Composition).

## When this fires

Explaining how something works to someone unfamiliar; a "full-resolution", "from scratch", "easy-to-read", or "explain to a stranger" request; the user says they "couldn't follow" or "couldn't see" something; teaching, onboarding, architecture or mechanism walkthroughs. This is a **teaching** tool, not a presentation one — for recaps, dashboards, or status tables that *present* rather than *explain*, it is the wrong fit. For a quick factual answer, a one-liner, or code only, answer inline instead.

## Procedure

Steps 3–5 are where the quality lives. Steps 3 and 5 (grounding the visuals, drawing the diagrams) apply when step 2 lands on a visual page; for an inline answer they collapse into the prose.

1. **Pin the subject.** Name one concrete subject, its audience (assume a smart stranger — no shared jargon, unless the user names a different audience), and the single thing they should walk away understanding. Everything below serves that one job.

2. **Choose the medium by fit, not habit.** Deliver in whichever form best serves *this* content, among those you render at genuinely high quality — do not default mechanically to one. Judge on a single axis: how much the content must be *seen* to be understood — its structure, states, moving parts — versus merely *read*. The more it must be seen, the more it earns a rich, self-contained visual page; the more it is linear or verbal, the lighter the medium. **Whenever the delivered medium is a published, self-contained HTML page** — on Claude Code, an **Artifact** — it must honor that target's constraints (see Published-page constraints).

3. **Ground the visuals in the subject's own states.** Before styling, list the subject's real distinctions — the ones the explanation turns on (proven vs unproven, granted vs refused, before vs after, healthy vs failing). Map each to a color so the palette *encodes meaning*; a legend names them once. Only then bring in craft (see Composition). See `references/playbook.md` → "Palette from states".

4. **Build the explanation by method, not template.** Do not stamp a fixed section list. Derive the structure from the subject, governed by the invariants and ordering constraints below; the "arc" in the playbook is a *default to adapt*, never a schema.
   - **Invariants:** define-on-first-use · claim-first paragraphs · motivate the problem before the mechanism · show-don't-assert (every load-bearing claim earns one example, diagram, or step; the *hardest* claim earns the most vivid one) · one narrative thread, not parallel sections · color and shape encode real state.
   - **Ordering constraints** — a partial order, not a sequence: thesis near the top · define before use · problem before its fix · trust-argument after the mechanism.
   - **Fidelity contract (non-negotiable):** the stranger gets the friendly, step-by-step treatment *and* the complete, honest mechanism. **Never trade a load-bearing detail for a smoother read; the hard or surprising part is the one thing you may not omit** — it is what they came for. You may *encapsulate* — name a sub-part, state its contract, defer its internals — but only when every claim at the current level stays true if the box were opened. Deferring detail behind an honest, named boundary is compression; dropping detail that changes what's true at the current level is unfaithful. See `references/playbook.md` → "The arc".
   - **Falsify before building (a cheap gate).** Before spending build effort, ask of the plan: *would I produce this same palette and this same structure for any similar subject?* A yes on either axis means you've templated — re-derive it from *this* subject before you draw. Catching it in the plan is cheap; catching it in a built page is not.

5. **Show the structural parts.** Anything with structure — a graph, pipeline, before/after, state machine, data flow, or dataset — gets an inline diagram with a one-line caption and a semantic legend. Prose explains; diagrams show. **One figure carries the page:** of all the diagrams, the one that shows the *hardest* claim earns the most craft and visual weight — keep the rest quiet and uniform so that one reads as the signal. Spend visual boldness once, and on the hard part, never on decoration. **Interactivity is welcome when it earns its place** — letting the reader replay or drive the hard part, compare states, or step the mechanism — never as decoration; static-first is the default. See `references/playbook.md` → "Diagram cookbook", "Chart craft", "Earned interactivity".

6. **Pair it with an inline summary.** After delivering a page, put a tight distilled version in the conversation — the thesis plus the mechanism in a few paragraphs — so the thread carries the gist and work can continue without opening the page.

## Composition — delegate craft, don't re-implement

Own the pedagogy; borrow the craft. Three rules:

- **Delegate to subordinate pure-craft skills** — ones that own only "how it looks" and hold no opinion on scope, medium, or pedagogy. **Resident hot set:** your harness's page-craft skill (on Claude Code, `artifact-design`) for palette pairing, type, layout, and anti-templating — load it at step 3 once the semantic palette is set. The playbook's diagram and chart cookbook covers the common visual craft in-house.
- **Discover the long tail just-in-time.** For a specialized craft surface a *particular* subject needs (maps, math typesetting, musical notation, molecular structure…), find and vet the right craft skill *at that moment* via the skills ecosystem (`find-skills` / `npx skills find`) rather than a fixed roster. Vet before trusting: a delegate must be reputable, pure-craft, subordinate, and self-contained-compatible (no mandated external CDN library).
- **Borrow, don't delegate, from opinion-carrying peers.** The test is a skill's *termination*, not its topic: if its definition of "done" differs from yours — it optimizes for a distinctive-looking page; you, for a reader who can re-explain the idea — it is a peer, not a subordinate, even when it shares your medium. Lift its concrete techniques into the playbook under your own constraints; never load it wholesale. Subordination can't be enforced by assertion — once another skill's body is in context, its imperatives compete with yours on salience — so you subordinate by *what you load* (a pure-craft skill, per the first rule) versus *what you read-and-distill* (a peer). A general visual-output generator built to make pages look distinctive is the standing example: borrow its calibration, keep control of the page.

## The bar (check the result against this)

- A reader could re-explain the idea to someone else afterward.
- Nothing is asserted without being shown or exemplified once — especially the hard part.
- No load-bearing detail was dropped for convenience; every simplification is an honest, named encapsulation, not a distortion.
- The medium fits the content — a page only where structure must be seen; inline where it needn't be.
- The visual identity is legible with the labels removed: color and shape carry the meaning.
- One figure carries the page: the hardest claim gets the most vivid treatment, and nothing else competes with it for attention.
- Interactivity, if any, does explanatory work; motion is restrained.
- It reads as a story with one thread, not a spec with parallel sections.

## Published-page constraints (non-negotiable when the medium is a self-contained published page)

Honor whatever sandbox your harness renders self-contained pages in — on Claude Code, an **Artifact**. For Claude Code Artifacts: inline CSS/JS, no external fonts or CDNs (the CSP blocks them), theme-aware, content-only (no `<html>`/`<head>`/`<body>` wrapper — the host adds them), a stable `<title>`, and an emoji favicon. Full property-level checklist in `references/playbook.md`.
