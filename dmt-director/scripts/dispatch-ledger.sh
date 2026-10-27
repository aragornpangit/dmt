#!/usr/bin/env bash
# =============================================================================
# dispatch-ledger.sh —— max-subagents 台账内核（ledger.py）的薄壳
# =============================================================================
# 【本文件现状】
#   本脚本已从「自实现台账读写/统计/锁」收敛为 **max-subagents/ledger.py 的薄壳**：
#   所有台账判据（pending/inflight 口径、重复单元拒绝、stale 锁接管、subagent 上下文
#   判定、过期判据、派发工具白名单）都委托给同一份实现：
#     /home/panxiaoyong/pxy/projects26h2/max-subagents/ledger.py（+ policy.py）
#   历史实现原样保留在同目录备份：scripts/dispatch-ledger.sh.orig-20261027（152 行）。
#
# 【7 条缺陷的修复位置】（细节见 max-subagents/docs/ledger-design.md §4、docs/ledger.md §5）
#   1. report 报数虚高（把 excused 算成未派）：pending 只数 planned。
#      → policy.counts_from_rows()；本壳 report 用 query --json 取数后按 dmt 格式拼装。
#   2. plan 不去重 → 幽灵单元：重复单元 rc=2 且不写账。
#      → ledger.py cmd_plan()；本壳 plan 传 --reset（dmt 的 plan 本就是重置语义）。
#   3. 锁无 stale 回收（残留锁 → 11s/rc=4，角色永久瘫痪）：锁内写 pid+ts，死 pid /
#      age>10s 立即接管，等待上限 3s，超时 fail-open rc=0。
#      → ledger.py LedgerLock；本壳【删除】原 mkdir 锁逻辑，不再自带锁。
#   4. 时间戳无日期 + 过期判据用文件 mtime：行内时间改 ISO 带日期；过期按行内时间。
#      → policy.now_iso() / ledger.py _effective_rows()；本壳给 check 传
#      MAX_SUBAGENTS_LEDGER_TTL_HOURS=24（旧账不阻断），绝不看文件 mtime。
#   5. inc 不区分 subagent 上下文：payload 带 agent_id 时不销父账。
#      → policy.is_subagent() / ledger.py cmd_inc()。
#   6. 派发工具名白名单与 gate 分叉：统一 policy.SPAWN_RE。
#      → policy.SPAWN_RE / ledger.py cmd_inc()。
#   7. pi adapter 不传 agent_id（max-subagents 侧新发现）：见适配器文档，与本壳无关。
#
# 【对外契约（dmt hook 与人在用，保持不变）】
#   子命令：plan / inc / excuse / done / append / check / report / status / ledger-path / inject / nudge
#     is-subagent：stdin payload 是否子代理上下文的布尔查询（rc=0 是 / rc=1 不是）。
#     判据单一来源为内核 policy.is_subagent()（self-work-guard.sh 经此查询，不再自带
#     内联 jq 副本）。注意 rc=1 是有效结果「不是子代理」，不走 kernel_pass 的
#     fail-open 映射；仅内核不可用时 fail-open rc=0（视为子代理放行）。
#     append：SendMessage 追加新单元过账（2026-10-27 事故 P3）——逐个 inc --unit，
#     账内 planned 就地认领、账外单元追加一行 dispatched；只增不改，不动既有行
#     （勿用 plan 重排：dmt 壳 plan 固定 --reset，会清掉已派/完成行、压低「派 M」）
#   调用：bash dispatch-ledger.sh <cmd> <role> [args...]；inc/check/nudge 从 stdin 读 payload
#   角色：dmt_role（"-"/空 → DMT_ROLE → herdr pane label）；只治理
#     director|devm|anam|director-helper|devm-helper|anam-helper，其它角色静默 exit 0；
#     DMT_DISPATCH_ALL=1 绕过白名单
#   账本：$(dmt_root)/locks/dispatch-<ROLE>.tsv（沿用原布局，不换到 state 目录）
#   excuse 理由码：dep|files|build|order|device|rea
#   check：有未派且在途 0 → rc=2；stop_hook_active=true → rc=0；>24h 旧账不阻断
#   report：并发账：单元 N（units）→ 派 M ＋ 未派 K（reason）[CAP=cap]（CAP 来自 probe-cap.sh）
#   nudge：hookSpecificOutput.additionalContext JSON
#   inject：dmt 原有文案
#
# 【fail-open】
#   内核不可用 / 意外退出码（非 0/2）：check 一律 rc=0（绝不卡住 agent）；
#   其它命令 stderr 报错后 rc=0。绝不允许脚本故障卡住 dmt 的 agent。
# =============================================================================
set -eu

DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/lib-dmt.sh"

# 台账内核：绝对路径常量（禁止相对路径 —— cwd 不受控，相对路径会 miss）
KERNEL="/home/panxiaoyong/pxy/projects26h2/max-subagents/ledger.py"

