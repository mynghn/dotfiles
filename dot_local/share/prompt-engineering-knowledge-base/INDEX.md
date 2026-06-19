# Prompt Engineering Knowledge Base — Index

Distilled prompt-engineering techniques, one self-contained entry per file under
`knowledge/`. Read this index first, then load only the entries matching the
query — not the whole corpus.

Each line: `- [<technique-slug>](knowledge/<technique-slug>.md) — <one-line description>`

## Techniques

<!-- one line per technique; appended by capture/refresh via scripts/pe-kb -->

- [chain-of-thought](knowledge/chain-of-thought.md) — Asking a model to reason step by step before it answers, to raise accuracy on multi-step arithmetic, logic, or commonsense tasks; deciding whether to elicit explicit reasoning at all on a modern reasoning model.
- [delimiters-and-structure](knowledge/delimiters-and-structure.md) — Wording a prompt that mixes several roles — instructions, context, reference data, examples, the user's input — and the model blurs them or follows the wrong part; deciding how to fence each section (XML tags, markdown headings, delimiters) so each role is parsed unambiguously.
- [exemplar-selection](knowledge/exemplar-selection.md) — Choosing WHICH few-shot examples to include and in what ORDER — picking representative, diverse, correct, consistently-formatted exemplars, and countering majority-label/recency/order bias from a bad selection.
- [explicit-instruction](knowledge/explicit-instruction.md) — Replacing a vague ask with a precise directive — stating exactly what is wanted: the desired output, format, constraints, intended audience, and success criteria, instead of relying on the model to infer intent.
- [few-shot-prompting](knowledge/few-shot-prompting.md) — Steering output format, labels, tone, or a hard-to-describe task by showing worked input/output demonstrations in the prompt; deciding between zero/one/few examples or whether to add examples at all.
- [positive-instruction](knowledge/positive-instruction.md) — Writing a directive as a prohibition ("don't use markdown", "never ask for X") and the model violates or ignores it; converting negative constraints into affirmative "do this instead" instructions to steer behavior more reliably.
- [reasoning-scaffolds](knowledge/reasoning-scaffolds.md) — Structuring HOW a model reasons inside one prompt — reason-then-answer, plan-then-execute, decompose-then-solve — to lift accuracy on multi-step problems beyond a bare "think step by step"; also when to drop the scaffold for reasoning models.
- [role-and-system-framing](knowledge/role-and-system-framing.md) — Composing the system/developer message to set persona, expertise, stance, and standing behavior before the task; deciding what belongs in the system layer vs. the user turn; making a role earn its tokens instead of cosmetic "you are an expert" filler.
