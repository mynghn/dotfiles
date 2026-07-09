# Illustrated explainer — playbook

The heavy, reusable material for building an explainer Artifact. Load this when
you reach steps 3–5. The running example throughout is a real one: an explainer
for a ledger engine that builds a graph of "what provably happened before what"
and walks it — a subject with three states (proven order, concurrent/unproven,
refused). Adapt the shapes; keep the discipline.

---

## Palette from states (step 3)

The move that separates a grounded page from a templated one: **derive the
accent colors from the subject's own distinctions, then let a legend name them
once.** Color stops being decoration and becomes a second channel of meaning —
the page reads even with the labels stripped off.

Method:
1. List the 2–4 distinctions the explanation actually turns on. Not "sections" —
   *states of the thing*. For the ledger: `provable order` · `concurrent
   (unproven)` · `refused`.
2. Give each a hue with a real-world logic, not a random pick. Ledger example:
   - `provable / granted / before` → a **deep teal** `#0e6f68` (ledger ink, the "spine")
   - `concurrent / uncertain` → an **ochre** `#b1692b` (caution, unresolved)
   - `refused / defeated` → a **clay red** `#9c3a2d` (a stop)
3. Choose neutrals with a faint bias toward the primary accent (a cool paper
   `#e9edee`, deep slate ink `#16212a`) so the ground reads *chosen*, not default.
4. Publish a small legend near the top so the reader learns the code once:

```html
<div class="legend">
  <span><span class="dot" style="background:#0e6f68"></span> provable order (≺)</span>
  <span><span class="dot" style="background:#b1692b"></span> concurrent (∥) — unproven</span>
  <span><span class="dot" style="background:#9c3a2d"></span> refused / defeated</span>
</div>
```

5. *Then* load `artifact-design` for the type pairing, layout, spacing, and its
   anti-templating checklist. This skill decides the semantic palette;
   `artifact-design` executes the craft around it. Avoid the current AI-design
   clichés it warns about (cream + serif + terracotta; lone acid-green pop;
   everything centered; rounded-everything).

---

## The arc (step 4)

Order the page as a single narrative thread. Each section leads with a
one-sentence claim (its heading or first line), and every term is defined the
first time it appears. A good default sequence — drop or merge sections the
subject doesn't need, never reorder past → present → why:

| # | Section | Its job | Test it passes |
|---|---------|---------|----------------|
| 0 | **Thesis** | One sentence: what this is and the single surprising claim. | A stranger knows what they're about to learn. |
| 1 | **The problem** | Why the naive approach fails; make the difficulty vivid and concrete. | The reader *feels* the problem before the fix. |
| 2 | **The idea** | The core move in plain language, plus the one rule that governs everything. | Stated without mechanism — just the intuition. |
| 3 | **The mechanism — full resolution** | How it actually works. This is the section people came for; do not abbreviate it. Use a before/after if you're correcting a misconception. | The hard part is *shown*, not asserted. |
| 4 | **A worked example** | One concrete case walked end to end, with the exact reads/steps. | The reader can replay it themselves. |
| 5 | **Why it holds** | The trust argument — an invariant, a proof sketch, an adversarial test, measured evidence. Be honest about limits. | Skepticism is answered, not dodged. |
| 6 | **What's next** | The open edges / how to use it / how it plugs in. | The reader knows what to do with this. |

Rules of thumb:
- **Define-on-first-use.** No term appears before its one-line definition. Jargon
  is the fastest way to lose a stranger.
- **Claim-first paragraphs.** Lead with the conclusion; support it after. A reader
  skimming headings and first sentences should still get the through-line.
- **Show, don't assert — once.** Every load-bearing claim earns one example, one
  diagram, or one worked step. The hardest claim earns the most vivid one.
- **Numbering means sequence.** Only number sections/steps when order actually
  carries information (a pipeline, a walk). Don't number parallel topics.

---

## Diagram cookbook (step 5)

Prefer inline **SVG** for precise labeled structure (graphs, flows, before/after
geometry) and **HTML/CSS** for card-style compares and legends. Keep every wide
figure in its own scroll box. Copyable primitives below.

### Figure frame + scroll box

```html
<figure>
  <div class="fig-frame"><svg viewBox="0 0 720 220" role="img" aria-label="...">…</svg></div>
  <figcaption>One line that says what the reader should take from it.</figcaption>
</figure>
```
```css
.fig-frame { background:#fff; border:1px solid #d2dbdb; border-radius:12px;
  padding:24px 18px 10px; overflow-x:auto; }
.fig-frame svg { display:block; margin:0 auto; min-width:560px; }
figcaption { color:#5b6c71; font-size:.92rem; margin-top:12px; max-width:64ch; }
```

