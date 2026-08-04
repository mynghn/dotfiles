# Session craft — the gate before, the loop after

Contents: [Fixing the reader contract](#fixing-the-reader-contract) ·
[Writing self-check questions](#writing-self-check-questions) ·
[The live close](#the-live-close) · [The ledger](#the-ledger)

## Fixing the reader contract

The gate is short by design. Its job is three variables — purpose, baseline, budget — and it earns
its place only by changing what gets built.

**Facts are looked up; decisions are asked.** Never ask what the work does, which files moved, what
the tests cover, or what a module is called — read it. Ask only what the artifact cannot tell you:
who the reader is, what they will do next, and how deep to go.

**Every question arrives from a formed position.** Investigate first, then put the question with your
own recommended answer and the reason behind it — the recommendation of an autonomous party, not a
menu of unweighed options. A menu whose every option carries your recommendation is delegated
sign-off, not a question.

**Assert a default with a veto window instead of asking, whenever a defensible default exists.**

> "You're reviewing this change, so I'll go deep on the concurrency fix and stay shallow on the test
> reorganization, at about ten minutes of reading. Say the word if you want it the other way."

beats "What would you like me to focus on?" — it costs the reader a glance instead of a decision, and
it still gives them the wheel.

**Ask one question at a time**, and only where the answer changes what you build *and* defensible
answers genuinely diverge. Two questions is usually one too many.

**What each variable buys, so you know when it matters:**

| If you learn… | It changes… |
|---|---|
| the reader will modify this, not just read it | invariants and fragile assumptions earn a section |
| the reader knows the stack but not this codebase | local idioms earn a section; language basics get no space |
| the reader is new to the domain | the "why it exists" layer grows; jargon gets defined on first use |
| the budget is five minutes | one trace, one figure, and the decision points — nothing else |

**With no reply, proceed.** Silence is not a blocker: take the default (general orientation, an
engineer new to this codebase but fluent in its language, about ten minutes), record it in the reader
contract, and build. A digest that arrived is worth more than a question that waited.

## Writing self-check questions

The digest carries at least three, near the end, spanning the three abilities. They test
understanding rather than recall, so a reader who skimmed cannot answer them from memory of the
wording.

- **Predict** — "The renderer is mid-flush when a mouse event arrives. What does the handler see?"
- **Explain** — "Why does capturing the handler rather than the whole view keep the intent clearer?"
- **Locate** — "A new field needs the same protection. Where do you add the lock, and where do you
  check that nothing else reads it?"

Every answer must be available from the digest. Say so, and point at the section that carries it —
a question whose answer is not in the document is homework, not a check.

Draw them from the load-bearing parts: if a question can be answered without understanding the hard
part, it is testing the wrong thing.

## The live close

When the reader is present, one or two prediction prompts beat any amount of extra prose, because a
prediction reveals the model the reader actually built. Take the hardest part and ask them to walk
it:

> "A request comes in with an expired token — walk me through where it goes."

Then respond to what the answer reveals: a missing step points at a section that needs opening, a
confident wrong turn points at something the digest asserted instead of showing. Offer this; a reader
who would rather just read is entitled to.

## The ledger

Close by accounting for what the digest could not fully settle. Every open thing ends in exactly one
of three states, and none are left floating:

- **verified** — checked against the source, with the anchor to prove it;
- **accepted** — a known approximation the reader should hold loosely, named as such;
- **carried forward** — a real open question, stated so the reader knows it is theirs to resolve.

This is also where inaccessible sources land: a private ticket you could not open, history that was
squashed, a subsystem outside the budget. Naming the edge of the map is part of drawing it honestly.
