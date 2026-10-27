#!/usr/bin/env bash
# dmt 产物落盘路径机检（检查「使用本团队的项目」）
# 判据来源：本仓 team.md §1（组织 / pane / 通信 / 技能 / 占用）、§3 落盘登记、§5（Git / 并行 / 门禁）、§7 机检清单
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
echo "== 2) 四个技能必须指向各自唯一目录（PRD / SPEC / 工单 / 人类文档归 dmt-director；dmt-pde 为 pde{n} 子代理技能） =="
# 负向断言：命中禁用表述即 FAIL（grep -E）
check_absent() {
  local file="$1" pat="$2" who="${3:-}"
  [ -n "$who" ] || who="$(basename "$(dirname "$file")")"
  if [ ! -f "$file" ]; then
    echo "FAIL 未找到              $who（$file）"
    fail=1
    return
  fi
  if grep -qE -- "$pat" "$file"; then
    echo "FAIL $who 含禁用表述 /$pat/"
    fail=1
  else
    echo "OK   $who 不含禁用表述 /$pat/"
  fi
}
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
check "$SKILLS_DIR/dmt-director/SKILL.md" 'docs/pd/prd/'
check "$SKILLS_DIR/dmt-director/SKILL.md" 'docs/pd/spec/'
check "$SKILLS_DIR/dmt-director/SKILL.md" 'docs/dev/tickets/'
check "$SKILLS_DIR/dmt-director/SKILL.md" 'to-tickets'
check "$SKILLS_DIR/dmt-director/SKILL.md" 'docs/human/human-arch/'
check "$SKILLS_DIR/dmt-director/SKILL.md" 'docs/human/human-plan/'
check "$SKILLS_DIR/dmt-pde/SKILL.md" 'pde{n}' 'dmt-pde'
check "$SKILLS_DIR/dmt-director/SKILL.md" 'docs/team.md'
check "$SKILLS_DIR/dmt-dm/SKILL.md" 'docs/dev/tickets/'
check "$SKILLS_DIR/dmt-am/SKILL.md" 'docs/analyst/'

echo
echo "== 2b) 组织归属：director 管 devm/anam，产品线只用 pde{n} 子代理 =="
check "$SKILLS_DIR/dmt-director/SKILL.md" 'pde{n}' 'director'
check "$SKILLS_DIR/dmt-director/SKILL.md" 'setup-team.sh' 'director'
check "$SKILLS_DIR/dmt-pde/SKILL.md" '子代理' 'dmt-pde'
check "$CONTRACT" '| `dmt-pde` | `pde{n}` |' '团队契约'

echo
echo "== 3) helper 纯分身语义与回收动作必须登记（任务完成即关；只有创建者能关；只关 pane 不关 tab） =="
check "$CONTRACT" 'close-helper.sh' '团队契约'
check "$SKILLS_DIR/dmt-director/SKILL.md" 'close-helper.sh' 'director'
check "$SKILLS_DIR/dmt-dm/SKILL.md" 'close-helper.sh' 'devm'
check "$SKILLS_DIR/dmt-am/SKILL.md" 'close-helper.sh' 'anam'
check "$CONTRACT" '禁止先关后收' '团队契约'
check "$CONTRACT" '只许关 pane' '团队契约'   # 禁则本体：只许关 pane（'herdr tab close' 在 §8 历史里也会出现，不能拿它当判据）
check "$CONTRACT" '一次性下发' '团队契约'
check "$CONTRACT" '不接受任何输入框内容' '团队契约'
check "$CONTRACT" '单向汇报' '团队契约'
check "$CONTRACT" '没有自己的 inbox' '团队契约'
check "$(dirname "$(readlink -f "$0")")/spawn-helper.sh" '一次性下发' 'spawn-helper.sh'

echo
echo "== 3b) 身份识别必须按 pane label（不得按 tab 内位置） =="
check "$CONTRACT" 'pane label' '团队契约'
check "$CONTRACT" '不按 tab 内位置' '团队契约'
for role in dmt-director dmt-pde dmt-dm dmt-am; do
  check "$SKILLS_DIR/$role/SKILL.md" 'pane label' "$role"
done

echo
echo "== 4) 经理层并行判据必须登记（无依赖任务一律派子代理） =="
check "$SKILLS_DIR/dmt-dm/SKILL.md" '必须并行' 'devm'
check "$SKILLS_DIR/dmt-am/SKILL.md" '必须并行' 'anam'
check "$CONTRACT" '无依赖任务一律派子代理' '团队契约'
check "$CONTRACT" 'min(N, CAP)' '团队契约'

