#!/bin/bash
# Install skills that are owned by the Skills CLI.
#
# Chezmoi owns ~/.agents/.skill-lock.json as the desired package-manager
# receipt; `npx skills` owns materializing the installed skill directories.
set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "npx not found; skipping Skills CLI-managed skills" >&2
  exit 0
fi

lock_file="$HOME/.agents/.skill-lock.json"
canonical_dir="$HOME/.agents/skills"
claude_dir="$HOME/.claude/skills"

[ -f "$lock_file" ] || {
  echo "$lock_file not found; skipping Skills CLI-managed skills" >&2
  exit 0
}

desired_lock="$(mktemp)"
cp "$lock_file" "$desired_lock"

restore_lock() {
  cp "$desired_lock" "$lock_file"
  rm -f "$desired_lock"
}
trap restore_lock EXIT

lock_has_skill() {
  local skill="$1"

  [ -f "$lock_file" ] || return 1
  node -e '
const fs = require("fs");
const lock = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
process.exit(lock.skills && lock.skills[process.argv[2]] ? 0 : 1);
' "$lock_file" "$skill"
}

agents=()
while IFS= read -r agent; do
  agents+=("$agent")
done < <(node -e '
const fs = require("fs");
const lock = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
const agents = lock.chezmoiManagedAgents || ["cline", "claude-code"];
for (const agent of agents) console.log(agent);
' "$lock_file")

skill_specs=()
while IFS= read -r spec; do
  skill_specs+=("$spec")
done < <(node -e '
const fs = require("fs");
const lock = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
for (const [name, entry] of Object.entries(lock.skills || {})) {
  if (!entry.source) continue;
  const source = entry.ref ? `${entry.source}#${entry.ref}` : entry.source;
  console.log(`${name}\t${source}`);
}
' "$lock_file")

agent_skill_is_installed() {
  local skill="$1"
  local agent="$2"

  case "$agent" in
    claude-code)
      [ -L "$claude_dir/$skill" ] || return 1
      [ -f "$claude_dir/$skill/SKILL.md" ] || return 1
      ;;
    cline | dexto | kimi-code-cli | loaf | warp | zed)
      [ -f "$canonical_dir/$skill/SKILL.md" ] || return 1
      ;;
    *)
      return 1
      ;;
  esac
}

skill_is_installed() {
  local skill="$1"

  [ -f "$canonical_dir/$skill/SKILL.md" ] || return 1
  lock_has_skill "$skill"

  for agent in "${agents[@]}"; do
    agent_skill_is_installed "$skill" "$agent" || return 1
  done
}

install_skill() {
  local source="$1"
  local skill="$2"
  local args=(skills add "$source" --skill "$skill" --global --yes)

  if skill_is_installed "$skill"; then
    return 0
  fi

  for agent in "${agents[@]}"; do
    args+=(--agent "$agent")
  done

  npx --yes "${args[@]}"
}

for spec in "${skill_specs[@]}"; do
  skill="${spec%%$'\t'*}"
  source="${spec#*$'\t'}"
  install_skill "$source" "$skill"
done
