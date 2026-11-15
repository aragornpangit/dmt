#!/usr/bin/env bash
# 本体角色用：开 helper pane（{角色}-helper）并代启动 harness、装载同角色技能与任务
# helper 机制（用户裁定）：建议判据（2026-11-04 第七十五次，可观测）＝
#   本体 pane agent_status == working（本体在忙）且该角色有 ≥1 条待办超过 10 分钟未处理；
#   是否派生由本体判断，判据只作参考。
#   旧口径「忙不过来 / 回报积压 / 仍有待办 三条同时成立」因无可观测判据而废弃（从不触发）。
#   ⇒ 在派生者自身 pane 所在的 tab 内、从派生者 pane 向下 split 出新 pane 并 rename 为 {角色}-helper（不另建 helper tab）
#   ⇒ 代启动 harness 并输同角色技能命令（dmt-dir→dmt-dir、dmt-dm→dmt-dm、dmt-am→dmt-am；前缀按 harness 走 `dmt_skill_cmd`）
#   harness：默认 codebuddy；备选 pi / opencode / codex / claude（--harness 或 $DMT_HARNESS；$DMT_HARNESS_CMD 可整体覆盖）
# 生命周期由创建者（本体角色）维护：建立、改名（label 漂移自愈）、任务完成回收（close-helper.sh 关 pane；派生者 pane 与所在 tab 保留）
# 独占动作不移交：硬件设备写操作归 dmt-dm/dmt-dir 本体、merge/push 归 dmt-dm 本体
# 分身语义（用户裁定）：技能同主体（dmt-dir→/dmt-dir、dmt-dm→/dmt-dm、dmt-am→/dmt-am）；任务随 spawn 一次性下发，此后不接受任何输入框内容；
# 工作成果单向汇报主体（inbox/<主体>/，方向 {seq}-{角色}-helper2{角色}-）；helper 没有自己的 inbox、不收件
# 用法：bash spawn-helper.sh <dmt-dir|dmt-dm|dmt-am> [任务文本] [--dry-run] [--no-start] [--harness <name>]
#   任务文本：可选，随启动一次性下发给分身（此后不再发任何输入框内容）
#   --harness：codebuddy（默认）| pi | opencode | codex | claude | hermes
#   幂等：label {角色}-helper 已存在 ⇒ echo 已存在 exit 0
#   需要 HERDR_ENV=1、HERDR_PANE_ID（在派生者 pane 内执行）
set -eu
ROLE="${1:?usage: spawn-helper.sh <dmt-dir|dmt-dm|dmt-am> [任务文本] [--dry-run] [--no-start]}"
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
case "$ROLE" in dmt-dir|dmt-dm|dmt-am) ;; *) echo "role must be dmt-dir|dmt-dm|dmt-am" >&2; exit 2 ;; esac
LABEL="${ROLE}-helper"
SKILL_NAME="$ROLE"
[ -n "${HERDR_PANE_ID:-}" ] || { echo "缺少 HERDR_PANE_ID（在派生者 pane 内执行本脚本）" >&2; exit 2; }

. "$(cd -P "$(dirname "$0")" && pwd -P)/lib-dmt.sh"

HARNESS="$(dmt_harness_name "$HARNESS_ARG")" || exit 2
HARNESS_CMD="$(dmt_harness_cmd "$HARNESS")" || exit 2
FIRST_PROMPT=0
if dmt_start_has_first_prompt "$HARNESS"; then FIRST_PROMPT=1; fi
TASK_PROMPT=""
if [ -n "$TASK" ]; then
  TASK_PROMPT="任务（随本轮一次性下发）：$TASK。完成后用 helper-report.sh 单向回报主体；此后不再接收输入。"
fi
PROMPT="$(dmt_skill_prompt "$HARNESS" "$SKILL_NAME" "$TASK_PROMPT" "$ROLE")"

