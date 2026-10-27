#!/usr/bin/env bash
# 派发账本：把「无依赖单元按需求派发」变成可机器校验的硬约束
# 用法：
#   plan   <role> <unit...>        开工前声明本批无依赖单元（重置账本）
#   inc    <role> [unit]           记一次派发（PostToolUse hook 自动调时不带 unit，自动认领第一个 planned 单元）
#   excuse <role> <unit> <code>    记一次豁免 code ∈ dep|files|build|order|device|rea（六条，与 team.md §5.2 白名单一致）
#   done   <role> <unit>           记一个单元收口
#   check  <role>                  合规 rc=0；有未派单元且在途 0 才 rc=2（Stop hook 用 rc=2 阻断本轮）
#   report <role>                  打印可粘贴的「并发账」一行
#   status <role>
#   ledger-path <role>             打印账本文件路径（parallel-guard 用）
#   inject -                       SessionStart hook：注入并行纪律与当前 CAP（stdout 进上下文）
#   nudge -                        PostToolUse hook：有未派单元时提示可补派下一批（additionalContext）
#   CAP：probe-cap.sh 探测（DMT_SUBAGENT_CAP > CODEBUDDY_CODE_MAX_CONCURRENT_SUBAGENTS > 8）；有效并发上限 n = min(8, cap)；在途 ≥1 属按需推进，Stop 不阻断
set -eu
CMD="${1:?usage: dispatch-ledger.sh <plan|inc|excuse|done|check|report|status|ledger-path|inject|nudge> <role> ...}"
ROLE="${2:?missing role}"
shift 2 || true
# 角色解析：参数 "-" 或空 ⇒ $DMT_ROLE ⇒ herdr pane label；只治理 director/devm/anam 与 helper（director-helper/devm-helper/anam-helper）
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
  case "$ROLE" in director|devm|anam|director-helper|devm-helper|anam-helper) ;; *) exit 0 ;; esac
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

# 账本行：unit <TAB> status(planned|dispatched|excused|done) <TAB> code(-|理由码) <TAB> 时间
# 单元名一律按字段比较（awk），不做正则匹配——单元名含 . * & / 也不会误伤
row_status() { awk -F'\t' -v u="$1" '$1==u{s=$2} END{print s}' "$LEDGER" 2>/dev/null || true; }
first_planned() { awk -F'\t' '$2=="planned"{print $1; exit}' "$LEDGER" 2>/dev/null || true; }
set_row() { # set_row <unit> <from> <to> <code：传 - 则不改 code 字段>
  awk -F'\t' -v OFS='\t' -v u="$1" -v from="$2" -v to="$3" -v code="$4" \
    '{ if(!done && $1==u && $2==from){ $2=to; if(code!="-") $3=code; done=1 } print }' \
    "$LEDGER" > "$LEDGER.tmp" && mv "$LEDGER.tmp" "$LEDGER"
}

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
    if [ -z "$u" ] || [ "$u" = auto ] || [ "$u" = "-" ]; then
      # hook 自动记账：认领第一个 planned 单元（不新增假单元，防账本被 auto 污染）
      u="$(first_planned)"
      [ -n "$u" ] || { echo "no planned unit left"; exit 0; }
    fi
    st="$(row_status "$u")"
    case "$st" in
      planned) set_row "$u" planned dispatched -; echo "dispatched $u" ;;
      dispatched|excused|done) echo "already recorded: $u ($st)" ;;
      *) printf '%s\tdispatched\t-\t%s\n' "$u" "$(date +%H%M%S)" >> "$LEDGER"; echo "dispatched $u" ;;
    esac
    ;;
  excuse)
    u="${1:?missing unit}"; code="${2:?missing code}"
    case "$code" in dep|files|build|order|device|rea) ;; *) echo "bad code: $code" >&2; exit 2 ;; esac
    st="$(row_status "$u")"
    case "$st" in
      planned) set_row "$u" planned excused "$code"; echo "excused $u ($code)" ;;
      dispatched|excused|done) echo "refuse: $u already recorded as $st" >&2; exit 2 ;;
      *) printf '%s\texcused\t%s\t%s\n' "$u" "$code" "$(date +%H%M%S)" >> "$LEDGER"; echo "excused $u ($code)" ;;
    esac
    ;;
  done)
    u="${1:?missing unit}"
    st="$(row_status "$u")"
    if [ "$st" = dispatched ]; then
      set_row "$u" dispatched done -
      echo "done $u"
    else
      echo "done $u (status=${st:-none}, skipped)"
    fi
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
    inflight="$(awk -F'\t' '$2=="dispatched"{c++} END{print c+0}' "$LEDGER")"
    # 按需求开：在途 ≥1 属按需推进，不阻断；只有「有未派单元且在途 0」才阻断（不比 CAP）
    if [ "${inflight:-0}" -ge 1 ]; then exit 0; fi
    echo "[dispatch] 单元 $n → 已派/已豁免 $d，未派：$left（在途 0，可继续派）" >&2
    echo "[dispatch] 先派后干：按需求派发，上限 min(8, cap)，或 excuse 记理由（dep|files|build|order|device|rea）。见 team.md §5.2。" >&2
    exit 2
    ;;
  report)
    n="$(awk -F'\t' 'END{print NR}' "$LEDGER" 2>/dev/null || echo 0)"
    units="$(awk -F'\t' '{printf "%s%s", (NR>1?" ":""), $1}' "$LEDGER" 2>/dev/null || true)"
    m="$(awk -F'\t' '$2=="dispatched"||$2=="done"{c++} END{print c+0}' "$LEDGER" 2>/dev/null)"
    k=$(( n - m ))
    if [ "$k" -lt 0 ]; then k=0; fi
    codes="$(awk -F'\t' '$2=="excused"{printf "%s:%s ", $1, $3}' "$LEDGER" 2>/dev/null || true)"
    cap="$(bash "$DIR/probe-cap.sh")"
    inflight="$(awk -F'\t' '$2=="dispatched"{c++} END{print c+0}' "$LEDGER" 2>/dev/null)"
    extra=""
    if [ "$k" -gt 0 ] && [ "${inflight:-0}" -ge "$cap" ]; then extra="cap:在途达上限、分批排队 "; fi
    reason="${codes}${extra}"
    if [ -z "$reason" ] && [ "$k" -gt 0 ]; then reason="缺理由码（不合规：须派发或 excuse）"; fi
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
    echo "并行纪律（dmt）：无依赖单元并发派 min(N, CAP) 个子代理（按需求开，上限 min(8, cap)，N 超上限分批；当前 CAP=$cap，probe-cap.sh 探测；唤醒后先补派再收口）；先派后干——开工先列单元清单并 dispatch-ledger.sh plan 落账再动手；子代理一律 run_in_background: true；收口立即向上级回报（完成即报，不傻等）。"
    ;;
  nudge)
    cap="$(bash "$DIR/probe-cap.sh")"
    [ -f "$LEDGER" ] || exit 0
    pending="$(awk -F'\t' '$2=="planned"{c++} END{print c+0}' "$LEDGER")"
    inflight="$(awk -F'\t' '$2=="dispatched"{c++} END{print c+0}' "$LEDGER")"
    if [ "$pending" -ge 1 ] && [ "$inflight" -lt "$cap" ]; then
      jq -n --arg t "[dispatch] 还有 $pending 个未派单元、在途 $inflight < CAP $cap：可补派下一批（min(N, CAP)，run_in_background: true）。" '{hookSpecificOutput:{additionalContext:$t}}'
    fi
    exit 0
    ;;
  *) echo "unknown cmd: $CMD" >&2; exit 2 ;;
esac
