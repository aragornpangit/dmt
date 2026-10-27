#!/usr/bin/env bash
# 经理用：按阈值开队长 pane（第 1 个在经理右侧，第 2 个起在上一队长下方）
# 用法：bash spawn-leader.sh <devm|anam> <n> [--dry-run] [--no-start] [--force-start]
#   需要 HERDR_ENV=1、HERDR_WORKSPACE_ID
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
N=$((10#$N))
if [ "$N" -lt 1 ]; then echo "n must be a positive integer" >&2; exit 2; fi

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

# 并发队长实例数上限 = min(8, cap)（team.md §1.2）：同类队长 pane 同时最多 CAP 个，达到上限拒开
# 幂等优先：label 已存在 ⇒ 上面已存在并 exit 0，不进闸门、不 REFUSE
SD="$(cd "$(dirname "$0")" && pwd)"
CAPV="$(bash "$SD/probe-cap.sh")"
if [ "$ROLE" = devm ]; then PFX=devtl; else PFX=anatl; fi
live="$(HERDR_ENV=1 herdr pane list --workspace "${HERDR_WORKSPACE_ID:-}" 2>/dev/null \
  | jq -r --arg re "^${PFX}[0-9]+$" '[.result.panes[] | select(.label|test($re))] | length' 2>/dev/null || echo 0)"
if [ "${live:-0}" -ge "$CAPV" ]; then
  echo "REFUSE: 并发队长实例数已达上限 min(8, cap)=$CAPV（在跑 ${live} 个 ${PFX}{n}）；先收口或分批" >&2
  exit 3
fi

me="$(pane_by_label "$ME" || true)"
[ -n "$me" ] || { echo "manager pane '$ME' not found" >&2; exit 3; }

if [ "$N" -eq 1 ]; then
  base="$me"; dir=right
else
  # 锚点：本经理名下现存最后一个队长 pane（按 label 找最大号），找不到退回经理 pane
  last="$(HERDR_ENV=1 herdr pane list --workspace "${HERDR_WORKSPACE_ID:-}" 2>/dev/null \
    | jq -r --arg pfx "$PREFIX" '[.result.panes[] | select(.label|test("^"+$pfx+"[0-9]+$")) | {l:.label, n:(.label|sub("^"+$pfx;"")|tonumber)}] | sort_by(.n) | last | .l // empty' || true)"
  base="$(pane_by_label "$last" || true)"
  if [ -n "$base" ]; then dir=down; else base="$me"; dir=right; fi
fi

pane="$(HERDR_ENV=1 herdr pane split "$base" --direction "$dir" --cwd "$PWD" --no-focus | jq -r '.result.pane.pane_id')"
h env HERDR_ENV=1 herdr pane rename "$pane" "$LABEL"
start_pane "$pane"
echo "spawned $LABEL ($pane)"
