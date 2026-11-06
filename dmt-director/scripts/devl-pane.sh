#!/usr/bin/env bash
# devm 用：管理 dmt-dev tab 内 devl pane 的生命周期（补位 / 扩容 / 回收 / 收养）
# 用法：bash devl-pane.sh <list|ensure-min|add|remove|adopt> [--index N] [--force]
#   需要环境变量 HERDR_ENV=1、HERDR_PANE_ID、HERDR_WORKSPACE_ID（在 devm pane 内执行）
#   常量：DEVL_MIN（默认 2）、DEVL_MAX（默认 0=不设策略上限）、MIN_DEVL_ROWS（默认 14）
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

DEVL_MIN="${DEVL_MIN:-2}"
DEVL_MAX="${DEVL_MAX:-0}"
MIN_DEVL_ROWS="${MIN_DEVL_ROWS:-14}"
HARNESS="$(dmt_harness_name "${DMT_HARNESS:-}")" || exit 2

tab_id() { dmt_herdr pane get "$HERDR_PANE_ID" 2>/dev/null | jq -r '.result.pane.tab_id // empty'; }
TAB_ID="$(tab_id)"
[ -n "$TAB_ID" ] || { echo "ERROR: 拿不到 devm 当前 tab_id" >&2; exit 4; }

