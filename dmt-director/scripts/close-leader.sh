#!/usr/bin/env bash
# 经理用：关闭本批队长 pane（只关 pane、不关 tab；非创建者不得代关）
# 用法：bash close-leader.sh <devm|anam> <n> [--force] [--dry-run]
set -eu
ROLE="${1:?usage: close-leader.sh <devm|anam> <n> [--force] [--dry-run]}"
N="${2:?missing n}"
shift 2 || true
FORCE=0; DRY=0
for a in "$@"; do
  case "$a" in --force) FORCE=1 ;; --dry-run) DRY=1 ;; *) echo "unknown arg: $a" >&2; exit 2 ;; esac
done
case "$ROLE" in devm|anam) ;; *) echo "role must be devm|anam" >&2; exit 2 ;; esac
if [ "$ROLE" = devm ]; then PREFIX=devtl; ME=devm; else PREFIX=anatl; ME=anam; fi
LABEL="${PREFIX}${N}"

list="$(HERDR_ENV=1 herdr pane list --workspace "${HERDR_WORKSPACE_ID:-}" 2>/dev/null)" || { echo "herdr pane list failed" >&2; exit 2; }
pane="$(printf '%s' "$list" | jq -r --arg l "$LABEL" '.result.panes[] | select(.label==$l) | .pane_id' | head -1 || true)"
[ -n "$pane" ] || { echo "$LABEL not found (already closed?)"; exit 0; }

# 收件箱定位到主工作树根（与 send-msg / msg-take 同口径；在 worktree 里跑也指回主树）
root="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)"
if [ -n "$root" ]; then
  case "$root" in */.git) root="${root%/.git}" ;; esac
else
  root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
inbox="$root/inbox/$ME"
# 未读按方向过滤：只把 ^[0-9]+-{队长}2{经理}- 的消息（含 .doing/）算该队长的未读/未收口
pat="^[0-9]+-${LABEL}2${ME}-"
unread="$(find "$inbox" -maxdepth 1 -name '*.md' -printf '%f\n' 2>/dev/null | grep -E "$pat" | head -1 || true)"
doing="$(find "$inbox/.doing" -maxdepth 1 -name '*.md' -printf '%f\n' 2>/dev/null | grep -E "$pat" | head -1 || true)"
if [ "$FORCE" != 1 ] && { [ -n "$unread" ] || [ -n "$doing" ]; }; then
  echo "REFUSE: $inbox 还有 ${LABEL}2${ME} 方向的未读或未收口消息（未读 ${unread:-无} / 未收口 ${doing:-无}）；先处理，或加 --force" >&2
  exit 3
fi

echo "人工确认清单（关闭 $LABEL 前逐项确认）：① 回报已入账 ② worktree 已 git worktree remove（由关闭者确认）③ 未读自动判（本脚本按 ${LABEL}2${ME} 方向查过）"
if [ "$DRY" = 1 ]; then echo "+ herdr pane close $pane"; else
  HERDR_ENV=1 herdr pane close "$pane"
  echo "closed $LABEL ($pane)"
fi
