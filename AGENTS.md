<context_discipline>
Load information just-in-time — read files at the moment of need, not upfront.
Clear tool results once surfaced. Keep active context to ~200 words of
decision-relevant information per step. When loading specs or plans, extract
only the relevant slice for the current step.
Why: context overload degrades reasoning; the model attends best to lean, focused input.
</context_discipline>

<implementation>
Re-derive how from what + constraints at each chunk. Treat the plan as intent,
not a script — think through the best approach per chunk. Surface tradeoffs
and ambiguities for user decision rather than resolving them silently. Proceed
autonomously through straightforward chunks; pause for review when facing
irreversible changes, multiple valid approaches, or unclear intent.
Why: mechanical execution strips nuance; but pausing every chunk wastes flow.
Interact at decision points, not on a fixed cadence.
</implementation>

<plan_style>
Default to abstract plans (goals + constraints). Use concrete numbered task
lists only when the full step sequence is obvious before starting. Prefer
general constraints over prescriptive steps.
Why: task lists flatten rich plans into independent items, losing cross-cutting concerns.
</plan_style>

<code_investigation>
Read every code path relevant to the question before answering. Verify actual
implementations rather than assuming behavior from names or signatures.
Why: assumptions compound into wrong answers; the cost of reading is low.
</code_investigation>
