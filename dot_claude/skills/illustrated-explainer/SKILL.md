---
name: illustrated-explainer
description: "Produce a polished, self-contained visual explainer as an Artifact web page — for a concept, system, algorithm, or mechanism explained to someone unfamiliar. Grounds the visual identity in the subject's own states (colors encode real distinctions, not decoration), structures it as problem → idea → mechanism → worked-example → why-it-holds, draws the structural parts as inline diagrams, and pairs it with a distilled summary in the conversation. Use when the user asks to explain, illustrate, or walk through how something works; wants a full-resolution, from-scratch, easy-to-read, or explain-to-a-stranger explanation; says they could not follow or could not see something; or when a concept would land better as a visual page than as terminal text (teaching, onboarding, architecture and mechanism walkthroughs). Composes with the artifact-design skill for palette, type, and layout craft."
---

# Illustrated explainer

Turn a concept, system, algorithm, or mechanism into a polished visual explainer — an Artifact web page a newcomer can follow top to bottom — and pair it with a distilled summary in the conversation. This skill owns the **medium decision, the explanation arc, the subject-grounding, and the diagrams**; it composes with `artifact-design` for the visual-craft layer (palette, type, layout, anti-templating).

## When this fires

Explaining how something works to someone unfamiliar; a "full-resolution", "from scratch", "easy-to-read", or "explain to a stranger" request; the user says they "couldn't follow" or "couldn't see" something; teaching material, onboarding, architecture or mechanism walkthroughs. When the ask is a quick factual answer, a one-liner, or code only, this is the wrong tool — answer inline instead.

## Procedure

Work through these in order. Steps 3–5 are where the quality lives.

1. **Confirm the medium.** Build a visual Artifact only when the content is conceptual, structural, or has moving parts a diagram clarifies. For a short factual reply, stay in the thread. Write the page to a `.html` file and publish with the Artifact tool.
2. **Pin the subject.** Name one concrete subject, its audience (assume a smart stranger — no shared jargon), and the single thing they should walk away understanding. Everything below serves that one job.
3. **Ground the visuals in the subject's own states.** Before any styling, list the subject's real distinctions — the ones the explanation turns on (e.g. proven vs unproven, granted vs refused, before vs after, healthy vs failing). Map each to a color so the palette *encodes meaning*. A legend then names them once. Only now load `artifact-design` for palette/type/layout craft. See `references/playbook.md` → "Palette from states".
4. **Structure the explanation as an arc**, not a reference dump: thesis → the problem → the core idea → the mechanism *at full resolution* → a worked example → why it holds → what's next. Lead each section with a one-sentence claim; define every term the first time it appears. See `references/playbook.md` → "The arc".
5. **Draw the structural parts.** Anything with structure — a graph, a pipeline, a before/after, a state machine, a data flow — gets an inline SVG/HTML diagram with a one-line caption and a semantic legend. Prose explains; diagrams show. See `references/playbook.md` → "Diagram cookbook".
6. **Pair it with an inline summary.** After publishing, put a tight distilled version in the conversation — the thesis plus the mechanism in a few paragraphs — so the thread carries the gist and work can continue without opening the panel.

## The bar (check the result against this)

- A reader could re-explain the idea to someone else afterward.
- Nothing is asserted without being shown or exemplified once — especially the hard part.
- The visual identity is legible with the labels removed: color and shape carry the meaning.
- It reads as a story with one thread, not a spec with parallel sections.

## Artifact constraints (non-negotiable)

Self-contained: inline all CSS/JS, embed images as data URIs, no external fonts or CDNs (the CSP blocks them — use system font stacks). Responsive: wide diagrams scroll inside their own `overflow-x: auto` box so the page body never scrolls sideways. Theme-aware unless the design commits to one look. Set a stable `<title>` and an emoji favicon. Write page content only — no `<html>`, `<head>`, or `<body>` wrapper (the tool adds them). Full checklist in `references/playbook.md`.
