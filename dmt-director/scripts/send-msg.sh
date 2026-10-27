#!/usr/bin/env bash
# 发收件箱消息 + herdr 门铃（文件名与方向自动生成）
# 用法：bash send-msg.sh <to> <from> <slug> <body-file> [--dry-run]
#   to/from ∈ director|devm|anam|devtl{n}|anatl{n}（pm 已并入 director）
# 序号：max(扫描 inbox/<to>/** 含 .doing/ 的现有最大号, inbox/<to>/.seq 高水位) + 1
set -eu
TO="${1:?usage: send-msg.sh <to> <from> <slug> <body-file>}"
FROM="${2:?missing from}"
SLUG="${3:?missing slug}"
BODY="${4:?missing body file}"
DRY=0; [ "${5:-}" = "--dry-run" ] && DRY=1
# 收发双方白名单：director|devm|anam|devtl{n}|anatl{n}，非法直接拒发（exit 2）
for who in "$TO" "$FROM"; do
  case "$who" in
    director|devm|anam|devtl[0-9]*|anatl[0-9]*) ;;
    *) echo "bad role: $who (want director|devm|anam|devtl{n}|anatl{n})" >&2; exit 2 ;;
  esac
done
[ -f "$BODY" ] || { echo "body file not found: $BODY" >&2; exit 2; }
[ -s "$BODY" ] || { echo "body file is empty: $BODY" >&2; exit 2; }

# 收件箱定位到主工作树根（与 close-leader/dispatch-ledger 同口径；在 worktree 里跑也指回主树）
ROOT="$(cd "$(dirname "$(git rev-parse --git-common-dir)")" && pwd)"
# 并发账门禁：向上级回报前必须交账 —— 有未派单元且并发位空闲时拒发（DMT_MSG_FORCE=1 强发）
DIR="$(cd "$(dirname "$0")" && pwd)"
superior_of() {
  case "$1" in
    devm|anam) echo director ;;
    devtl*) echo devm ;;
    anatl*) echo anam ;;
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
