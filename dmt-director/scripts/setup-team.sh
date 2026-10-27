#!/usr/bin/env bash
# director 用：给自己正名，建 devm（本 tab 右侧）/ anam（独立 tab）两个 pane 并代启动 cbc（创建与启动都幂等）
# 用法：bash setup-team.sh [--dry-run] [--no-start] [--force-start] [--reload]
#   --no-start     只建 pane，不启动
#   --force-start  即使 agent 已在跑也重发启动命令（默认跳过：对运行中的 agent 发启动命令会被当成用户提问）
#   --reload       对已在跑的 pane 只补发技能命令（重载技能，不重发启动命令）
#   需要环境变量 HERDR_ENV=1、HERDR_PANE_ID、HERDR_TAB_ID、HERDR_WORKSPACE_ID
set -eu
DRY=0; START=1; FORCE=0; RELOAD=0
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --no-start) START=0 ;;
    --force-start) FORCE=1 ;;
    --reload) RELOAD=1 ;;
    *) echo "unknown arg: $a" >&2; exit 2 ;;
  esac
done
missing=""
[ -n "${HERDR_ENV:-}" ] || missing="$missing HERDR_ENV"
[ -n "${HERDR_PANE_ID:-}" ] || missing="$missing HERDR_PANE_ID"
[ -n "${HERDR_TAB_ID:-}" ] || missing="$missing HERDR_TAB_ID"
[ -n "${HERDR_WORKSPACE_ID:-}" ] || missing="$missing HERDR_WORKSPACE_ID"
[ -z "$missing" ] || { echo "缺少环境变量:$missing（在 director pane 内执行本脚本）" >&2; exit 2; }

h() { if [ "$DRY" = 1 ]; then echo "+ $*" >&2; else "$@"; fi; }
pane_by_label() {
  HERDR_ENV=1 herdr pane list --workspace "$HERDR_WORKSPACE_ID" \
    | jq -r --arg l "$1" '.result.panes[] | select(.label==$l) | .pane_id' | head -1
}
# agent_status: unknown = 该 pane 没有 agent 在跑；idle/working/blocked = 已在跑
pane_status() {
  HERDR_ENV=1 herdr pane get "$1" 2>/dev/null \
    | jq -r '.result.pane.agent_status // "unknown"' 2>/dev/null || echo unknown
}
# 就绪判据：轮询 agent_status 不再是 unknown。
# 不要用 wait-output 匹配屏幕文字 —— 对已在跑的 pane 它会立刻命中历史输出，等于没有判据。
wait_ready() {
  local pane="$1" i=0 st
  while [ "$i" -lt 60 ]; do
    st="$(pane_status "$pane")"
    if [ "$st" != "unknown" ]; then echo "ready ($st): $pane"; return 0; fi
    sleep 1; i=$((i + 1))
  done
  echo "WARN: $pane still unknown after 60s; skill command sent anyway" >&2
  return 1
}
ensure_started() {
  local pane="$1" skill="$2" st
  [ "$START" = 1 ] || { echo "skip start: $pane"; return 0; }
  if [ "$DRY" = 1 ]; then
    echo "+ [dry] start $pane: codebuddy --permission-mode auto  then  $skill" >&2
    return 0
  fi
  st="$(pane_status "$pane")"
  if [ "$st" != "unknown" ] && [ "$FORCE" != 1 ]; then
    echo "already running (agent_status=$st): $pane -- 不重发启动命令"
    if [ "$RELOAD" = 1 ]; then
      h env HERDR_ENV=1 herdr pane send-text "$pane" "$skill"
      h env HERDR_ENV=1 herdr pane send-keys "$pane" enter
      echo "reloaded skill on $pane"
    fi
    return 0
  fi
  h env HERDR_ENV=1 herdr pane send-text "$pane" 'codebuddy --permission-mode auto'
  h env HERDR_ENV=1 herdr pane send-keys "$pane" enter
  wait_ready "$pane" || true
  h env HERDR_ENV=1 herdr pane send-text "$pane" "$skill"
  h env HERDR_ENV=1 herdr pane send-keys "$pane" enter
}

# 1) 自己正名：先 tab 后 pane
h env HERDR_ENV=1 herdr tab rename "$HERDR_TAB_ID" director
h env HERDR_ENV=1 herdr pane rename "$HERDR_PANE_ID" director

# 2) devm：在 director pane 右侧 split（与 director 同 tab，左 director 右 devm）
devm="$(pane_by_label devm || true)"
if [ -z "$devm" ]; then
  if [ "$DRY" = 1 ]; then
    echo "+ herdr pane split $HERDR_PANE_ID --direction right --cwd $PWD --no-focus" >&2
    echo "+ herdr pane rename <devm-pane> devm" >&2
    devm="<devm-pane>"
  else
    devm="$(HERDR_ENV=1 herdr pane split "$HERDR_PANE_ID" --direction right --cwd "$PWD" --no-focus | jq -r '.result.pane.pane_id // empty')"
    [ -n "$devm" ] || { echo "ERROR: pane split 失败（devm）" >&2; exit 4; }
    HERDR_ENV=1 herdr pane rename "$devm" devm
  fi
fi
ensure_started "$devm" '/dmt-dm'

# 3) anam：独立建 tab
p="$(pane_by_label anam || true)"
if [ -z "$p" ]; then
  # 幂等按 tab label 判：已有 anam tab（pane label 漂移）⇒ 取该 tab 的 pane 改名，不再建第二个 tab
  tab="$(HERDR_ENV=1 herdr tab list --workspace "$HERDR_WORKSPACE_ID" | jq -r '.result.tabs[] | select(.label=="anam") | .tab_id' | head -1)"
  if [ -n "$tab" ]; then
    p="$(HERDR_ENV=1 herdr pane list --workspace "$HERDR_WORKSPACE_ID" | jq -r --arg t "$tab" '.result.panes[] | select(.tab_id==$t) | .pane_id' | head -1)"
    h env HERDR_ENV=1 herdr pane rename "$p" anam
  elif [ "$DRY" = 1 ]; then
    echo "+ herdr tab create --workspace $HERDR_WORKSPACE_ID --cwd $PWD --label anam" >&2
    echo "+ herdr pane rename <anam-pane> anam" >&2
    p="<anam-pane>"
  else
    p="$(HERDR_ENV=1 herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label anam | jq -r '.result.root_pane.pane_id // empty')"
    [ -n "$p" ] || { echo "ERROR: tab create 失败（anam）" >&2; exit 4; }
    HERDR_ENV=1 herdr pane rename "$p" anam
  fi
fi
ensure_started "$p" '/dmt-am'
echo "team ready: director / devm（director tab 右侧）/ anam（独立 tab）；产品工作由 director 自派 pde{n} 子代理（/dmt-pde），不占 pane"
