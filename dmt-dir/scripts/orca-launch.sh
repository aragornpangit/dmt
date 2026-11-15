#!/usr/bin/env bash
# 在 Orca 里按矩阵 start_cmd（yolo 档）起一个 harness 终端，并登记到派生台账供回收。
# 用法：bash orca-launch.sh <harness> [--worktree <selector>] [--role <name>] [--dry-run]
#   harness     pi / codebuddy / claude / codex / hermes / opencode（矩阵 harnesses: 段）
#   --worktree  缺省 path:$PWD；也可传 id: / name: / branch: 等 orca 选择器
#   --role      角色名，写进台账（缺省用 harness 名）
#   --dry-run   只打印将执行的命令，不创建终端
# 为什么不用终端标题认领：harness 起来后会自己改标题（实测 pi 把标签改成「π - proj」），
# 所以所有权记在台账 <项目根>/.dmt/orca-terminals.tsv，由 orca-reap.sh 消费。
# 生命周期：谁派生谁回收；工作完成（或失败、放弃）后跑 orca-reap.sh。
set -eu
HARNESS="${1:?usage: orca-launch.sh <harness> [--worktree <sel>] [--role <name>] [--dry-run]}"
shift || true
WT=""; ROLE=""; DRY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --worktree) WT="${2:?missing worktree selector}"; shift ;;
    --role) ROLE="${2:?missing role}"; shift ;;
    --dry-run) DRY=1 ;;
    *) echo "unknown arg: $1（只认 --worktree / --role / --dry-run）" >&2; exit 2 ;;
  esac
  shift
done

DIR="$(cd -P "$(dirname "$0")" && pwd -P)"
MATRIX="$DIR/harness-matrix.sh"
[ -x "$MATRIX" ] || { echo "orca-launch: 缺 harness-matrix.sh" >&2; exit 3; }

if ! bash "$MATRIX" list | grep -qx "$HARNESS"; then
  echo "orca-launch: 未知 harness '$HARNESS'（可选：$(bash "$MATRIX" list | tr '\n' ' ')）" >&2
  exit 2
fi
command -v orca >/dev/null 2>&1 || { echo "orca-launch: 本机没有 orca CLI" >&2; exit 3; }

CMD="$(bash "$MATRIX" get "$HARNESS" start_cmd)"
[ -n "$CMD" ] || { echo "orca-launch: 矩阵缺 $HARNESS 的 start_cmd" >&2; exit 3; }
# start_cmd 里的 $DMT_SCRIPTS_DIR 在此展开成绝对路径（终端里的 shell 未必带该变量）
CMD="${CMD//\$DMT_SCRIPTS_DIR/$DIR}"
ROLE="${ROLE:-$HARNESS}"
WT="${WT:-path:$PWD}"

if [ "$DRY" = 1 ]; then
  echo "+ orca terminal create --worktree $WT --title dmt:$ROLE:$HARNESS --command '$CMD' --json"
  exit 0
fi

out="$(orca terminal create --worktree "$WT" --title "dmt:${ROLE}:${HARNESS}" --command "$CMD" --json 2>&1)" || {
  echo "orca-launch: 创建终端失败：$out" >&2; exit 4; }
handle="$(printf '%s' "$out" | python3 -c 'import json,sys; d=json.load(sys.stdin); r=d.get("result",{}); t=r.get("terminal") or r; print(t.get("handle",""))' 2>/dev/null || true)"
if [ -z "$handle" ]; then
  echo "orca-launch: 已创建但没解析到 handle，原始回执：$out" >&2
  exit 5
fi

# 台账落在项目根，便于跨会话回收；不是 git 产物，建议加入项目 .gitignore
ROOT="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null | sed 's#/\.git$##' || pwd)"
[ -n "$ROOT" ] || ROOT="$PWD"
mkdir -p "$ROOT/.dmt"
printf '%s\t%s\t%s\t%s\t%s\n' "$handle" "$ROLE" "$HARNESS" "$WT" "$(date +%s)" >> "$ROOT/.dmt/orca-terminals.tsv"

echo "$handle"
echo "已登记 $ROOT/.dmt/orca-terminals.tsv —— 完成后由你回收：bash $DIR/orca-reap.sh --role $ROLE" >&2
