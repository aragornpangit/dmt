#!/usr/bin/env bash
# dmt-dir 用：部署 tab dmt-dir-am（dmt-dir 左 60% / dmt-am 右）与 tab dmt-dm（dmt-dm 左 30% / dmt-dl1 右上 / dmt-dl2 右下），并代启动 harness（幂等）
# 用法：bash setup-team.sh [--dry-run] [--no-start] [--force-start] [--reload] [--harness <name>]
#   --no-start     只建 pane，不启动
#   --force-start  即使 agent 已在跑也重发启动命令（默认跳过：对运行中的 agent 发启动命令会被当成用户提问）
#   --reload       对已在跑的 pane 补发技能命令（重载技能，不重发启动命令；codex 在新会话重开）
#   --harness      harness 名：codebuddy（默认）| pi | opencode | codex | claude（亦可 $DMT_HARNESS；$DMT_HARNESS_CMD 整体覆盖）
#   需要环境变量 HERDR_ENV=1、HERDR_PANE_ID、HERDR_TAB_ID、HERDR_WORKSPACE_ID
set -eu
DRY=0; START=1; FORCE=0; RELOAD=0; HARNESS_ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY=1 ;;
    --no-start) START=0 ;;
    --force-start) FORCE=1 ;;
    --reload) RELOAD=1 ;;
    --harness) HARNESS_ARG="${2:-}"; shift ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done
missing=""
[ -n "${HERDR_ENV:-}" ] || missing="$missing HERDR_ENV"
[ -n "${HERDR_PANE_ID:-}" ] || missing="$missing HERDR_PANE_ID"
[ -n "${HERDR_TAB_ID:-}" ] || missing="$missing HERDR_TAB_ID"
[ -n "${HERDR_WORKSPACE_ID:-}" ] || missing="$missing HERDR_WORKSPACE_ID"
[ -z "$missing" ] || { echo "缺少环境变量:$missing（在 dmt-dir pane 内执行本脚本）" >&2; exit 2; }

. "$(cd -P "$(dirname "$0")" && pwd -P)/lib-dmt.sh"

HARNESS="$(dmt_harness_name "$HARNESS_ARG")" || exit 2
HARNESS_CMD="$(dmt_harness_cmd "$HARNESS")" || exit 2
FIRST_PROMPT=0
if dmt_start_has_first_prompt "$HARNESS"; then FIRST_PROMPT=1; fi