### Arrowhead marker + a directed edge (the "≺ / flows-to" relation)

```html
<defs>
  <marker id="ah" markerWidth="10" markerHeight="10" refX="8" refY="5" orient="auto">
    <path d="M0,0 L10,5 L0,10 z" fill="#0e6f68"/>
  </marker>
</defs>
<line x1="166" y1="73" x2="200" y2="73" stroke="#0e6f68" stroke-width="1.6" marker-end="url(#ah)"/>
```

### A labeled node box (two-line: title + gloss)

```html
<g font-family="ui-monospace, Menlo, monospace" font-size="12.5">
  <rect x="24" y="48" width="150" height="50" rx="8" fill="#fff" stroke="#0e6f68"/>
  <text x="99" y="70" text-anchor="middle" fill="#16212a">approve · PR1</text>
  <text x="99" y="86" text-anchor="middle" fill="#5b6c71" font-size="11">Alice reviews</text>
</g>
```

### Concurrency / uncertainty (dashed, ochre)

```html
<rect x="204" y="160" width="200" height="50" rx="8" fill="#f6ecdf"
      stroke="#b1692b" stroke-dasharray="5 4"/>
<text x="304" y="192" text-anchor="middle" fill="#b1692b" font-size="15">∥</text>
```

### Highlight a subset (shade a backdrop rect *behind* the nodes)

For "everything before e", "the relevant slice", "what this step reads":

```html
<rect x="8" y="30" width="520" height="86" rx="12" fill="#dbeeeb"/>  <!-- draw FIRST -->
<text x="20" y="24" fill="#0a4d47" font-size="11" font-weight="700">↓ e — the slice this step reads</text>
<!-- then the node boxes on top -->
```

### Before/after (a correction) — two HTML cards, semantic-colored

Use when the point is "it used to do X (wrong), now it does Y". Red-tagged old,
teal-tagged new; identical structure so the eye compares.

```html
<div class="compare">
  <div class="card old"><h4><span class="tag">before</span> the flaw</h4><p>…</p></div>
  <div class="card new"><h4><span class="tag">now</span> the fix</h4><p>…</p></div>
</div>
```
```css
.compare { display:grid; grid-template-columns:1fr 1fr; gap:16px; }
@media (max-width:680px){ .compare{ grid-template-columns:1fr; } }
.card { background:#fff; border:1px solid #d2dbdb; border-radius:10px; padding:20px; }
.card.old h4 { color:#9c3a2d; } .card.new h4 { color:#0e6f68; }
.tag { font-family:ui-monospace,monospace; font-size:10px; letter-spacing:.1em;
  text-transform:uppercase; padding:2px 7px; border-radius:20px; border:1px solid currentColor; }
```

### Legend (HTML, put it once near the top)

```css
.legend { display:flex; flex-wrap:wrap; gap:8px 20px; font-family:ui-monospace,monospace;
  font-size:12px; color:#5b6c71; }
.legend span { display:inline-flex; align-items:center; gap:7px; }
.legend .dot { width:11px; height:11px; border-radius:3px; }
```

Diagram discipline:
- One idea per figure. If it needs two captions, it's two figures.
- Label with the subject's real vocabulary (mono font ties code-like terms together).
- Every figure earns a caption that states the takeaway, not what's drawn.
- `role="img"` + `aria-label` on each SVG; never rely on color alone (pair hue with shape/dashes/labels).

---

## Pair with an inline summary (step 6)

The Artifact is the deliverable, but the conversation should still carry the
gist — so the reader can act without opening the side panel, and so a later
session (or a compaction) keeps the substance. After publishing, post in-thread:
the one-sentence thesis, then the mechanism distilled to a few paragraphs (the
same through-line as the page, minus the diagrams), then any open decision. Link
the Artifact. Keep it skimmable; it is the page's abstract, not a second copy.

---

## Artifact constraints checklist

- [ ] Content only — no `<html>`/`<head>`/`<body>` wrapper (the tool wraps it).
- [ ] All CSS/JS inline; images as `data:` URIs; **no external fonts or CDNs** (CSP blocks them) — use system stacks (`ui-monospace…`, a serif stack, a sans stack).
- [ ] Body never scrolls sideways: every wide table/diagram/code block in its own `overflow-x:auto` container; images `max-width:100%`.
- [ ] Theme-aware unless the design deliberately commits to one look (`@media (prefers-color-scheme: dark)` + the viewer's `data-theme` override).
- [ ] Motion is optional and restrained — a single load reveal at most; gate it behind `prefers-reduced-motion`. Excess animation reads as AI-generated.
- [ ] Visible keyboard focus; every non-void tag closed; attributes double-quoted.
- [ ] Stable `<title>` and an emoji favicon; keep both constant across redeploys (edit the same file path to update in place).
