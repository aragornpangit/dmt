#!/usr/bin/env bash
# worktree.sh —— 实施单元的隔离工作区供给器。
#
# 为什么要有这个脚本：纪律要求「一个实施单元一个隔离 worktree（独立 index）+ 独立分支」，
# 但此前全仓没有任何东西真的创建 worktree，子代理又共享调用者的 cwd 和 index ——
# 并行派发时两个 de 会互相踩工作区和暂存区。本脚本把这条规则变成可执行步骤。
#
# 用法：
#   bash worktree.sh add <ticket> [--base <ref>] [--branch <name>] [--root <dir>]
#   bash worktree.sh list [--root <dir>]
#   bash worktree.sh remove <ticket> [--delete-branch] [--force] [--root <dir>]
#
# 约定：
#   worktree 路径 = <主工作树>/.worktrees/<ticket>
#   分支名       = dmt/<ticket>（可用 --branch 覆盖）
#   台账         = <主工作树>/.dmt/worktrees.tsv（ticket / branch / path / base / created）
#   .worktrees/ 与 .dmt/ 写入 <git-common-dir>/info/exclude，保持 git status 干净（不改 .gitignore）
#
# add 成功输出两行机读字段：WORKTREE=<绝对路径>、BRANCH=<分支名>，供派发 prompt 直接引用。
# remove 默认保留分支（评审要基于该分支的 commit），--delete-branch 才删。
set -eu

DIR="$(cd -P "$(dirname "$0")" && pwd -P)"
. "$DIR/lib-dmt.sh"

usage() {
  sed -n '3,25p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 2
}
die() { echo "worktree: $*" >&2; exit 2; }

CMD="${1:-}"; [ -n "$CMD" ] || usage; shift || true
TICKET=""; BASE=""; BRANCH=""; ROOT=""; DELETE_BRANCH=0; FORCE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --base) BASE="${2:?missing ref}"; shift ;;
    --branch) BRANCH="${2:?missing name}"; shift ;;
    --root) ROOT="${2:?missing dir}"; shift ;;
    --delete-branch) DELETE_BRANCH=1 ;;
    --force|-f) FORCE=1 ;;
    -*) usage ;;
    *) [ -z "$TICKET" ] && TICKET="$1" || usage ;;
  esac
  shift
done

ROOT="${ROOT:-$(dmt_root)}"
ROOT="$(cd -P "$ROOT" 2>/dev/null && pwd -P)" || die "主工作树不存在"
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || die "不是 git 仓库：$ROOT"

GIT_COMMON="$(git -C "$ROOT" rev-parse --path-format=absolute --git-common-dir)"
WT_BASE="$ROOT/.worktrees"
LEDGER_DIR="$ROOT/.dmt"
LEDGER="$LEDGER_DIR/worktrees.tsv"

ensure_exclude() {
  local f="$GIT_COMMON/info/exclude"
  mkdir -p "$(dirname "$f")" 2>/dev/null || true
  [ -f "$f" ] || : >"$f"
  local k
  for k in ".worktrees/" ".dmt/"; do
    grep -qxF "$k" "$f" 2>/dev/null || printf '%s\n' "$k" >>"$f"
  done
}

valid_ticket() {
  case "$1" in
    ""|.|..|*/*|*\\*) return 1 ;;
  esac
  printf '%s' "$1" | grep -qE '^[A-Za-z0-9][A-Za-z0-9._-]*$'
}

case "$CMD" in
  add)
    valid_ticket "$TICKET" || die "ticket 名非法（只允许字母数字 . _ -，且不能含路径分隔符）：$TICKET"
    BRANCH="${BRANCH:-dmt/$TICKET}"
    WT="$WT_BASE/$TICKET"
    if [ -e "$WT" ]; then die "worktree 已存在：$WT（先 remove 或换 ticket）"; fi
    if git -C "$ROOT" show-ref --verify --quiet "refs/heads/$BRANCH"; then
      die "分支已存在：$BRANCH（评审需要保留分支，请换 ticket 或先 --delete-branch 清理）"
    fi
    if [ -z "$BASE" ]; then
      BASE="$(git -C "$ROOT" rev-parse --verify HEAD 2>/dev/null)" || die "仓库还没有 commit，无法建 worktree"
    fi
    git -C "$ROOT" rev-parse --verify "$BASE^{commit}" >/dev/null 2>&1 || die "base 不存在：$BASE"
    mkdir -p "$WT_BASE"
    ensure_exclude
    git -C "$ROOT" worktree add -b "$BRANCH" "$WT" "$BASE" >/dev/null || die "git worktree add 失败"
    mkdir -p "$LEDGER_DIR"
    [ -f "$LEDGER" ] || printf 'ticket\tbranch\tpath\tbase\tcreated\n' >"$LEDGER"
    printf '%s\t%s\t%s\t%s\t%s\n' "$TICKET" "$BRANCH" "$WT" "$BASE" "$(date +%Y-%m-%dT%H:%M:%S)" >>"$LEDGER"
    echo "WORKTREE=$WT"
    echo "BRANCH=$BRANCH"
    ;;
  list)
    if [ ! -f "$LEDGER" ]; then echo "（无台账：$LEDGER）"; exit 0; fi
    printf 'TICKET\tBRANCH\tSTATE\tPATH\n'
    tail -n +2 "$LEDGER" | while IFS=$'\t' read -r t b p base created; do
      [ -n "${t:-}" ] || continue
      if [ -d "$p" ]; then st=present; else st=missing; fi
      printf '%s\t%s\t%s\t%s\n' "$t" "$b" "$st" "$p"
    done
    ;;
  remove)
    valid_ticket "$TICKET" || die "ticket 名非法：$TICKET"
    WT="$WT_BASE/$TICKET"
    [ -d "$WT" ] || die "worktree 不存在：$WT"
    BRANCH="$(awk -F'\t' -v t="$TICKET" 'NR>1 && $1==t {print $2}' "$LEDGER" 2>/dev/null | tail -1 || true)"
    BRANCH="${BRANCH:-dmt/$TICKET}"
    if [ "$FORCE" != 1 ] && [ -n "$(git -C "$WT" status --porcelain 2>/dev/null)" ]; then
      die "工作区有未提交改动：$WT（确认无用后加 --force）"
    fi
    if [ "$FORCE" = 1 ]; then
      git -C "$ROOT" worktree remove --force "$WT"
    else
      git -C "$ROOT" worktree remove "$WT"
    fi
    if [ -f "$LEDGER" ]; then
      tmp="$(mktemp)"; awk -F'\t' -v t="$TICKET" 'NR==1 || $1!=t' "$LEDGER" >"$tmp"; mv "$tmp" "$LEDGER"
    fi
    if [ "$DELETE_BRANCH" = 1 ]; then
      git -C "$ROOT" branch -D "$BRANCH" >/dev/null 2>&1 || echo "WARN 分支未删除（可能已被检出）：$BRANCH" >&2
    fi
    echo "REMOVED=$WT"
    [ "$DELETE_BRANCH" = 1 ] && echo "BRANCH_DELETED=$BRANCH" || echo "BRANCH_KEPT=$BRANCH"
    ;;
  *) usage ;;
esac