h() { if [ "$DRY" = 1 ]; then echo "+ $*" >&2; else "$@"; fi; }
pane_by_label() { dmt_pane_by_label "$1"; }
# agent_status: unknown = 该 pane 没有 agent 在跑；idle/working/blocked = 已在跑
pane_status() { dmt_pane_status "$1"; }
tab_id_by_label() {
  dmt_herdr tab list --workspace "$HERDR_WORKSPACE_ID" 2>/dev/null \
    | jq -r --arg l "$1" '.result.tabs[]? | select(.label==$l) | .tab_id' 2>/dev/null | head -1 || true
}
first_pane_in_tab() {
  dmt_herdr pane list --workspace "$HERDR_WORKSPACE_ID" 2>/dev/null \
    | jq -r --arg t "$1" '.result.panes[]? | select(.tab_id==$t) | .pane_id' 2>/dev/null | head -1 || true
}
# 就绪判据：轮询 agent_status 不再是 unknown。
# 不要用 wait-output 匹配屏幕文字 —— 对已在跑的 pane 它会立刻命中历史输出，等于没有判据。
wait_ready() { dmt_wait_ready "$1" 60 || true; }
ensure_started() {
  local pane="$1" skill_name="$2" role="$3" st prompt
  prompt="$(dmt_skill_prompt "$HARNESS" "$skill_name" '' "$role")"
  [ "$START" = 1 ] || { echo "skip start: $pane"; return 0; }
  if [ "$DRY" = 1 ]; then
    if [ "$FIRST_PROMPT" = 1 ]; then
      echo "+ [dry] start $pane: $HARNESS_CMD '<角色技能 prompt>' (harness=$HARNESS, first prompt)" >&2
    else
      echo "+ [dry] start $pane: $HARNESS_CMD (harness=$HARNESS)  then  $(dmt_skill_cmd "$HARNESS" "$skill_name")" >&2
    fi
    return 0
  fi
  st="$(pane_status "$pane")"
  if [ "$st" != "unknown" ] && [ "$FORCE" != 1 ]; then
    echo "already running (agent_status=$st): $pane -- 不重发启动命令"
    if [ "$RELOAD" = 1 ]; then
      if [ "$FIRST_PROMPT" = 1 ]; then
        echo "WARN codex 的首轮 prompt 只在启动时生效；技能重载须重开 pane: $pane" >&2
      else
        h dmt_herdr pane send-text "$pane" "$(dmt_skill_cmd "$HARNESS" "$skill_name")"
        h dmt_herdr pane send-keys "$pane" enter
        echo "reloaded skill on $pane"
      fi
    fi
    return 0
  fi
  if [ "$FIRST_PROMPT" = 1 ]; then
    # Codex 首次会话可能先出 trust/启动界面；技能必须与启动命令同一次提交，
    # 否则第二次粘贴会落进确认界面而不是成为会话 prompt。
    h env HERDR_ENV=1 DMT_PANE_ROLE="$role" herdr pane send-text "$pane" \
      "DMT_PANE_ROLE=$role $HARNESS_CMD '$prompt'"
    h dmt_herdr pane send-keys "$pane" enter
    wait_ready "$pane" || true
  else
    h dmt_herdr pane send-text "$pane" "$HARNESS_CMD"
    h dmt_herdr pane send-keys "$pane" enter
    wait_ready "$pane" || true
    h dmt_herdr pane send-text "$pane" "$(dmt_skill_cmd "$HARNESS" "$skill_name")"
    h dmt_herdr pane send-keys "$pane" enter
  fi
  # 档位复验（第六十三次）：就绪只证明「有 agent 在跑」，不证明它跑在自动档。
  # 非自动档的 pane 每次工具调用都要人点批准 —— 表现为「脚本超时/命令失败」，根因却在权限层。
  verify_auto_mode "$pane"
}

# 启动后回读 argv 复验自动档；rc=1 告警并把该 pane 标出来，不静默放过。
# argv 拿不到（rc=2，如 herdr process-info 不可用）只记 INFO —— 不把工具限制当违规。
verify_auto_mode() {
  local pane="$1" rc=0
  dmt_pane_auto_mode "$pane" || rc=$?
  case "$rc" in
    0) echo "auto-mode OK: $pane" ;;
    2) echo "INFO 无法判定权限档位（拿不到 argv）: $pane" >&2 ;;
    *) echo "WARN $pane 不在自动批准档位 —— 每次工具调用都可能撞审批；请用 --harness/--force-start 重开该 pane（argv: $(dmt_pane_argv "$pane")）" >&2 ;;
  esac
  return 0
}

# 1) 自己正名：当前 tab 为 dmt-dir-am，当前 pane 为 dmt-dir
h dmt_herdr tab rename "$HERDR_TAB_ID" dmt-dir-am
h dmt_herdr pane rename "$HERDR_PANE_ID" dmt-dir

# 2) dmt-dm tab：dmt-dm 左 30%，dmt-dl1 右上、dmt-dl2 右下（固定两个队长）
dm_pane="$(pane_by_label dmt-dm || true)"
dmtab="$(tab_id_by_label dmt-dm || true)"
if [ -z "$dm_pane" ]; then
  if [ -z "$dmtab" ]; then
    if [ "$DRY" = 1 ]; then
      echo "+ herdr tab create --workspace $HERDR_WORKSPACE_ID --cwd $PWD --label dmt-dm" >&2
      echo "+ herdr pane rename <dmt-dm-pane> dmt-dm" >&2
      dm_pane="<dmt-dm-pane>"
    else
      dm_pane="$(dmt_herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label dmt-dm | jq -r '.result.root_pane.pane_id // empty')"
      [ -n "$dm_pane" ] || { echo "ERROR: tab create 失败（dmt-dm）" >&2; exit 4; }
      dmt_herdr pane rename "$dm_pane" dmt-dm
    fi
  else
    if [ "$DRY" = 1 ]; then
      dm_pane="<dmt-dm-pane>"
    else
      dm_pane="$(first_pane_in_tab "$dmtab")"
      [ -n "$dm_pane" ] || { echo "ERROR: dmt-dm tab 内没有 pane" >&2; exit 4; }
      dmt_herdr pane rename "$dm_pane" dmt-dm
    fi
  fi
