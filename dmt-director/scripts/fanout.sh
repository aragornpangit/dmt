#!/usr/bin/env bash
# 一键并行派发器：把单元清单展开成按 team.md §5.2 骨架填好的派发 prompt（一单元一份）
# 用法：fanout.sh <role> <units-file> [--cap N]
#   units-file 每行一个单元，TAB 分隔：单元名 <TAB> 输入路径 <TAB> 边界(Files) <TAB> 产物 <TAB> 判据 <TAB> timeoutMs
#   --cap N：本批按需求开的并发数，封顶 8（非数字或 >8 按 8，下限 1）
# 输出：派发计划 + 每单元一份 prompt；模型在同一回复内并发派 min(N, CAP) 个子代理（按需求开，上限 min(8, cap)）。
set -eu
ROLE="${1:?usage: fanout.sh <role> <units-file> [--cap N]}"
UNITS="${2:?missing units file}"
CAPARG=""
if [ "${3:-}" = "--cap" ]; then CAPARG="${4:?--cap needs a value}"; fi
[ -f "$UNITS" ] || { echo "units file not found: $UNITS" >&2; exit 2; }
DIR="$(cd "$(dirname "$0")" && pwd)"
CAP="${CAPARG:-$(bash "$DIR/probe-cap.sh")}"
# --cap 封顶 8：非数字或 >8 按 8，下限 1
case "$CAP" in ''|*[!0-9]*) CAP=8 ;; esac
CAP=$((10#$CAP))
if [ "$CAP" -gt 8 ]; then CAP=8; fi
if [ "$CAP" -lt 1 ]; then CAP=1; fi
n=0
echo "派发计划：role=$ROLE CAP=$CAP（按需求开，上限 min(8, cap)，N 超上限分批，唤醒后先补派再收口）"
echo "---"
while IFS=$'\t' read -r unit input bounds product criteria timeout; do
  [ -n "$unit" ] || continue
  n=$((n + 1))
  wave=$(( (n - 1) / CAP + 1 ))
  echo "[单元 $n · 第 $wave 波] 子代理 prompt："
  echo "你是 $ROLE 的子代理。单元：$unit。输入：$input。边界：$bounds。产物：$product。判据：$criteria。回报：结论+证据（一手出处/可复现命令）+分级[OBS]/[INF]/[UNK]。超时：${timeout:-2700000}。"
  echo "---"
done < "$UNITS"
echo "共 $n 个单元：先 dispatch-ledger.sh plan $ROLE <单元名...> 落账（先派后干），再在同一回复内并发派 min($n, $CAP) 个（按需求开，上限 min(8, cap)，run_in_background: true）；N 超上限分批，唤醒后先补派再收口。"
