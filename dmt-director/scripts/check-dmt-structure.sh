#!/usr/bin/env bash
# check-dmt-structure.sh —— 结构化机检（YAML 单一来源）
#
# 与 check-dmt-doc-paths.sh 的分工：
#   · 本脚本校验**结构性事实**：技能清单、版本同号、产物目录、脚本齐备、harness 矩阵、
#     已废止脚本不得回潮。事实定义在 dmt-director/dmt_contract.yaml（单一来源）。
#   · check-dmt-doc-paths.sh 仍保留「散文纪律是否登记」的软断言（写进 team.md / 技能即可）。
#
# 用法：bash check-dmt-structure.sh [项目根目录]      默认当前目录
#   DMT_SKILLS_DIR 覆盖技能安装位置（默认 <项目根>/.agents/skills）
#   DMT_CONTRACT_YAML 覆盖结构契约路径（默认 <仓>/dmt-director/dmt_contract.yaml）
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/../.." && pwd)"
ROOT="$(cd "${1:-$PWD}" && pwd)" || exit 2
SKILLS_DIR="${DMT_SKILLS_DIR:-$ROOT/.agents/skills}"
CONTRACT_YAML="${DMT_CONTRACT_YAML:-$REPO/dmt-director/dmt_contract.yaml}"

fail=0
ok()   { echo "OK   $*"; }
bad()  { echo "FAIL $*"; fail=1; }

if ! command -v python3 >/dev/null 2>&1 || ! python3 -c 'import yaml' >/dev/null 2>&1; then
  echo "FAIL 需要 python3 + PyYAML 才能跑结构化机检"; exit 3
fi
[ -f "$CONTRACT_YAML" ] || { echo "FAIL 结构契约不存在：$CONTRACT_YAML"; exit 2; }

export DMT_CONTRACT_YAML="$CONTRACT_YAML"

echo "项目根：    $ROOT"
echo "技能目录：  $SKILLS_DIR"
echo "结构契约：  $CONTRACT_YAML"
echo

# ---- 1) 版本同号：契约 version 必须等于全部 version_sources ----
echo "== 1) 版本同号（dmt_contract.yaml.version = 全部 version_sources） =="
ver="$(python3 -c 'import os,yaml;print(yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["version"])')"
echo "契约版本：$ver"
while IFS= read -r f; do
  [ -n "$f" ] || continue
  # 版本源路径解析：仓内布局（$REPO/dmt-dm/SKILL.md）优先；否则回退到技能目录
  # （目标项目里技能装在 $SKILLS_DIR/dmt-dm/SKILL.md，没有仓内 dmt-dm/ 目录）。
  path="$REPO/$f"
  if [ ! -f "$path" ]; then
    skill_name="$(basename "$(dirname "$f")")"
    path="$SKILLS_DIR/$skill_name/SKILL.md"
  fi
  if [ ! -f "$path" ]; then bad "版本源缺失：$f"; continue; fi
  case "$f" in
    dmt-director/team.md)
      # team.md 在目标项目里是 docs/team.md（软链到 dmt-director/team.md）；回退查 $ROOT/docs/team.md
      tp="$path"; [ -f "$tp" ] || tp="$ROOT/docs/team.md"
      got="$(head -5 "$tp" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)" ;;
    *)
      got="$(sed -n 's/^version: *//p' "$path" | head -1)" ;;
  esac
  if [ "$got" = "$ver" ]; then ok "版本同号 $f ($got)"; else bad "版本不同号 $f：$got ≠ $ver"; fi
done < <(python3 -c 'import os,yaml;[print(x) for x in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["version_sources"]]')
echo

# ---- 2) 技能清单：七个技能在技能目录里各有一个 SKILL.md，名字与 name: 字段一致 ----
echo "== 2) 技能清单（七个技能各就各位，frontmatter name 一致） =="
while IFS= read -r skill; do
  skill="${skill% }"
  [ -n "$skill" ] || continue
  f="$SKILLS_DIR/$skill/SKILL.md"
  if [ ! -f "$f" ]; then bad "技能缺失 $skill（$f）"; continue; fi
  nm="$(sed -n 's/^name: *//p' "$f" | head -1)"
  if [ "$nm" = "$skill" ]; then ok "技能 $skill（name 一致）"; else bad "技能 $skill：frontmatter name=$nm 不一致"; fi
done < <(python3 -c 'import os,yaml;[print(k) for k in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["skills"]]')
echo

