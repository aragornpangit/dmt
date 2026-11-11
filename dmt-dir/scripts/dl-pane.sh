#!/usr/bin/env bash
# 可选 herdr 适配器：管理按需派生、完成即回收的协调者 pane（仅显式启用完整团队适配器时使用）。
# 布局：dmt-dm 左 30%，dmt-dl1 右上、dmt-dl2 右下；三者同处 tab dmt-dm。
# 用法：bash dl-pane.sh <list|ensure-min|add|remove|rebalance|adopt> [--index N] [--force]
#   需要环境变量 HERDR_ENV=1、HERDR_PANE_ID、HERDR_WORKSPACE_ID（在 dmt-dm pane 内执行）
#   常量：DL_MIN（默认 2）、DL_MAX（默认 2）、DM_WIDTH（默认 0.3）
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
[ -z "$missing" ] || { echo "缺少环境变量:$missing（在 dmt-dm pane 内执行本脚本）" >&2; exit 2; }

. "$(cd -P "$(dirname "$0")" && pwd -P)/lib-dmt.sh"

DL_MIN="${DL_MIN:-2}"
DL_MAX="${DL_MAX:-2}"
DM_WIDTH="${DM_WIDTH:-0.3}"
HARNESS="$(dmt_harness_name "${DMT_HARNESS:-}")" || exit 2

list_dl() {
  dmt_herdr pane list --workspace "$HERDR_WORKSPACE_ID" 2>/dev/null \
    | jq -r '.result.panes[]? | select((.label // "") | test("^dmt-dl[0-9]+$")) | [.label, .pane_id, .tab_id, (.agent_status // "unknown")] | @tsv' \
    | sort -t$'\t' -k1,1V
}
count_dl() { list_dl | sed '/^$/d' | wc -l | tr -d ' '; }
next_index() {
  local used i
  used="$(list_dl | cut -f1 | sed 's/^dmt-dl//' | sort -n)"
  i=1
  while printf '%s\n' "$used" | grep -qx "$i"; do i=$((i+1)); done
  printf '%s' "$i"
}
pane_for() { dmt_pane_by_label "$1" || true; }

# 重排：dmt-dm 占 30% 宽，dmt-dl1 占右半区 50% 高（与 setup-team.sh 初始布局一致）。
rebalance() {
  local any
  any="$(list_dl | head -1 | cut -f2)"
  [ -n "$any" ] || return 0
  dmt_herdr pane layout --pane "$any" 2>/dev/null | python3 -c "$(cat <<'PY'
import json, sys
try:
    layout = json.load(sys.stdin)["result"]["layout"]
except Exception:
    sys.exit(0)
panes = layout.get("panes") or []
area = layout.get("area") or {}
w, h = area.get("width") or 0, area.get("height") or 0
if not w or not h:
    sys.exit(0)
by = {p.get("label"): p for p in panes}
dm, dl1, dl2 = by.get("dmt-dm"), by.get("dmt-dl1"), by.get("dmt-dl2")
if not dm or not dl1 or not dl2:
    sys.exit(0)
cur_w = dm["rect"]["width"] / w
d_w = 0.3 - cur_w
if abs(d_w) >= 0.01:
    print(f'{dm["pane_id"]}\t{"right" if d_w > 0 else "left"}\t{abs(d_w):.3f}')
cur_h = dl1["rect"]["height"] / h
d_h = 0.5 - cur_h
if abs(d_h) >= 0.01:
    print(f'{dl1["pane_id"]}\t{"down" if d_h > 0 else "up"}\t{abs(d_h):.3f}')
PY
)" 2>/dev/null | while IFS=$'\t' read -r p dir amt; do
    [ -n "${p:-}" ] || continue
    dmt_herdr pane resize --pane "$p" --direction "$dir" --amount "$amt" >/dev/null 2>&1 || true
  done
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
start_dl() {
  local pane="$1" role="$2" st prompt first=0
  dmt_start_has_first_prompt "$HARNESS" && first=1
  prompt="$(dmt_skill_prompt "$HARNESS" dmt-dl '' "$role")"
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
    dmt_herdr pane send-text "$pane" "$(dmt_skill_cmd "$HARNESS" dmt-dl)"
    dmt_herdr pane send-keys "$pane" enter
    sleep 0.6
    dmt_herdr pane send-keys "$pane" enter
  fi
  dmt_wait_ready "$pane" 60 || true
  verify_auto_mode "$pane"
}
add_one() {
  local cur n base pane label
  cur="$(count_dl)"
  if [ "$DL_MAX" -gt 0 ] 2>/dev/null && [ "$cur" -ge "$DL_MAX" ]; then
    echo "已达 DL_MAX=$DL_MAX（可选适配器容量上限）" >&2; return 1
  fi
  n="$(next_index)"
  label="dmt-dl$n"
  if [ "$n" = 1 ]; then
    base="$(pane_for dmt-dm)"
    [ -n "$base" ] || { echo "ERROR: 找不到 dmt-dm pane" >&2; return 1; }
    pane="$(dmt_herdr pane split "$base" --direction right --ratio "$DM_WIDTH" --cwd "$PWD" --no-focus | jq -r '.result.pane.pane_id // empty')"
  else
    base="$(pane_for dmt-dl1)"
    [ -n "$base" ] || { echo "ERROR: 找不到 dmt-dl1 pane，无法切出 $label" >&2; return 1; }
    pane="$(dmt_herdr pane split "$base" --direction down --ratio 0.5 --cwd "$PWD" --no-focus | jq -r '.result.pane.pane_id // empty')"
  fi
  [ -n "$pane" ] || { echo "ERROR: pane split 失败（$label）" >&2; return 1; }
  dmt_herdr pane rename "$pane" "$label" >/dev/null
  mkdir -p "$PWD/inbox/$label"
  start_dl "$pane" "$label"
  sleep 1
  rebalance
  echo "added $label ($pane)"
}
remove_one() {
  local idx="$1" label pane st dirty
  [ -n "$idx" ] || { echo "用法: dl-pane.sh remove --index N" >&2; return 2; }
  label="dmt-dl$idx"
  pane="$(pane_for "$label")"
  [ -n "$pane" ] || { echo "找不到 $label" >&2; return 1; }
  [ "$(count_dl)" -gt "$DL_MIN" ] || { echo "拒绝：n=$DL_MIN 是下限；如需回收到 0 请设 DL_MIN=0" >&2; return 1; }
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
  sleep 1
  rebalance
  echo "closed $label ($pane)；inbox/$label/ 保留，收口后手工清理"
}

case "$CMD" in
  list)
    printf 'label\tpane\ttab\tstatus\n'
    list_dl
    echo "count=$(count_dl) min=$DL_MIN max=$DL_MAX"
    ;;
  ensure-min)
    while [ "$(count_dl)" -lt "$DL_MIN" ]; do add_one || exit 1; done
    ;;
  add) add_one ;;
  rebalance) rebalance; echo "rebalanced $(count_dl) dmt-dl panes" ;;
  remove) remove_one "$INDEX" ;;
  adopt)
    echo "adopted dmt-dl panes:"
    list_dl
    ;;
  *) echo "unknown command: $CMD" >&2; exit 2 ;;
esac
