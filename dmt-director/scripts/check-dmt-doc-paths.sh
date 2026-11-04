#!/usr/bin/env bash
# dmt 产物落盘路径机检（检查「使用本团队的项目」）
# 判据来源：本仓 team.md §1（组织 / pane / 通信 / 技能 / 占用）、§3 落盘登记、§5（Git / 并行 / 门禁）、§7 机检清单
# 用法：bash dmt-director/scripts/check-dmt-doc-paths.sh [项目根目录]    默认当前目录
#     环境变量 DMT_SKILLS_DIR 可覆盖技能安装位置（默认 <项目根>/.agents/skills）
set -u

ROOT="$(cd "${1:-$PWD}" && pwd)" || exit 2
SKILLS_DIR="${DMT_SKILLS_DIR:-$ROOT/.agents/skills}"
# 契约定位：项目内 docs/team.md（安装副本）优先；只有脚本本身就在 $ROOT 的技能仓里时才回退到仓内正本。
# 回退不能无条件：否则目标项目缺契约时会被技能仓的 team.md 顶替，机检报假绿。
CONTRACT="$ROOT/docs/team.md"
if [ ! -f "$CONTRACT" ] && [ "$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)" = "$ROOT" ]; then
  CONTRACT="$ROOT/dmt-director/team.md"
fi
# OPS 必须跟着**契约实际所在目录**走：docs/team.md 是软链（→ dmt-director/team.md），
# 而仓内维护时契约回退到 dmt-director/team.md。两种情形下 `$ROOT/docs/OPS.md` 都可能不存在
# （回退时 docs/OPS.md 根本没有），故用 readlink -f 解析后的真实目录定位同目录的 OPS.md。
# 2026-11-03 修复：此前写死 `${CONTRACT%/*}/OPS.md`，仓内跑机检时整段 ③/⑭ 断言全部「未找到」。
if [ -f "$CONTRACT" ]; then
  OPS="$(dirname "$(readlink -f "$CONTRACT")")/OPS.md"
else
  OPS="${CONTRACT%/*}/OPS.md"   # 契约缺失：保留原推导，让后续断言按「未找到」如实报红
fi

# 六个产物目录（docs 下）+ 收件箱根（项目根下，不在 docs/ 内）
DOC_DIRS="docs/pd/prd docs/pd/spec docs/dev/tickets docs/analyst docs/human/human-arch docs/human/human-plan"

fail=0
echo "项目根：  $ROOT"
echo "技能目录：$SKILLS_DIR"
echo "契约文件：$CONTRACT"
for r in dmt-director dmt-dm dmt-am dmt-pde dmt-de dmt-ae dmt-reviewer; do
  if [ -L "$SKILLS_DIR/$r" ]; then echo "WARN 技能为软链（校验的是技能仓本体）：$SKILLS_DIR/$r"; break; fi
