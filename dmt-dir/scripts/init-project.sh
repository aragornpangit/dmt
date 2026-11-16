#!/usr/bin/env bash
# 初始化被服务项目：技能落点 + 核心产物目录 + 可选收件箱，并跑一次机检（幂等）
# 用法：bash init-project.sh [项目根目录] [--no-check]
set -eu
ROOT=""; CHECK=1
for a in "$@"; do
  case "$a" in
    --no-check) CHECK=0 ;;
    -*) echo "unknown option: $a" >&2; exit 2 ;;
    *) ROOT="$a" ;;
  esac
done
[ -n "$ROOT" ] || ROOT="$PWD"
mkdir -p "$ROOT"
ROOT="$(cd -P "$ROOT" && pwd -P)"
SCRIPT_DIR="$(cd -P "$(dirname "$0")" && pwd -P)"

mkdir -p "$ROOT"/docs/{pd/{prd,spec},dev/tickets,analyst,human/{human-arch,human-plan},handoff} \
         "$ROOT"/inbox/{dmt-dir,dmt-dm,dmt-am} "$ROOT"/locks

# 装到项目自己的技能目录，避免不同项目之间角色版本漂移；已有技能由安装器幂等刷新。
bash "$SCRIPT_DIR/install-skills.sh" "$ROOT" --no-artifact-check >/dev/null

# __pycache__/ 与 *.pyc：2026-11-05 实测——子代理的 python 探针会在目标项目留下 .pyc（不在交付物内）
for line in 'inbox/*/' 'locks/' '.codebuddy/' '__pycache__/' '*.pyc'; do
  grep -qxF "$line" "$ROOT/.gitignore" 2>/dev/null || echo "$line" >> "$ROOT/.gitignore"
done

echo "initialized: $ROOT"
if [ "$CHECK" = 1 ]; then
  DMT_SKILLS_DIR="$ROOT/.agents/skills" bash "$SCRIPT_DIR/check-dmt.sh" "$ROOT"
else
  echo "skip check（--no-check）；装好技能后再跑 bash $SCRIPT_DIR/check-dmt.sh \"$ROOT\""
fi
