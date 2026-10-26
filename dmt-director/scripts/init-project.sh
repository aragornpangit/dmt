#!/usr/bin/env bash
# 初始化被服务项目的目录与 .gitignore，并跑一次机检（幂等）
# 用法：bash init-project.sh [项目根目录]（默认当前目录）
set -eu
ROOT="$(cd "${1:-$PWD}" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$ROOT"/docs/{pd/{prd,spec},dev/tickets,analyst,human/{human-arch,human-plan}} \
         "$ROOT"/inbox/{director,devm,anam} "$ROOT"/locks

for line in 'inbox/*/' 'locks/'; do
  grep -qxF "$line" "$ROOT/.gitignore" 2>/dev/null || echo "$line" >> "$ROOT/.gitignore"
done

echo "initialized: $ROOT"
bash "$SCRIPT_DIR/check-dmt-doc-paths.sh" "$ROOT"
