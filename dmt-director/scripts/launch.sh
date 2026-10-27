#!/usr/bin/env bash
# director 用：一键拉起 dmt 团队（幂等，可分阶段跳过）
# 用法：bash launch.sh [项目根目录] [选项]（项目根默认当前目录）
#   --copy          技能改为复制安装（默认软链）
#   --user-hooks    hooks 装用户级 ~/.codebuddy（默认装项目级 <root>/.codebuddy）
#   --skip-skills   跳过技能安装
#   --skip-hooks    跳过 hooks 安装
#   --skip-team     跳过建团队 pane（无 herdr 环境时也会自动跳过）
#   --dry-run       只打印将执行的动作，不实际执行
# 阶段（顺序固定）：① install-skills → ② init-project → ③ install-hooks → ④ setup-team
# 请在技能仓（或其安装副本）的 dmt-director/scripts/ 内执行本脚本。
set -eu
ROOT="."
COPY=0; USERHOOKS=0; DOSKILLS=1; DOHOOKS=1; DOTEAM=1; DRY=0
ARGS=()
for a in "$@"; do
  case "$a" in
    --copy) COPY=1 ;;
    --user-hooks) USERHOOKS=1 ;;
    --skip-skills) DOSKILLS=0 ;;
    --skip-hooks) DOHOOKS=0 ;;
    --skip-team) DOTEAM=0 ;;
    --dry-run) DRY=1 ;;
    -*) echo "unknown option: $a" >&2; exit 2 ;;
    *) ARGS+=("$a") ;;
  esac
done
if [ "${#ARGS[@]}" -gt 0 ]; then
  ROOT="$(cd "${ARGS[0]}" && pwd)"
else
  ROOT="$PWD"
fi
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

run() { echo "[launch] $*"; [ "$DRY" = 1 ] || "$@"; }

echo "[launch] 目标项目：$ROOT"
if [ "$DOSKILLS" = 1 ]; then
  if [ "$COPY" = 1 ]; then run bash "$SCRIPT_DIR/install-skills.sh" "$ROOT" --copy
  else run bash "$SCRIPT_DIR/install-skills.sh" "$ROOT"; fi
else
  echo "[launch] 跳过技能安装"
fi

run bash "$SCRIPT_DIR/init-project.sh" "$ROOT"

if [ "$DOHOOKS" = 1 ]; then
  if [ "$USERHOOKS" = 1 ]; then run bash "$SCRIPT_DIR/install-hooks.sh" --user
  else run bash "$SCRIPT_DIR/install-hooks.sh" "$ROOT"; fi
else
  echo "[launch] 跳过 hooks 安装"
fi

if [ "$DOTEAM" = 1 ]; then
  # 建团队守卫：四个 herdr 变量齐备才建（缺一则 setup-team.sh 会在 : "$VAR" 处直接断掉）
  missing=""
  [ -n "${HERDR_ENV:-}" ] || missing="$missing HERDR_ENV"
  [ -n "${HERDR_PANE_ID:-}" ] || missing="$missing HERDR_PANE_ID"
  [ -n "${HERDR_TAB_ID:-}" ] || missing="$missing HERDR_TAB_ID"
  [ -n "${HERDR_WORKSPACE_ID:-}" ] || missing="$missing HERDR_WORKSPACE_ID"
  # 建 pane 的 cwd 取 setup-team.sh 的 $PWD，必须先进项目根再调用，否则 pane 会落在 scripts/ 目录
  if [ -z "$missing" ]; then ( cd "$ROOT" && run bash "$SCRIPT_DIR/setup-team.sh" )
  else echo "[launch] herdr 环境不齐（缺:$missing），跳过建团队；在 director pane 内重跑本脚本或直接 bash $SCRIPT_DIR/setup-team.sh"; fi
else
  echo "[launch] 跳过建团队"
fi

echo "[launch] 完成。机检：bash $SCRIPT_DIR/check-dmt-doc-paths.sh $ROOT"
