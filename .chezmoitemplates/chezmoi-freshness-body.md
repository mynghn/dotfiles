The **chezmoi surface** of this machine's agent toolchain: the dotfiles source repo, apply-drift, and any configured chezmoi git-repo externals. Mechanism is declarative — `chezmoi update`. (The Metacognition framework is a *separate* surface — `git pull` + `install`, not chezmoi — owned by `metacognition-freshness`.)

**Read-first, confirmed-update.** Run the check, show the verdict, then update only what it flags `**`, and only after the user confirms.

## 1. Check (read-only)
Run the bundled sweep (`scripts/check.sh` in this skill's own directory):
```sh
~/.claude/skills/chezmoi-freshness/scripts/check.sh   # Claude
~/.agents/skills/chezmoi-freshness/scripts/check.sh   # Codex
```
Reports validity (`chezmoi doctor`), apply-drift (`chezmoi status`), the dotfiles source vs origin, and **each configured external's behind/ahead vs its real remote** (fetch-only). `behind=0` everywhere ⇒ fresh; `**` marks actionable apply drift or unpulled upstream commits.

Second-column `R` entries from unconditional `run_` scripts are reported as informational `[run]` entries, not apply drift: chezmoi schedules them on every apply, so they remain in `chezmoi status` after a successful update.

> Why not just `chezmoi status`: it treats an external as clean until its `refreshPeriod` elapses, silently hiding upstream commits. The script fetches and compares configured externals directly.

## 2. Update (only flagged surfaces, only after confirmation)
- **A configured external stale, or the source behind with externals configured** → `chezmoi update --refresh-externals` (pulls the source and re-pulls externals regardless of refresh period).
- **Source behind only, no externals stale** → `chezmoi update`.
- **Informational `[run]` entries only** → no update needed; they are unconditional scripts scheduled for every apply.
- **Cosmetic apply-drift** — a lone trailing-newline on `.claude/settings.json` (Claude Code rewrites it) → ignore, or `chezmoi re-add ~/.claude/settings.json`, or `.chezmoiignore` it.

Re-run the check to confirm `behind=0` afterward.

## Gotchas (load-bearing)
- **mynghn credential.** The dotfiles repo and any mynghn-owned externals are private; the active gh account (`socar-nio`) can't reach them, so a bare `git push` 403s. The check fetches with a mynghn cred automatically. To **push**:
  ```sh
  export MYNGHN_TOKEN=$(gh auth token --user mynghn)
  git -C <repo> -c credential.helper= \
    -c credential.helper='!f(){ echo username=mynghn; echo "password=$MYNGHN_TOKEN"; };f' push origin HEAD:main
  unset MYNGHN_TOKEN
  ```
- **`chezmoi status` ≠ fresh** — it hides externals stale within their refresh period; trust the script's behind/ahead vs remote.
- **`R` ≠ drift.** A second-column `R` means an unconditional script will run on apply; it is expected to persist and must not trigger an update.
- **Never history-op the chezmoi source repo** (no amend/rebase) — it takes the user's own commits concurrently; let them commit, don't.
- Sibling skill: **metacognition-freshness** owns the Metacognition framework surface (it's install-bootstrapped, not chezmoi).
