#!/usr/bin/env bash
# dmt 产物落盘路径机检（检查「使用本团队的项目」）
# 判据来源：本仓 team.md §3「落盘唯一位置（硬约束）」、§1 组织、§5 并行口径
# 用法：bash dmt-director/scripts/check-dmt-doc-paths.sh [项目根目录]    默认当前目录
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
echo "== 2) 六个角色技能必须指向各自唯一目录（PRD / SPEC / 工单 / 人类文档归 dmt-pm） =="
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
check "$SKILLS_DIR/dmt-pm/SKILL.md" 'docs/pd/prd/'
check "$SKILLS_DIR/dmt-pm/SKILL.md" 'docs/pd/spec/'
check "$SKILLS_DIR/dmt-pm/SKILL.md" 'docs/dev/tickets/'
check "$SKILLS_DIR/dmt-pm/SKILL.md" 'to-tickets'
check "$SKILLS_DIR/dmt-pm/SKILL.md" 'docs/human/human-arch/'
check "$SKILLS_DIR/dmt-pm/SKILL.md" 'docs/human/human-plan/'
check "$SKILLS_DIR/dmt-director/SKILL.md" 'docs/team.md'
check "$SKILLS_DIR/dmt-dm/SKILL.md" 'docs/dev/tickets/'
check "$SKILLS_DIR/dmt-am/SKILL.md" 'docs/analyst/'
check "$SKILLS_DIR/dmt-dtl/SKILL.md" 'docs/dev/tickets/'
check "$SKILLS_DIR/dmt-atl/SKILL.md" 'docs/analyst/'

echo
echo "== 2b) 组织归属：director 管 pm/devm/anam，pm 无队长层只用子代理 =="
check "$SKILLS_DIR/dmt-director/SKILL.md" 'pm' 'director'
check "$SKILLS_DIR/dmt-director/SKILL.md" 'setup-team.sh' 'director'
check "$SKILLS_DIR/dmt-pm/SKILL.md" '子代理' 'dmt-pm'
check "$CONTRACT" '| `dmt-pm` | `pm` |' '团队契约'

echo
echo "== 3) 队长实例关闭动作必须登记（用完即关；只有创建者能关；只关 pane 不关 tab） =="
check "$CONTRACT" 'close-leader.sh' '团队契约'
check "$CONTRACT" '禁止先关后收' '团队契约'
check "$CONTRACT" '只许关 pane' '团队契约'   # 禁则本体：只许关 pane（'herdr tab close' 在 §8 历史里也会出现，不能拿它当判据）
check "$SKILLS_DIR/dmt-dm/SKILL.md" 'close-leader.sh' 'devm'
check "$SKILLS_DIR/dmt-am/SKILL.md" 'close-leader.sh' 'anam'

echo
echo "== 3b) 身份识别必须按 pane label（不得按 tab 内位置） =="
check "$CONTRACT" 'pane label' '团队契约'
check "$CONTRACT" '不按 tab 内位置' '团队契约'
for role in dmt-director dmt-pm dmt-dm dmt-am dmt-dtl dmt-atl; do
  check "$SKILLS_DIR/$role/SKILL.md" 'pane label' "$role"
done

echo
echo "== 4) 队长层并行判据必须登记（无依赖 ≥2 ⇒ 并发派发） =="
check "$SKILLS_DIR/dmt-dtl/SKILL.md" '必须并行' 'devtl'
check "$SKILLS_DIR/dmt-atl/SKILL.md" '必须并行' 'anatl'
check "$CONTRACT" '≥2 ⇒ 必须并发派发' '团队契约'

echo
echo "== 4b) 经理层路径判据与饱和派发必须登记（devm ≤4 / anam ≤4） =="
check "$SKILLS_DIR/dmt-dm/SKILL.md" '≤4' 'devm'
check "$SKILLS_DIR/dmt-dm/SKILL.md" '>4' 'devm'
check "$SKILLS_DIR/dmt-am/SKILL.md" '≤4' 'anam'
check "$SKILLS_DIR/dmt-am/SKILL.md" '>4' 'anam'
check "$CONTRACT" '≤4 ⇒ 自己派生 `dev-e`' '团队契约'
check "$CONTRACT" '≤4 ⇒ 自己派生 `ana-e`' '团队契约'
check "$CONTRACT" '并发数 = 单元数' '团队契约'
check "$SKILLS_DIR/dmt-dm/SKILL.md" '开满' 'devm'
check "$SKILLS_DIR/dmt-am/SKILL.md" '开满' 'anam'
check "$SKILLS_DIR/dmt-dm/SKILL.md" 'teammate' 'devm'
check "$SKILLS_DIR/dmt-am/SKILL.md" 'teammate' 'anam'

echo
echo "== 4c) 门铃通道必须登记（五种 harness 优先 agent prompt，其余回退） =="
check "$CONTRACT" 'opencode2' '团队契约'
check "$CONTRACT" 'agent prompt' '团队契约'

