#!/usr/bin/env bash
# director 用：给自己正名，建 pm / devm / anam 三个 pane 并代启动 cbc（幂等）
# 用法：bash setup-team.sh [--dry-run] [--no-start]
#   需要环境变量 HERDR_ENV=1、HERDR_PANE_ID、HERDR_TAB_ID、HERDR_WORKSPACE_ID
set -eu
DRY=0; START=1
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --no-start) START=0 ;;
    *) echo "unknown arg: $a" >&2; exit 2 ;;
  esac
done
: "${HERDR_ENV:?must run inside herdr (HERDR_ENV=1)}"
: "${HERDR_PANE_ID:?missing HERDR_PANE_ID}"
: "${HERDR_TAB_ID:?missing HERDR_TAB_ID}"
: "${HERDR_WORKSPACE_ID:?missing HERDR_WORKSPACE_ID}"

h() { if [ "$DRY" = 1 ]; then echo "+ $*" >&2; else "$@"; fi; }
pane_by_label() {
  HERDR_ENV=1 herdr pane list --workspace "$HERDR_WORKSPACE_ID" \
    | jq -r --arg l "$1" '.result.panes[] | select(.label==$l) | .pane_id' | head -1
}
ensure_started() {
  local pane="$1" skill="$2"
  [ "$START" = 1 ] || { echo "skip start: $pane"; return 0; }
  h env HERDR_ENV=1 herdr pane send-text "$pane" 'codebuddy --permission-mode auto'
  h env HERDR_ENV=1 herdr pane send-keys "$pane" enter
  h env HERDR_ENV=1 herdr pane wait-output "$pane" --source visible --match 'auto mode on' --timeout 60000
  h env HERDR_ENV=1 herdr pane send-text "$pane" "$skill"
  h env HERDR_ENV=1 herdr pane send-keys "$pane" enter
}

# 1) 自己正名：先 tab 后 pane
h env HERDR_ENV=1 herdr tab rename "$HERDR_TAB_ID" director
h env HERDR_ENV=1 herdr pane rename "$HERDR_PANE_ID" director

# 2) pm：在 director pane 右侧 split
pm="$(pane_by_label pm || true)"
if [ -z "$pm" ]; then
  pm="$(HERDR_ENV=1 herdr pane split "$HERDR_PANE_ID" --direction right --cwd "$PWD" --no-focus | jq -r '.result.pane.pane_id')"
  h env HERDR_ENV=1 herdr pane rename "$pm" pm
fi
ensure_started "$pm" '/dmt-pm'

# 3) devm / anam：各自建 tab
for role in devm anam; do
  p="$(pane_by_label "$role" || true)"
  if [ -z "$p" ]; then
    p="$(HERDR_ENV=1 herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label "$role" | jq -r '.result.root_pane.pane_id')"
    h env HERDR_ENV=1 herdr pane rename "$p" "$role"
  fi
  case "$role" in devm) skill='/dmt-dm' ;; anam) skill='/dmt-am' ;; esac
  ensure_started "$p" "$skill"
done
echo "team ready: director / pm / devm / anam"
