#!/usr/bin/env bash
# 探测当前 harness 的最大子代理并行数（CAP），只输出一个整数。
# 优先级：DMT_SUBAGENT_CAP > CODEBUDDY_CODE_MAX_CONCURRENT_SUBAGENTS > 已知 harness 默认 > 8
#   codebuddy 会话默认 20（官方 sub-agents 文档）；探测不到的 harness 一律 8。
set -u
cap="${DMT_SUBAGENT_CAP:-}"
if [ -z "$cap" ]; then cap="${CODEBUDDY_CODE_MAX_CONCURRENT_SUBAGENTS:-}"; fi
if [ -z "$cap" ]; then
  if [ -n "${CODEBUDDY_SESSION_ID:-}${CODEBUDDY_CODE:-}${CODEBUDDY:-}" ] || command -v codebuddy >/dev/null 2>&1; then
    cap=20
  else
    cap=8
  fi
fi
case "$cap" in ''|*[!0-9]*|0) cap=8 ;; esac
echo "$cap"
