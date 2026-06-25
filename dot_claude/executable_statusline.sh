#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract data with single jq call (calculate context % from tokens if not provided)
eval $(echo "$input" | jq -r '
  "cwd=\(.workspace.current_dir | @sh)",
  "project_dir=\(.workspace.project_dir | @sh)",
  "model=\(.model.display_name // "" | @sh)",
  "context_remaining=\(
    if .context_window.remaining_percentage then
      .context_window.remaining_percentage
    elif .context_window.used_percentage then
      100 - .context_window.used_percentage
    elif .context_window.total_input_tokens and .context_window.context_window_size then
      (100 - (.context_window.total_input_tokens * 100 / .context_window.context_window_size)) | floor
    else
      ""
    end | tostring | @sh)",
  # Subscription rate-limit quota (Pro/Max only, absent until first API
  # response of a session — so every field degrades to "" gracefully).
  "q5_pct=\(.rate_limits.five_hour.used_percentage // "" | tostring | @sh)",
  "q5_reset=\(.rate_limits.five_hour.resets_at // "" | tostring | @sh)",
  "q7_pct=\(.rate_limits.seven_day.used_percentage // "" | tostring | @sh)",
  "q7_reset=\(.rate_limits.seven_day.resets_at // "" | tostring | @sh)",
  "in_tok=\(.context_window.total_input_tokens // "" | tostring | @sh)",
  "win_size=\(.context_window.context_window_size // "" | tostring | @sh)",
  "cache_read=\(.context_window.current_usage.cache_read_input_tokens // "" | tostring | @sh)",
  "cache_in=\(.context_window.current_usage.input_tokens // "" | tostring | @sh)",
  "cache_create=\(.context_window.current_usage.cache_creation_input_tokens // "" | tostring | @sh)",
  "cost=\(.cost.total_cost_usd // "" | tostring | @sh)"
' 2>/dev/null) || { echo "Claude Code"; exit 0; }

# Colors
R='\033[0m'
C='\033[36m'
G='\033[32m'
Y='\033[33m'
B='\033[34m'
M='\033[35m'
O='\033[38;5;208m'
D='\033[90m'
P='\033[38;5;213m'

# Separator
S=" ${D}│${R} "

# Humanize a raw token count: 159000 -> 159K, 1000000 -> 1M, 1250000 -> 1.2M.
human_tok() {
    local n=${1%.*}
    [ -z "$n" ] || [ "$n" = "null" ] && return
    if [ "$n" -ge 1000000 ] 2>/dev/null; then
        local m=$((n / 1000000)) frac=$(((n % 1000000) / 100000))
        if [ "$frac" -eq 0 ]; then printf '%dM' "$m"; else printf '%d.%dM' "$m" "$frac"; fi
    elif [ "$n" -ge 1000 ] 2>/dev/null; then
        printf '%dK' $((n / 1000))
    elif [ "$n" -ge 0 ] 2>/dev/null; then
        printf '%d' "$n"
    fi
}

# Build output across three lines:
#   line1: identity/location/model  (user, cwd, git, model, effort)
#   line2: budgets                  (ctx/*, quota/*, spent)
#   line3: environment              (aws, k8s)
# Every segment is appended WITH a leading separator; each line's leading
# separator is stripped just before printing.
line1=""; line2=""; line3=""
# Identity: the logged-in Anthropic account email; fall back to the local OS
# user only when signed out.
acct=$(jq -r '.oauthAccount.emailAddress // empty' "$HOME/.claude.json" 2>/dev/null)
if [ -n "$acct" ]; then
    line1+="${S}${B}account:${acct}${R}"
else
    line1+="${S}${B}user:${USER:-$(whoami)}${R}"
fi
# Plan/rate-limit tier (e.g. default_claude_max_5x -> max5x) for line 2 (next to quota).
tier=$(jq -r '.oauthAccount.userRateLimitTier // empty' "$HOME/.claude.json" 2>/dev/null \
       | sed -e 's/^default_//' -e 's/^claude_//' -e 's/_//g')

# Directory (abbreviate home as ~, smart truncation)
if [ "$cwd" = "$HOME" ]; then
    dir="~"
