#!/usr/bin/env bash
# 探测当前 harness 最大支持的 agent 数（cap），输出团队有效并发上限 CAP = min(8, cap)。
# 优先级：DMT_SUBAGENT_CAP > CODEBUDDY_CODE_MAX_CONCURRENT_SUBAGENTS > 已知 harness 默认 > 8
#   codebuddy 原始 20（官方 sub-agents 文档）；探测不到的 harness 一律 8。
#   团队并发上限 8（用户裁定 2026-10-26）：cap > 8 按 8 算，总监/经理/队长一律 min(8, cap)。
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
cap=$((10#$cap))
if [ "$cap" -gt 8 ]; then cap=8; fi
echo "$cap"
