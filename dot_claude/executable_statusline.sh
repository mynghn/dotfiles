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
    end | tostring | @sh)"
' 2>/dev/null) || { echo "Claude Code"; exit 0; }

# Colors
R='\033[0m'
C='\033[36m'
G='\033[32m'
Y='\033[33m'
B='\033[34m'
M='\033[35m'
D='\033[90m'

# Separator
S=" ${D}│${R} "

# Build output
out="${C}👤 ${USER:-$(whoami)}${R}"

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
out+="${S}${B}📁 ${dir}${R}"

# Git branch (only if .git exists - fast check)
if [ -d "${cwd}/.git" ] || [ -d "${project_dir}/.git" ]; then
    gitdir="${cwd}"
    [ -d "${project_dir}/.git" ] && gitdir="${project_dir}"
    if branch=$(git -C "$gitdir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null); then
        # Truncate branch name if > 30 chars
        [ ${#branch} -gt 30 ] && branch="${branch:0:29}…"
        out+="${S}${G}🔶 ${branch}${R}"
    fi
fi

# Model
[ -n "$model" ] && out+="${S}${M}🤖 ${model}${R}"

# Context remaining
if [ -n "$context_remaining" ] && [ "$context_remaining" != "null" ] && [ "$context_remaining" != "" ]; then
    ctx=${context_remaining%.*}
    if [ "$ctx" -ge 70 ] 2>/dev/null; then
        out+="${S}${G}💭 ${ctx}%${R}"
    elif [ "$ctx" -ge 30 ] 2>/dev/null; then
        out+="${S}${Y}💭 ${ctx}%${R}"
    else
        out+="${S}\033[31m💭 ${ctx}%${R}"
    fi
fi

# AWS Profile
[ -n "$AWS_PROFILE" ] && out+="${S}${Y}☁️  ${AWS_PROFILE}${R}"

# Kubernetes context (check KUBECONFIG or default location)
kubeconfig="${KUBECONFIG:-$HOME/.kube/config}"
if [ -f "$kubeconfig" ]; then
    kctx=$(grep -m1 'current-context:' "$kubeconfig" 2>/dev/null | awk '{print $2}')
    [ -n "$kctx" ] && [ "$kctx" != "docker-desktop" ] && out+="${S}${C}⎈ ${kctx}${R}"
fi

printf '%b\n' "$out"
