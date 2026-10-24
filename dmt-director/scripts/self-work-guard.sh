#!/usr/bin/env bash
# PreToolUse hook：经理还有未派单元时，不许自己写交付物（先派后干的牙）
# 用法：self-work-guard.sh <role> <file>
set -eu
ROLE="${1:?usage: self-work-guard.sh <role> <file>}"
FILE="${2:?missing file}"
DIR="$(cd "$(dirname "$0")" && pwd)"
case "$FILE" in
  */docs/pd/*|*/docs/dev/tickets/*|*/docs/analyst/*|*/docs/human/*) ;;
  *) exit 0 ;;
esac
if bash "$DIR/dispatch-ledger.sh" check "$ROLE" >/dev/null 2>&1; then exit 0; fi
{
  echo "[self-work-guard] 该文件是交付物，属于「单元工作」，而本批还有单元没派。"
  echo "[self-work-guard] 先派子代理（team.md §5.2 先派后干），或 dispatch-ledger.sh excuse <unit> <code> 记理由。"
  bash "$DIR/dispatch-ledger.sh" report "$ROLE" || true
} >&2
exit 2
