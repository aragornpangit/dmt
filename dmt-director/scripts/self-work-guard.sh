#!/usr/bin/env bash
# PreToolUse hook：经理还有未派单元时，不许自己写交付物（先派后干的牙）
# 用法：self-work-guard.sh <role> <file>
set -eu
ROLE="${1:?usage: self-work-guard.sh <role> <file>}"
FILE="${2:-}"
# hook payload arrives on stdin (JSON); prefer it, the CLI argument is only a fallback
payload=""; if [ ! -t 0 ]; then payload="$(timeout 1 cat 2>/dev/null || true)"; fi
if [ -z "$FILE" ] && [ -n "$payload" ]; then
  FILE="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // .tool_input.path // .tool_input.notebook_path // empty' 2>/dev/null || true)"
fi
[ -n "$FILE" ] || exit 0
# 归一成绝对路径：hook 偶尔给相对路径，相对形式会绕过下面的 */docs/... 模式
FILE="$(realpath -m "$FILE" 2>/dev/null || printf '%s' "$FILE")"
DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/lib-dmt.sh"
# 角色解析：参数 "-" 或空 ⇒ $DMT_ROLE ⇒ herdr pane label；只治理 director/devm/anam 与 helper（director-helper/devm-helper/anam-helper）
ROLE="$(dmt_role "$ROLE")"
if [ "${DMT_DISPATCH_ALL:-0}" != 1 ]; then
  case "$ROLE" in director|devm|anam|director-helper|devm-helper|anam-helper) ;; *) exit 0 ;; esac
fi
case "$FILE" in
  */docs/pd/*|*/docs/dev/tickets/*|*/docs/analyst/*|*/docs/human/*) ;;
  *) exit 0 ;;
esac
# 判据只看「还有未派单元」：在途 ≥1 也要拦（否则先派 1 个就能自己写掉剩下全部交付物）
LEDGER="$(bash "$DIR/dispatch-ledger.sh" ledger-path "$ROLE" 2>/dev/null || true)"
if [ -n "$LEDGER" ] && [ -f "$LEDGER" ]; then
  pending="$(awk -F'\t' '$2=="planned"{c++} END{print c+0}' "$LEDGER")"
  [ "$pending" -ge 1 ] || exit 0
else
  exit 0
fi
{
  echo "[self-work-guard] 该文件是交付物，属于「单元工作」，而本批还有单元没派。"
  echo "[self-work-guard] 先派子代理（team.md §5.2 先派后干），或 dispatch-ledger.sh excuse <role> <unit> <code> 记理由。"
  bash "$DIR/dispatch-ledger.sh" report "$ROLE" || true
} >&2
exit 2
