#!/usr/bin/env bash
# ctx-budget.sh —— 上下文预算预警（Orca 运行时建议 #8 的落地件）
#
# 为什么需要：harness 的上下文到 300K 量级后会被压缩，压缩会丢细节；而"快满了"是静默的
# （没有提示，直到某一轮回答突然变差）。本脚本把"还剩多少"变成一个可随时查、可挂 hook 的命令。
#
# 口径（**必须一起读**，否则数字会被误读）：
#   · 量的是**字节**，不是 token；token 是用区间估算的代理量，不是精确值。
#   · **不能用整个 jsonl 的字节**：日志保留全部历史（含已被压缩掉的部分），实测整文件 9.4 MB
#     而当前窗口只有约 0.4 MB ⇒ 用整文件会把 105K 读成 3M，直接误导。
#   · 因此以**最近一次压缩点**（jsonl 里 `"type":"session-meta"` 的最后一行）为界，只量其后字节。
#     没有压缩点时退化为整文件，并在输出里**明确标注**这一点。
#   · token 区间：bytes/4（英文偏多）… bytes/2.5（中文/JSON 偏多）。**不要把中点当精确值引用。**
#
# 用法：
#   bash ctx-budget.sh              # 查当前会话（读 CODEBUDDY_SESSION_ID）
#   bash ctx-budget.sh --file F     # 查指定 jsonl
#   bash ctx-budget.sh --raw        # 另外打印整文件字节（对照用）
#   bash ctx-budget.sh --json       # 机器可读
#   bash ctx-budget.sh --quiet      # 只在 WARN/ACT 时输出（可挂 hook）
#
# rc：0=OK（<200K 估算）｜3=WARN（200K–300K，建议准备交接）｜4=ACT（≥300K，应立即交接）
#     5=找不到会话文件（不猜、不静默返回 OK）
set -u

WARN_K=200000
ACT_K=300000
FILE=""
JSON=0
QUIET=0
RAW=0

while [ $# -gt 0 ]; do
  case "$1" in
    --file) FILE="${2:-}"; shift 2 ;;
    --json) JSON=1; shift ;;
    --quiet) QUIET=1; shift ;;
    --raw) RAW=1; shift ;;
    --warn) WARN_K="${2:-}"; shift 2 ;;
    --act)  ACT_K="${2:-}";  shift 2 ;;
    -h|--help) sed -n '2,26p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

# ---- 定位会话文件：显式 > CODEBUDDY_SESSION_ID > 该项目下最新 jsonl
if [ -z "$FILE" ]; then
  root="${HOME}/.codebuddy/projects"
  proj="${CODEBUDDY_PROJECT_DIR:-$PWD}"
  slug="$(printf '%s' "$proj" | sed 's#^/##; s#/#-#g')"
  sid="${CODEBUDDY_SESSION_ID:-}"
  if [ -n "$sid" ] && [ -r "$root/$slug/$sid.jsonl" ]; then
    FILE="$root/$slug/$sid.jsonl"
  elif [ -d "$root/$slug" ]; then
    FILE="$(ls -t "$root/$slug"/*.jsonl 2>/dev/null | head -1)"
  fi
fi

if [ -z "${FILE:-}" ] || [ ! -r "$FILE" ]; then
  echo "ctx-budget: 找不到会话文件（试过 CODEBUDDY_SESSION_ID 与 $HOME/.codebuddy/projects/<slug>/*.jsonl）" >&2
  echo "  提示：用 --file <path> 显式指定；不要在没有读数时假定'预算充足'" >&2
  exit 5
fi

read -r live_bytes live_lines since_line total_bytes total_lines <<EOF
$(python3 - "$FILE" <<'PY'
import sys, os
p = sys.argv[1]
total = os.path.getsize(p)
# 从尾部倒着找最后一个 session-meta 行（压缩点），避免整文件读入内存
marker = b'"type":"session-meta"'
alt    = b'"type": "session-meta"'
CH = 1 << 16
with open(p, 'rb') as f:
    f.seek(0, os.SEEK_END)
    end = f.tell()
    pos = end
    buf = b''
    found = -1
    while pos > 0 and found < 0:
        step = min(CH, pos)
        pos -= step
        f.seek(pos)
        buf = f.read(step) + buf
        i = max(buf.rfind(marker), buf.rfind(alt))
        if i >= 0:
            found = pos + i
            break
        if len(buf) > 4 * CH:      # 只保留尾部窗口，防内存膨胀
            buf = buf[-2 * CH:]
if found < 0:
    live = total
    since = 1
else:
    with open(p, 'rb') as f:
        f.seek(found)
        live = total - found
    with open(p, 'rb') as f:
        since = f.read(found).count(b'\n') + 1
with open(p, 'rb') as f:
    tl = 0
    while True:
        c = f.read(1 << 20)
        if not c:
            break
        tl += c.count(b'\n')
print(live, 0, since, total, tl)
PY
)
EOF

lo=$(( live_bytes / 4 ))
hi=$(( live_bytes * 2 / 5 ))
mid=$(( (lo + hi) / 2 ))
if [ "$since_line" -le 1 ]; then basis="整文件（本会话尚无压缩点）"; else basis="自最近压缩点（第 ${since_line} 行）起"; fi

if   [ "$mid" -ge "$ACT_K" ]; then verdict="ACT";   rc=4
elif [ "$mid" -ge "$WARN_K" ]; then verdict="WARN"; rc=3
else verdict="OK"; rc=0
fi

if [ "$JSON" = 1 ]; then
  printf '{"file":"%s","live_bytes":%s,"basis":"%s","est_tokens_low":%s,"est_tokens_high":%s,"est_tokens_mid":%s,"total_bytes":%s,"verdict":"%s","warn":%s,"act":%s}\n' \
    "$FILE" "$live_bytes" "$basis" "$lo" "$hi" "$mid" "$total_bytes" "$verdict" "$WARN_K" "$ACT_K"
  exit $rc
fi

if [ "$QUIET" = 1 ] && [ "$rc" = 0 ]; then exit 0; fi

echo "ctx-budget: $verdict"
echo "  会话: $FILE"
echo "  当前窗口: $live_bytes 字节（$basis）"
echo "  估算 token: $lo – $hi（中点 $mid）｜口径 bytes/4 … bytes/2.5，非精确值"
[ "$RAW" = 1 ] && echo "  整文件: $total_bytes 字节（含已被压缩的历史，**不可当窗口大小**）"
case "$verdict" in
  OK)   echo "  建议: 无需动作" ;;
  WARN) echo "  建议: 开始准备交接件（目标与状态／产物与证据路径／未决项／口径限制／下一步），不要等到被压缩" ;;
  ACT)  echo "  建议: 立即写交接件并换新会话；此后每次回答都在丢细节的边缘" ;;
esac
exit $rc
