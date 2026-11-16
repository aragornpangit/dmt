#!/usr/bin/env bash
# 回收 orca-launch.sh 派生的 Orca 终端（按台账认领，不碰别人的终端）。
# 用法：bash orca-reap.sh [--role <name>] [--dry-run] [--list] [--root <项目根>]
#   --role   只回收该角色派生的终端
#   --root   台账所在项目根（缺省取当前目录所在仓库的主工作树根）
#   --dry-run / --list  只列出，不关闭
# 台账：<项目根>/.dmt/orca-terminals.tsv
#   （handle / role / harness / worktree / 创建时间 / pane_key）
#   pane_key = "<tabId>:<leafId>"；旧台账只有前 5 列，读取时按 "-" 补齐，不丢行。
# 已经不在运行的 handle 会从台账静默清掉（终端被手动关掉或进程已退）。
# 退出码：0 全部回收或无事可做；4 有终端关闭失败。
set -eu
ROLE=""; DRY=0; LIST=0; ROOT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --role) ROLE="${2:?missing role}"; shift ;;
    --root) ROOT="${2:?missing project root}"; shift ;;
    --dry-run) DRY=1 ;;
    --list) LIST=1 ;;
    *) echo "unknown arg: $1（只认 --role / --root / --dry-run / --list）" >&2; exit 2 ;;
  esac
  shift
done

if [ -z "$ROOT" ]; then
  ROOT="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null | sed 's#/\.git$##' || pwd)"
fi
LEDGER="$ROOT/.dmt/orca-terminals.tsv"
[ -f "$LEDGER" ] || { echo "orca-reap: 无派生台账 $LEDGER（没有 dmt 派生的终端）"; exit 0; }

command -v orca >/dev/null 2>&1 || { echo "orca-reap: 本机没有 orca CLI" >&2; exit 3; }
live="$(orca terminal list --json 2>&1)" || { echo "orca-reap: terminal list 失败：$live" >&2; exit 4; }
live_handles="$(printf '%s' "$live" | python3 -c '
import json,sys
d=json.load(sys.stdin); r=d.get("result",d)
print("\n".join(t.get("handle","") for t in (r.get("terminals") or [])))
' 2>/dev/null || true)"

tmp="$(mktemp)"; trap 'rm -f "$tmp"' EXIT
n=0; fail=0; kept=0
while IFS=$'\t' read -r handle role harness wt ts pane_key; do
  [ -n "$handle" ] || continue
  pane_key="${pane_key:--}"
  if ! printf '%s\n' "$live_handles" | grep -qx "$handle"; then
    continue   # 终端已不存在：从台账清掉，不计数
  fi
  if [ -n "$ROLE" ] && [ "$role" != "$ROLE" ]; then
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$handle" "$role" "$harness" "$wt" "$ts" "$pane_key" >> "$tmp"; kept=$((kept+1))
    continue
  fi
  n=$((n+1))
  if [ "$LIST" = 1 ] || [ "$DRY" = 1 ]; then
    echo "would close $handle  ${role}/${harness}  $wt  pane_key=$pane_key"
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$handle" "$role" "$harness" "$wt" "$ts" "$pane_key" >> "$tmp"; kept=$((kept+1))
    continue
  fi
  if orca terminal close --terminal "$handle" >/dev/null 2>&1; then
    echo "closed $handle  ${role}/${harness}  pane_key=$pane_key"
  else
    echo "FAILED to close $handle  ${role}/${harness}" >&2
    fail=$((fail+1))
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$handle" "$role" "$harness" "$wt" "$ts" "$pane_key" >> "$tmp"; kept=$((kept+1))
  fi
done < "$LEDGER"
mv "$tmp" "$LEDGER"
[ "$n" -gt 0 ] || echo "orca-reap: 无匹配的派生终端（role=${ROLE:-any}）"
[ "$kept" -gt 0 ] || rm -f "$LEDGER"
[ "$fail" = 0 ] || exit 4
