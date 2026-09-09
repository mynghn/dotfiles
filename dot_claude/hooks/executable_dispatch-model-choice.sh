#!/usr/bin/env bash
# dispatch(Workflow·Agent)의 model·effort 배치를 그대로 비춰 준다.
#
# 왜: 같은 실수가 세 번 재발했다 — model·effort를 "적기는" 하면서 전부 같은 값으로 채웠다.
# 기억 노트는 세션 시작에 한 번 읽히고, 정작 dispatch를 짜는 순간엔 아무것도 멈춰 세우지 않는다.
#
# 무엇을 하지 않는가: **판정하지 않는다.** 어떤 배치가 옳은지는 워크로드마다 다르다.
# 임계값도 처방("이건 sonnet으로")도 두지 않는다 — 고른 값을 사실로 되비출 뿐이다.
# 경고만 낸다. 차단하지 않는다 — 사용자에게는 systemMessage로,
# dispatch를 짜는 모델에게는 hookSpecificOutput.additionalContext로 같은 한 줄을 보낸다.
# (systemMessage는 사용자 터미널 전용이라 모델에겐 아무것도 남지 않았다.
#  PreToolUse의 additionalContext는 CC 2.1.266 스키마에 있고 permissionDecision 없이도 전달된다.
#  permissionDecisionReason은 deny/ask일 때만 살아남으므로 여기선 쓸 수 없다 — 그건 차단이다.)
set -uo pipefail
payload="$(cat)"
tool="$(printf '%s' "$payload" | jq -r '.tool_name // ""')"
NUDGE='이 워크로드에 맞는 배치인지 확인하라.'

emit() {
  jq -cn --arg m "$1" '{
    systemMessage: $m,
    suppressOutput: true,
    hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: $m}
  }'
  exit 0
}

# "opus×3, sonnet×1" 꼴로 센다. 값이 없는 호출은 "없음×N".
tally() { # $1=script  $2=key  $3=총 호출 수
  local found
  found=$(printf '%s\n' "$1" | grep -oE "$2: *['\"][A-Za-z0-9._-]+['\"]" \
          | sed -E "s/.*['\"]([^'\"]+)['\"]/\1/" | sort | uniq -c \
          | awk '{printf "%s×%s, ", $2, $1}')
  local n; n=$(printf '%s\n' "$1" | grep -o "$2:" | wc -l | tr -d ' ')
  if [ "${3:-0}" -gt "$n" ]; then found="${found}없음×$(( $3 - n )), "; fi
  printf '%s' "${found%, }"
}

case "$tool" in
  Workflow)
    script="$(printf '%s' "$payload" | jq -r '.tool_input.script // .tool_input.scriptPath // ""')"
    [ -z "$script" ] && exit 0
    [ -f "$script" ] && script="$(cat "$script" 2>/dev/null || true)"
    agents=$(printf '%s\n' "$script" | grep -o 'agent(' | wc -l | tr -d ' ')
    [ "${agents:-0}" -lt 1 ] && exit 0
    emit "dispatch agent ${agents} — model: $(tally "$script" model "$agents") · effort: $(tally "$script" effort "$agents") · ${NUDGE}"
    ;;
  Agent)
    st="$(printf '%s' "$payload" | jq -r '.tool_input.subagent_type // ""')"
    [ "$st" = "fork" ] && exit 0
    m="$(printf '%s' "$payload" | jq -r '.tool_input.model // "세션 상속"')"
    emit "dispatch Agent — model: ${m} · ${NUDGE}"
    ;;
esac
exit 0
