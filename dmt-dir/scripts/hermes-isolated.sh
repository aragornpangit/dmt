#!/usr/bin/env bash
# hermes-isolated.sh —— 给每个 agent 实例独立 HERMES_HOME（建议 #2 的落地件）
#
# 为什么需要：gateway 与 agent 默认共用 `~/.hermes`（memory/ skills/ state.db auth.json），
# 实测已发生互相覆盖（agent 的 skill 被 gateway 侧 patch、memory 被改）。
# 软链不解决问题——软链仍指向同一份文件，仍会被另一方写。
#
# 做法：每个实例一个 home，技能用**副本**（首次播种时复制），凭证只在本机复制不外传。
#
# 用法：
#   bash hermes-isolated.sh <实例名> [-- hermes 参数...]
#   bash hermes-isolated.sh dmt-dir -- chat --yolo
#   bash hermes-isolated.sh dmt-dir --dry-run        # 只做目录准备并打印将执行的命令
#   HERMES_ISOLATED_NO_SEED=1 bash hermes-isolated.sh <名>   # 不播种（空 home）
#
# 回验（脚本会自己打印）：
#   ls "$HERMES_HOME"/state.db 应在本实例首次运行后新生成；原 ~/.hermes/state.db mtime 不再变
#
# rc：0=已 exec 或 dry-run 成功｜2=用法错｜3=源 home 不可读且要求播种｜4=hermes 不在 PATH
set -u

if [ $# -lt 1 ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  sed -n '2,22p' "$0"; exit 2
fi

NAME="$1"; shift
DRY=0
if [ "${1:-}" = "--dry-run" ]; then DRY=1; shift; fi
if [ "${1:-}" = "--" ]; then shift; fi

SRC="${HERMES_SRC_HOME:-$HOME/.hermes}"
DST="${HERMES_AGENTS_DIR:-$HOME/.hermes-agents}/$NAME"

if [ "$DRY" = 1 ]; then
  echo "hermes-isolated: [dry-run] 将使用 HERMES_HOME=$DST（本次不落盘、不播种）"
  [ -d "$DST/skills" ] && echo "  [dry-run] skills 已存在（不会覆盖）" || echo "  [dry-run] 将播种 skills 副本"
  [ -f "$DST/auth.json" ] && echo "  [dry-run] auth.json 已存在" || echo "  [dry-run] 将复制 auth.json（600）"
  echo "  [dry-run] 将执行: HERMES_HOME=\"$DST\" hermes $*"
  exit 0
fi

mkdir -p "$DST" || { echo "hermes-isolated: 无法创建 $DST" >&2; exit 3; }

seed=1
[ "${HERMES_ISOLATED_NO_SEED:-0}" = "1" ] && seed=0
if [ "$seed" = 1 ]; then
  if [ ! -d "$SRC" ]; then
    echo "hermes-isolated: 源 home 不可读（$SRC）；如需空 home 设 HERMES_ISOLATED_NO_SEED=1" >&2
    exit 3
  fi
  # 只播种一次：已有 skills 就不覆盖（避免把别的实例的改动带进来）
  if [ ! -d "$DST/skills" ] && [ -d "$SRC/skills" ]; then
    cp -a "$SRC/skills" "$DST/skills" && echo "hermes-isolated: 已播种 skills（副本，非软链）"
  fi
  if [ ! -f "$DST/auth.json" ] && [ -f "$SRC/auth.json" ]; then
    cp -a "$SRC/auth.json" "$DST/auth.json" && chmod 600 "$DST/auth.json" \
      && echo "hermes-isolated: 已复制 auth.json（仅本机，600）"
  fi
fi

echo "hermes-isolated: HERMES_HOME=$DST"
echo "  源 home: $SRC（不再被本实例写入）"

CMD=(hermes "$@")
command -v hermes >/dev/null 2>&1 || { echo "hermes-isolated: hermes 不在 PATH" >&2; exit 4; }
exec env HERMES_HOME="$DST" "${CMD[@]}"
