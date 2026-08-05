#!/usr/bin/env bash
# L1/L2 checker for the software-digest skill.
# Materializes the pinned fixtures (once, cached) and runs the deterministic checks.
#
#   ./run.sh                    # all scenarios
#   ./run.sh s1-bubbletea-pr    # one scenario
#
# Fixture cache location is overridable:  SD_EVAL_CACHE=/path ./run.sh
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/../../../.." && pwd)"
cache="${SD_EVAL_CACHE:-$HOME/.cache/software-digest-evals}"
mkdir -p "$cache"

# --- pinned fixtures -------------------------------------------------------
BUBBLETEA_SHA=c60f0c53042238305ec13b486326588f12aea0ec   # merge commit of PR #1691
CHEZMOI_SHA=1de81edb10bdb0a088e409fd660cd43b5e95c152      # this repo, pre-work
STARLETTE_TAG=1.3.1                                       # 8ebffd067857

fetch_sha() { # url sha dir
  local url="$1" sha="$2" dir="$3"
  [ -d "$dir/.git" ] && return 0
  echo "  materializing $(basename "$dir") @ ${sha:0:12} …" >&2
  rm -rf "$dir"; mkdir -p "$dir"
  # depth 2 so the commit has a parent: a change fixture is only a change if its
  # diff is reachable. At depth 1 `git show <sha>` reports every file as added.
  git init -q "$dir" \
    && git -C "$dir" remote add origin "$url" \
    && git -C "$dir" fetch -q --depth 2 origin "$sha" \
    && git -C "$dir" checkout -q FETCH_HEAD
}

fetch_tag() { # url tag dir
  local url="$1" tag="$2" dir="$3"
  [ -d "$dir/.git" ] && return 0
  echo "  materializing $(basename "$dir") @ $tag …" >&2
  rm -rf "$dir"
  git clone -q --depth 1 --branch "$tag" "$url" "$dir"
}

materialize_local() { # sha dir
  local sha="$1" dir="$2"
  [ -f "$dir/.materialized" ] && return 0
  echo "  materializing chezmoi @ ${sha:0:12} …" >&2
  rm -rf "$dir"; mkdir -p "$dir"
  git -C "$root" archive "$sha" | tar -x -C "$dir" && touch "$dir/.materialized"
}

echo "fixtures (cache: $cache)" >&2
fetch_sha https://github.com/charmbracelet/bubbletea.git "$BUBBLETEA_SHA" "$cache/bubbletea"
materialize_local "$CHEZMOI_SHA" "$cache/chezmoi"
fetch_tag https://github.com/encode/starlette.git "$STARLETTE_TAG" "$cache/starlette"
echo >&2

exec python3 "$here/check.py" "$root" "$cache" "$@"
