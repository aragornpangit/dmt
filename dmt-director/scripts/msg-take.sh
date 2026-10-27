#!/usr/bin/env bash
# 收件方认领：把消息从 inbox/<role>/ 移到 inbox/<role>/.doing/（认领在前、读入在后）
# 用法：bash msg-take.sh <role> <file>        file 可为文件名或路径，取 basename
set -eu
ROLE="${1:?usage: msg-take.sh <role> <file>}"
FILE="${2:?missing file}"
# 角色白名单：director|devm|anam|devtl{n}|anatl{n}，非法 exit 2
case "$ROLE" in
  director|devm|anam|devtl[0-9]*|anatl[0-9]*) ;;
  *) echo "bad role: $ROLE (want director|devm|anam|devtl{n}|anatl{n})" >&2; exit 2 ;;
esac
# 收件箱定位到主工作树根（与 close-leader/dispatch-ledger 同口径）
ROOT="$(cd "$(dirname "$(git rev-parse --git-common-dir)")" && pwd)"
BOX="$ROOT/inbox/$ROLE"
NAME="$(basename "$FILE")"
SRC="$BOX/$NAME"
[ -f "$SRC" ] || { echo "not found: $SRC" >&2; exit 2; }
mkdir -p "$BOX/.doing"
[ -e "$BOX/.doing/$NAME" ] && { echo "already taken: $NAME" >&2; exit 3; }
mv "$SRC" "$BOX/.doing/$NAME"
echo "$BOX/.doing/$NAME"
