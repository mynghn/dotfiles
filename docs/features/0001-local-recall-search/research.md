# 0001-local-recall-search — Research

## Predecessor failure evidence (mgrep)

- `mixedbread-ai/mgrep` — Apache-2.0, npm `@mixedbread/mgrep`, ~4.3k★, v0.1.13 (2026-04).
- Requires `mgrep login` / `MXBAI_API_KEY`; uploads files to a hosted Mixedbread Store; every search calls the hosted Search API.
- Consequence observed in use: `fetch failed` / DNS errors in network-restricted Codex sandboxes; the removed skill carried a sandbox-escalation workaround (`9709725`).
- Removal commit in this repo: `61999dd` (skill at `dot_agents/skills/mgrep/SKILL.md`, now in `.chezmoiremove`).

## Local semantic search tool landscape (verified 2026-07-16, GitHub API where noted)

Fully-local candidates (no cloud API/key at query time):

| Tool | Repo | ~Stars | Version (date) | License | Interface | Factual caveats |
|---|---|---|---|---|---|---|
| ck | `BeaconBay/ck` | 1,680 | v0.7.11 (2026-05); commits 2026-07 | Apache-2.0 | CLI + MCP (`ck --serve`) | Pre-1.0; install via `cargo install ck-search` only (brew/apt pending); in-process ONNX/FastEmbed BGE-small ~130 MB, first-run download; `.ck/` index 1–3× source size; tree-sitter ~7–11 langs; README: "no code or queries sent to external services" |
| qmd | `tobi/qmd` | 27,900 | v2.5.3 (2026-05); 582 commits | MIT | CLI (`search`/`vsearch`/`query`) + MCP (Claude Code/Desktop documented; HTTP transport) | Node ≥22 or Bun; three GGUF models ~2 GB total (embeddinggemma-300M, qwen3-reranker-0.6b, query-expansion-1.7B) downloaded from HuggingFace on first use to `~/.cache/qmd/models/`; docs/notes-first, code chunking secondary (TS/JS/Py/Go/Rust); SQLite index |
| qmd (Rust) | `qntx-labs/qmd` | 37 | early | Apache-2.0/MIT | CLI + MCP crate | Independent Rust implementation; single binary; too young to be load-bearing |
| codanna | `bartolli/codanna` | 710 | v0.9.23 (2026-07) | Apache-2.0 | MCP + CLI | Pre-1.0 with breaking re-index most releases; solo maintainer; local model ~150 MB first-use download; symbols/call-graph + semantic |
| probe | `probelabs/probe` | 660 | v0.6.0-rc327 (2026-06) | Apache-2.0 | CLI + MCP (npm) | No embeddings — ripgrep + tree-sitter AST + BM25 boolean; NL layer requires a cloud LLM key (optional); perpetual RC versioning |
| cocoindex-code | `cocoindex-io/cocoindex-code` | 2,500 | v0.2.37 (2026-06) | Apache-2.0 | CLI + MCP + agent skill | Local only with `[full]` extra (~1 GB torch); slim default routes embeddings to cloud; 28+ langs; embedded LMDB/SQLite |
| chunkhound | `chunkhound/chunkhound` | 1,360 | v5.2.1 (2026-07) | MIT | MCP + CLI | Semantic requires a provider — local only via self-configured Ollama; 97 open issues; "100% AI Generated" badge |
| grepai | `yoanbernabeu/grepai` | 1,800 | v0.35.0 (2026-03) | MIT | CLI + MCP + skills | Requires a running Ollama/LM Studio daemon; Go binary; call-graph tracing |

Excluded on facts:

- `Davidyz/VectorCode` — self-described beta; needs a ChromaDB backend.
- `XiaoConstantine/sgrep` — ~15★.
- `jina-ai/jina-grep-cli` — Apple-Silicon-only; no releases.
- `arunsupe/semantic-grep` — word-level word2vec; stale since 2024-08.
- `sturdy-dev/semantic-code-search` — abandoned 2023; AGPL.
- `comby` — last release 2022.
- Sourcegraph `src`/Cody — requires a server instance; Cody enterprise-only since ~2025-07.
- `the_silver_searcher` — no release since 2018.

Exact-match baselines:

- `BurntSushi/ripgrep` — ~66.2k★, v15.2.0 (2026-07-15), static binary.
- `Genivia/ugrep` — ~3.2k★, v7.8.2 (2026-05), adds boolean/fuzzy/TUI.

## Provisioning-relevant facts

- Both ck and qmd download models on **first use** by default; both cache locally and run offline thereafter.
  Install-time pre-pull is therefore a provisioning step, not tool-default behavior.
- ck embeds per-directory into `.ck/`; qmd indexes configured collections into a per-user SQLite database.
- qmd exposes MCP tools `query`, `get`, `multi_get`, `status`; a long-lived server keeps the ~2 GB models warm across queries.

## Repo provisioning conventions (inspected 2026-07-16)

- Install machinery: a single `run_after_npx-skills.sh` — `run_after_` (re-runs every apply) with internal idempotence checks and graceful skip when a runtime (`npx`) is missing.
- No package/toolchain management exists in the repo: no Brewfile, no runtime installers; runtimes are assumed present.
- Skill exposure: canonical dir `~/.agents/skills` (chezmoi `dot_agents/skills/`); Claude consumes via `~/.claude/skills/<name>` symlinks (source files `dot_claude/skills/symlink_<name>` containing `../../.agents/skills/<name>`); Codex reads the canonical dir natively.
- MCP management: Codex — managed `[mcp_servers.*]` section appended by `dot_codex/modify_private_config.toml` (awk-based, context7 present); Claude — no MCP config managed in this repo.
- Global git ignore: neither `~/.gitconfig` nor a global ignore file is chezmoi-managed; git's default global excludes path is `~/.config/git/ignore` when `core.excludesFile` is unset, and `dot_config/` exists (starship only).

## Sources

- https://github.com/mixedbread-ai/mgrep · https://www.npmjs.com/package/@mixedbread/mgrep
- https://github.com/BeaconBay/ck · https://beaconbay.github.io/ck/ · https://crates.io/crates/ck-search
- https://github.com/tobi/qmd · https://github.com/qntx-labs/qmd
- https://github.com/bartolli/codanna · https://docs.codanna.sh
- https://github.com/probelabs/probe · https://github.com/cocoindex-io/cocoindex-code
- https://github.com/chunkhound/chunkhound · https://github.com/yoanbernabeu/grepai
- https://github.com/BurntSushi/ripgrep · https://github.com/Genivia/ugrep
- Excluded-tool repos: VectorCode, sgrep, jina-grep-cli, semantic-grep, semantic-code-search, comby, src-cli (see per-row caveats)
