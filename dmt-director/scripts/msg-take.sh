#!/usr/bin/env bash
# 收件方认领：把消息从 inbox/<role>/ 移到 inbox/<role>/.doing/（认领在前、读入在后）
# 用法：bash msg-take.sh <role> <file>        file 可为文件名或路径，取 basename
set -eu
ROLE="${1:?usage: msg-take.sh <role> <file>}"
FILE="${2:?missing file}"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
BOX="$ROOT/inbox/$ROLE"
NAME="$(basename "$FILE")"
SRC="$BOX/$NAME"
[ -f "$SRC" ] || { echo "not found: $SRC" >&2; exit 2; }
mkdir -p "$BOX/.doing"
[ -e "$BOX/.doing/$NAME" ] && { echo "already taken: $NAME" >&2; exit 3; }
mv "$SRC" "$BOX/.doing/$NAME"
echo "$BOX/.doing/$NAME"
