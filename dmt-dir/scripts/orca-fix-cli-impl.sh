#!/usr/bin/env bash
# 修 orca CLI 的 jsonc-parser 子模块缺失（Cannot find module './impl/format'）。
# 用法：bash orca-fix-cli-impl.sh [--check] [--artifact <dir>]
#   --check        只判定当前是否已修好，不动文件（rc=0 已修好 / 1 缺失）
#   --artifact     指定 artifact 目录（缺省从 orca 启动器解析）
#
# 背景：orca 1.4.237 的 out/cli/index.js 内联了 jsonc-parser 主模块，但 UMD 分支
# 仍走 `require("./impl/format")` 等相对路径，而 bundle 未包含 impl/* 四个子模块。
# 结果：`orca agent hooks status` 报 Cannot find module './impl/format'（升级后必复发）。
# 修法：把本机已安装的 jsonc-parser（同主版本 3.x）的 UMD impl/*.js 复制到 out/cli/impl/。
# 幂等：目标文件已存在则跳过；不改 index.js、不改任何判据。
set -eu
CHECK=0; ARTIFACT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --check) CHECK=1 ;;
    --artifact) ARTIFACT="${2:?missing artifact dir}"; shift ;;
    *) echo "unknown arg: $1（只认 --check / --artifact）" >&2; exit 2 ;;
  esac
  shift
done

LAUNCHER="$HOME/.config/orca/cli/bin/orca"
if [ -z "$ARTIFACT" ]; then
  [ -f "$LAUNCHER" ] || { echo "orca-fix: 找不到启动器 $LAUNCHER" >&2; exit 3; }
  ARTIFACT="$(sed -n "s#.*exec '[^']*node' '\([^']*/out/cli/index.js\)'.*#\1#p" "$LAUNCHER" | head -1)"
  ARTIFACT="${ARTIFACT%/out/cli/index.js}"
fi
[ -d "$ARTIFACT/out/cli" ] || { echo "orca-fix: 不是有效的 artifact 目录：$ARTIFACT" >&2; exit 3; }

need=0
for m in format edit scanner parser string-intern; do
  [ -f "$ARTIFACT/out/cli/impl/$m.js" ] || need=1
done

if [ "$CHECK" = 1 ]; then
  if [ "$need" = 0 ]; then echo "OK  impl 子模块齐全：$ARTIFACT/out/cli/impl"; exit 0; fi
  echo "MISSING  $ARTIFACT/out/cli/impl 缺子模块" >&2; exit 1
fi

if [ "$need" = 0 ]; then
  echo "已修好，无需动作：$ARTIFACT/out/cli/impl"
else
  SRC=""
  for c in "$HOME/.local/lib/node_modules/rea-agents/node_modules/jsonc-parser/lib/umd/impl" \
           "$HOME"/.nvm/versions/node/*/lib/node_modules/*/node_modules/jsonc-parser/lib/umd/impl \
           /usr/lib/node_modules/*/node_modules/jsonc-parser/lib/umd/impl; do
    [ -f "$c/format.js" ] && { SRC="$c"; break; }
  done
  [ -n "$SRC" ] || SRC="$(find "$HOME" /usr/lib/node_modules -maxdepth 8 -type d -path '*jsonc-parser/lib/umd/impl' 2>/dev/null | head -1)"
  [ -n "$SRC" ] || { echo "orca-fix: 本机找不到 jsonc-parser 的 UMD impl 目录" >&2; exit 4; }
  echo "源：$SRC"
  mkdir -p "$ARTIFACT/out/cli/impl"
  for m in format edit scanner parser string-intern; do
    [ -f "$SRC/$m.js" ] || { echo "orca-fix: 源缺 $m.js" >&2; exit 4; }
    cp -a "$SRC/$m.js" "$ARTIFACT/out/cli/impl/$m.js"
    echo "  + impl/$m.js"
  done
fi

# 回验：只对当前生效的 artifact 跑（拷到别处试修时不做，避免假绿）
ACTIVE=""
[ -f "$LAUNCHER" ] && ACTIVE="$(sed -n "s#.*exec '[^']*node' '\([^']*/out/cli/index.js\)'.*#\1#p" "$LAUNCHER" | head -1)"
if [ -n "$ACTIVE" ] && [ "${ACTIVE%/out/cli/index.js}" = "$ARTIFACT" ] && command -v orca >/dev/null 2>&1; then
  if orca agent hooks status >/dev/null 2>&1; then
    echo "回验 OK：orca agent hooks status rc=0"
  else
    echo "回验 FAIL：orca agent hooks status 仍失败" >&2; exit 5
  fi
else
  echo "跳过回验（非生效 artifact）：$ARTIFACT"
fi
