#!/usr/bin/env bash
# 一键并行派发器：把单元清单展开成按 team.md §5.2 骨架填好的派发 prompt（一单元一份）
# 用法：fanout.sh <role> <units-file> [--cap N]
#   units-file 每行一个单元，TAB 分隔：单元名 <TAB> 输入路径 <TAB> 边界(Files) <TAB> 产物 <TAB> 判据 <TAB> timeoutMs
# 输出：派发计划 + 每单元一份 prompt；模型只需在同一回复内并发派出 min(N, CAP) 个子代理。
set -eu
ROLE="${1:?usage: fanout.sh <role> <units-file> [--cap N]}"
UNITS="${2:?missing units file}"
CAPARG=""
[ "${3:-}" = "--cap" ] && CAPARG="${4:-}"
[ -f "$UNITS" ] || { echo "units file not found: $UNITS" >&2; exit 2; }
DIR="$(cd "$(dirname "$0")" && pwd)"
CAP="${CAPARG:-$(bash "$DIR/probe-cap.sh")}"
n=0
echo "派发计划：role=$ROLE CAP=$CAP（每波 min(N, CAP)，N > CAP 分波补满，唤醒后先补派再收口）"
echo "---"
while IFS=$'\t' read -r unit input bounds product criteria timeout; do
  [ -n "$unit" ] || continue
  n=$((n + 1))
  wave=$(( (n - 1) / CAP + 1 ))
  echo "[单元 $n · 第 $wave 波] 子代理 prompt："
  echo "你是 $ROLE 的子代理。单元：$unit。输入：$input。边界：$bounds。产物：$product。判据：$criteria。回报：结论+证据（一手出处/可复现命令）+分级[OBS]/[INF]/[UNK]。超时：${timeout:-2700000}。"
  echo "---"
done < "$UNITS"
echo "共 $n 个单元：同一回复内并发派出前 min($n, $CAP) 个（run_in_background: true），再用 dispatch-ledger.sh plan $ROLE <单元名...> 落账。"