CMD="${1:?usage: dispatch-ledger.sh <plan|inc|excuse|done|append|check|report|status|ledger-path|inject|nudge> <role> ...}"
ROLE="${2:?missing role}"
shift 2 || true

# 角色解析：参数 "-" 或空 ⇒ $DMT_ROLE ⇒ herdr pane label；只治理 director/devm/anam 与 helper
ROLE="$(dmt_role "$ROLE")"
if [ "${DMT_DISPATCH_ALL:-0}" != 1 ]; then
  case "$ROLE" in
    director|devm|anam|director-helper|devm-helper|anam-helper) ;;
    *) exit 0 ;;   # 非治理角色对所有命令静默 exit 0（契约 10）
  esac
fi
# 空角色兜底：不能进文件路径 / 锁名（引用未定义变量必须有默认值，契约 2）
[ -n "$ROLE" ] || ROLE="default"

# 账本固定落在「主工作树」根：worktree 里跑也写回 <main>/locks/（契约 4）
ROOT="$(dmt_root)"
LEDGER="$ROOT/locks/dispatch-$ROLE.tsv"
mkdir -p "$ROOT/locks" 2>/dev/null || true

# hook payload：非 tty 时读 stdin（原样转发给内核；超时 1s 防止挂死）
payload=""
if [ ! -t 0 ]; then payload="$(timeout 1 cat 2>/dev/null || true)"; fi

# 内核是否可用（脚本缺失 / 无 python3 都算不可用 → fail-open）
kernel_available() {
  [ -f "$KERNEL" ] && command -v python3 >/dev/null 2>&1
}

# 透传执行：stdin=payload；退出码 0/2 原样返回（契约语义），其它（含内核缺失）报错后 rc=0。
# 一次调用只调一次内核 ⇒ 不会形成读改写竞态（锁由 ledger.py 内部管理）。
kernel_pass() {
  local rc=0
  if ! kernel_available; then
    echo "[dispatch] 台账内核不可用（$KERNEL），fail-open：rc=0" >&2
    return 0
  fi
  printf '%s' "$payload" | python3 "$KERNEL" "$@" || rc=$?
  case "$rc" in
    0|2) return "$rc" ;;
    *) echo "[dispatch] 台账内核 ${1:-} 意外退出码 $rc，fail-open 转为 rc=0" >&2; return 0 ;;
  esac
}