h() { if [ "$DRY" = 1 ]; then echo "+ $*" >&2; else "$@"; fi; }
pane_by_label() { dmt_pane_by_label "$1"; }
pane_status() { dmt_pane_status "$1"; }
# 就绪判据：轮询 agent_status 不再是 unknown（与 setup-team.sh 同判据）
wait_ready() { dmt_wait_ready "$1" 60 || true; }
# 档位复验（第六十三次，与 setup-team.sh 同一判据）：非自动档的 pane 每次工具调用都要人批准
verify_auto_mode() {
  local pane="$1" rc=0
  dmt_pane_auto_mode "$pane" || rc=$?
  case "$rc" in
    0) echo "auto-mode OK: $pane" ;;
    2) echo "INFO 无法判定权限档位（拿不到 argv）: $pane" >&2 ;;
    *) echo "WARN $pane 不在自动批准档位 —— 每次工具调用都可能撞审批；请用 --harness 重开该 helper（argv: $(dmt_pane_argv "$pane")）" >&2 ;;
  esac
  return 0
}
start_pane() {
  local pane="$1"
  [ "$START" = 1 ] || { echo "skip start: $pane"; return 0; }
  if [ "$DRY" = 1 ]; then
    if [ "$FIRST_PROMPT" = 1 ]; then
      echo "+ [dry] start $pane: $HARNESS_CMD '<role+task prompt>' (harness=$HARNESS, first prompt)" >&2
    else
      echo "+ [dry] start $pane: $HARNESS_CMD (harness=$HARNESS)  then  $(dmt_skill_cmd "$HARNESS" "$SKILL_NAME")" >&2
    fi
    [ -z "$TASK" ] || echo "+ [dry] task → $pane（一次性下发，此后不接受输入框内容）: $(printf '%s\n' "$TASK" | head -1)" >&2
    return 0
  fi
  local st; st="$(pane_status "$pane")"
  if [ "$st" != "unknown" ]; then
    echo "already running (agent_status=$st): $pane -- 不重发启动命令"
    return 0
  fi
  if [ "$FIRST_PROMPT" = 1 ]; then
    # Codex 的技能与任务必须合成首轮 prompt，避免角色先自行开工或进入交互界面。
    h env HERDR_ENV=1 DMT_PANE_ROLE="$LABEL" herdr pane send-text "$pane" \
      "DMT_PANE_ROLE=$LABEL $HARNESS_CMD '$PROMPT'"
    h dmt_herdr pane send-keys "$pane" enter
    wait_ready "$pane" || true
  else
    h env HERDR_ENV=1 DMT_PANE_ROLE="$LABEL" herdr pane send-text "$pane" "$HARNESS_CMD"
    h dmt_herdr pane send-keys "$pane" enter
    wait_ready "$pane" || true
    h dmt_herdr pane send-text "$pane" "$(dmt_skill_cmd "$HARNESS" "$SKILL_NAME")"
    h dmt_herdr pane send-keys "$pane" enter
    if [ -n "$TASK" ]; then
      # 任务一次性下发：此后不再向该 pane 发任何输入框内容
      h dmt_herdr pane send-text "$pane" "$TASK"
      h dmt_herdr pane send-keys "$pane" enter
    fi
  fi
  verify_auto_mode "$pane"
}

# 1) 幂等：helper pane 已存在 ⇒ 不重建
existing="$(pane_by_label "$LABEL")"
if [ -n "$existing" ]; then
  echo "已存在 $LABEL ($existing)"
  exit 0
fi

# 2) 在派生者所在 tab 内、从派生者 pane 向下 split 出本次 helper 的 pane
#    不另建 helper tab：helper 与派生者同 tab，关闭 helper 不影响 tab 与派生者。
if [ "$DRY" = 1 ]; then
  h herdr pane split "$HERDR_PANE_ID" --direction down --ratio 0.5 --cwd "$PWD" --no-focus
  h herdr pane rename "<new-pane>" "$LABEL"
  pane="<new-pane>"
else
  pane="$(dmt_herdr pane split "$HERDR_PANE_ID" --direction down --ratio 0.5 --cwd "$PWD" --no-focus | jq -r '.result.pane.pane_id // empty')"
  [ -n "$pane" ] || { echo "ERROR: pane split 失败（$LABEL）" >&2; exit 4; }
  dmt_herdr pane rename "$pane" "$LABEL"
fi

# 3) 代启动 harness 并装载同角色技能
start_pane "$pane"
echo "spawned $LABEL ($pane) in tab of $HERDR_PANE_ID"
