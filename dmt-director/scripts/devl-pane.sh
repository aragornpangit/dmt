#!/usr/bin/env bash
# 可选 herdr 适配器：按需管理 dmt-devl pane 生命周期。
# 布局与容量由环境变量配置；默认不强制常驻队长。
# 用法：bash devl-pane.sh <list|ensure-min|add|remove|rebalance|adopt> [--index N] [--force]
#   需要环境变量 HERDR_ENV=1、HERDR_PANE_ID、HERDR_WORKSPACE_ID（在 devm pane 内执行）
#   常量：DEVL_MIN（默认 0）、DEVL_MAX（默认 0=不设策略上限）、DEVL_PER_TAB（默认 2）
set -eu

CMD="${1:-list}"; shift || true
INDEX=""; FORCE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --index) INDEX="${2:-}"; shift ;;
    --force) FORCE=1 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

missing=""
[ -n "${HERDR_ENV:-}" ] || missing="$missing HERDR_ENV"
[ -n "${HERDR_PANE_ID:-}" ] || missing="$missing HERDR_PANE_ID"
[ -n "${HERDR_WORKSPACE_ID:-}" ] || missing="$missing HERDR_WORKSPACE_ID"
[ -z "$missing" ] || { echo "缺少环境变量:$missing（在 devm pane 内执行本脚本）" >&2; exit 2; }

. "$(cd -P "$(dirname "$0")" && pwd -P)/lib-dmt.sh"

DEVL_MIN="${DEVL_MIN:-0}"
DEVL_MAX="${DEVL_MAX:-0}"
DEVL_PER_TAB="${DEVL_PER_TAB:-2}"
HARNESS="$(dmt_harness_name "${DMT_HARNESS:-}")" || exit 2

