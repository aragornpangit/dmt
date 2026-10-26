#!/usr/bin/env bash
# 派发账本：把「无依赖单元必须派满」变成可机器校验的硬约束
# 用法：
#   plan   <role> <unit...>        开工前声明本批无依赖单元（重置账本）
#   inc    <role> [unit]           记一次派发（PostToolUse hook 在 Agent 调用后自动调）
#   excuse <role> <unit> <code>    记一次豁免 code ∈ dep|files|build|order|device|rea|atomic
#   done   <role> <unit>           记一个单元收口
#   check  <role>                  合规 rc=0；有未派单元 rc=2（Stop hook 用 rc=2 阻断本轮）
#   report <role>                  打印可粘贴的「并发账」一行
#   status <role>
#   ledger-path <role>             打印账本文件路径（parallel-guard 用）
#   inject -                       SessionStart hook：注入并行纪律与当前 CAP（stdout 进上下文）
#   nudge -                        PostToolUse hook：水位不满时催派下一波（additionalContext）
#   CAP：probe-cap.sh 探测（DMT_SUBAGENT_CAP > CODEBUDDY_CODE_MAX_CONCURRENT_SUBAGENTS > codebuddy 默认 20 > 8）；在途 ≥ CAP 时未派单元视为分波排队，Stop 不阻断
set -eu
CMD="${1:?usage: dispatch-ledger.sh <plan|inc|excuse|done|check|report|status> <role> ...}"
ROLE="${2:?missing role}"
shift 2 || true
# 角色解析：参数 "-" 或空 ⇒ $DMT_ROLE ⇒ herdr pane label；只治理 director/devm/anam
resolve_role() {
  r="$1"
  if [ -z "$r" ] || [ "$r" = "-" ]; then r="${DMT_ROLE:-}"; fi
  if [ -z "$r" ] && [ -n "${HERDR_PANE_ID:-}" ]; then
    r="$(HERDR_ENV=1 herdr pane list --workspace "${HERDR_WORKSPACE_ID:-}" 2>/dev/null \
        | jq -r --arg p "$HERDR_PANE_ID" '.result.panes[] | select(.pane_id==$p) | .label' | head -1 || true)"
  fi
  printf '%s' "$r"
}
ROLE="$(resolve_role "$ROLE")"
if [ "${DMT_DISPATCH_ALL:-0}" != 1 ]; then
  case "$ROLE" in director|devm|anam) ;; *) exit 0 ;; esac
fi
# 账本固定落在「主工作树」根：worktree 里跑也写回 <main>/locks/，
# 否则 director 在项目根巡检 locks/dispatch-*.tsv 看不到，且各分支 .gitignore 未必有 locks/。
root="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)"
if [ -n "$root" ]; then
  case "$root" in */.git) root="${root%/.git}" ;; esac
else
  root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
ROOT="$root"
DIR="$(cd "$(dirname "$0")" && pwd)"
LEDGER="$ROOT/locks/dispatch-$ROLE.tsv"
mkdir -p "$ROOT/locks"

