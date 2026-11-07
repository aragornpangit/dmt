#!/usr/bin/env bash
# 把 dmt 技能装到目标项目（默认软链，--copy 则复制）
# 用法：bash install-skills.sh <project-root> [--copy] [--harness all|claude,codebuddy,codex,opencode,pi]
#
# 技能落点（2026-11-04 逐 harness 探针实测：各 harness 只认自己的目录，**没有"一处通用"**）：
#   .agents/skills/    ← codex / opencode / pi（pi 的项目级 .agents/skills 需 --approve 才可见）
#   .claude/skills/    ← claude（opencode 也读它）
#   .codebuddy/skills/ ← codebuddy
# 默认 --harness all ⇒ 上面三处全装（五个 harness 全覆盖）；也可只装指定 harness 的落点。
# 不必另装 codex / pi 的私有目录（.codex/skills、.pi/skills）—— 它们已经读 .agents/skills/。
#
# 契约与脚本只落在 <target>/dmt-dir/，不再生成 docs/ 第二副本。
# link 模式软链、copy 模式复制；两种布局使用相同的相对链接。
set -eu

TARGET=""
MODE=link
HARNESS="all"
while [ $# -gt 0 ]; do
  case "$1" in
    --copy|copy) MODE=copy ;;
    link) MODE=link ;;
    --harness) HARNESS="${2:?missing harness list}"; shift ;;
    -*) echo "unknown arg: $1（只认 --copy 与 --harness）" >&2; exit 2 ;;
    *) TARGET="$1" ;;
  esac
  shift
done
[ -n "$TARGET" ] || { echo "usage: install-skills.sh <project-root> [--copy] [--harness all|claude,codebuddy,codex,opencode,pi]" >&2; exit 2; }

REPO="$(cd -P "$(dirname "$0")/../.." && pwd -P)"
# 目标目录不存在时自动创建（2026-11-06：此前直接 `cd` 失败，报错落在 set -e 的 line 33，提示无用）
if [ ! -d "$TARGET" ]; then
  mkdir -p "$TARGET" || { echo "install-skills: 无法创建目标目录 $TARGET" >&2; exit 2; }
