#!/usr/bin/env bash
# runtime-detect.sh —— 判定当前会话的 harness 运行平台（harness-runtime-platform）
#
# 与 harness-detect.sh 正交：harness-detect 答「我是哪个 agent CLI」，本脚本答
# 「harness 跑在哪层运行平台上」。两者不是同一根轴，不得合并成单一枚举。
# 术语：harness = pi / cbc / claudecode / codex-cli / opencode（矩阵 harnesses:）；
#       运行平台 = runtimes:(herdr) + ades:(orca / t3code)，矩阵各成员带 kind。
#
# 用法：bash runtime-detect.sh [--explain]
# 输出：stdout 一行 herdr|orca|t3code|none|unknown
# rc：  0 = 已判定（none 也是正常结果，表示裸跑无运行平台）
#       1 = unknown（同时命中多个不同运行平台，fail-closed 不猜）
#       2 = 参数错
#
# 判据优先级（首个命中为准）：
#   ① $DMT_PLATFORM   显式覆盖（人工逃生舱；非法值 rc=2）
#   ② 环境事实        HERDR_* ⇒ herdr；ORCA_* ⇒ orca
#   ③ none            无任何运行平台标记
#   ④ unknown         同时命中多个不同运行平台 ⇒ 不猜，交调用方处置
#
# t3code 暂无已实测的环境判据，只能由 DMT_PLATFORM 显式指定；不猜变量名。
set -u

EXPLAIN=0
while [ $# -gt 0 ]; do
  case "$1" in
    --explain) EXPLAIN=1 ;;
    -h|--help) sed -n '2,26p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

note() { [ "$EXPLAIN" = 1 ] && echo "[runtime-detect] $*" >&2; return 0; }

if [ -n "${DMT_PLATFORM:-}" ]; then
  case "$DMT_PLATFORM" in
    herdr|orca|t3code|none) note "源=DMT_PLATFORM（显式覆盖）"; printf '%s\n' "$DMT_PLATFORM"; exit 0 ;;
    *) echo "bad DMT_PLATFORM: $DMT_PLATFORM（want herdr|orca|t3code|none）" >&2; exit 2 ;;
  esac
fi

herdr_src=""; orca_src=""
for v in HERDR_ENV HERDR_PANE_ID HERDR_SOCKET_PATH; do
  if [ -n "${!v:-}" ]; then herdr_src="$v"; break; fi
done
for v in ORCA_TERMINAL_HANDLE ORCA_CLI_COMMAND; do
  if [ -n "${!v:-}" ]; then orca_src="$v"; break; fi
done

n=0
[ -n "$herdr_src" ] && n=$((n + 1))
[ -n "$orca_src" ] && n=$((n + 1))

if [ "$n" -gt 1 ]; then
  note "冲突：herdr($herdr_src) 与 orca($orca_src) 同时命中，不猜"
  printf 'unknown\n'
  exit 1
elif [ -n "$herdr_src" ]; then
  note "源=环境标记 $herdr_src ⇒ herdr（runtimes: / kind: pane-runtime）"
  printf 'herdr\n'
  exit 0
elif [ -n "$orca_src" ]; then
  note "源=环境标记 $orca_src ⇒ orca（ades: / kind: ade）"
  printf 'orca\n'
  exit 0
fi

note "无运行平台标记 ⇒ none（裸跑，非错误）"
printf 'none\n'
exit 0
