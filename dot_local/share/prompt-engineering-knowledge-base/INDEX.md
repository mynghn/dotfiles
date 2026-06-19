# Prompt Engineering Knowledge Base — Index

Distilled prompt-engineering techniques, one self-contained entry per file under
`knowledge/`. Read this index first, then load only the entries matching the
query — not the whole corpus.

Each line: `- [<technique-slug>](knowledge/<technique-slug>.md) — <one-line description>`

## Techniques

<!-- one line per technique; appended by capture/refresh via scripts/pe-kb -->

- [delimiters-and-structure](knowledge/delimiters-and-structure.md) — Wording a prompt that mixes several roles — instructions, context, reference data, examples, the user's input — and the model blurs them or follows the wrong part; deciding how to fence each section (XML tags, markdown headings, delimiters) so each role is parsed unambiguously.
- [explicit-instruction](knowledge/explicit-instruction.md) — Replacing a vague ask with a precise directive — stating exactly what is wanted: the desired output, format, constraints, intended audience, and success criteria, instead of relying on the model to infer intent.