list_devl() {
  dmt_herdr pane list --workspace "$HERDR_WORKSPACE_ID" 2>/dev/null \
    | jq -r --arg t "$TAB_ID" '.result.panes[]? | select(.tab_id==$t) | select((.label // "") | test("^devl[0-9]+$")) | [.label, .pane_id, (.agent_status // "unknown")] | @tsv' \
    | sort -t$'\t' -k1,1V
}
count_devl() { list_devl | sed '/^$/d' | wc -l | tr -d ' '; }
next_index() {
  local used i
  used="$(list_devl | cut -f1 | sed 's/^devl//' | sort -n)"
  i=1
  while printf '%s\n' "$used" | grep -qx "$i"; do i=$((i+1)); done
  printf '%s' "$i"
}
tab_height() {
  dmt_herdr pane layout --pane "$HERDR_PANE_ID" 2>/dev/null | jq -r '.result.layout.area.height // 0'
}
geom_cap() {
  local h; h="$(tab_height)"
  case "$h" in ''|*[!0-9]*) echo 99; return ;; esac
  [ "$h" -gt 0 ] || { echo 99; return; }
  echo $((h / MIN_DEVL_ROWS))
}
bottom_devl_pane() {
  local y id best="" besty=-1 ids
  ids="$(list_devl | cut -f2)"
  [ -n "$ids" ] || { printf ''; return; }
  while IFS=$'\t' read -r y id; do
    [ -n "$id" ] || continue
    printf '%s\n' "$ids" | grep -qx "$id" || continue
    if [ "$y" -gt "$besty" ] 2>/dev/null; then besty="$y"; best="$id"; fi
  done < <(dmt_herdr pane layout --pane "$HERDR_PANE_ID" 2>/dev/null | jq -r '.result.layout.panes[]? | [.rect.y, .pane_id] | @tsv')
  printf '%s' "$best"
}
# 把右槽所有 devl pane 调成等高：从最底层 split 往上，逐个把 ratio 设成 1/(n-i)。
# 背景：split 只切「当前 pane」，不重排祖先；不加这一步，第 3 个队长会只剩 6~8 行。
rebalance_devl_column() {
  local json cmds p dir amt
  json="$(dmt_herdr pane layout --pane "$HERDR_PANE_ID" 2>/dev/null)" || return 0
  [ -n "$json" ] || return 0
  cmds="$(printf '%s' "$json" | python3 -c "$(cat <<'PY'
import json, sys
try:
    layout = json.load(sys.stdin)["result"]["layout"]
except Exception:
    sys.exit(0)
devm_id = sys.argv[1]
panes = layout.get("panes") or []
splits = layout.get("splits") or []
devm = next((p for p in panes if p.get("pane_id") == devm_id), None)
if not devm:
    sys.exit(0)
dx = devm["rect"]["x"] + devm["rect"]["width"]
col = [p for p in panes if p.get("pane_id") != devm_id and p["rect"]["x"] >= dx]
col.sort(key=lambda p: p["rect"]["y"])
n = len(col)
if n < 2:
    sys.exit(0)
vs = [s for s in splits if s.get("direction") == "down" and s["rect"]["x"] >= dx]
vs.sort(key=lambda s: s["rect"]["y"])
for i in range(len(vs) - 1, -1, -1):
    s = vs[i]
    target = 1.0 / (n - i)
    delta = target - s.get("ratio", 0)
    if abs(delta) < 0.01:
        continue
    top = min(col, key=lambda p: abs(p["rect"]["y"] - s["rect"]["y"]))
    lower = [p for p in col if p["rect"]["y"] > top["rect"]["y"]]
    if not lower:
        continue
    nxt = min(lower, key=lambda p: p["rect"]["y"])
    if delta > 0:
        print(f'{top["pane_id"]}\tdown\t{delta:.3f}')
    else:
        print(f'{nxt["pane_id"]}\tup\t{-delta:.3f}')
PY
)" "$HERDR_PANE_ID")"
  [ -n "$cmds" ] || return 0
  while IFS=$'\t' read -r p dir amt; do
    [ -n "$p" ] || continue
    dmt_herdr pane resize --pane "$p" --direction "$dir" --amount "$amt" >/dev/null 2>&1 || true
  done <<< "$cmds"
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
  local cur cap n target dir ratio pane
  cur="$(count_devl)"
  cap="$(geom_cap)"
  if [ "$DEVL_MAX" -gt 0 ] 2>/dev/null && [ "$cur" -ge "$DEVL_MAX" ]; then
    echo "已达 DEVL_MAX=$DEVL_MAX" >&2; return 1
  fi
  if [ "$cur" -ge "$cap" ]; then
    echo "已达几何上限 floor(H/$MIN_DEVL_ROWS)=$cap（H=$(tab_height)）；请开 dmt-dev2 tab（由 director 建）" >&2; return 1
  fi
  n="$(next_index)"
  if [ "$cur" -eq 0 ]; then
    target="$HERDR_PANE_ID"; dir="right"; ratio="0.5"
  else
    target="$(bottom_devl_pane)"; dir="down"; ratio="0.5"
  fi
  [ -n "$target" ] || { echo "ERROR: 找不到 split 目标" >&2; return 1; }
  pane="$(dmt_herdr pane split "$target" --direction "$dir" --ratio "$ratio" --cwd "$PWD" --no-focus | jq -r '.result.pane.pane_id // empty')"
  [ -n "$pane" ] || { echo "ERROR: pane split 失败（devl$n）" >&2; return 1; }
  dmt_herdr pane rename "$pane" "devl$n" >/dev/null
  mkdir -p "$PWD/inbox/devl$n"
  start_devl "$pane" "devl$n"
  rebalance_devl_column
  echo "added devl$n ($pane)"
}
remove_one() {
  local idx="$1" label pane st wt dirty
  [ -n "$idx" ] || { echo "用法: devl-pane.sh remove --index N" >&2; return 2; }
  label="devl$idx"
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
  sleep 1   # 等 layout 树收敛后再重排，否则会按旧的三 pane 比例算
  rebalance_devl_column
  echo "closed $label ($pane)；inbox/devl$idx/ 保留，收口后手工清理"
}

case "$CMD" in
  list)
    printf 'label\tpane\tstatus\n'
    list_devl
    echo "count=$(count_devl) min=$DEVL_MIN max=$DEVL_MAX cap=$(geom_cap) height=$(tab_height)"
    ;;
  ensure-min)
    while [ "$(count_devl)" -lt "$DEVL_MIN" ]; do add_one || exit 1; done
    ;;
  add) add_one ;;
  rebalance) rebalance_devl_column; echo "rebalanced $(count_devl) devl panes" ;;
  remove) remove_one "$INDEX" ;;
  adopt)
    echo "adopted devl panes in tab $TAB_ID:"
    list_devl
    ;;
  *) echo "unknown command: $CMD" >&2; exit 2 ;;
esac
