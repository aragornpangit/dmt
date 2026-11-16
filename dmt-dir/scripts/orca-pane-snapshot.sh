#!/usr/bin/env bash
# orca-pane-snapshot.sh —— Orca 终端巡检快照（建议 #11 的落地件）
#
# 为什么需要：`agentIdentity` 会滞后、handle 会随 pane 重启漂移，而这些都是**静默发生**的。
# 事后想回答"当时那个 pane 到底是谁"，只有快照能作证。
#
# 落点：`<项目根>/.dmt/orca-panes-<YYYYmmdd-HHMMSS>.json`（原始）＋ 同名 `.tsv`（人读）
#   · `.dmt/` 已在项目 .gitignore 内（运行时产物，不入库）
#   · 项目根由 `git rev-parse --git-common-dir` 推导，不依赖 CWD
#
# 用法：
#   bash orca-pane-snapshot.sh             # 落一份快照并打印一行摘要
#   bash orca-pane-snapshot.sh --print     # 只打印不落盘
#   bash orca-pane-snapshot.sh --root DIR  # 指定项目根（默认按 git 推导）
#
# rc：0=成功｜1=orca/jq 不可用｜2=无终端｜5=写盘失败
set -u

PRINT=0
ROOT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --print) PRINT=1; shift ;;
    --root) ROOT="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

command -v orca >/dev/null 2>&1 || { echo "orca-pane-snapshot: orca 不在 PATH" >&2; exit 1; }
command -v jq   >/dev/null 2>&1 || { echo "orca-pane-snapshot: jq 不在 PATH" >&2; exit 1; }

raw="$(orca terminal list --json 2>/dev/null)" || { echo "orca-pane-snapshot: terminal list 失败" >&2; exit 1; }
n="$(printf '%s' "$raw" | jq -r '.result.terminals | length' 2>/dev/null || echo 0)"
[ "${n:-0}" -gt 0 ] 2>/dev/null || { echo "orca-pane-snapshot: 无终端" >&2; exit 2; }

# 人读表：handle / pane_key(tabId:leafId) / identity / connected / title
tsv="$(printf '%s' "$raw" | jq -r '.result.terminals[]
  | [(.handle // "-"), ((.tabId // "-") + ":" + (.leafId // "-")), (.agentIdentity // "none"),
     ((.connected // false) | tostring), (.title // "")]
  | @tsv' 2>/dev/null)"

if [ "$PRINT" = 1 ]; then
  printf 'handle\tpane_key\tidentity\tconnected\ttitle\n'
  printf '%s\n' "$tsv"
  echo "terminals=$n（未落盘，--print）" >&2
  exit 0
fi

if [ -z "$ROOT" ]; then
  ROOT="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null | sed 's#/\.git$##')"
fi
[ -n "$ROOT" ] || ROOT="$PWD"
mkdir -p "$ROOT/.dmt" || { echo "orca-pane-snapshot: 无法创建 $ROOT/.dmt" >&2; exit 5; }

ts="$(date +%Y%m%d-%H%M%S)"
jf="$ROOT/.dmt/orca-panes-$ts.json"
tf="$ROOT/.dmt/orca-panes-$ts.tsv"
printf '%s\n' "$raw" > "$jf" || exit 5
{ printf 'handle\tpane_key\tidentity\tconnected\ttitle\n'; printf '%s\n' "$tsv"; } > "$tf" || exit 5

orphans="$(printf '%s\n' "$tsv" | awk -F'\t' '$3=="none"' | wc -l)"
echo "orca-pane-snapshot: terminals=$n orphans=$orphans -> $jf"
exit 0
