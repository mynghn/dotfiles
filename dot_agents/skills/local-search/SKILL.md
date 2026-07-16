---
name: local-search
description: Searches local files by meaning instead of by exact text — finds code from a description of its behavior, and finds knowledge-base entries, agent skills, docs, and notes from a description of their content. Use when the exact word, symbol, or filename is unknown, when a keyword search came back empty or noisy, or when the question is where something is handled, how something works, or which document covers a topic. Runs fully offline. For an exact token or regex that is already known, use ripgrep directly.
---

## Route by what is known about the target

| The target is known by | Use | Because |
|---|---|---|
| An exact token, symbol, or regex | `rg` | Exact, no index, always current. |
| Behavior or concept, in code | `ck` | Embeddings match code whose names are unknown. |
| Meaning, in prose | `qmd` | Expansion and reranking absorb vocabulary drift. |

Reach for `ck` or `qmd` when `rg` cannot work because the wording is unknown — not in place of it.

## Commands

Pass the flags as written; each is load-bearing.

Code — searches any tree:

```bash
ck -n --hybrid --topk 10 "verifies a signed token before granting access" src/
```

`-n` gives line numbers; without it a result carries no line. `--topk 10` is not optional: `--hybrid` returns *every* ranked match when uncapped — a small tree yields ~100KB — so without it the answer arrives buried in the corpus. Use `--sem` when keyword overlap misleads the hybrid ranking; it caps at 10 on its own. The first search of a tree builds its `.ck/` index and is slow: that is indexing, not failure.

Prose — searches registered collections:

```bash
qmd update && qmd query "how should context be curated" -c kb-vault --full-path
```

`qmd update` re-indexes changed files so results match current contents; it is fast, so run it each time. `--full-path` gives an openable `path:line`; without it results are `qmd://` ids that cannot be opened.

Collections: `kb-vault` (distilled knowledge), `agent-skills` (agent instructions), `chezmoi-docs` (managed planning docs).

## Examples

**Do** — the symbol is known exactly:
`rg -n "authenticate_user" src/`
**Don't**: `ck -n --hybrid "authenticate_user" src/` — spends an index build on what `rg` answers instantly.

**Do** — the behavior is known, the name is not:
`ck -n --hybrid --topk 10 "rejects a request once the rate limit is exceeded" src/`
**Don't**: `rg -n "rate limit" src/` — misses code that never spells the phrase.

**Do** — the idea is known, the entry's wording is not:
`qmd update && qmd query "why long prompts lose accuracy" -c kb-vault --full-path`
**Don't**: `qmd query "context" -c kb-vault` — one word cannot be ranked, and the location is unopenable.

**Do** — describe the behavior, not a word in it:
`ck -n --hybrid --topk 10 "where the retry budget is decremented" src/`
**Don't**: `ck -n --hybrid "retry" src/` — names a token, which is `rg`'s job, and uncapped returns the whole tree ranked.

## When a collection is not indexed

`Collection not found: <name>` with exit 1 means the corpus was never registered. Report that, and give the fix:

```bash
qmd collection add <path> --name <name> && qmd embed
```

`No results found.` with exit 0 is different: the collection is indexed and genuinely holds no match. Never report an unregistered collection as "nothing found" — one is a gap in coverage, the other is an answer.