case "$CMD" in
  plan)
    # 契约 ③：重复单元被拒 rc=2 且不写账（ledger.py 先查重后落盘）
    [ "$#" -ge 1 ] || { echo "plan needs at least one unit" >&2; exit 2; }
    rc=0
    kernel_pass plan --ledger-path "$LEDGER" --session "$ROLE" --reset -- "$@" || rc=$?
    exit "$rc"
    ;;
  inc)
    # hook 自动记账形如 `inc - auto`：auto/-/空 都不带 --unit，由内核认领第一个 planned
    args=(inc --ledger-path "$LEDGER" --session "$ROLE")
    case "${1:-}" in
      ""|auto|-) ;;
      *) args+=(--unit "$1") ;;
    esac
    rc=0
    kernel_pass "${args[@]}" || rc=$?
    exit "$rc"
    ;;
  excuse)
    [ "$#" -ge 1 ] || { echo "excuse needs a unit" >&2; exit 2; }
    [ "$#" -ge 2 ] || { echo "excuse needs a code" >&2; exit 2; }
    rc=0
    kernel_pass excuse --ledger-path "$LEDGER" --session "$ROLE" --unit "$1" --code "$2" || rc=$?
    exit "$rc"
    ;;
  done)
    [ "$#" -ge 1 ] || { echo "done needs a unit" >&2; exit 2; }
    rc=0
    kernel_pass done --ledger-path "$LEDGER" --session "$ROLE" --unit "$1" || rc=$?
    exit "$rc"
    ;;
  append)
    # 一子代理一单元队列（2026-10-27 事故 P3）：SendMessage 追加的新单元必须过账，
    # 使「派 M」等于实际在途数。逐个 inc --unit：账内 planned 就地认领；账外单元
    # 追加一行 dispatched（ledger.py 原生语义），不动既有行 —— 所以不走 plan 重排。
    [ "$#" -ge 1 ] || { echo "append needs at least one unit" >&2; exit 2; }
    rc=0
    for u in "$@"; do
      kernel_pass inc --ledger-path "$LEDGER" --session "$ROLE" --unit "$u" || rc=$?
    done
    exit "$rc"
    ;;
  check)
    # 契约 6：>24h 旧账不阻断 —— 按行内 ISO 时间判过期（内核支持），绝不看文件 mtime
    export MAX_SUBAGENTS_LEDGER_TTL_HOURS="${MAX_SUBAGENTS_LEDGER_TTL_HOURS:-24}"
    rc=0
    kernel_pass check --ledger-path "$LEDGER" --session "$ROLE" || rc=$?
    exit "$rc"
    ;;
  report)
    # 契约 7：取内核统计（含 rows），按 dmt 原格式拼装 + CAP
    cap="$(bash "$DIR/probe-cap.sh" 2>/dev/null || echo 8)"
    json=""
    if kernel_available; then
      json="$(python3 "$KERNEL" query --ledger-path "$LEDGER" --session "$ROLE" --json 2>/dev/null || true)"
    fi
    total=0; pending=0; inflight=0; done_n=0; units=""; codes=""
    if [ -n "$json" ] && command -v jq >/dev/null 2>&1; then
      total="$(printf '%s' "$json" | jq -r '.total // 0' 2>/dev/null || echo 0)"
      pending="$(printf '%s' "$json" | jq -r '.pending // 0' 2>/dev/null || echo 0)"
      inflight="$(printf '%s' "$json" | jq -r '.inflight // 0' 2>/dev/null || echo 0)"
      done_n="$(printf '%s' "$json" | jq -r '.done // 0' 2>/dev/null || echo 0)"
      units="$(printf '%s' "$json" | jq -r '[.rows[]?.unit] | join(" ")' 2>/dev/null || true)"
      codes="$(printf '%s' "$json" | jq -r '[.rows[]? | select(.status=="excused") | "\(.unit):\(.code) "] | join("")' 2>/dev/null || true)"
    fi
    # 数值兜底：jq 异常时不能让算术失败（fail-open）
    case "$total" in ''|*[!0-9]*) total=0 ;; esac
    case "$pending" in ''|*[!0-9]*) pending=0 ;; esac
    case "$inflight" in ''|*[!0-9]*) inflight=0 ;; esac
    case "$done_n" in ''|*[!0-9]*) done_n=0 ;; esac
    case "$cap" in ''|*[!0-9]*) cap=8 ;; esac
    m=$(( inflight + done_n ))     # 「派」= 在途 + 完成（与原格式一致）
    k="$pending"                   # 「未派」= 仅 planned（缺陷 1 修复：不再把 excused 算进来）
    extra=""
    if [ "$k" -gt 0 ] && [ "$inflight" -ge "$cap" ]; then extra="cap:在途达上限、分批排队 "; fi
    reason="${codes}${extra}"
    if [ -z "$reason" ] && [ "$k" -gt 0 ]; then reason="缺理由码（不合规：须派发或 excuse）"; fi
    echo "并发账：单元 $total（$units）→ 派 $m ＋ 未派 $k（${reason:-无}）[CAP=$cap]"
    exit 0
    ;;
  status)
    rc=0
    kernel_pass status --ledger-path "$LEDGER" --session "$ROLE" || rc=$?
    exit "$rc"
    ;;
  ledger-path)
    # parallel-guard.sh / self-work-guard.sh 用；输出解析后的绝对路径（契约 4）
    out=""
    if kernel_available; then
      out="$(python3 "$KERNEL" ledger-path --ledger-path "$LEDGER" 2>/dev/null || true)"
    fi
    printf '%s\n' "${out:-$LEDGER}"
    exit 0
    ;;
  inject)
    # 契约 9：保留 dmt 原有文案（含 CAP 与 team.md 口径）
    cap="$(bash "$DIR/probe-cap.sh" 2>/dev/null || echo 8)"
    echo "并行纪律（dmt）：无依赖单元并发派 min(N, CAP) 个子代理（按需求开，上限 min(8, cap)，N 超上限分批；当前 CAP=$cap，probe-cap.sh 探测；唤醒后先补派再收口）；先派后干——开工先列单元清单并 dispatch-ledger.sh plan 落账再动手；子代理一律 run_in_background: true；收口立即向上级回报（完成即报，不傻等）；SendMessage 追加新单元必须先 `append` 过账（派 M = 实际在途），不得把新单元堆进在途子代理的队列。"
    exit 0
    ;;
  nudge)
    # 契约 8：内核输出即 hookSpecificOutput.additionalContext JSON
    rc=0
    kernel_pass nudge --ledger-path "$LEDGER" --session "$ROLE" || rc=$?
    exit "$rc"
    ;;
  is-subagent)
    # 布尔查询：rc=0 是子代理 / rc=1 不是。不能直接套 kernel_pass —— 它把非 0/2
    # 一律 fail-open 成 0，会把「不是子代理」（rc=1，有效结果）误报成「是」，导致
    # self-work-guard.sh 对主线程整体放行。这里原样透传 0/1，只在内核不可用（脚本
    # 缺失 / 无 python3）时 fail-open rc=0：视为子代理放行（guard 是纪律闸非安全闸，
    # 宁可漏拦不可错杀主线程的正常流程）。
    if ! kernel_available; then
      echo "[dispatch] 台账内核不可用（$KERNEL），is-subagent fail-open：rc=0（视为子代理）" >&2
      exit 0
    fi
    rc=0
    printf '%s' "$payload" | python3 "$KERNEL" is-subagent || rc=$?
    exit "$rc"
    ;;
  *)
    echo "unknown cmd: $CMD" >&2
    exit 2
    ;;
esac