else
  curtab="$(dmt_herdr pane get "$dm_pane" 2>/dev/null | jq -r '.result.pane.tab_id // empty')"
  if [ -n "$curtab" ] && [ "$curtab" != "$dmtab" ]; then
    if [ -z "$dmtab" ]; then
      h dmt_herdr pane move "$dm_pane" --new-tab --tab-label dmt-dm --no-focus
    else
      echo "WARN: dmt-dm 已在 $curtab，但 dmt-dm tab 已存在（$dmtab）；请手工把 dmt-dm 移入或先关空 tab" >&2
    fi
  fi
fi
ensure_started "$dm_pane" dmt-dm dmt-dm

# 2b) 固定两个开发队长：dmt-dl1 从 dmt-dm 右侧切出（dmt-dm 保留 30%），dmt-dl2 从 dmt-dl1 下方对半切出
dl1_pane="$(pane_by_label dmt-dl1 || true)"
for n in 1 2; do
  label="dmt-dl$n"
  p="$(pane_by_label "$label" || true)"
  if [ -z "$p" ]; then
    if [ "$DRY" = 1 ]; then
      echo "+ herdr pane split <base> $( [ "$n" = 1 ] && echo '--direction right --ratio 0.3' || echo '--direction down --ratio 0.5' ) -> $label" >&2
      p="<$label-pane>"
    elif [ "$n" = 1 ]; then
      p="$(dmt_herdr pane split "$dm_pane" --direction right --ratio 0.3 --cwd "$PWD" --no-focus | jq -r '.result.pane.pane_id // empty')"
      [ -n "$p" ] || { echo "ERROR: pane split 失败（$label）" >&2; exit 4; }
      dmt_herdr pane rename "$p" "$label"
      mkdir -p "$PWD/inbox/$label"
      dl1_pane="$p"
    else
      [ -n "$dl1_pane" ] || dl1_pane="$(pane_by_label dmt-dl1 || true)"
      [ -n "$dl1_pane" ] || { echo "ERROR: 找不到 dmt-dl1 pane，无法切出 $label" >&2; exit 4; }
      p="$(dmt_herdr pane split "$dl1_pane" --direction down --ratio 0.5 --cwd "$PWD" --no-focus | jq -r '.result.pane.pane_id // empty')"
      [ -n "$p" ] || { echo "ERROR: pane split 失败（$label）" >&2; exit 4; }
      dmt_herdr pane rename "$p" "$label"
      mkdir -p "$PWD/inbox/$label"
    fi
  fi
  ensure_started "$p" dmt-dl "$label"
done

# 3) dmt-am：与 dmt-dir 同处 dmt-dir-am tab，右侧（dmt-dir 保留 60%）
p="$(pane_by_label dmt-am || true)"
if [ -z "$p" ]; then
  if [ "$DRY" = 1 ]; then
    echo "+ herdr pane split $HERDR_PANE_ID --direction right --ratio 0.6 --cwd $PWD --no-focus" >&2
    echo "+ herdr pane rename <dmt-am-pane> dmt-am" >&2
    p="<dmt-am-pane>"
  else
    p="$(dmt_herdr pane split "$HERDR_PANE_ID" --direction right --ratio 0.6 --cwd "$PWD" --no-focus | jq -r '.result.pane.pane_id // empty')"
    [ -n "$p" ] || { echo "ERROR: pane split 失败（dmt-am）" >&2; exit 4; }
    dmt_herdr pane rename "$p" dmt-am
  fi
else
  curtab="$(dmt_herdr pane get "$p" 2>/dev/null | jq -r '.result.pane.tab_id // empty')"
  if [ -n "$curtab" ] && [ "$curtab" != "$HERDR_TAB_ID" ]; then
    h dmt_herdr pane move "$p" --tab "$HERDR_TAB_ID" --target-pane "$HERDR_PANE_ID" --split right --ratio 0.6 --no-focus
  fi
fi
ensure_started "$p" dmt-am dmt-am
echo "team ready: tab dmt-dir-am[dmt-dir 60% | dmt-am] / tab dmt-dm[dmt-dm 30% | dmt-dl1 | dmt-dl2]"
