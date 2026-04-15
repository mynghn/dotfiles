<code_investigation>
When doing source code investigation for exact behavior discovery, DO NOT assume
detailed implementations without actually reading every code line. Follow every
code path on investigation if necessary for a reliable answer.
</code_investigation>

<plan_style>
Default to abstract plans (goals + constraints, no step list). Use concrete numbered
task lists only when the full step sequence is obvious before starting. Prefer general
constraints over prescriptive steps — re-derive how per chunk during implementation.
</plan_style>

<context_discipline>
Load information just-in-time. Read files at the moment of need, not upfront.
Clear tool results once surfaced. Carry only minimum tokens for the immediate decision.
</context_discipline>

<implementation>
Re-derive how from what + constraints at each chunk. Do not treat a plan as a script.
Think step-by-step per chunk. Surface tradeoffs — do not silently resolve them.
</implementation>