case "$CMD" in
  plan)
    [ $# -ge 1 ] || { echo "plan needs at least one unit" >&2; exit 2; }
    : > "$LEDGER"
    for u in "$@"; do printf '%s\tplanned\t-\t%s\n' "$u" "$(date +%H%M%S)" >> "$LEDGER"; done
    echo "planned $# unit(s) for $ROLE"
    ;;
  inc)
    # only a sub-agent dispatch counts as a unit: the hook fires on every tool, filter by tool_name
    payload=""; if [ ! -t 0 ]; then payload="$(timeout 1 cat 2>/dev/null || true)"; fi
    if [ -n "$payload" ]; then
      tn="$(printf '%s' "$payload" | jq -r '.tool_name // empty' 2>/dev/null || true)"
      case "$tn" in Agent|Task|Teammate|teammate) ;; *) exit 0 ;; esac
    fi
    u="${1:-auto}"
    if grep -q "^$u	planned	-	" "$LEDGER" 2>/dev/null; then
      sed -i "s/^$u	planned	-	/$u	dispatched	-	/" "$LEDGER"
    else
      printf '%s\tdispatched\t-\t%s\n' "$u" "$(date +%H%M%S)" >> "$LEDGER"
    fi
    echo "dispatched $u"
    ;;
  excuse)
    u="${1:?missing unit}"; code="${2:?missing code}"
    case "$code" in dep|files|build|order|device|rea|atomic) ;; *) echo "bad code: $code" >&2; exit 2 ;; esac
    if grep -q "^$u	planned	-	" "$LEDGER" 2>/dev/null; then
      sed -i "s/^$u	planned	-	/$u	excused	$code	/" "$LEDGER"
    else
      printf '%s\texcused\t%s\t%s\n' "$u" "$code" "$(date +%H%M%S)" >> "$LEDGER"
    fi
    echo "excused $u ($code)"
    ;;
  done)
    u="${1:?missing unit}"
    sed -i "s/^$u	dispatched	/$u	done	-	/" "$LEDGER" 2>/dev/null || true
    echo "done $u"
    ;;
  check)
    # Stop hook anti-loop: if this turn was already bounced once (stop_hook_active=true), let it end
    payload=""; if [ ! -t 0 ]; then payload="$(timeout 1 cat 2>/dev/null || true)"; fi
    if [ -n "$payload" ] && [ "$(printf '%s' "$payload" | jq -r '.stop_hook_active // false' 2>/dev/null)" = "true" ]; then exit 0; fi
    # 超过 24h 的旧账不再阻断（避免历史批次卡住新会话）
    if [ -n "$(find "$LEDGER" -mmin +1440 2>/dev/null)" ]; then exit 0; fi
    [ -f "$LEDGER" ] || exit 0
    left="$(awk -F'\t' '$2=="planned"{printf "%s ", $1}' "$LEDGER")"
    [ -n "$left" ] || exit 0
    n="$(awk -F'\t' 'END{print NR}' "$LEDGER")"
    d="$(awk -F'\t' '$2!="planned"{c++} END{print c+0}' "$LEDGER")"
    cap="$(bash "$DIR/probe-cap.sh")"
    inflight="$(awk -F'\t' '$2=="dispatched"{c++} END{print c+0}' "$LEDGER")"
    # 分波：在途已达 harness 并发上限 ⇒ 等完成通知再补派下一波，不阻断
    if [ "${inflight:-0}" -ge "$cap" ]; then exit 0; fi
    echo "[dispatch] 单元 $n → 已派/已豁免 $d，未派：$left（在途 ${inflight:-0} < CAP $cap，可继续派）" >&2
    echo "[dispatch] 先派后干：每波 min(N, CAP) 把并发派满，或 excuse 记理由（dep|files|build|order|device|rea|atomic）。见 team.md §5.2。" >&2
    exit 2
    ;;
  report)
    n="$(awk -F'\t' 'END{print NR}' "$LEDGER" 2>/dev/null || echo 0)"
    units="$(awk -F'\t' '{printf "%s ", $1}' "$LEDGER" 2>/dev/null)"
    m="$(awk -F'\t' '$2=="dispatched"||$2=="done"{c++} END{print c+0}' "$LEDGER" 2>/dev/null)"
    k=$(( n - m ))
    if [ "$k" -lt 0 ]; then k=0; fi
    codes="$(awk -F'\t' '$2=="excused"{printf "%s:%s ", $1, $3}' "$LEDGER" 2>/dev/null)"
    cap="$(bash "$DIR/probe-cap.sh")"
    inflight="$(awk -F'\t' '$2=="dispatched"{c++} END{print c+0}' "$LEDGER" 2>/dev/null)"
    extra=""
    if [ "$k" -gt 0 ] && [ "${inflight:-0}" -ge "$cap" ]; then extra="cap:在途${inflight}>=${cap},下一波补派 "; fi
    reason="${codes}${extra}"
    echo "并发账：单元 $n（$units）→ 派 $m ＋ 未派 $k（${reason:-无}）[CAP=${cap}]"
    ;;
  status)
    if [ -f "$LEDGER" ]; then column -t -s "$(printf '\t')" "$LEDGER"; else echo "(no ledger for $ROLE)"; fi
    ;;
  ledger-path)
    echo "$LEDGER"
    ;;
  inject)
    cap="$(bash "$DIR/probe-cap.sh")"
    echo "并行纪律（dmt）：无依赖单元每波并发派 min(N, CAP) 个子代理（当前 CAP=$cap，probe-cap.sh 探测；N > CAP 分波补满，唤醒后先补派再收口）；先派后干——开工先列单元清单并 dispatch-ledger.sh plan 落账再动手；子代理一律 run_in_background: true；收口立即向上级回报（完成即报，不傻等）。"
    ;;
  nudge)
    cap="$(bash "$DIR/probe-cap.sh")"
    [ -f "$LEDGER" ] || exit 0
    pending="$(awk -F'\t' '$2=="planned"{c++} END{print c+0}' "$LEDGER")"
    inflight="$(awk -F'\t' '$2=="dispatched"{c++} END{print c+0}' "$LEDGER")"
    if [ "$pending" -ge 1 ] && [ "$inflight" -lt "$cap" ]; then
      jq -n --arg t "[dispatch] 还有 $pending 个未派单元、在途 $inflight < CAP $cap：立即补派下一波（每波 min(N, CAP)，run_in_background: true），别让并发位空着。" '{hookSpecificOutput:{additionalContext:$t}}'
    fi
    exit 0
    ;;
  *) echo "unknown cmd: $CMD" >&2; exit 2 ;;
esac
