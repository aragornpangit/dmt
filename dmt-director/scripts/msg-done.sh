#!/usr/bin/env bash
# 收件方收口：办完后从 inbox/<role>/.doing/ 删除该消息
# 用法：bash msg-done.sh <role> <file>
set -eu
ROLE="${1:?usage: msg-done.sh <role> <file>}"
FILE="${2:?missing file}"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
BOX="$ROOT/inbox/$ROLE"
NAME="$(basename "$FILE")"
SRC="$BOX/.doing/$NAME"
[ -f "$SRC" ] || { echo "not in .doing: $SRC" >&2; exit 2; }
rm -f "$SRC"
echo "done: $NAME"