# ---- 3) 产物目录 + 运行时目录必须存在（仅当 ROOT 是被管理的目标项目时要求） ----
# 技能仓自身（ROOT == REPO）不装产物目录，跳过（避免维护仓误报红）。
echo "== 3) 产物目录 / 运行时目录 =="
if [ "$ROOT" = "$REPO" ]; then
  echo "SKIP 维护仓自身（$ROOT == 技能仓）—— 不要求装产物目录"
else
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    if [ -d "$ROOT/$d" ]; then ok "目录 $d"; else bad "目录缺失 $d"; fi
  done < <(python3 -c 'import os,yaml;[print(x) for x in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["artifact_dirs"]]')
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    if [ -d "$ROOT/$d" ]; then ok "运行时目录 $d"; else bad "运行时目录缺失 $d"; fi
  done < <(python3 -c 'import os,yaml;[print(x) for x in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["runtime_dirs"]]')
fi
echo

# ---- 4) 脚本齐备且可执行；已废止脚本不得回潮 ----
echo "== 4) 脚本齐备 + 已废止脚本不得回潮 =="
while IFS= read -r s; do
  [ -n "$s" ] || continue
  f="$SCRIPT_DIR/$s"
  if [ -x "$f" ]; then ok "脚本可执行 $s"; else bad "脚本缺失或不可执行 $s"; fi
done < <(python3 -c 'import os,yaml;[print(x) for x in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["scripts"]]')
while IFS= read -r s; do
  [ -n "$s" ] || continue
  if [ -e "$SCRIPT_DIR/$s" ]; then bad "已废止脚本回潮 $s"; else ok "已废止脚本未回潮 $s"; fi
done < <(python3 -c 'import os,yaml;[print(x) for x in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["forbidden_scripts"]]')
echo

# ---- 5) harness 矩阵：五个 harness 齐备，落点/前缀/启动命令/并发上限字段完整 ----
echo "== 5) harness 矩阵完整性（harness_matrix.yaml） =="
MATRIX="$SCRIPT_DIR/harness-matrix.sh"
if [ ! -x "$MATRIX" ]; then bad "缺 harness-matrix.sh"; else
  for h in codebuddy claude codex opencode pi; do
    pre="$(bash "$MATRIX" get "$h" slash_prefix 2>/dev/null || true)"
    cmd="$(bash "$MATRIX" get "$h" start_cmd 2>/dev/null || true)"
    dir="$(bash "$MATRIX" get "$h" skills.dir_project 2>/dev/null || true)"
    if [ -n "$pre" ] && [ -n "$cmd" ] && [ -n "$dir" ]; then
      ok "harness $h（dir=$dir prefix=$pre）"
    else
      bad "harness $h 字段不完整（prefix='$pre' cmd='$cmd' dir='$dir'）"
    fi
  done
  # pi 的前缀必须是 /skill:，其余必须是 /
  for h in codebuddy claude codex opencode; do
    pre="$(bash "$MATRIX" get "$h" slash_prefix)"
    [ "$pre" = "/" ] && ok "$h 前缀 /" || bad "$h 前缀应为 /，实为 '$pre'"
  done
  p="$(bash "$MATRIX" get pi slash_prefix)"
  [ "$p" = "/skill:" ] && ok "pi 前缀 /skill:" || bad "pi 前缀应为 /skill:，实为 '$p'"
fi
echo

# ---- 6) 单一来源纪律：每份技能须「指针」到 team.md，不得复述团队级共性口径 ----
echo "== 6) 单一来源纪律（技能指针到 team.md，不复述共性口径） =="
while IFS= read -r skill; do
  skill="${skill% }"; [ -n "$skill" ] || continue
  f="$SKILLS_DIR/$skill/SKILL.md"
  [ -f "$f" ] || continue
  if grep -qE 'team\.md|docs/team\.md' "$f"; then
    ok "技能 $skill 指针到 team.md"
  else
    bad "技能 $skill 未指针到 team.md（共性口径应写指针，不复述）"
  fi
  # 负向：技能正文不得复述「写操作归属」整句（应指针）
  if grep -q '硬件设备写操作.*只.*devm.*director.*均可' "$f"; then
    bad "技能 $skill 复述了写操作归属整句（应指针到 team.md §5.4）"
  else
    ok "技能 $skill 未复述写操作归属整句"
  fi
done < <(python3 -c 'import os,yaml;[print(k) for k in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["skills"]]')
echo

if [ "$fail" = 0 ]; then echo "ALL_PASS"; else echo "HAS_FAIL"; fi
exit "$fail"