fi
TARGET="$(cd -P "$TARGET" && pwd -P)"
# 防自引用：target 落在技能仓内时拒绝（否则会把软链建到自身，造出 <repo>/dmt-dir/dmt-dir 之类残留）
case "$TARGET" in
  "$REPO"|"$REPO"/*) echo "拒绝：target 落在技能仓内（$TARGET）—— 技能仓是维护地，不是安装目标" >&2; exit 2 ;;
esac

# harness → 技能落点目录：**单一来源＝harness_matrix.yaml**（经 harness-matrix.sh 读取），
# 不再在脚本里写死 case 分支。`all` 取矩阵的 install_all_dirs。
MATRIX="$REPO/dmt-dir/scripts/harness-matrix.sh"
[ -x "$MATRIX" ] || { echo "install-skills: 缺 harness-matrix.sh（无法解析落点）" >&2; exit 3; }
if [ "$HARNESS" = "all" ]; then
  out="$(bash "$MATRIX" install-dirs)" || exit 2
else
  out="$(bash "$MATRIX" install-dirs-for "$HARNESS")" || exit 2
fi
DIRS=""
for d in $out; do
  case " $DIRS " in *" $d "*) ;; *) DIRS="$DIRS $d" ;; esac
done
[ -n "$DIRS" ] || { echo "no skill dir resolved for --harness '$HARNESS'" >&2; exit 2; }

CORE_ITEMS="SKILL.md team.md OPS.md dmt_contract.yaml harness_matrix.yaml team ops harness scripts hooks"
SKILLS="dmt-dir dmt-dm dmt-dl dmt-am dmt-pde dmt-de dmt-ae"
# 历史改名遗留：旧技能名不会自动消失（软链会变断链、副本会变孤儿目录），安装时显式清理。
# 含 dmt-rve/dmt-pm/dmt-dtl/dmt-atl 等旧名，以及本轮改名前的 dmt-director / dmt-devl。
LEGACY_SKILLS="dmt-rve dmt-pm dmt-dtl dmt-atl dmt-director dmt-devl"
for rel in $DIRS; do
  mkdir -p "$TARGET/$rel"
  for s in $LEGACY_SKILLS; do rm -rf "$TARGET/$rel/$s"; done
  for s in $SKILLS; do
    # 目标已存在且是实体目录（旧版复制/旧落点）时必须先删，否则 ln -sfn 会把软链建到目录里面
    rm -rf "$TARGET/$rel/$s"
    if [ "$s" = "dmt-dir" ]; then
      mkdir -p "$TARGET/$rel/$s"
      for item in $CORE_ITEMS; do
        [ -e "$REPO/$s/$item" ] || continue
        if [ "$MODE" = "copy" ]; then
          cp -r "$REPO/$s/$item" "$TARGET/$rel/$s/$item"
        else
          ln -sfn "$REPO/$s/$item" "$TARGET/$rel/$s/$item"
        fi
      done
    elif [ "$MODE" = "copy" ]; then
      cp -r "$REPO/$s" "$TARGET/$rel/$s"
    else
      ln -sfn "$REPO/$s" "$TARGET/$rel/$s"
    fi
  done
  echo "skills -> $TARGET/$rel ($MODE)"
done

# 只分发运行所需文件；CHANGELOG、维护日志与仓级事故记录不进入目标项目。
# 脚本目录固定为 <target>/dmt-dir/scripts/，与契约命令一致。
if [ "$MODE" = "link" ] && [ -e "$TARGET/dmt-dir" ] && [ ! -L "$TARGET/dmt-dir" ]; then
  echo "WARN: $TARGET/dmt-dir 已存在且不是软链，沿用现有目录" >&2
else
  rm -rf "$TARGET/dmt-dir"
  mkdir -p "$TARGET/dmt-dir"
  for item in $CORE_ITEMS; do
    [ -e "$REPO/dmt-dir/$item" ] || continue
    if [ "$MODE" = "copy" ]; then
      cp -r "$REPO/dmt-dir/$item" "$TARGET/dmt-dir/$item"
    else
      ln -sfn "$REPO/dmt-dir/$item" "$TARGET/dmt-dir/$item"
    fi
  done
fi
chmod +x "$TARGET/dmt-dir/scripts/"*.sh 2>/dev/null || true

# 清理旧版 DMT 文档镜像；项目自己的其他 docs 内容不动。
# 唯一入口为 <target>/dmt-dir/team.md 与 OPS.md，避免双源和重复上下文。
rm -f "$TARGET/docs/team.md" "$TARGET/docs/OPS.md" \
      "$TARGET/docs/CHANGELOG.md"
rm -rf "$TARGET/docs/ops" "$TARGET/docs/team" "$TARGET/docs/changelog" "$TARGET/docs/harness"

# pi 子代理 agent 定义（.pi/agents/）：只装给 pi（或 all）。
# 为什么单列：pi 的 delegate 默认 inheritSkills: false ⇒ 子代理无技能清单；
# 这些定义用 inheritSkills: false + skills: 精确白名单把角色技能注入子代理（见 harness/pi.md §4.1）。
case " $HARNESS " in
  *" all "*|*" pi "*)
    mkdir -p "$TARGET/.pi/agents"
    # 清理源模板中已不存在的旧 agent 定义（改名遗留不会自动消失，不写死旧名）
    for f in "$TARGET/.pi/agents/"*.md; do
      [ -e "$f" ] || [ -L "$f" ] || continue
      b="$(basename "$f")"
      [ -f "$REPO/dmt-dir/harness/pi-agents/$b" ] || rm -f "$f"
    done
    for f in "$REPO/dmt-dir/harness/pi-agents/"*.md; do
      b="$(basename "$f")"
      [ "$b" = "README.md" ] && continue
      rm -f "$TARGET/.pi/agents/$b"
      if [ "$MODE" = "copy" ]; then cp "$f" "$TARGET/.pi/agents/$b"; else ln -sfn "$f" "$TARGET/.pi/agents/$b"; fi
    done
    echo "pi agents -> $TARGET/.pi/agents ($MODE)"
    ;;
esac

# 安装只分发并检查技能；目录与收件箱由用户显式运行 init-project.sh 建立。
# DMT_SKILLS_DIR 指向本次实际装的第一个落点，避免平台目录不同时误判。
FIRST_DIR="$(printf '%s' "$DIRS" | awk '{print $1}')"
DMT_SKILLS_DIR="$TARGET/$FIRST_DIR" bash "$REPO/dmt-dir/scripts/check-dmt.sh" "$TARGET"
echo "installed ($MODE, --harness $HARNESS) into $TARGET"