elif [[ "$cwd" == "$HOME"/* ]]; then
    dir="~/${cwd#$HOME/}"
else
    dir="$cwd"
fi

# Smart truncation if > 30 chars: collapse middle directories, preserve full names
if [ ${#dir} -gt 30 ]; then
    # Split into parts
    IFS='/' read -ra parts <<< "$dir"
    len=${#parts[@]}

    if [ $len -gt 3 ]; then
        # Single-pass: calculate how many dirs to keep based on average length
        excess=$((${#dir} - 30))
        avg_per_dir=$(( ${#dir} / len ))
        [ $avg_per_dir -lt 1 ] && avg_per_dir=1
        to_remove=$(( (excess / avg_per_dir) + 1 ))
        keep=$((len - to_remove))
        [ $keep -lt 3 ] && keep=3

        # Keep first half and last half, collapse middle
        first_half=$(( (keep - 1) / 2 ))
        last_half=$(( keep - first_half - 1 ))
        [ $first_half -lt 1 ] && first_half=1
        [ $last_half -lt 1 ] && last_half=1

        # Build: first_half dirs + … + last_half dirs
        result="${parts[0]}"
        for ((i=1; i<first_half; i++)); do
            result+="/${parts[$i]}"
        done
        result+="/…"
        for ((i=len-last_half; i<len; i++)); do
            result+="/${parts[$i]}"
        done
        dir="$result"
    fi
fi
line1+="${S}${C}cwd:${dir}${R}"

# Git branch + worktree. Use -e (not -d): a linked worktree's .git is a FILE.
if [ -e "${cwd}/.git" ] || [ -e "${project_dir}/.git" ]; then
    gitdir="${cwd}"
    [ -e "${project_dir}/.git" ] && gitdir="${project_dir}"
    if branch=$(git -C "$gitdir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null); then
        # Truncate branch name if > 30 chars
        [ ${#branch} -gt 30 ] && branch="${branch:0:29}…"
        line1+="${S}${C}git:${branch}${R}"
    fi
    # Linked worktree: the absolute git dir is <repo>/.git/worktrees/<name>.
    # Main worktree has no /worktrees/ segment, so this shows only when relevant.
    gd=$(git -C "$gitdir" rev-parse --absolute-git-dir 2>/dev/null)
    case "$gd" in
        */worktrees/*) wt="${gd##*/worktrees/}"; wt="${wt%%/*}"
                       line1+="${S}${M}wt:${wt}${R}" ;;
    esac
fi

# Model
[ -n "$model" ] && line1+="${S}${O}model:${model}${R}"

# Output style (payload field is either an object {name} or a plain string)
ostyle=$(echo "$input" | jq -r '(.output_style | if type=="object" then .name else . end) // empty' 2>/dev/null)
[ -n "$ostyle" ] && line1+="${S}${O}style:${ostyle}${R}"

# Effort level (not in stdin payload — read from settings; local overrides global).
# Shares the model color since both describe how the model runs.
effort=""
for sf in "$HOME/.claude/settings.local.json" "$HOME/.claude/settings.json"; do
    [ -f "$sf" ] || continue
    effort=$(jq -r '.effortLevel // empty' "$sf" 2>/dev/null)
    [ -n "$effort" ] && break
done
[ -n "$effort" ] && line1+="${S}${O}effort:${effort}${R}"

# Context: one segment ctx:<left%>(<used>/<size>), green->yellow->red on
# remaining headroom (lots of room green, nearly full red).
if [ -n "$context_remaining" ] && [ "$context_remaining" != "null" ] && [ "$context_remaining" != "" ]; then
    ctx=${context_remaining%.*}
    if [ "$ctx" -ge 70 ] 2>/dev/null; then ctxcol="$G"
    elif [ "$ctx" -ge 30 ] 2>/dev/null; then ctxcol="$Y"
    else ctxcol='\033[31m'; fi
    ctxseg="ctx:${ctx}%"
    itok=$(human_tok "$in_tok"); wsz=$(human_tok "$win_size")
    if [ -n "$itok" ] && [ -n "$wsz" ]; then ctxseg+="(${itok}/${wsz})"
    elif [ -n "$itok" ]; then ctxseg+="(${itok})"; fi
    line2+="${S}${ctxcol}${ctxseg}${R}"
fi

# Cache hit rate of the latest turn: cache_read / (cache_read + fresh_in +
# cache_create). High = context cheaply reused; low = expensive reprocessing
# (cache expired after its 5-min TTL, or an early-prompt edit busted the suffix).
if [ -n "$cache_read" ] && [ "$cache_read" != "null" ]; then
    cr=${cache_read%.*}; ci=${cache_in%.*}; cc=${cache_create%.*}
    [ -z "$ci" ] || [ "$ci" = "null" ] && ci=0
    [ -z "$cc" ] || [ "$cc" = "null" ] && cc=0
    ctot=$((cr + ci + cc))
    if [ "$ctot" -gt 0 ] 2>/dev/null; then
        chit=$((cr * 100 / ctot))
        if [ "$chit" -ge 90 ] 2>/dev/null; then chcol="$G"
        elif [ "$chit" -ge 50 ] 2>/dev/null; then chcol="$Y"
        else chcol='\033[31m'; fi
        line2+="${S}${chcol}cache:${chit}%${R}"
    fi
fi

# Quota: render a used-percentage segment (color inverted vs ctx — low used is
# good). Append a reset countdown only when near the limit (>=80%), so the
# common case stays compact. Silently skips when the field is absent.
render_quota() {
    local label="$1" pct="$2" reset="$3"
    [ -z "$pct" ] || [ "$pct" = "null" ] && return
    local p=${pct%.*}                       # floor float -> int
    [ -z "$p" ] && return
    local col
    if [ "$p" -lt 50 ] 2>/dev/null; then col="$G"
    elif [ "$p" -lt 80 ] 2>/dev/null; then col="$Y"
    else col='\033[31m'; fi
    local seg="${label}:${p}%"
    if [ "$p" -ge 80 ] 2>/dev/null && [ -n "$reset" ] && [ "$reset" != "null" ]; then
        local now delta r=${reset%.*}
        now=$(date +%s)
        delta=$((r - now))
        if [ "$delta" -gt 0 ]; then
            local d=$((delta / 86400)) h=$(((delta % 86400) / 3600)) m=$(((delta % 3600) / 60))
            if [ "$d" -gt 0 ]; then
                seg+=" ↻${d}d${h}h"
            elif [ "$h" -gt 0 ]; then
                seg+=$(printf ' ↻%dh%02dm' "$h" "$m")
            else
                seg+=" ↻${m}m"
            fi
        fi
    fi
    line2+="${S}${col}${seg}${R}"
}
[ -n "$tier" ] && line2+="${S}${B}plan:${tier}${R}"
render_quota "quota/5h" "$q5_pct" "$q5_reset"
render_quota "quota/1w" "$q7_pct" "$q7_reset"

# Session cost estimate
if [ -n "$cost" ] && [ "$cost" != "null" ]; then
    costfmt=$(printf '%.2f' "$cost" 2>/dev/null)
    [ -n "$costfmt" ] && line2+="${S}${P}spent:\$${costfmt}${R}"
fi

# AWS Profile
[ -n "$AWS_PROFILE" ] && line3+="${S}${M}aws:${AWS_PROFILE}${R}"

# Kubernetes context (check KUBECONFIG or default location)
kubeconfig="${KUBECONFIG:-$HOME/.kube/config}"
if [ -f "$kubeconfig" ]; then
    kctx=$(grep -m1 'current-context:' "$kubeconfig" 2>/dev/null | awk '{print $2}')
    [ -n "$kctx" ] && [ "$kctx" != "docker-desktop" ] && line3+="${S}${M}k8s:${kctx}${R}"
fi

# Strip each line's leading separator, then emit non-empty lines (one per row).
out=""
for ln in "$line1" "$line2" "$line3"; do
    ln=${ln#"$S"}
    [ -n "$ln" ] || continue
    [ -n "$out" ] && out+=$'\n'
    out+="$ln"
done
printf '%b\n' "$out"
