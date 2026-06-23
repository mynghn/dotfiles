---
name: metacognition-freshness
description: Check and (after confirmation) update the freshness and validity of the Metacognition framework — the tooling repo and the private vault repo (vs their remotes), plus whether installed Claude+Codex adapters cover every configured sibling. Use after a Metacognition main-branch update, when siblings/entries may be stale, or to confirm the framework is current. Metacognition is install-bootstrapped, NOT a chezmoi external — update via git pull + re-run install, not chezmoi. For the chezmoi-managed dotfiles surface use chezmoi-freshness instead.
argument-hint: "[check | update]"
---

The **Metacognition surface** of this machine's agent toolchain: the `metacognition` tooling repo + the private `metacognition-vault` repo, and the installed Claude+Codex KB adapters. Mechanism is imperative — `git pull` + re-run `install`. It is **not** a chezmoi external, so `chezmoi update` will never touch it. (The chezmoi-managed dotfiles surface is owned by `chezmoi-freshness`.)

**Read-first, confirmed-update.** Run the check, show the verdict, then update only if it flags `**`, and only after the user confirms.

## 1. Check (read-only)
Run the bundled sweep (`scripts/check.sh` in this skill's own directory):
```sh
~/.claude/skills/metacognition-freshness/scripts/check.sh   # Claude
~/.agents/skills/metacognition-freshness/scripts/check.sh   # Codex
```
Reports each repo's clean/dirty + **behind/ahead vs origin** (fetch-only), and **adapter parity** — whether every `config/<stem>` has an installed Claude *and* Codex `*-knowledge-base` adapter. `behind=0` and adapters `ok` ⇒ fresh + valid; `**` marks an action.

## 2. Update (only if flagged, only after confirmation)
A repo behind origin, **or** a missing adapter (e.g. `main` added a sibling but `install` wasn't re-run) → pull both repos and re-render adapters:
```sh
git -C ~/.local/share/metacognition pull --ff-only
git -C ~/.local/share/metacognition-vault pull --ff-only
~/.local/share/metacognition/install
```
Re-run the check to confirm `behind=0` and adapters `ok`.

## Gotchas (load-bearing)
- **mynghn credential.** Both repos are mynghn-owned and the vault is **private**; the active gh account (`socar-nio`) can't reach it, so a bare `git pull`/`push` 403s (`Repository not found` for the private vault). The check fetches with a mynghn cred automatically. To pull/push manually:
  ```sh
  export MYNGHN_TOKEN=$(gh auth token --user mynghn)
  git -C <repo> -c credential.helper= \
    -c credential.helper='!f(){ echo username=mynghn; echo "password=$MYNGHN_TOKEN"; };f' pull --ff-only
  unset MYNGHN_TOKEN
  ```
- **Not a chezmoi external** — `chezmoi update` won't update it; you must `git pull` + re-run `install` (which re-renders both providers' adapters from `templates + config + wiring`).
- **Re-run `install` after pulling** — new/renamed siblings only become live adapters when `install` runs; the adapter-parity check catches a skipped install.
- **FAMILY.md is chezmoi-frozen until B1** — structural registry edits won't flow yet.
- **Vault writes go through the engine and commit as `mynghn`** — never hand-edit the vault; never commit it under socar-nio.
- Sibling skill: **chezmoi-freshness** owns the dotfiles + chezmoi-external surface.
