#!/usr/bin/env bash
# 本体角色用：开 helper pane（{角色}-helper）并代启动 cbc、装载同角色技能分流
# helper 机制（用户裁定）：{总监|经理}忙不过来、且子代理在途已达上限 min(8, cap)、且仍有待办任务
#   ⇒ 找/建 helper tab（label 固定 helper，全队共享一个，没有就建）→ 在 helper tab 内 split 出 pane 并 rename 为 {角色}-helper
#   ⇒ 代启动 harness 并输同角色技能命令（director→/dmt-director、devm→/dmt-dm、anam→/dmt-am）
#   harness：默认 codebuddy；备选 pi / opencode / codex（--harness 或 $DMT_HARNESS；$DMT_HARNESS_CMD 可整体覆盖）
# 生命周期由创建者（本体角色）维护：建立、改名（label 漂移自愈）、任务完成回收（close-helper.sh 关 pane；helper tab 保留复用）
# 独占动作不移交：装机只归 director 本体、merge/push 只归 devm 本体
# 分身语义（用户裁定）：技能同主体（director→/dmt-director、devm→/dmt-dm、anam→/dmt-am）；任务随 spawn 一次性下发，此后不接受任何输入框内容；
# 工作成果单向汇报主体（inbox/<主体>/，方向 {seq}-{角色}-helper2{角色}-）；helper 没有自己的 inbox、不收件
# 用法：bash spawn-helper.sh <director|devm|anam> [任务文本] [--dry-run] [--no-start] [--harness <name>]
#   任务文本：可选，随启动一次性下发给分身（此后不再发任何输入框内容）
#   --harness：codebuddy（默认）| pi | opencode | codex
#   幂等：label {角色}-helper 已存在 ⇒ echo 已存在 exit 0
#   需要 HERDR_ENV=1、HERDR_WORKSPACE_ID
set -eu
ROLE="${1:?usage: spawn-helper.sh <director|devm|anam> [任务文本] [--dry-run] [--no-start]}"
shift || true
DRY=0; START=1; TASK=""; HARNESS_ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY=1 ;;
    --no-start) START=0 ;;
    --harness) HARNESS_ARG="${2:-}"; shift ;;
    -*) echo "unknown arg: $1" >&2; exit 2 ;;
    *) if [ -z "$TASK" ]; then TASK="$1"; else echo "unknown arg: $1" >&2; exit 2; fi ;;
  esac
  shift
done
case "$ROLE" in director|devm|anam) ;; *) echo "role must be director|devm|anam" >&2; exit 2 ;; esac
LABEL="${ROLE}-helper"
case "$ROLE" in
  director) SKILL='/dmt-director' ;;
  devm) SKILL='/dmt-dm' ;;
  anam) SKILL='/dmt-am' ;;
esac

. "$(cd "$(dirname "$0")" && pwd)/lib-dmt.sh"

HARNESS="$(dmt_harness_name "$HARNESS_ARG")" || exit 2
HARNESS_CMD="$(dmt_harness_cmd "$HARNESS")" || exit 2

h() { if [ "$DRY" = 1 ]; then echo "+ $*" >&2; else "$@"; fi; }
# 查询类：失败给空（dry-run / 无 herdr 环境也能走完分支打印）
q() { HERDR_ENV=1 herdr "$@" 2>/dev/null || true; }
list_panes() { q pane list --workspace "${HERDR_WORKSPACE_ID:-}"; }
pane_by_label() { dmt_pane_by_label "$1"; }
pane_status() { dmt_pane_status "$1"; }
# 就绪判据：轮询 agent_status 不再是 unknown（与 setup-team.sh 同判据）
wait_ready() { dmt_wait_ready "$1" 60 || true; }
start_pane() {
  local pane="$1"
  [ "$START" = 1 ] || { echo "skip start: $pane"; return 0; }
  if [ "$DRY" = 1 ]; then
    echo "+ [dry] start $pane: $HARNESS_CMD (harness=$HARNESS)  then  $SKILL" >&2
    [ -z "$TASK" ] || echo "+ [dry] task → $pane（一次性下发，此后不接受输入框内容）: $(printf '%s\n' "$TASK" | head -1)" >&2
    return 0
  fi
  local st; st="$(pane_status "$pane")"
  if [ "$st" != "unknown" ]; then
    echo "already running (agent_status=$st): $pane -- 不重发启动命令"
    return 0
  fi
  h env HERDR_ENV=1 herdr pane send-text "$pane" "$HARNESS_CMD"
  h env HERDR_ENV=1 herdr pane send-keys "$pane" enter
  wait_ready "$pane" || true
  h env HERDR_ENV=1 herdr pane send-text "$pane" "$SKILL"
  h env HERDR_ENV=1 herdr pane send-keys "$pane" enter
  if [ -n "$TASK" ]; then
    # 任务一次性下发：此后不再向该 pane 发任何输入框内容
    h env HERDR_ENV=1 herdr pane send-text "$pane" "$TASK"
    h env HERDR_ENV=1 herdr pane send-keys "$pane" enter
  fi
}

