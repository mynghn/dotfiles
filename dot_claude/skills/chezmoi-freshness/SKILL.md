---
name: chezmoi-freshness
description: Check and (after confirmation) update the freshness and validity of the chezmoi-managed dotfiles — the source repo, apply-drift, and every chezmoi git-repo external (e.g. the LeanPlan /requirement…/impl skills). Use when asked to check, verify, doctor, or update chezmoi state, or after a main-branch update to a chezmoi external. Goes beyond `chezmoi status`, which reports an external as clean until its refresh period (168h) elapses and so hides upstream commits — this fetches and compares each external against its real remote. For the Metacognition framework (NOT chezmoi-managed) use metacognition-freshness instead.
argument-hint: "[check | update]"
---

The **chezmoi surface** of this machine's agent toolchain: the dotfiles source repo, apply-drift, and every chezmoi git-repo external (today: the LeanPlan skills). Mechanism is declarative — `chezmoi update`. (The Metacognition framework is a *separate* surface — `git pull` + `install`, not chezmoi — owned by `metacognition-freshness`.)

**Read-first, confirmed-update.** Run the check, show the verdict, then update only what it flags `**`, and only after the user confirms.

## 1. Check (read-only)
Run the bundled sweep (`scripts/check.sh` in this skill's own directory):
```sh
~/.claude/skills/chezmoi-freshness/scripts/check.sh   # Claude
~/.agents/skills/chezmoi-freshness/scripts/check.sh   # Codex
```
Reports validity (`chezmoi doctor`), apply-drift (`chezmoi status`), the dotfiles source vs origin, and **each external's behind/ahead vs its real remote** (fetch-only). `behind=0` everywhere ⇒ fresh; `**` marks a surface with unpulled upstream commits.

> Why not just `chezmoi status`: it treats an external as clean until its `refreshPeriod` (168h) elapses, silently hiding upstream commits — a 16-commit LeanPlan lag once read as "clean". The script fetches and compares directly.

## 2. Update (only flagged surfaces, only after confirmation)
- **An external stale, or the source behind** → `chezmoi update --refresh-externals` (pulls the source and re-pulls externals regardless of refresh period).
- **Source behind only, no externals stale** → `chezmoi update`.
- **Cosmetic apply-drift** — a lone trailing-newline on `.claude/settings.json` (Claude Code rewrites it) → ignore, or `chezmoi re-add ~/.claude/settings.json`, or `.chezmoiignore` it.

Re-run the check to confirm `behind=0` afterward.

## Gotchas (load-bearing)
- **mynghn credential.** The dotfiles repo and the mynghn-owned externals (e.g. leanplan) are private; the active gh account (`socar-nio`) can't reach them, so a bare `git push` 403s. The check fetches with a mynghn cred automatically. To **push**:
  ```sh
  export MYNGHN_TOKEN=$(gh auth token --user mynghn)
  git -C <repo> -c credential.helper= \
    -c credential.helper='!f(){ echo username=mynghn; echo "password=$MYNGHN_TOKEN"; };f' push origin HEAD:main
  unset MYNGHN_TOKEN
  ```
- **`chezmoi status` ≠ fresh** — it hides externals stale within their refresh period; trust the script's behind/ahead vs remote.
- **Never history-op the chezmoi source repo** (no amend/rebase) — it takes the user's own commits concurrently; let them commit, don't.
- Sibling skill: **metacognition-freshness** owns the Metacognition framework surface (it's install-bootstrapped, not chezmoi).
