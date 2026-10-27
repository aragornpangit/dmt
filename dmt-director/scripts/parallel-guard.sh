#!/usr/bin/env bash
# PreToolUse hook：治理角色在「还有未派单元」时，禁止同步（非后台）Agent 调用 —— 强制后台并行
# 用法：parallel-guard.sh <role|->
# hook payload（stdin JSON）含 .tool_name 与 .tool_input.run_in_background
set -eu
ROLE="${1:--}"
payload=""; if [ ! -t 0 ]; then payload="$(timeout 1 cat 2>/dev/null || true)"; fi
[ -n "$payload" ] || exit 0
tn="$(printf '%s' "$payload" | jq -r '.tool_name // empty' 2>/dev/null || true)"
case "$tn" in Agent|Task|Teammate|teammate) ;; *) exit 0 ;; esac
rb="$(printf '%s' "$payload" | jq -r '.tool_input.run_in_background // false' 2>/dev/null || true)"
[ "$rb" = "true" ] && exit 0
DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/lib-dmt.sh"
ROLE="$(dmt_role "$ROLE")"
if [ "${DMT_DISPATCH_ALL:-0}" != 1 ]; then
  case "$ROLE" in director|devm|anam|director-helper|devm-helper|anam-helper) ;; *) exit 0 ;; esac
fi
LEDGER="$(bash "$DIR/dispatch-ledger.sh" ledger-path "$ROLE" 2>/dev/null || true)"
[ -n "$LEDGER" ] && [ -f "$LEDGER" ] || exit 0
pending="$(awk -F'\t' '$2=="planned"{c++} END{print c+0}' "$LEDGER")"
[ "$pending" -ge 1 ] || exit 0
{
  echo "[parallel-guard] 本批还有 $pending 个未派单元：Agent 调用必须 run_in_background: true，"
  echo "[parallel-guard] 并在同一回复内并发派发（按需求开，上限 min(8, cap)）；同步调用会把并行变串行。"
  bash "$DIR/dispatch-ledger.sh" report "$ROLE" || true
} >&2
exit 2