# 本 workspace 全部 dmt-devl{n} pane（跨所有 dmt-dev{n} tab）
list_devl() {
  dmt_herdr pane list --workspace "$HERDR_WORKSPACE_ID" 2>/dev/null \
    | jq -r '.result.panes[]? | select((.label // "") | test("^dmt-devl[0-9]+$")) | [.label, .pane_id, .tab_id, (.agent_status // "unknown")] | @tsv' \
    | sort -t$'\t' -k1,1V
}
count_devl() { list_devl | sed '/^$/d' | wc -l | tr -d ' '; }
next_index() {
  local used i
  used="$(list_devl | cut -f1 | sed 's/^dmt-devl//' | sort -n)"
  i=1
  while printf '%s\n' "$used" | grep -qx "$i"; do i=$((i+1)); done
  printf '%s' "$i"
}
pane_tab() { dmt_herdr pane get "$1" 2>/dev/null | jq -r '.result.pane.tab_id // empty'; }
tab_label() {
  dmt_herdr tab list --workspace "$HERDR_WORKSPACE_ID" 2>/dev/null \
    | jq -r --arg t "$1" '.result.tabs[]? | select(.tab_id==$t) | .label // empty' | head -1
}
# 现有 dmt-dev{n} tab，按 n 升序
devl_tabs() {
  dmt_herdr tab list --workspace "$HERDR_WORKSPACE_ID" 2>/dev/null \
    | jq -r '.result.tabs[]? | select((.label // "") | test("^dmt-dev[0-9]+$")) | [.label, .tab_id] | @tsv' \
    | sort -t$'\t' -k1,1V
}
count_in_tab() {
  list_devl | awk -F'\t' -v t="$1" '$3==t' | wc -l | tr -d ' '
}
next_tab_no() {
  local n=0 i
  while IFS=$'\t' read -r lab _; do
    [ -n "$lab" ] || continue
    i="${lab#dmt-dev}"
    [ "$i" -gt "$n" ] 2>/dev/null && n="$i"
  done < <(devl_tabs)
  printf '%s' "$((n+1))"
}
# 找第一个未满的 dmt-dev{n} tab；都满则返回空
tab_with_room() {
  local lab tid
  while IFS=$'\t' read -r lab tid; do
    [ -n "$tid" ] || continue
    if [ "$(count_in_tab "$tid")" -lt "$DEVL_PER_TAB" ]; then printf '%s' "$tid"; return; fi
  done < <(devl_tabs)
  printf ''
}
# 把每个 dmt-dev{n} tab 内的水平分栏调成 50/50
rebalance_tabs() {
  local tid json
  while IFS=$'\t' read -r _ tid; do
    [ -n "$tid" ] || continue
    json="$(dmt_herdr pane layout --pane "$(list_devl | awk -F'\t' -v t="$tid" '$3==t{print $2; exit}')" 2>/dev/null)" || continue
    [ -n "$json" ] || continue
    printf '%s' "$json" | python3 -c "$(cat <<'PY'
import json, sys
try:
    layout = json.load(sys.stdin)["result"]["layout"]
except Exception:
    sys.exit(0)
panes = [p for p in (layout.get("panes") or []) if (p.get("label") or "").startswith("dmt-devl")]
area = layout.get("area") or {}
if len(panes) != 2 or not area.get("width"):
    sys.exit(0)
left = min(panes, key=lambda p: p["rect"]["x"])
right = max(panes, key=lambda p: p["rect"]["x"])
cur = left["rect"]["width"] / area["width"]
delta = 0.5 - cur
if abs(delta) < 0.01:
    sys.exit(0)
if delta > 0:
    print(f'{left["pane_id"]}\tright\t{delta:.3f}')
else:
    print(f'{right["pane_id"]}\tleft\t{-delta:.3f}')
PY
)" 2>/dev/null | while IFS=$'\t' read -r p dir amt; do
      [ -n "${p:-}" ] || continue
      dmt_herdr pane resize --pane "$p" --direction "$dir" --amount "$amt" >/dev/null 2>&1 || true
    done
  done < <(devl_tabs)
}
verify_auto_mode() {
  local pane="$1" rc=0
  dmt_pane_auto_mode "$pane" || rc=$?
  case "$rc" in
    0) echo "auto-mode OK: $pane" ;;
    2) echo "INFO 无法判定权限档位（拿不到 argv）: $pane" >&2 ;;
    *) echo "WARN $pane 不在自动批准档位 —— 请用 --force 重开该 pane" >&2 ;;
  esac
  return 0
}
start_devl() {
  local pane="$1" role="$2" st prompt first=0
  dmt_start_has_first_prompt "$HARNESS" && first=1
  prompt="$(dmt_skill_prompt "$HARNESS" dmt-devl '' "$role")"
  st="$(dmt_pane_status "$pane")"
  if [ "$st" != "unknown" ] && [ "$FORCE" != 1 ]; then
    echo "already running (agent_status=$st): $pane"
    return 0
  fi
  if [ "$first" = 1 ]; then
    dmt_herdr pane send-text "$pane" "DMT_PANE_ROLE=$role $(dmt_harness_cmd "$HARNESS") '$prompt'"
    dmt_herdr pane send-keys "$pane" enter
  else
    dmt_herdr pane send-text "$pane" "$(dmt_harness_cmd "$HARNESS")"
    dmt_herdr pane send-keys "$pane" enter
    dmt_wait_ready "$pane" 60 || true
    dmt_herdr pane send-text "$pane" "$(dmt_skill_cmd "$HARNESS" dmt-devl)"
    dmt_herdr pane send-keys "$pane" enter
    sleep 0.6
    dmt_herdr pane send-keys "$pane" enter   # opencode 首启偶发吞回车，补一次
  fi
  dmt_wait_ready "$pane" 60 || true
  verify_auto_mode "$pane"
}
add_one() {
  local cur n tid lab pane
  cur="$(count_devl)"
  if [ "$DEVL_MAX" -gt 0 ] 2>/dev/null && [ "$cur" -ge "$DEVL_MAX" ]; then
    echo "已达 DEVL_MAX=$DEVL_MAX" >&2; return 1
  fi
  n="$(next_index)"
  tid="$(tab_with_room)"
  if [ -z "$tid" ]; then
    lab="dmt-dev$(next_tab_no)"
    pane="$(dmt_herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label "$lab" | jq -r '.result.root_pane.pane_id // empty')"
    [ -n "$pane" ] || { echo "ERROR: tab create 失败（$lab）" >&2; return 1; }
    echo "created tab $lab"
  elif [ "$(count_in_tab "$tid")" -eq 0 ]; then
    pane="$(dmt_herdr pane list --workspace "$HERDR_WORKSPACE_ID" 2>/dev/null \
      | jq -r --arg t "$tid" '.result.panes[]? | select(.tab_id==$t) | .pane_id' | head -1)"
    [ -n "$pane" ] || { echo "ERROR: $tid 内没有 pane" >&2; return 1; }
  else
    pane="$(dmt_herdr pane split "$(list_devl | awk -F'\t' -v t="$tid" '$3==t{print $2; exit}')" \
      --direction right --ratio 0.5 --cwd "$PWD" --no-focus | jq -r '.result.pane.pane_id // empty')"
    [ -n "$pane" ] || { echo "ERROR: pane split 失败（$tid）" >&2; return 1; }
  fi
  dmt_herdr pane rename "$pane" "dmt-devl$n" >/dev/null
  mkdir -p "$PWD/inbox/dmt-devl$n"
  start_devl "$pane" "dmt-devl$n"
  rebalance_tabs
  echo "added dmt-devl$n ($pane)"
}
remove_one() {
  local idx="$1" label pane st dirty
  [ -n "$idx" ] || { echo "用法: devl-pane.sh remove --index N" >&2; return 2; }
  label="dmt-devl$idx"
  pane="$(dmt_pane_by_label "$label" || true)"
  [ -n "$pane" ] || { echo "找不到 $label" >&2; return 1; }
  [ "$(count_devl)" -gt "$DEVL_MIN" ] || { echo "拒绝：n=$DEVL_MIN 是下限，不得再减" >&2; return 1; }
  st="$(dmt_pane_status "$pane")"
  if [ "$st" = "working" ] && [ "$FORCE" != 1 ]; then
    echo "拒绝：$label 仍在 working；先让它收口或加 --force" >&2; return 1
  fi
  if [ "$FORCE" != 1 ]; then
    dirty="$(git -C "$PWD" status --porcelain 2>/dev/null | head -1 || true)"
    [ -z "$dirty" ] || { echo "拒绝：主工作树有未提交改动（$dirty）；先收口或加 --force" >&2; return 1; }
    while IFS= read -r wt; do
      [ -n "$wt" ] || continue
      dirty="$(git -C "$wt" status --porcelain 2>/dev/null | head -1 || true)"
      [ -z "$dirty" ] || { echo "拒绝：worktree 有未提交改动：$wt；先收口或加 --force" >&2; return 1; }
    done < <(git -C "$PWD" worktree list --porcelain 2>/dev/null | awk '/^worktree /{print $2}')
  fi
  dmt_herdr pane close "$pane" >/dev/null
  sleep 1   # 等 layout 树收敛后再重排
  rebalance_tabs
  echo "closed $label ($pane)；inbox/$label/ 保留，收口后手工清理"
}

case "$CMD" in
  list)
    printf 'label\tpane\ttab\tstatus\n'
    list_devl
    echo "count=$(count_devl) min=$DEVL_MIN max=$DEVL_MAX per_tab=$DEVL_PER_TAB"
    ;;
  ensure-min)
    while [ "$(count_devl)" -lt "$DEVL_MIN" ]; do add_one || exit 1; done
    ;;
  add) add_one ;;
  rebalance) rebalance_tabs; echo "rebalanced $(count_devl) devl panes" ;;
  remove) remove_one "$INDEX" ;;
  adopt)
    echo "adopted devl panes:"
    list_devl
    ;;
  *) echo "unknown command: $CMD" >&2; exit 2 ;;
esac
