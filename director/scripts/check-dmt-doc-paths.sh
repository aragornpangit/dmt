#!/usr/bin/env bash
# dmt 产物落盘路径机检（检查「使用本团队的项目」）
# 判据来源：本仓 team.md §3「落盘唯一位置（硬约束）」
# 用法：bash director/scripts/check-dmt-doc-paths.sh [项目根目录]    默认当前目录
#     环境变量 DMT_SKILLS_DIR 可覆盖技能安装位置（默认 <项目根>/.agents/skills）
set -u

ROOT="$(cd "${1:-$PWD}" && pwd)" || exit 2
SKILLS_DIR="${DMT_SKILLS_DIR:-$ROOT/.agents/skills}"
# 契约定位：优先项目内的 docs/team.md，回退到脚本真实位置的上一级（脚本与本仓 team.md 同级时）
if [ -f "$ROOT/docs/team.md" ]; then
  CONTRACT="$ROOT/docs/team.md"
else
  CONTRACT="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)/team.md"
fi

# 六个产物目录（docs 下）+ 收件箱根（项目根下，不在 docs/ 内）
DOC_DIRS="docs/pd/prd docs/pd/spec docs/dev/tickets docs/analyst docs/human/human-arch docs/human/human-plan"

fail=0
echo "项目根：  $ROOT"
echo "技能目录：$SKILLS_DIR"
echo
echo "== 1) 六个产物目录与根目录 inbox/ 必须存在 =="
for d in $DOC_DIRS; do
  if [ -d "$ROOT/$d" ]; then
    echo "OK   目录存在            $d"
  else
    echo "FAIL 目录缺失            $d"
    fail=1
  fi
done
if [ -d "$ROOT/inbox" ]; then
  echo "OK   目录存在            inbox/（项目根，不在 docs/ 下）"
else
  echo "FAIL 目录缺失            inbox/（项目根，不在 docs/ 下）"
  fail=1
fi

echo
echo "== 2) 五个角色技能必须指向各自唯一目录 =="
check() {
  local file="$1" want="$2" who="${3:-}"
  [ -n "$who" ] || who="$(basename "$(dirname "$file")")"
  if [ ! -f "$file" ]; then
    echo "FAIL 未找到              $who（$file）"
    fail=1
    return
  fi
  if grep -q -- "$want" "$file"; then
    echo "OK   $who 含 $want"
  else
    echo "FAIL $who 缺 $want"
    fail=1
  fi
}
check "$SKILLS_DIR/director/SKILL.md" 'docs/pd/prd/'
check "$SKILLS_DIR/director/SKILL.md" 'docs/pd/spec/'
check "$SKILLS_DIR/director/SKILL.md" 'docs/human/human-arch/'
check "$SKILLS_DIR/director/SKILL.md" 'docs/human/human-plan/'
check "$SKILLS_DIR/dev-m/SKILL.md" 'docs/dev/tickets/'
check "$SKILLS_DIR/ana-m/SKILL.md" 'docs/analyst/'
check "$SKILLS_DIR/dev-tl/SKILL.md" 'docs/dev/tickets/'
check "$SKILLS_DIR/ana-tl/SKILL.md" 'docs/analyst/'

echo
echo "== 3) 组长实例关闭动作必须登记（用完即关；只有创建者能关） =="
check "$CONTRACT" 'herdr tab close' '团队契约'
check "$CONTRACT" '禁止先关后收' '团队契约'
check "$SKILLS_DIR/dev-m/SKILL.md" 'herdr tab close' 'dev-m'
check "$SKILLS_DIR/ana-m/SKILL.md" 'herdr tab close' 'ana-m'

echo
echo "== 4) 组长层并行判据必须登记（无依赖 ≥2 ⇒ 并发派发） =="
check "$SKILLS_DIR/dev-tl/SKILL.md" '必须并行' 'dev-tl'
check "$SKILLS_DIR/ana-tl/SKILL.md" '必须并行' 'ana-tl'
check "$CONTRACT" '≥2 ⇒ 必须并发派发' '团队契约'

echo
echo "== 4b) 经理层用工方式必须登记（自营 / 分包 双路径） =="
check "$SKILLS_DIR/dev-m/SKILL.md" '自营' 'dev-m'
check "$SKILLS_DIR/ana-m/SKILL.md" '自营' 'ana-m'
check "$CONTRACT" '用工方式' '团队契约'

echo
echo "== 5) 团队契约必须登记六个唯一目录与收件箱根 =="
if [ -f "$CONTRACT" ]; then
  for d in 'docs/pd/prd/' 'docs/pd/spec/' 'docs/dev/tickets/' 'docs/analyst/' 'docs/human/human-arch/' 'docs/human/human-plan/' 'inbox/'; do
    if grep -q -- "$d" "$CONTRACT"; then
      echo "OK   契约含              $d"
    else
      echo "FAIL 契约缺              $d"
      fail=1
    fi
  done
else
  echo "FAIL 未找到团队契约      $CONTRACT"
  fail=1
fi

echo
echo "== 6) 负样本：判据必须能拒绝坏路径（期望 rc=1） =="
# 只查「落盘唯一位置」登记表（§3 表格行）—— §8 变更记录里的历史留痕不算登记
if grep -E '^\|' "$CONTRACT" | grep -q -- 'not-a-dmt-output-dir'; then
  echo "FAIL 坏路径被登记为产物目录"
  fail=1
else
  echo "OK   坏路径未被登记为产物目录（表格命中 rc=1）"
fi

echo "---"
if [ "$fail" -eq 0 ]; then
  echo "ALL_PASS"
else
  echo "HAS_FAIL"
fi
exit "$fail"
