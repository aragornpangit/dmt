#!/usr/bin/env bash
# devm 用（merge 与 push 归 devm）：显式路径提交并推送到 GitLab + GitHub（每 ticket 一推 / 每小时巡检）
# 用法：bash publish.sh -m <message> [--auto] [--no-push] [--remotes "gitlab origin"] -- <paths...>
#   --auto 由 git status --porcelain 枚举改动路径（仍是显式路径，不用 git add -A）
set -eu
MSG=""; AUTO=0; PUSH=1; REMOTES="gitlab origin"; PATHS=""
while [ $# -gt 0 ]; do
  case "$1" in
    -m) MSG="${2:?missing message}"; shift 2 ;;
    --auto) AUTO=1; shift ;;
    --no-push) PUSH=0; shift ;;
    --remotes) REMOTES="${2:?missing remotes}"; shift 2 ;;
    --) shift; PATHS="$*"; break ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done
[ -n "$MSG" ] || { echo "missing -m <message>" >&2; exit 2; }

if [ "$AUTO" = 1 ]; then
  PATHS=""
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    p="${line:3}"
    # rename 行（R old -> new）取新路径
    case "$p" in *" -> "*) p="${p##* -> }" ;; esac
    # 含空格 / 引号的路径跳过并告警（避免按空格切分吃错路径）
    case "$p" in
      *\"*) echo "WARN: 跳过含引号的路径: $p" >&2; continue ;;
      *' '*) echo "WARN: 跳过含空格的路径: $p" >&2; continue ;;
    esac
    PATHS="$PATHS$p "
  done < <(git status --porcelain)
fi
[ -n "${PATHS// /}" ] || { echo "nothing to commit"; exit 0; }

# 显式列路径：先 add 指定路径，再 commit 这些路径
# shellcheck disable=SC2086
git add -- $PATHS
# shellcheck disable=SC2086
git commit -m "$MSG" -- $PATHS

if [ "$PUSH" = 1 ]; then
  branch="$(git rev-parse --abbrev-ref HEAD)"
  for r in $REMOTES; do
    git push "$r" "HEAD:${branch}"
  done
fi
