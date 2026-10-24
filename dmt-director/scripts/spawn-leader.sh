#!/usr/bin/env bash
# 经理用：按阈值开队长 pane（第 1 个在经理右侧，第 2 个起在上一队长下方）
# 用法：bash spawn-leader.sh <devm|anam> <n> [--dry-run] [--no-start] [--force-start]
#   需要 HERDR_ENV=1、HERDR_WORKSPACE_ID、HERDR_PANE_ID（经理自己的 pane）
#   幂等：label 已存在时不重建；若该 pane 没有 agent 在跑（agent_status=unknown）则补启动
set -eu
ROLE="$1"
N="$2"
shift 2 || true
DRY=0; START=1; FORCE=0
for a in "$@"; do
  case "$a" in --dry-run) DRY=1 ;; --no-start) START=0 ;; --force-start) FORCE=1 ;; *) echo "unknown arg: $a" >&2; exit 2 ;; esac
done
case "$ROLE" in devm|anam) ;; *) echo "role must be devm|anam" >&2; exit 2 ;; esac
case "$N" in ''|*[!0-9]*) echo "n must be a positive integer" >&2; exit 2 ;; esac

h() { if [ "$DRY" = 1 ]; then echo "+ $*" >&2; else "$@"; fi; }
pane_by_label() {
  HERDR_ENV=1 herdr pane list --workspace "$HERDR_WORKSPACE_ID" \
    | jq -r --arg l "$1" '.result.panes[] | select(.label==$l) | .pane_id' | head -1
}
pane_status() {
  HERDR_ENV=1 herdr pane get "$1" 2>/dev/null \
    | jq -r '.result.pane.agent_status // "unknown"' 2>/dev/null || echo unknown
}
wait_ready() {
  local pane="$1" i=0 st
  while [ "$i" -lt 60 ]; do
    st="$(pane_status "$pane")"
    if [ "$st" != "unknown" ]; then echo "ready ($st): $pane"; return 0; fi
    sleep 1; i=$((i + 1))
  done
  echo "WARN: $pane still unknown after 60s" >&2
  return 1
}
start_pane() {
  local pane="$1"
  [ "$START" = 1 ] || { echo "skip start: $pane"; return 0; }
  if [ "$DRY" = 1 ]; then echo "+ [dry] start $pane" >&2; return 0; fi
  local st; st="$(pane_status "$pane")"
  if [ "$st" != "unknown" ] && [ "$FORCE" != 1 ]; then
    echo "already running (agent_status=$st): $pane -- 不重发启动命令"
    return 0
  fi
  h env HERDR_ENV=1 herdr pane send-text "$pane" 'codebuddy --permission-mode auto'
  h env HERDR_ENV=1 herdr pane send-keys "$pane" enter
  wait_ready "$pane" || true
  h env HERDR_ENV=1 herdr pane send-text "$pane" "$SKILL"
  h env HERDR_ENV=1 herdr pane send-keys "$pane" enter
}

if [ "$ROLE" = devm ]; then
  PREFIX=devtl; ME=devm; SKILL='/dmt-dtl'
else
  PREFIX=anatl; ME=anam; SKILL='/dmt-atl'
fi
LABEL="$PREFIX$N"

existing="$(pane_by_label "$LABEL" || true)"
if [ -n "$existing" ]; then
  echo "$LABEL already exists ($existing)"
  start_pane "$existing"
  exit 0
fi

me="$(pane_by_label "$ME" || true)"
[ -n "$me" ] || { echo "manager pane '$ME' not found" >&2; exit 3; }

if [ "$N" -eq 1 ]; then
  base="$me"; dir=right
else
  prev="$PREFIX$((N-1))"
  base="$(pane_by_label "$prev" || true)"
  [ -n "$base" ] || { echo "previous leader pane '$prev' not found" >&2; exit 3; }
  dir=down
fi

pane="$(HERDR_ENV=1 herdr pane split "$base" --direction "$dir" --cwd "$PWD" --no-focus | jq -r '.result.pane.pane_id')"
h env HERDR_ENV=1 herdr pane rename "$pane" "$LABEL"
start_pane "$pane"
echo "spawned $LABEL ($pane)"
