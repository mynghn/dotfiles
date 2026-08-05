# Guiding a reader through code

Six shapes. Pick by what the reader's purpose needs — most digests use two or three, and a digest
that uses all six has stopped selecting. Each one below states what it is for, what it looks like,
and how it fails.

## 1. Reading path

**For:** a reader who will open the code themselves and needs a door and an order.

An ordered list of places to open, each with the one thing to notice there and the reason it comes at
this position. Start at a real entry point — a `main`, a route registration, a handler, a CLI command,
a test that exercises the whole thing — not at the alphabetically first file.

```
1. cmd/serve.go:31 — the process starts here; note that the renderer is chosen before the model.
2. renderer/cursed.go:88 — the chosen renderer's contract. Everything downstream assumes it.
3. …
```

**Fails when** it becomes a file listing with line numbers attached. If the "why this position"
column is empty, you have a directory, not a path.

## 2. End-to-end trace of one representative scenario

**For:** almost every reader. This is the bridge between static structure and runtime behavior, and
it is the single most reliably useful piece of a digest.

Pick one concrete, representative case — a request with real values, a record moving through a
pipeline, a keystroke reaching a handler — and follow it from entry to exit, naming each place it
passes and what happens to it there. Pair it with a sequence figure so the reader can see the shape
they are reading.

Choose the scenario that touches the work's core. A trace through the boring path teaches nothing.

**Fails when** the values stay abstract. "The request is validated" is prose; "`POST /orders` with an
expired token reaches `auth/middleware.py:44`, which returns 401 before the handler runs" is a trace.

## 3. Dissection of the core mechanism

**For:** work whose weight sits in one algorithm, invariant, state machine, or protocol.

Take the one thing that carries the load and open it fully: what it guarantees, how it guarantees it,
which invariant must hold, and what happens when it does not. This is where the fidelity contract
binds hardest — the hard part is what the reader came for, so it is the one thing that may not be
compressed.

Where the mechanism is a concurrency or ordering property, say plainly what is protected, by what,
and across which boundary — those are the claims readers most often get wrong.

**Fails when** it is asserted rather than shown. A mechanism section without a figure, a trace, or a
quoted excerpt is a claim wearing a heading.

## 4. Map of the decision points

**For:** a reader who needs to know where the work could have gone another way.

The places where a real alternative existed: what was chosen, what it was chosen over, and what was
traded. The written record often states these outright — a description saying "opted to capture just
the handler rather than duplicating the reference" is a decision point handed to you.

Report the decision and its trade; the reader forms the verdict. Mark the basis: a rationale from a
description is `stated`, a rationale you reconstructed from the code is `inferred`.

**Fails when** every difference becomes a "decision." A decision point needs a live alternative — if
there was only one reasonable way, it is a mechanism, not a choice.

## 5. Dictionary of local idioms

**For:** onboarding and handoff, where the reader will keep reading long after the digest ends.

The recurring patterns, naming conventions, and house helpers of this codebase — the things that,
once known, let a reader skim what previously needed decoding. Three to seven entries, each with one
example pointing at a real place.

```
`*Msg` types — every event the runtime delivers is a value, never a callback. See tea.go:210.
`fooOrDie(…)` — the house helper that panics on setup errors; only legal during initialization.
```

**Fails when** it lists language features rather than local convention. The reader knows what a
decorator is; they do not know that in this codebase decorators mean "registered at import time."

## 6. Fragile assumptions and invariants

**For:** anyone who will modify the work rather than only read it.

What must stay true, what is easy to break by accident, and what couples to what across a distance.
This is descriptive: name the assumption and where it is relied upon, so the reader can keep it in
mind.

```
`lastView` is written under the mutex and read on the mouse path — every new reader of that
field must take the same lock (renderer/cursed.go:88, renderer/cursed.go:141).
```

**Fails when** it drifts into grading the code. State the constraint and where it binds; the reader
decides what to think of it.

---

**Choosing.** Orientation and handoff lean on 1, 2, 5, and 6. Understanding a specific change leans on
2, 3, and 4. Sizing up an unfamiliar project leans on 2 and 4, with 3 only where the project's claim
to be interesting lives. When the budget is short, the trace (2) survives and the rest yields — it
carries more understanding per line than anything else here.