echo
echo "== 4b) 经理层路径与按需求并发必须登记（一律直接派工程师子代理） =="
check "$SKILLS_DIR/dmt-dm/SKILL.md" '直接派' 'devm'
check "$SKILLS_DIR/dmt-am/SKILL.md" '直接派' 'anam'
check "$CONTRACT" '经理一律直接派工程师子代理' '团队契约'
check "$CONTRACT" 'min(8, cap)' '团队契约'
check "$CONTRACT" '按需求开' '团队契约'
check "$SKILLS_DIR/dmt-dm/SKILL.md" '按需求开' 'devm'
check "$SKILLS_DIR/dmt-am/SKILL.md" '按需求开' 'anam'
check "$SKILLS_DIR/dmt-dm/SKILL.md" 'teammate' 'devm'
check "$SKILLS_DIR/dmt-am/SKILL.md" 'teammate' 'anam'

echo
echo "== 4c) 门铃通道必须登记（五种 harness 优先 agent prompt，其余回退） =="
check "$CONTRACT" 'opencode2' '团队契约'
check "$CONTRACT" 'agent prompt' '团队契约'

echo
echo "== 4d) 装机只归 director、merge 与 push 只归 devm（每 ticket 一推；每小时巡检） =="
check "$CONTRACT" 'merge 与 push 只归 devm' '团队契约'
check "$CONTRACT" '只许 `director` 执行' '团队契约'
check "$CONTRACT" '至少每完成一个 ticket 推送一次' '团队契约'
check "$CONTRACT" '至少每小时' '团队契约'
check "$SKILLS_DIR/dmt-dm/SKILL.md" 'push 与 merge 归 devm' 'devm'
check "$SKILLS_DIR/dmt-director/SKILL.md" '不代推' 'director'
check_absent "$SKILLS_DIR/dmt-director/SKILL.md" 'git push.{0,3}只由 director' 'director'

echo
echo "== 4e) mattpocock 强制技能必须逐角色登记 =="
check "$CONTRACT" '强制使用' '团队契约'
check "$SKILLS_DIR/dmt-director/SKILL.md" '/grilling' 'director'
check "$SKILLS_DIR/dmt-director/SKILL.md" '/code-review' 'director'
check "$SKILLS_DIR/dmt-director/SKILL.md" '/to-spec' 'director'
check "$SKILLS_DIR/dmt-director/SKILL.md" '/to-tickets' 'director'
check "$SKILLS_DIR/dmt-dm/SKILL.md" '/code-review' 'devm'
check "$SKILLS_DIR/dmt-am/SKILL.md" '/research' 'anam'
check "$SKILLS_DIR/dmt-director/SKILL.md" '/grill-me' 'director'
check "$SKILLS_DIR/dmt-pde/SKILL.md" '/grilling' 'dmt-pde'
check "$SKILLS_DIR/dmt-pde/SKILL.md" '/research' 'dmt-pde'
check "$SKILLS_DIR/dmt-pde/SKILL.md" '/to-spec' 'dmt-pde'
check "$SKILLS_DIR/dmt-pde/SKILL.md" '/to-tickets' 'dmt-pde'
check "$SKILLS_DIR/dmt-am/SKILL.md" '/grill-me' 'anam'
check "$SKILLS_DIR/dmt-am/SKILL.md" '/grill-with-docs' 'anam'
# 工程师吸收的原队长执行技能（登记在契约角色表 dev-e / ana-e 行）
check "$CONTRACT" '/tdd' 'dev-e 行'
check "$CONTRACT" '/implement' 'dev-e 行'
check "$CONTRACT" '/diagnosing-bugs' 'dev-e 行'
check "$CONTRACT" '`/rea`' 'ana-e 行'
check "$CONTRACT" '/grilling' 'ana-e 行'
check "$CONTRACT" '/grill-me' 'ana-e 行'
check "$CONTRACT" '/grill-with-docs' 'ana-e 行'

echo
echo "== 4f) 文件占用（编辑前检查）必须登记 =="
check "$CONTRACT" '文件占用' '团队契约'
check "$CONTRACT" 'file-claim' '团队契约'
for role in dmt-director dmt-pde dmt-dm dmt-am; do
  check "$SKILLS_DIR/$role/SKILL.md" 'file-claim' "$role"
done
if [ -f "$(dirname "$(readlink -f "$0")")/file-claim.sh" ]; then
  echo "OK   file-claim.sh 存在"
else
  echo "FAIL 缺 file-claim.sh"
  fail=1
fi

echo
echo "== 4g) 评审门禁归属（文档门禁归 director / 代码门禁归 devm） =="
check "$CONTRACT" '文档门禁' '团队契约'
check "$CONTRACT" '代码门禁' '团队契约'
check "$SKILLS_DIR/dmt-director/SKILL.md" '文档门禁' 'director'
check "$SKILLS_DIR/dmt-dm/SKILL.md" '代码门禁' 'devm'
check "$SKILLS_DIR/dmt-director/SKILL.md" '不替代' 'director'

