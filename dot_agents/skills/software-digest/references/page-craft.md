# Page craft — the standalone digest document

Contents: [Skeleton](#skeleton) · [Theme and color plumbing](#theme-and-color-plumbing) ·
[Type and layout](#type-and-layout) · [In-page progressive disclosure](#in-page-progressive-disclosure) ·
[Containment](#containment) · [The generic look to steer away from](#the-generic-look-to-steer-away-from) ·
[Checklist](#checklist)

Nothing wraps this file — it is the whole document, opened from disk, offline. Everything it needs
travels inside it.

## Skeleton

```html
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>… subject — digest</title>
<style>
  :root {
    color-scheme: light dark;
    /* semantic state colors — see diagram-craft.md; both prose and SVG read these */
    --ink: #1a1d21; --muted: #5d6672; --bg: #faf9f7; --surface: #fff; --line: #e2e0db;
    --state-a: #0e6f68; --state-b: #b1692b; --state-c: #9c3a2d;
  }
  @media (prefers-color-scheme: dark) {
    :root { --ink: #e6e8ea; --muted: #99a1ab; --bg: #14171a; --surface: #1c2024; --line: #2c3137;
            --state-a: #4ec2b2; --state-b: #e0a05c; --state-c: #e08a72; }
  }
  *, *::before, *::after { box-sizing: border-box; }
  body { margin: 0; padding: 0 1.25rem; background: var(--bg); color: var(--ink);
         font: 1.02rem/1.62 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
  .wrap { max-width: 46rem; margin: 0 auto; padding: 2.5rem 0 5rem; }
  img { max-width: 100%; }
</style>
</head>
<body>
<div class="wrap"> … </div>
</body>
</html>
```

Use system font stacks only — a web font would need the network. A serif stack
(`Charter, Georgia, serif`) suits long prose; `ui-monospace, SFMono-Regular, Menlo, monospace` marks
the subject's own vocabulary (identifiers, paths, states) so code-like terms read as one family.

## Theme and color plumbing

Declare every color once as a custom property on `:root`, and override the set inside
`@media (prefers-color-scheme: dark)`. Then **both the prose and the SVG read the same variables** —
`fill="var(--state-a)"`, never a literal hex inside a diagram. A figure whose colors are hard-coded
goes unreadable the moment the reader's system is in dark mode.

A theme toggle is optional. If you add one, stamp `data-theme="dark|light"` on the root element and
write `:root[data-theme="dark"] { … }` rules that win over the media query in both directions.

## Type and layout

- Cap the measure at about **64–70 characters** (`max-width: 46rem` on the container does this).
- Claims in primary ink; captions, glosses, and asides in `--muted`. The contrast difference is the
  hierarchy — you rarely need a third weight.
- Frames and cards: `1px solid var(--line)`, `border-radius: 10px`, padding `1rem 1.2rem`.
  Backgrounds `var(--surface)`, one step off the page background rather than a heavy fill.
- Comparison grids: `grid-template-columns: 1fr 1fr`, collapsing to `1fr` under `680px`.
- Keep any motion to a single load reveal at most, inside
  `@media (prefers-reduced-motion: no-preference)`.
- Real `<button>` elements for anything interactive, and a visible `:focus-visible` outline.

## In-page progressive disclosure

The digest is a map that zooms. Three layers, in the same document:

1. **Skim layer** — the title, a one-paragraph thesis, and the section headings. Because every
   paragraph leads with its claim, a reader who reads only headings and first sentences still gets
   the through-line. Write for that reader explicitly.
2. **Read layer** — the sections themselves, in order.
3. **Depth layer** — the parts only some readers need, behind `<details>`.

A collapsible is legitimate only when its summary line states a contract that stays true unopened —
the same encapsulation test the digest as a whole runs on:

```html
<details>
  <summary>All eleven touched files, and why each moved</summary>
  …
</details>
```

For a digest with more than about five sections, add a short table of contents after the reader
contract, linking to `id`-bearing headings. Keep it flat.

## Containment

**The page body never scrolls sideways.** Every wide thing carries its own scroll box:

```html
<figure>
  <div class="fig-frame"><svg viewBox="0 0 720 240" role="img" aria-label="…">…</svg></div>
  <figcaption>One line stating what to take from it.</figcaption>
</figure>
```

```css
.fig-frame { border: 1px solid var(--line); border-radius: 12px; padding: 1.4rem 1.1rem .6rem;
             background: var(--surface); overflow-x: auto; }
.fig-frame svg { display: block; margin: 0 auto; min-width: 34rem; }
figcaption { color: var(--muted); font-size: .9rem; margin-top: .7rem; max-width: 64ch; }
pre, .tablewrap { overflow-x: auto; }
```

The `min-width` on the SVG is deliberate: rather than squashing below legibility, the figure keeps
its size and its own frame scrolls.

## The generic look to steer away from

A digest that looks machine-issued reads as machine-thought. These are the tells:

- a purple-to-blue gradient banner, or any gradient used as decoration;
- glassmorphic translucent cards and heavy drop shadows;
- emoji as section markers;
- full-saturation rainbow accents where colors carry no state;
- everything centered, with an oversized hero heading above thin content;
- uniform card grids that impose the same shape on unlike things.

The positive form of all six: let the subject's own distinctions choose the colors, keep chrome
quiet, and spend visual weight exactly once — on the hardest idea.

## Checklist

- [ ] Complete document; opens from `file://` with the network off.
- [ ] All CSS and JS inline; no external font, stylesheet, script, or image.
- [ ] Colors as `:root` custom properties; dark mode covered; SVG fills read the variables.
- [ ] Body does not scroll sideways at 375px; every wide element has its own scroll box.
- [ ] Every `<svg>` carries `role="img"` and an `aria-label`.
- [ ] Every figure has a caption stating its takeaway.
- [ ] Reader contract near the top; self-check section near the end.
- [ ] Attributes double-quoted, non-void tags closed, `<title>` present.