# 1) 幂等：helper pane 已存在 ⇒ 不重建
existing="$(pane_by_label "$LABEL")"
if [ -n "$existing" ]; then
  echo "已存在 $LABEL ($existing)"
  exit 0
fi

# 2) 找/建 helper tab（label 固定 helper，全队共享一个）
TAB="$(q tab list --workspace "${HERDR_WORKSPACE_ID:-}" \
  | jq -r '.result.tabs[]? | select(.label=="helper") | .tab_id' 2>/dev/null | head -1 || true)"
ROOT_PANE=""
if [ -z "$TAB" ]; then
  if [ "$DRY" = 1 ]; then
    echo "+ herdr tab create --workspace ${HERDR_WORKSPACE_ID:-} --cwd $PWD --label helper" >&2
    TAB="<helper-tab>"; ROOT_PANE="<helper-tab-root>"
  else
    out="$(HERDR_ENV=1 herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label helper)"
    TAB="$(printf '%s' "$out" | jq -r '.result.tab.tab_id // empty')"
    ROOT_PANE="$(printf '%s' "$out" | jq -r '.result.root_pane.pane_id // empty')"
  fi
  echo "created helper tab $TAB"
fi

# 3) helper tab 内的锚点 pane（新建 tab 用 root pane，已有 tab 取其中一个 pane 做 split）
base="$ROOT_PANE"
if [ -z "$base" ]; then
  base="$(list_panes | jq -r --arg t "$TAB" '.result.panes[]? | select(.tab_id==$t) | .pane_id' 2>/dev/null | head -1 || true)"
fi
if [ -z "$base" ]; then
  if [ "$DRY" = 1 ]; then
    echo "(dry) helper tab $TAB 内暂无 pane，按占位 pane 走完分支" >&2
    base="<helper-tab-pane>"
  else
    echo "helper tab $TAB 找不到可 split 的锚点 pane" >&2
    exit 3
  fi
fi

# 4) 取本次 helper 的 pane 并 rename 为 {角色}-helper
#    新建 tab ⇒ **直接用 root pane**（与 setup-team.sh 建 anam tab 同做法；
#    此前总是 split 会多切一刀、并留下无法用 label 定位的孤儿 pane）
#    已有 tab（root 可能已被别的角色 helper 占用）⇒ 才 split 新 pane
if [ -n "${ROOT_PANE:-}" ]; then
  pane="$ROOT_PANE"
  h env HERDR_ENV=1 herdr pane rename "$pane" "$LABEL"
  echo "use existing root pane of new helper tab: $pane"
else
  if [ "$DRY" = 1 ]; then
    h herdr pane split "$base" --direction right --cwd "$PWD" --no-focus
    h herdr pane rename "<new-pane>" "$LABEL"
    pane="<new-pane>"
  else
    pane="$(HERDR_ENV=1 herdr pane split "$base" --direction right --cwd "$PWD" --no-focus | jq -r '.result.pane.pane_id')"
    HERDR_ENV=1 herdr pane rename "$pane" "$LABEL"
  fi
fi

# 5) 代启动 harness 并装载同角色技能分流
start_pane "$pane"
echo "spawned $LABEL ($pane) on tab $TAB"
