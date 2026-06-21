#!/usr/bin/env bash
# metacognition-freshness — read-only freshness + validity of the METACOGNITION
# framework: the tooling repo + the private vault repo (vs their remotes), and
# whether installed Claude+Codex adapters cover every configured sibling.
#
# Metacognition is install-bootstrapped, NOT a chezmoi external — chezmoi will
# not update it. Update = git pull both repos + re-run install. Read-only here.
set -uo pipefail

# The vault is private + mynghn-owned; the active gh account (socar-nio) can't
# reach it, so read-only fetches use a mynghn credential when available.
MTOK="$(gh auth token --user mynghn 2>/dev/null || true)"
mynghn_git() { local repo="$1"; shift
  if [ -n "$MTOK" ]; then
    MYNGHN_TOKEN="$MTOK" git -C "$repo" -c credential.helper= \
      -c credential.helper='!f(){ echo username=mynghn; echo "password=$MYNGHN_TOKEN"; };f' "$@"
  else git -C "$repo" "$@"; fi; }
sync_state() { local repo="$1" br up d
  [ -n "$(git -C "$repo" status --porcelain 2>/dev/null)" ] && d=dirty || d=clean
  br="$(git -C "$repo" symbolic-ref --short HEAD 2>/dev/null || echo HEAD)"
  mynghn_git "$repo" fetch -q origin 2>/dev/null || true
  up="origin/$br"; git -C "$repo" rev-parse --verify -q "$up" >/dev/null 2>&1 || up="origin/HEAD"
  printf '%s behind=%s ahead=%s' "$d" \
    "$(git -C "$repo" rev-list --count "HEAD..$up" 2>/dev/null || echo '?')" \
    "$(git -C "$repo" rev-list --count "$up..HEAD" 2>/dev/null || echo '?')"; }
flag() { case "$1" in *behind=0*) printf '  ok ' ;; *behind=\?*) printf ' n/a ' ;; *) printf ' ** ' ;; esac; }

TOOL="$HOME/.local/share/metacognition"
VAULT="$HOME/.local/share/metacognition-vault"
echo "== metacognition-freshness ============================================="
for pair in "tooling:$TOOL" "vault:$VAULT"; do
  nm="${pair%%:*}"; R="${pair#*:}"
  if [ -d "$R/.git" ]; then s="$(sync_state "$R")"; printf '[%-7s]%s %s  (%s)\n' "$nm" "$(flag "$s")" "$s" "$R"
  else printf '[%-7s]  n/a  not found at %s\n' "$nm" "$R"; fi
done

# adapter parity: every config/<stem> should have installed Claude + Codex adapters
if [ -d "$TOOL/config" ]; then
  miss=0
  for cfg in "$TOOL"/config/*; do
    [ -f "$cfg" ] || continue; stem="${cfg##*/}"; case "$stem" in *.md|README) continue;; esac
    name="$stem-knowledge-base"
    [ -f "$HOME/.claude/skills/$name/SKILL.md" ] || { echo "[adapters] ** Claude adapter missing for $stem (run install)"; miss=1; }
    [ -f "$HOME/.codex/skills/$name/SKILL.md"  ] || { echo "[adapters] ** Codex adapter missing for $stem (run install)";  miss=1; }
  done
  [ "$miss" = 0 ] && echo "[adapters]  ok  every configured sibling has Claude + Codex adapters"
fi

echo "========================================================================"
echo "Fix (after review, only if flagged **):"
echo "  git -C $TOOL pull --ff-only \\"
echo "    && git -C $VAULT pull --ff-only \\"
echo "    && $TOOL/install"
echo "  (vault is private + mynghn-owned: fetch/pull/push need the mynghn gh-credential override — see SKILL.md)"
echo "  note: FAMILY.md is chezmoi-frozen until B1; vault commits/pushes go as mynghn."