echo
echo "== 4d) 装机与推送只归 director（每 ticket 一推；每小时巡检） =="
check "$CONTRACT" '只有 director 能执行' '团队契约'
check "$CONTRACT" '只许 .director. 执行' '团队契约'
check "$CONTRACT" '至少每完成一个 ticket 推送一次' '团队契约'
check "$CONTRACT" '至少每小时' '团队契约'
check "$SKILLS_DIR/dmt-director/SKILL.md" 'git push' 'director'
check "$SKILLS_DIR/dmt-dm/SKILL.md" '不得 push' 'devm'

echo
echo "== 4e) mattpocock 强制技能必须逐角色登记 =="
check "$CONTRACT" '强制使用' '团队契约'
check "$SKILLS_DIR/dmt-director/SKILL.md" '/grilling' 'director'
check "$SKILLS_DIR/dmt-director/SKILL.md" '/code-review' 'director'
check "$SKILLS_DIR/dmt-pm/SKILL.md" '/to-spec' 'pm'
check "$SKILLS_DIR/dmt-pm/SKILL.md" '/to-tickets' 'pm'
check "$SKILLS_DIR/dmt-dm/SKILL.md" '/code-review' 'devm'
check "$SKILLS_DIR/dmt-dtl/SKILL.md" '/tdd' 'devtl'
check "$SKILLS_DIR/dmt-atl/SKILL.md" '/research' 'anatl'
check "$SKILLS_DIR/dmt-atl/SKILL.md" '/rea' 'anatl'
check "$SKILLS_DIR/dmt-dtl/SKILL.md" '/implement' 'devtl'
check "$SKILLS_DIR/dmt-director/SKILL.md" '/grill-me' 'director'
check "$SKILLS_DIR/dmt-pm/SKILL.md" '/grill-me' 'pm'
check "$SKILLS_DIR/dmt-pm/SKILL.md" '/grill-with-docs' 'pm'
check "$SKILLS_DIR/dmt-am/SKILL.md" '/grill-me' 'anam'
check "$SKILLS_DIR/dmt-am/SKILL.md" '/grill-with-docs' 'anam'

echo
echo "== 4f) 文件占用（编辑前检查）必须登记 =="
check "$CONTRACT" '文件占用' '团队契约'
check "$CONTRACT" 'file-claim' '团队契约'
for role in dmt-director dmt-pm dmt-dm dmt-am dmt-dtl dmt-atl; do
  check "$SKILLS_DIR/$role/SKILL.md" 'file-claim' "$role"
done
if [ -f "$(dirname "$(readlink -f "$0")")/file-claim.sh" ]; then
  echo "OK   file-claim.sh 存在"
else
  echo "FAIL 缺 file-claim.sh"
  fail=1
fi

echo
echo "== 4g) 评审门禁归属（文档归 pm / 代码归 devm） =="
check "$CONTRACT" '文档门禁' '团队契约'
check "$CONTRACT" '代码门禁' '团队契约'
check "$SKILLS_DIR/dmt-pm/SKILL.md" '文档门禁' 'pm'
check "$SKILLS_DIR/dmt-dm/SKILL.md" '代码门禁' 'devm'
check "$SKILLS_DIR/dmt-director/SKILL.md" '不替代' 'director'

echo
echo "== 4h) cbc-herdr 通用技能必须逐角色登记 =="
for role in dmt-director dmt-pm dmt-dm dmt-am dmt-dtl dmt-atl; do
  check "$SKILLS_DIR/$role/SKILL.md" 'cbc-herdr' "$role"
done

echo
echo "== 4i) mattpocock 技能名必须与上游一致并带 raw 链接 =="
check "$CONTRACT" 'raw.githubusercontent.com' '团队契约'
for role in dmt-director dmt-pm dmt-dm dmt-am dmt-dtl dmt-atl; do
  check "$SKILLS_DIR/$role/SKILL.md" 'raw.githubusercontent.com' "$role"
done

echo
echo "== 4j) 确定性动作必须脚本化（脚本齐备且可执行） =="
for s in init-project.sh setup-team.sh spawn-leader.sh close-leader.sh send-msg.sh msg-take.sh msg-done.sh publish.sh file-claim.sh install-skills.sh check-dmt-doc-paths.sh; do
  f="$(dirname "$(readlink -f "$0")")/$s"
  if [ -x "$f" ]; then echo "OK   $s"; else echo "FAIL $s 缺失或不可执行"; fail=1; fi
done

echo
echo "== 4k) 收件箱三态必须登记（认领 .doing/、收口删除、.seq 高水位） =="
check "$CONTRACT" '.doing/' '团队契约'
check "$CONTRACT" '.seq' '团队契约'
check "$CONTRACT" 'msg-take.sh' '团队契约'
check "$CONTRACT" 'msg-done.sh' '团队契约'
for role in dmt-director dmt-pm dmt-dm dmt-am dmt-dtl dmt-atl; do
  check "$SKILLS_DIR/$role/SKILL.md" 'msg-take.sh' "$role"
done

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