echo
echo "== 4h) cbc-herdr 通用技能必须逐角色登记 =="
for role in dmt-director dmt-dm dmt-am; do
  check "$SKILLS_DIR/$role/SKILL.md" 'cbc-herdr' "$role"
done

echo
echo "== 4i) mattpocock 技能名必须与上游一致并带 raw 链接 =="
check "$CONTRACT" 'raw.githubusercontent.com' '团队契约'
for role in dmt-director dmt-pde dmt-dm dmt-am; do
  check "$SKILLS_DIR/$role/SKILL.md" 'raw.githubusercontent.com' "$role"
done

echo
echo "== 4j) 确定性动作必须脚本化（脚本齐备且可执行） =="
for s in launch.sh init-project.sh setup-team.sh spawn-helper.sh close-helper.sh send-msg.sh msg-take.sh msg-done.sh dispatch-ledger.sh self-work-guard.sh parallel-guard.sh probe-cap.sh fanout.sh install-hooks.sh publish.sh file-claim.sh install-skills.sh check-dmt-doc-paths.sh; do
  f="$(dirname "$(readlink -f "$0")")/$s"
  if [ -x "$f" ]; then echo "OK   $s"; else echo "FAIL $s 缺失或不可执行"; fail=1; fi
done

echo
echo "== 4k) 收件箱三态必须登记（认领 .doing/、收口删除、.seq 高水位） =="
check "$CONTRACT" '.doing/' '团队契约'
check "$CONTRACT" '.seq' '团队契约'
check "$CONTRACT" 'msg-take.sh' '团队契约'
check "$CONTRACT" 'msg-done.sh' '团队契约'
for role in dmt-director dmt-dm dmt-am; do
  check "$SKILLS_DIR/$role/SKILL.md" 'msg-take.sh' "$role"
done

echo
echo "== 4l) 先派后干、并发账与完成即报必须登记 =="
check "$CONTRACT" '先派后干' '团队契约'
check "$CONTRACT" '并发账' '团队契约'
check "$CONTRACT" '派发合规' '团队契约'
for role in dmt-director dmt-dm dmt-am; do
  check "$SKILLS_DIR/$role/SKILL.md" '先派后干' "$role"
  check "$SKILLS_DIR/$role/SKILL.md" '并发账' "$role"
done
check "$CONTRACT" '完成即报' '团队契约'
for role in dmt-director dmt-dm dmt-am; do
  check "$SKILLS_DIR/$role/SKILL.md" '完成即报' "$role"
done

echo
echo "== 4m) 团队契约必须带版本号与日期，且与四个技能同号 =="
ver_skill="$(sed -n 's/^version: *//p' "$SKILLS_DIR/dmt-director/SKILL.md" 2>/dev/null | head -1)"
if [ -n "$ver_skill" ]; then echo "OK   director 技能版本      $ver_skill"; else echo "FAIL director 技能缺 version"; fail=1; fi
ver_doc="$(head -10 "$CONTRACT" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
if [ -n "$ver_doc" ]; then echo "OK   契约头部版本          $ver_doc"; else echo "FAIL 契约头部缺版本号（抽查时无法判断装载版本）"; fail=1; fi
if [ -n "$ver_skill" ] && [ "$ver_doc" = "$ver_skill" ]; then
  echo "OK   契约与技能同号        $ver_doc"
else
  echo "FAIL 契约与技能不同号      doc=${ver_doc:-none} skill=${ver_skill:-none}"; fail=1
fi
if head -10 "$CONTRACT" 2>/dev/null | grep -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}'; then
  echo "OK   契约头部带日期"
else
  echo "FAIL 契约头部缺日期"; fail=1
fi
for role in dmt-pde dmt-dm dmt-am; do
  v="$(sed -n 's/^version: *//p' "$SKILLS_DIR/$role/SKILL.md" 2>/dev/null | head -1)"
  if [ -n "$v" ] && [ "$v" = "$ver_skill" ]; then echo "OK   $role 版本同号"; else echo "FAIL $role 版本不同号（${v:-none}）"; fail=1; fi
done

# 从项目根执行时 scripts/ 不存在（脚本装在 dmt-director/scripts/）；契约里只允许带前缀的写法
# 只查正文（§0–§7）；§8 变更记录里的历史写法不算
if sed -n '1,/^## 8\./p' "$CONTRACT" 2>/dev/null | grep -q '`scripts/'; then
  echo "FAIL 契约里有不带 dmt-director/ 前缀的脚本路径（从项目根执行会 rc=127）"; fail=1
else
  echo "OK   契约脚本路径均带 dmt-director/ 前缀"
fi

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
echo "== 6) 负样本：坏路径不得被登记为产物目录（负样本不进登记表） =="
# 只认契约里的表格登记行（^| 开头）—— §8 变更记录里的历史留痕不算登记
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
