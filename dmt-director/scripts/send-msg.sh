#!/usr/bin/env bash
# 发收件箱消息 + herdr 门铃（文件名与方向自动生成）
# 用法：bash send-msg.sh <to> <from> <slug> <body-file> [--dry-run]
#   from ∈ director|devm|anam|{角色}-helper；to ∈ director|devm|anam（helper 无自己的 inbox、不接受输入框内容）
#   helper 发出的单向汇报只写箱、不按门铃（本体扫箱收取）
# 序号：max(扫描 inbox/<to>/** 含 .doing/ 的现有最大号, inbox/<to>/.seq 高水位) + 1
set -eu
TO="${1:?usage: send-msg.sh <to> <from> <slug> <body-file>}"
FROM="${2:?missing from}"
SLUG="${3:?missing slug}"
BODY="${4:?missing body file}"
DRY=0; [ "${5:-}" = "--dry-run" ] && DRY=1
# 发方白名单：director|devm|anam|{角色}-helper（helper 成果单向汇报主体）；收方不含 helper
# helper 是纯分身（用户裁定）：无自己的 inbox、不接受输入框内容 —— 任务随 spawn-helper 一次性下发
for who in "$TO"; do
  case "$who" in
    director|devm|anam) ;;
    director-helper|devm-helper|anam-helper)
      echo "helper 不接受输入框内容、无自己的 inbox（任务随 spawn-helper 一次性下发，成果由 helper 单向汇报主体）：$TO 不能作收方" >&2; exit 2 ;;
    *) echo "bad role: $TO (want director|devm|anam)" >&2; exit 2 ;;
  esac
done
case "$FROM" in
  director|devm|anam|director-helper|devm-helper|anam-helper) ;;
  *) echo "bad role: $FROM (want director|devm|anam|{角色}-helper)" >&2; exit 2 ;;
esac
[ -f "$BODY" ] || { echo "body file not found: $BODY" >&2; exit 2; }
[ -s "$BODY" ] || { echo "body file is empty: $BODY" >&2; exit 2; }

# 收件箱定位到主工作树根（与 dispatch-ledger 同口径；在 worktree 里跑也指回主树）
DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/lib-dmt.sh"
ROOT="$(dmt_root)"
# 并发账门禁：向上级回报前必须交账 —— 有未派单元且并发位空闲时拒发（DMT_MSG_FORCE=1 强发）
DIR="$(cd "$(dirname "$0")" && pwd)"
superior_of() {
  case "$1" in
    devm|anam) echo director ;;
    *) echo "" ;;
  esac
}
SUP="$(superior_of "$FROM")"
if [ -n "$SUP" ] && [ "$SUP" = "$TO" ] && [ "${DMT_MSG_FORCE:-0}" != 1 ]; then
  if ! bash "$DIR/dispatch-ledger.sh" check "$FROM" >/dev/null 2>&1; then
    echo "[send-msg] 并发账门禁：还有未派单元且并发位空闲，按需求开，上限 min(8, cap)，先派发再回报（DMT_MSG_FORCE=1 可强发）。" >&2
    bash "$DIR/dispatch-ledger.sh" report "$FROM" >&2 || true
    exit 2
  fi
fi
BOX="$ROOT/inbox/$TO"
mkdir -p "$BOX/.doing"

# 串行化「算号 + 落盘 + 写 .seq」：同一 inbox 有多个写者（devm / anam / 三个 helper）
LOCK="$BOX/.seq.lock"
tries=0
while ! mkdir "$LOCK" 2>/dev/null; do
  tries=$((tries + 1))
  [ "$tries" -lt 300 ] || { echo "[send-msg] 等锁超时：$LOCK" >&2; exit 4; }
  sleep 0.1
done
trap 'rmdir "$LOCK" 2>/dev/null || true' EXIT

# 扫描自愈：根目录与 .doing/ 里的现有最大号（.seq 丢失或被拷贝时兜底）
scan_max="$(find "$BOX" -maxdepth 2 -name '[0-9]*-*' -printf '%f\n' 2>/dev/null \
            | sed -n 's/^0*\([0-9]\{1,\}\)-.*/\1/p' | sort -n | tail -1 || true)"
# 高水位：已发出的最大号，不随消息删除而回退（内容必须是无前导零的十进制整数）
file_max="$(cat "$BOX/.seq" 2>/dev/null || echo 0)"
case "$file_max" in ''|*[!0-9]*) file_max=0 ;; esac
# 关键：文件名带前导零（077），.seq 可能是旧版写下的带零值；
# bash 的算术把 077 当八进制（=63），会把序号打回 64 造成撞号。
# 一律用 10# 强制十进制，再比较与自增。
[ -n "${scan_max:-}" ] || scan_max=0
scan_max=$((10#$scan_max))
file_max=$((10#$file_max))
if [ "$scan_max" -gt "$file_max" ]; then file_max="$scan_max"; fi
seq_num=$(( file_max + 1 ))
seq="$(printf '%03d' "$seq_num")"
ts="$(date +%y%m%d%H%M)"
DIRECTION="${FROM}2${TO}"
NAME="${seq}-${DIRECTION}-${SLUG}-${ts}.md"

if [ "$DRY" = 1 ]; then
  echo "+ cp $BODY $BOX/$NAME"; echo "+ printf '%d\n' $seq_num > $BOX/.seq"; echo "+ doorbell -> $TO"; exit 0
fi
cp "$BODY" "$BOX/$NAME"
printf '%d\n' "$seq_num" > "$BOX/.seq.tmp" && mv "$BOX/.seq.tmp" "$BOX/.seq"
rmdir "$LOCK" 2>/dev/null || true; trap - EXIT

# helper 的单向汇报只写箱、不按门铃（无门铃往返）：本体扫箱收取
case "$FROM" in
  *-helper) echo "$NAME"; exit 0 ;;
esac

pane="$(HERDR_ENV=1 herdr pane list --workspace "${HERDR_WORKSPACE_ID:-}" \
  | jq -r --arg l "$TO" '.result.panes[] | select(.label==$l) | .pane_id' | head -1 || true)"
[ -n "$pane" ] || { echo "WARN: pane label '$TO' not found; message written, doorbell skipped" >&2; echo "$NAME"; exit 0; }

MSG="你有新消息 ${NAME}，在 inbox/${TO}/"
out="$(HERDR_ENV=1 herdr agent prompt "$pane" "$MSG" 2>&1 || true)"
case "$out" in
  *agent_prompted*) ;;
  *)
    HERDR_ENV=1 herdr pane send-text "$pane" "$MSG"
    HERDR_ENV=1 herdr pane send-keys "$pane" enter
    ;;
esac
echo "$NAME"
