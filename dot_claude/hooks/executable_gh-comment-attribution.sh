#!/usr/bin/env bash
# PreToolUse hook (Bash): require the Claude Code attribution footer on
# GitHub comment-posting commands.
#
# Reads the Bash tool-call JSON on stdin. If the command posts a GitHub comment
# (gh pr/issue comment, gh pr review --body, gh api .../comments, graphql
# add*Comment) and the marker URL claude.com/claude-code is absent from both the
# command text AND any referenced --body-file / -F / body=@file, it denies the
# call and tells the model to append the footer.
#
# Fails open: anything it can't positively classify as a marker-less comment
# post is allowed through (a missed enforcement is preferable to blocking
# unrelated git/gh work).
set -uo pipefail

MARKER='claude.com/claude-code'

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null)

# Fast path: not a gh invocation -> nothing to enforce.
case "$cmd" in
  *gh*) ;;
  *) exit 0 ;;
esac

# Don't block help output.
case "$cmd" in
  *--help*|*" -h "*|*" -h") exit 0 ;;
esac

is_post=0

# gh pr comment / gh issue comment  (the `comment` subcommand, NOT the
# read-only `--comments` flag of `gh pr view`).
if printf '%s' "$cmd" | grep -Eq 'gh[[:space:]]+(pr|issue)[[:space:]]+comment([[:space:]]|$)'; then
  is_post=1
fi

# gh pr review WITH a body (bare --approve / --request-changes carry no text).
if printf '%s' "$cmd" | grep -Eq 'gh[[:space:]]+pr[[:space:]]+review' \
   && printf '%s' "$cmd" | grep -Eq '(--body([[:space:]]|=)|--body-file|[[:space:]]-F[[:space:]]|[[:space:]]-b[[:space:]])'; then
  is_post=1
fi

# gh api: graphql add*Comment mutations, or a REST /comments endpoint with a body field.
if printf '%s' "$cmd" | grep -Eq 'gh[[:space:]]+api'; then
  if printf '%s' "$cmd" | grep -Eq '(addComment|addPullRequestReviewComment|addDiscussionComment)'; then
    is_post=1
  elif printf '%s' "$cmd" | grep -Eq '/comments' \
       && printf '%s' "$cmd" | grep -Eq '(body=|body@|(-f|-F|--field|--raw-field)[[:space:]]+body)'; then
    is_post=1
  fi
fi

[ "$is_post" -eq 1 ] || exit 0

# Marker inline? (covers --body "..." and heredoc bodies, which live in cmd)
if printf '%s' "$cmd" | grep -qF "$MARKER"; then
  exit 0
fi

# Marker in a referenced body file?  Collect candidate paths from
# --body-file PATH|=PATH, -F PATH, and body=@PATH / body@PATH (gh api).
candidates=$(
  {
    printf '%s' "$cmd" | grep -oE '\-\-body-file[ =][^ ]+' | sed -E 's/^--body-file[ =]//'
    printf '%s' "$cmd" | grep -oE '([[:space:]]|^)-F[[:space:]]+[^ ]+' | sed -E 's/.*-F[[:space:]]+//'
    printf '%s' "$cmd" | grep -oE 'body=?@[^ ]+' | sed -E 's/^body=?@//'
  } 2>/dev/null | sort -u
)

while IFS= read -r f; do
  [ -n "$f" ] || continue
  f=${f%\"}; f=${f#\"}; f=${f%\'}; f=${f#\'}   # strip surrounding quotes
  if [ -f "$f" ] && grep -qF "$MARKER" "$f" 2>/dev/null; then
    exit 0
  fi
done <<EOF
$candidates
EOF

REASON='이 GitHub 코멘트에 Claude Code 작성 표시가 없습니다. 코멘트 본문 끝에 아래 footer를 추가한 뒤 다시 실행하세요:

🤖 Generated with [Claude Code](https://claude.com/claude-code)

(hook은 claude.com/claude-code 마커가 본문 또는 --body-file/-F 대상 파일에 있는지 확인합니다.)'

jq -n --arg r "$REASON" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
exit 0
