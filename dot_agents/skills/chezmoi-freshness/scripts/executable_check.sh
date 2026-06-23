#!/usr/bin/env bash
# chezmoi-freshness — read-only freshness + validity of the CHEZMOI surface:
# the dotfiles source repo, apply-drift, and every configured chezmoi git-repo
# external checked against its real remote.
#
# WHY beyond `chezmoi status`: it reports an external as clean until its
# refreshPeriod elapses, so it HIDES upstream commits. This fetches and
# compares each external directly. Read-only: fetches, never merges/applies.
set -uo pipefail

# mynghn-owned externals/repos are private; the active gh account (socar-nio)
# can't reach them, so read-only fetches use a mynghn credential when available.
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

echo "== chezmoi-freshness ===================================================="
errs="$(chezmoi doctor 2>/dev/null | grep -cE '^error' || true)"
echo "[validity] chezmoi doctor errors: ${errs:-0}  (a 'latest-version' warning is cosmetic)"
st="$(chezmoi status 2>/dev/null || true)"
if [ -z "$st" ]; then echo "[apply  ] clean — target matches source"
else echo "[apply  ] ** pending drift (chezmoi apply would change):"; echo "$st" | sed 's/^/           /'
  echo "           (a lone 'MM .claude/settings.json' is a trailing-newline rewrite — cosmetic)"; fi

SRC="$(chezmoi source-path)"; s="$(sync_state "$SRC")"; echo "[source ]$(flag "$s") $s  ($SRC)"

# every git-repo external vs its remote
EXT="$SRC/.chezmoiexternal.toml"
if [ -f "$EXT" ]; then
  awk -F'"' '/^\[".*"\]/{p=$2} /type[ \t]*=[ \t]*"git-repo"/{print p}' "$EXT" | while read -r path; do
    repo="$HOME/$path"; nm="${path##*/}"
    if [ -d "$repo/.git" ]; then s="$(sync_state "$repo")"; printf '[ext:%-6s]%s %s\n' "$nm" "$(flag "$s")" "$s"
    else printf '[ext:%-6s]  n/a  no checkout at %s\n' "$nm" "$repo"; fi
  done
else echo "[ext    ]  none (.chezmoiexternal.toml absent)"; fi

echo "========================================================================"
echo "Fix (after review, only if flagged **):  chezmoi update  (add --refresh-externals only when an external is flagged)"
echo "  cosmetic settings.json drift -> ignore, or: chezmoi re-add ~/.claude/settings.json"
echo "  (pushing a mynghn-owned external/repo needs the mynghn gh-credential override — see SKILL.md)"