done
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
echo "== 2) 七个技能必须指向各自唯一目录（PRD / SPEC / 工单 / 人类文档归 dmt-director；dmt-pde / dmt-de / dmt-ae / dmt-reviewer 为子代理角色技能） =="
# 负向断言：命中禁用表述即 FAIL（grep -E）
# 只查正文：§7 机检清单与 §8 变更记录会原样复述断言字面，整文件 grep 会被自己「自证」
_body() { sed -n '1,/^## 7\./p' "$1"; }
check_absent() {
  local file="$1" pat="$2" who="${3:-}"
  [ -n "$who" ] || who="$(basename "$(dirname "$file")")"
  if [ ! -f "$file" ]; then
    echo "FAIL 未找到              $who（$file）"
    fail=1
    return
  fi
  if _body "$file" | grep -qE -- "$pat"; then
    echo "FAIL $who 含禁用表述 /$pat/"
    fail=1
  else
    echo "OK   $who 不含禁用表述 /$pat/"
  fi
}
check_row() { # check_row <file> <行首 id> <want> <who>：按表格行锚定，防止 §7 / §8 的复述顶替
  local file="$1" row="$2" want="$3" who="${4:-$2}"
  if [ ! -f "$file" ]; then echo "FAIL 未找到              $who（$file）"; fail=1; return; fi
  if _body "$file" | grep -F -- "| \`$row\` |" | grep -q -- "$want"; then
    echo "OK   $who 行含 $want"
  else
    echo "FAIL $who 行缺 $want（按行锚定未命中）"
    fail=1
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
  if _body "$file" | grep -q -- "$want"; then
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
# 互斥：别人的产物目录不得出现在本角色技能里（只查正文，软链安装时同样生效）
# 只查「不得落笔」的目录：dmt-am 不得把 PRD / 工单当自己的产物（只读引用其它目录不算越界）
check_absent "$SKILLS_DIR/dmt-am/SKILL.md" 'docs/pd/prd/|docs/dev/tickets/' 'dmt-am 越界'
# 三个新增子代理角色技能必须存在且自述为子代理（2026-11-04 第六十七次）
for r in dmt-de dmt-ae dmt-reviewer; do
  check "$SKILLS_DIR/$r/SKILL.md" '子代理' "$r"
done

echo
echo "== 2b) 组织归属：director 管 devm/anam，产品线只用 pde{n} 子代理 =="
check "$SKILLS_DIR/dmt-director/SKILL.md" 'pde{n}' 'director'
check "$SKILLS_DIR/dmt-director/SKILL.md" 'setup-team.sh' 'director'
check "$SKILLS_DIR/dmt-pde/SKILL.md" '子代理' 'dmt-pde'
check "$CONTRACT" '| `dmt-pde` | `pde{n}` |' '团队契约'

echo
echo "== 3) helper 纯分身语义与回收动作必须登记（任务完成即关；只有创建者能关；只关 pane 不关 tab） =="
check "$OPS" 'close-helper.sh' '团队契约'
check "$SKILLS_DIR/dmt-director/SKILL.md" 'close-helper.sh' 'director'
check "$SKILLS_DIR/dmt-dm/SKILL.md" 'close-helper.sh' 'devm'
check "$SKILLS_DIR/dmt-am/SKILL.md" 'close-helper.sh' 'anam'
check "$OPS" '禁止先关后收' '团队契约'
check "$OPS" '只许关 pane' '团队契约'   # 禁则本体：只许关 pane（'herdr tab close' 在 §8 历史里也会出现，不能拿它当判据）
check "$OPS" '一次性下发' '团队契约'
check "$OPS" '不接受任何输入框内容' '团队契约'
check "$OPS" '单向汇报' '团队契约'
check "$OPS" '没有自己的 inbox' '团队契约'
check "$(dirname "$(readlink -f "$0")")/spawn-helper.sh" '一次性下发' 'spawn-helper.sh'

echo
echo "== 3b) 身份识别必须按 pane label（不得按 tab 内位置） =="
check "$OPS" 'pane label' '团队契约'
check "$OPS" '不按 tab 内位置' '团队契约'
for role in dmt-director dmt-dm dmt-am dmt-pde dmt-de dmt-ae dmt-reviewer; do
  check "$SKILLS_DIR/$role/SKILL.md" 'pane label' "$role"
done

echo
echo "== 4) 并行判据必须登记（依赖分析在前；并行按需、不强制派满，2026-11-02 用户裁定） =="
check "$SKILLS_DIR/dmt-dm/SKILL.md" '依赖分析' 'devm'
check "$SKILLS_DIR/dmt-am/SKILL.md" '依赖分析' 'anam'
check "$CONTRACT" '依赖分析' '团队契约'
check "$CONTRACT" '不强制派满' '团队契约'
check "$CONTRACT" '不设并发上限' '团队契约'

echo
echo "== 4b) 经理层路径必须登记（一律直接派工程师子代理，按需求开） =="
check "$SKILLS_DIR/dmt-dm/SKILL.md" '直接派' 'devm'
check "$SKILLS_DIR/dmt-am/SKILL.md" '直接派' 'anam'
check "$CONTRACT" '经理一律直接派工程师子代理' '团队契约'
check "$CONTRACT" '按需求开' '团队契约'
check "$SKILLS_DIR/dmt-dm/SKILL.md" '按需求开' 'devm'
check "$SKILLS_DIR/dmt-am/SKILL.md" '按需求开' 'anam'
check "$SKILLS_DIR/dmt-dm/SKILL.md" 'teammate 方式' 'devm'
check "$SKILLS_DIR/dmt-am/SKILL.md" 'teammate 方式' 'anam'

echo
echo "== 4c) 门铃通道必须登记（五个 harness 优先 agent prompt，其余回退） =="
check "$OPS" 'claude / codebuddy / codex / opencode / pi' '门铃表五 harness'
check_absent "$OPS" 'opencode2' '门铃表旧 harness 名（2026-11-04 已更正）'
check "$OPS" 'agent prompt' '团队契约'

echo
echo "== 4d) 硬件设备写操作与 merge/push 均只归 devm（每 ticket 一推；每小时巡检） =="
check "$CONTRACT" 'merge 与 push 只归 devm' '团队契约'
check "$CONTRACT" '只许 `devm` 执行' '团队契约'
check "$CONTRACT" '至少每完成一个 ticket 推送一次' '团队契约'
check "$CONTRACT" '至少每小时' '团队契约'
check "$SKILLS_DIR/dmt-dm/SKILL.md" 'push 与 merge 归 devm' 'devm'
# 2026-11-04 第六十八次：设备操作（装机）从 director 移交 devm
check "$SKILLS_DIR/dmt-dm/SKILL.md" '硬件设备写操作' 'devm'
check "$SKILLS_DIR/dmt-director/SKILL.md" '不代推' 'director'
check_absent "$SKILLS_DIR/dmt-director/SKILL.md" 'git push[^。]{0,20}只由[ ]*director' 'director'
check_absent "$CONTRACT" '只许 `director` 执行|装机只归 director|装机归 director|装机仍归 director' '契约装机归属（应归 devm）'
# 2026-11-04 第六十九次：设备操作抽象为通用「硬件设备写操作」（不绑定项目特定命令）
check_absent "$CONTRACT" 'adb install|bcr_t36_calib|bcr_detect_probe|dump_prefs' '契约不得绑定具体项目设备命令'

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
# 工程师执行技能（登记在契约角色表 dev-e / ana-e 行）
check_row "$CONTRACT" 'dev-e' '/tdd' 'dev-e 行'
check_row "$CONTRACT" 'dev-e' '/implement' 'dev-e 行'
check_row "$CONTRACT" 'dev-e' '/code-review' 'dev-e 行'
check_row "$CONTRACT" 'dev-e' '/diagnosing-bugs' 'dev-e 行'
check_row "$CONTRACT" 'ana-e' '`/rea`' 'ana-e 行'
check_row "$CONTRACT" 'ana-e' '/research' 'ana-e 行'
check_row "$CONTRACT" 'ana-e' '/grilling' 'ana-e 行'
check_row "$CONTRACT" 'ana-e' '/grill-me' 'ana-e 行'
check_row "$CONTRACT" 'ana-e' '/grill-with-docs' 'ana-e 行'
# reviewer{n}：验收必用 /code-review（上游：mattpocock/skills engineering/code-review）
check_row "$CONTRACT" 'reviewer{n}' '/code-review' 'reviewer 行'
check "$SKILLS_DIR/dmt-director/SKILL.md" '/code-review' 'director'
# 四个子代理角色技能各自的强制技能（2026-11-04 第六十七次：技能名与运行 id 一一对应）
for x in '/tdd' '/implement' '/code-review' '/diagnosing-bugs'; do
  check "$SKILLS_DIR/dmt-de/SKILL.md" "$x" 'dmt-de'
done
for x in '/research' '/rea' '/grilling' '/grill-me' '/grill-with-docs'; do
  check "$SKILLS_DIR/dmt-ae/SKILL.md" "$x" 'dmt-ae'
done
check "$SKILLS_DIR/dmt-reviewer/SKILL.md" '/code-review' 'dmt-reviewer'
check "$SKILLS_DIR/dmt-reviewer/SKILL.md" 'reviewer{n}' 'dmt-reviewer'
check_row "$CONTRACT" 'dmt-de' '`dmt-de` | `dev-e` |' '三层命名表 dmt-de'
check_row "$CONTRACT" 'dmt-ae' '`dmt-ae` | `ana-e` |' '三层命名表 dmt-ae'
check_row "$CONTRACT" 'dmt-reviewer' '`dmt-reviewer` | `reviewer{n}` |' '三层命名表 dmt-reviewer'

echo
echo "== 4f) 文件占用（编辑前检查）必须登记 =="
check "$OPS" '文件占用' '团队契约'
check "$OPS" 'file-claim' '团队契约'
for role in dmt-director dmt-dm dmt-am dmt-pde dmt-de dmt-ae dmt-reviewer; do
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
# 2026-11-04 第六十九次：reviewer{n} 归 devm（代码验收由 devm 派，director 只抽查/复验）
check "$CONTRACT" '`reviewer{n}` 直属 `devm`' '团队契约（reviewer 归 devm）'
check "$SKILLS_DIR/dmt-dm/SKILL.md" 'reviewer{n}' 'devm（派 reviewer）'
check "$SKILLS_DIR/dmt-reviewer/SKILL.md" 'devm' 'dmt-reviewer（上级 devm）'
check_absent "$SKILLS_DIR/dmt-director/SKILL.md" '按验收票数派|按票数派 `reviewer1' 'director 不得再派 reviewer（改为抽查/复验）'
# 2026-11-04 第七十次：独立性四条硬约束（结论平行可见 + 抽查下限/高风险复验/留痕）
check "$CONTRACT" '结论平行可见' '团队契约'
check "$CONTRACT" '每批至少抽 1 票' '团队契约'
check "$CONTRACT" '100% 复验' '团队契约'
check "$CONTRACT" '必须留痕' '团队契约'
check "$SKILLS_DIR/dmt-director/SKILL.md" '每批至少抽 1 票' 'director'
check "$SKILLS_DIR/dmt-director/SKILL.md" '100% 复验' 'director'
check "$SKILLS_DIR/dmt-dm/SKILL.md" '抄送 director' 'devm'
check "$SKILLS_DIR/dmt-reviewer/SKILL.md" '结论平行可见' 'dmt-reviewer'

echo
echo "== 4h) cbc-herdr 通用技能必须逐角色登记 =="
for role in dmt-director dmt-dm dmt-am; do
  check "$SKILLS_DIR/$role/SKILL.md" 'cbc-herdr' "$role"
done

echo
echo "== 4i) mattpocock 技能名必须与上游一致并带 raw 链接 =="
check "$CONTRACT" 'raw.githubusercontent.com' '团队契约'
for role in dmt-director dmt-dm dmt-am dmt-pde dmt-de dmt-ae dmt-reviewer; do
  check "$SKILLS_DIR/$role/SKILL.md" 'raw.githubusercontent.com' "$role"
done

echo
echo "== 4i-b) 技能链接文字必须与上游目录名逐字一致 =="
check_links() {
  local file="$1" who="${2:-$(basename "$(dirname "$file")")}" n=0 bad=0 label dir
  [ -f "$file" ] || return 0
  while IFS= read -r m; do
    label="$(printf '%s' "$m" | sed -n 's#^\[`\{0,1\}/\([a-z-]*\)`\{0,1\}\].*#\1#p')"
    dir="$(printf '%s' "$m" | sed -n 's#.*/skills/[a-z-]*/\([a-z-]*\)/SKILL\.md).*#\1#p')"
    [ -n "$label" ] && [ -n "$dir" ] || continue
    n=$((n + 1))
    if [ "$label" != "$dir" ]; then
      echo "FAIL $who 链接文字 /$label 与上游目录 $dir 不一致"
      fail=1; bad=1
    fi
  done < <(grep -oE '\[`?/[a-z-]+`?\]\(https://raw\.githubusercontent\.com/mattpocock/skills/main/skills/[a-z-]+/[a-z-]+/SKILL\.md\)' "$file")
  if [ "$n" -eq 0 ]; then echo "FAIL $who 未校验到任何技能链接（判据空转）"; fail=1; return; fi
  [ "$bad" = 1 ] || echo "OK   $who 的 $n 条技能链接文字与上游目录名一致"
}
check_links "$CONTRACT" '团队契约'
for role in dmt-director dmt-dm dmt-am dmt-pde dmt-de dmt-ae dmt-reviewer; do check_links "$SKILLS_DIR/$role/SKILL.md" "$role"; done

echo
echo "== 4j) 确定性动作必须脚本化（脚本齐备且可执行） =="
for s in lib-dmt.sh launch.sh init-project.sh setup-team.sh spawn-helper.sh close-helper.sh send-msg.sh msg-take.sh msg-done.sh publish.sh file-claim.sh install-skills.sh check-dmt-doc-paths.sh auto-review-model.sh; do
  f="$(dirname "$(readlink -f "$0")")/$s"
  if [ -x "$f" ]; then echo "OK   $s"; else echo "FAIL $s 缺失或不可执行"; fail=1; fi
done

echo
echo "== 4k) 收件箱三态必须登记（认领 .doing/、收口删除、.seq 高水位） =="
check "$OPS" '.doing/' '团队契约'
check "$OPS" '.seq' '团队契约'
check "$OPS" 'msg-take.sh' '团队契约'
check "$OPS" 'msg-done.sh' '团队契约'
for role in dmt-director dmt-dm dmt-am; do
  check "$SKILLS_DIR/$role/SKILL.md" 'msg-take.sh' "$role"
done

echo
echo "== 4l) 完成即报与按需派发必须登记 =="
check "$OPS" '完成即报' '团队契约'
for role in dmt-director dmt-dm dmt-am; do
  check "$SKILLS_DIR/$role/SKILL.md" '完成即报' "$role"
done
for role in dmt-director dmt-dm dmt-am; do
  check "$SKILLS_DIR/$role/SKILL.md" '依赖分析' "$role"
done

echo
echo "== 4l-b) max-subagents / 饱和派发机制不得回潮（2026-11-02 用户裁定：不强制派满、不设并发上限） =="
# 负向断言：契约正文与七份技能正文里不得再出现 CAP 探测、派发账本、先派后干、并发账、每波 min(N, CAP) 等饱和派发表述。
# （§7 / §8 会复述这些字面，_body 只查正文，历史记录不判红）
for f in "$CONTRACT" "$SKILLS_DIR/dmt-director/SKILL.md" "$SKILLS_DIR/dmt-pde/SKILL.md" "$SKILLS_DIR/dmt-dm/SKILL.md" "$SKILLS_DIR/dmt-am/SKILL.md" "$SKILLS_DIR/dmt-de/SKILL.md" "$SKILLS_DIR/dmt-ae/SKILL.md" "$SKILLS_DIR/dmt-reviewer/SKILL.md"; do
  check_absent "$f" 'min\(8, cap\)|min\(N, CAP\)|并发账|先派后干|饱和派发|probe-cap|dispatch-ledger|fanout\.sh|install-hooks|MAX_SUBAGENTS' "$(basename "$(dirname "$f")") 饱和机制回潮"
done

echo
echo "== 4m) 团队契约必须带版本号与日期，且与七个技能同号 =="
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
for role in dmt-dm dmt-am dmt-pde dmt-de dmt-ae dmt-reviewer; do
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
echo
echo "== 4n) 一子代理一单元队列必须登记（2026-10-27 事故后立规） =="
# pde 是子代理技能、不派发，不在此列（用户裁定 2026-10-27）
for f in "$CONTRACT" "$SKILLS_DIR/dmt-director/SKILL.md" "$SKILLS_DIR/dmt-dm/SKILL.md" "$SKILLS_DIR/dmt-am/SKILL.md"; do
  if grep -q '一子代理一单元队列' "$f" 2>/dev/null; then
    echo "OK   一子代理一单元队列        $(basename "$(dirname "$f")")/$(basename "$f")"
  else
    echo "FAIL 缺一子代理一单元队列      $f"; fail=1
  fi
done
for k in '文件面矩阵' '验收面'; do
  if sed -n '1,/^## 8\./p' "$CONTRACT" | grep -q -- "$k"; then
    echo "OK   队列纪律要素              $k"
  else
    echo "FAIL 队列纪律要素缺失          $k"; fail=1
  fi
done
if [ -f "$(dirname "$CONTRACT")/../logs/2026-10-27-serial-queue-incident.md" ]; then
  echo "OK   事故复盘档在位"
else
  echo "INFO 事故复盘档仅在技能仓内（目标项目不安装，不判红）"
fi

echo
echo "== 4o) 派发 prompt 文件写入纪律必须登记（改 bash 用单引号 heredoc／禁 JS 模板字符串／Edit 锚点唯一） =="
# 三份 pane 派发技能 + 四份子代理技能（同样收 prompt、同样用 Edit）均须带该纪律
for f in "$CONTRACT" "$SKILLS_DIR/dmt-director/SKILL.md" "$SKILLS_DIR/dmt-dm/SKILL.md" "$SKILLS_DIR/dmt-am/SKILL.md" "$SKILLS_DIR/dmt-pde/SKILL.md" "$SKILLS_DIR/dmt-de/SKILL.md" "$SKILLS_DIR/dmt-ae/SKILL.md" "$SKILLS_DIR/dmt-reviewer/SKILL.md"; do
  if grep -q '文件写入纪律' "$f" 2>/dev/null; then
    echo "OK   文件写入纪律              $(basename "$(dirname "$f")")/$(basename "$f")"
  else
    echo "FAIL 缺文件写入纪律            $f"; fail=1
  fi
done
check "$CONTRACT" '单引号 heredoc' '团队契约'
check "$CONTRACT" '模板字符串' '团队契约'
check "$CONTRACT" 'oldString' '团队契约'

echo
# 4p) pi harness 的 agent 名承载：角色语义名 ≠ pi-subagents 的 agent 注册名（agent 字段填 delegate）
echo "== 4p) pi harness agent 名承载必须登记（角色语义名 ≠ pi agent 注册名，agent 字段填 delegate） =="
check "$CONTRACT" 'agent 名承载' '团队契约'
check "$CONTRACT" 'delegate' '团队契约'
check "$SKILLS_DIR/dmt-director/SKILL.md" 'delegate' 'director'
check "$SKILLS_DIR/dmt-dm/SKILL.md" 'delegate' 'devm'
check "$SKILLS_DIR/dmt-am/SKILL.md" 'delegate' 'anam'
check "$SKILLS_DIR/dmt-pde/SKILL.md" 'delegate' 'pde'
check "$SKILLS_DIR/dmt-de/SKILL.md" 'delegate' 'dmt-de'
check "$SKILLS_DIR/dmt-ae/SKILL.md" 'delegate' 'dmt-ae'
check "$SKILLS_DIR/dmt-reviewer/SKILL.md" 'delegate' 'dmt-reviewer'

echo
echo "== 4q) 五 harness 兼容必须登记（斜杠前缀分流 / .agents 落点 / 启动参数） =="
# 2026-11-03 第六十二次：多 harness 适配。判据只锚「契约有没有把这些差异写下来」，
# 不锚具体参数值 —— 参数会随 harness 版本变，但「差异必须被登记」这条不变。
check "$CONTRACT" 'harness 兼容' '团队契约'
check "$CONTRACT" '不是五个 harness 的交集' '团队契约（2026-11-04 实测更正：.agents 落点只覆盖 codex/opencode/pi）'
check "$CONTRACT" 'dmt_skill_cmd' '团队契约'
check "$CONTRACT" 'skill:dmt-' '团队契约（pi 斜杠前缀）'
for role in dmt-director dmt-dm dmt-am; do
  check "$SKILLS_DIR/$role/SKILL.md" 'skill:dmt-' "$role（pi 斜杠前缀）"
done
for h in codebuddy claude codex opencode pi; do
  check "$CONTRACT" "\`$h\`" "团队契约 harness=$h"
done
# 脚本侧：lib 必须真有分流实现，且两份启动脚本不得写死 /dmt-* 技能命令
lib="$(dirname "$(readlink -f "$0")")/lib-dmt.sh"
if grep -q 'dmt_skill_cmd' "$lib"; then echo "OK   lib-dmt.sh 含 dmt_skill_cmd"; else echo "FAIL lib-dmt.sh 缺 dmt_skill_cmd"; fail=1; fi
# 2026-11-04 第六十六次：技能落点必须覆盖 claude / codebuddy（它们不读 .agents/skills）
iss="$(dirname "$(readlink -f "$0")")/install-skills.sh"
if grep -q '\.claude/skills' "$iss" && grep -q '\.codebuddy/skills' "$iss"; then
  echo "OK   install-skills.sh 覆盖 .claude/skills 与 .codebuddy/skills 落点"
else
  echo "FAIL install-skills.sh 未覆盖非 .agents 落点（claude / codebuddy 装不上）"; fail=1
fi
for s in setup-team.sh spawn-helper.sh; do
  if grep -qF "'/dmt-" "$(dirname "$(readlink -f "$0")")/$s"; then
    echo "FAIL $s 写死技能命令（应经 dmt_skill_cmd 生成）"; fail=1
  else
    echo "OK   $s 未写死技能命令"
  fi
done

echo
echo "== 4r) 权限档位复验必须存在且判据正确（非自动档 ⇒ 每次工具调用撞审批） =="
# 2026-11-03 第六十三次：bcr-nh 三个 pane 全落在 default 档，33 次工具栏 ASK，
# 表象却是「脚本超时 / 命令失败」（另一 pane 标题直接是 file-claim.sh 审批超时）。
# 启动脚本此前只验 agent_status（=有 agent 在跑），从不验档位，故根因一直没被发现。
lib="$(dirname "$(readlink -f "$0")")/lib-dmt.sh"
for f in "$lib" "$(dirname "$(readlink -f "$0")")/setup-team.sh" "$(dirname "$(readlink -f "$0")")/spawn-helper.sh"; do
  if grep -q 'dmt_pane_auto_mode\|verify_auto_mode' "$f"; then
    echo "OK   $(basename "$f") 含档位复验"
  else
    echo "FAIL $(basename "$f") 缺档位复验（启动后不验自动档）"; fail=1
  fi
done
# 行为断言：用 $DMT_PANE_ARGV 逃生舱喂 argv，验判据本身（正例全认、反例不误认）
auto_case() { # auto_case <argv> <want: 0|1>
  local got=0
  ( export DMT_PANE_ARGV="$1"; . "$lib"; dmt_pane_auto_mode x ) 2>/dev/null || got=$?
  if [ "$got" = "$2" ]; then echo "OK   argv=[$1] → rc=$got"
  else echo "FAIL argv=[$1] 期望 rc=$2 实得 rc=$got"; fail=1; fi
}
auto_case 'codebuddy --permission-mode auto' 0
auto_case 'claude --permission-mode auto' 0
auto_case 'pi --approve' 0
auto_case 'opencode --auto' 0
auto_case 'codex -a never' 0
auto_case 'codex --ask-for-approval never' 0
auto_case 'codex --yolo' 0
auto_case 'codebuddy' 1
auto_case 'codebuddy --permission-mode default' 1
auto_case 'claude --permissions-mode auto' 1     # 拼错的参数不得被当成自动档
auto_case 'claude --autocompact auto' 1          # 子串误判回归：--autocompact 不是 --auto

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
