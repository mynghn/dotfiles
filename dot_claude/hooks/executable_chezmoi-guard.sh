#!/bin/sh
file=$(jq -r '.tool_input.file_path // empty')
[ -z "$file" ] && exit 0

chezmoi source-path "$file" >/dev/null 2>&1 || exit 0

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"This file is chezmoi-managed."}}\n'
