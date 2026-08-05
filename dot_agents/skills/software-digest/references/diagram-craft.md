# Diagram craft — figures that carry explanatory load

Contents: [Palette from the subject's states](#palette-from-the-subjects-states) ·
[Which figure answers which question](#which-figure-answers-which-question) ·
[SVG primitives](#svg-primitives) · [Discipline](#discipline)

## Palette from the subject's states

Before styling anything, list the **two to four distinctions this explanation actually turns on** —
states of the subject, not sections of the document. For delivered software work they are usually
one of:

- `unchanged / added / removed` — for a change
- `hot path / cold path` — where the work happens
- `before / after` — a migration or a fix
- `caller / boundary / callee` — a crossing
- `safe / guarded / unguarded` — a concurrency or validation story

Give each state a hue with real-world logic behind it: ordered and proven reads as deep teal; caution
or contention as ochre; a stop or a defeat as clay red. Pick neutrals with a faint bias toward the
primary accent so the ground reads chosen rather than default. Publish one small legend near the
first figure, and never re-explain it.

Two rules make the encoding honest:

- **Never carry meaning by hue alone.** Pair every hue with a shape, a dash pattern, a position, or a
  label — it must survive grayscale and color blindness. `stroke-dasharray="5 4"` plus a tint plus
  the state's hue is three redundant channels for "uncertain or concurrent."
- **Falsify the palette.** If the finished palette would fit any other subject just as well, you
  skipped the derivation. Go back to the state list.

## Which figure answers which question

| The reader's question | The figure |
|---|---|
| What are the parts, and what talks to what? | Node-and-edge diagram, inline SVG |
| What happens, in what order, across which components? | Sequence or swimlane |
| What shape does one request or record travel through? | Pipeline or flow, left to right |
| What changed? | Before/after pair, identical structure so the eye compares |
| What states can this be in, and what moves it? | State machine |
| Where does this sit in the larger system? | Context diagram, the subject filled, neighbors outlined |
| How much, how many, how distributed? | A chart — and only when the number carries the point |

Charts follow the ordinary honesty rules: bars start at zero, no 3D ever, no pie beyond a rough
split of fewer than six slices, both axes labeled, and series labeled directly rather than through a
legend lookup. A misleading chart is an unfaithful omission wearing a disguise.

## SVG primitives

Hand-write the SVG. All of these read theme variables, so they survive dark mode.

**Directed edge with an arrowhead**

```html
<defs>
  <marker id="ah" markerWidth="10" markerHeight="10" refX="8" refY="5" orient="auto">
    <path d="M0,0 L10,5 L0,10 z" fill="var(--state-a)"/>
  </marker>
</defs>
<line x1="166" y1="73" x2="212" y2="73" stroke="var(--state-a)" stroke-width="1.6"
      marker-end="url(#ah)"/>
```

**Labeled node with a gloss** — wrap a group so the whole thing inherits type:

```html
<g font-family="ui-monospace, Menlo, monospace" font-size="12.5">
  <rect x="24" y="48" width="140" height="50" rx="8" fill="var(--surface)"
        stroke="var(--line)"/>
  <text x="94" y="70" text-anchor="middle" fill="var(--ink)">Router</text>
  <text x="94" y="86" text-anchor="middle" font-size="10.5" fill="var(--muted)">path → endpoint</text>
</g>
```

**Highlighting a slice** — SVG has no z-index, so paint the backdrop first, then the nodes on top,
then a small label naming what the slice is.

**Uncertainty or concurrency** — `stroke-dasharray="5 4"` with a tinted fill and the caution hue.

**Accessibility** — every `<svg>` gets `role="img"` and an `aria-label` that states what the figure
shows, in a sentence.

When the shape is a simple two-column comparison or a legend, plain HTML and CSS beat SVG: it
reflows, it themes for free, and it costs less to write.

## Discipline

- **One idea per figure.** If it needs two captions, it is two figures.
- **The caption states the takeaway**, not what is drawn. One line.
- **Label with the subject's real vocabulary** — the identifiers and paths that appear in the code.
- **Numbering means sequence.** Number the steps of a walk; never number parallel topics.
- **One figure carries the page.** The figure showing the hardest claim gets the craft and the visual
  weight; every other figure stays quiet and uniform so that one reads as the signal. Boldness spent
  on every figure is spent on none.
- **Prose explains; diagrams show.** A figure that repeats what the paragraph already said is
  decoration — cut it.
