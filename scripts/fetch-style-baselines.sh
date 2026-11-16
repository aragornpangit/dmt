#!/usr/bin/env bash
# fetch-style-baselines.sh —— 抓取五语言权威编码规范，落到 dmt-reviewer/references/。
#
# 为什么要有这个脚本：评审基线必须可复现、可审计、离线可用。评审时联网检索规范会让
# 同一个 commit 在不同时间得到不同结论（网络抖动、搜索排名漂移、把博客当标准）。
# 因此规范正文一次抓取入库，评审只读本地副本；本脚本用于首次生成与季度刷新。
#
# 用法：
#   bash scripts/fetch-style-baselines.sh              # 抓取并覆盖 references/*.md
#   bash scripts/fetch-style-baselines.sh --check      # 只校验已入库副本的来源与体积
#   bash scripts/fetch-style-baselines.sh --out <dir>  # 写到指定目录（默认 dmt-reviewer/references）
#
# 只抓正文，不改条文：去 HTML 包装、去非 http(s) 链接（避免仓库内断链），其余原样保留。
# 许可证与版权按上游保留在文件头；MIT / CC BY 3.0 均允许再分发，条件是保留归属。
set -eu

REPO="$(cd -P "$(dirname "$0")/.." && pwd -P)"
OUT="$REPO/dmt-reviewer/references"
CHECK=0
while [ $# -gt 0 ]; do
  case "$1" in
    --check) CHECK=1; shift ;;
    --out) OUT="${2:?missing dir}"; shift ;;
    -*) echo "unknown arg: $1" >&2; exit 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

# lang|url|license|holder|title
SOURCES='
python|https://peps.python.org/pep-0008/|Public domain|Python Software Foundation|PEP 8 – Style Guide for Python Code
java|https://raw.githubusercontent.com/google/styleguide/gh-pages/javaguide.md|CC BY 3.0 Unported|Google LLC|Google Java Style Guide
javascript|https://raw.githubusercontent.com/airbnb/javascript/master/README.md|MIT|Airbnb|Airbnb JavaScript Style Guide
typescript|https://raw.githubusercontent.com/google/styleguide/gh-pages/tsguide.md|CC BY 3.0 Unported|Google LLC|Google TypeScript Style Guide
cpp|https://raw.githubusercontent.com/google/styleguide/gh-pages/cppguide.md|CC BY 3.0 Unported|Google LLC|Google C++ Style Guide
'

if [ "$CHECK" = 1 ]; then
  fail=0
  while IFS='|' read -r lang url lic holder title; do
    [ -n "$lang" ] || continue
    f="$OUT/$lang.md"
    if [ ! -s "$f" ]; then echo "FAIL 缺基线 $lang（$f）" >&2; fail=1; continue; fi
    size=$(wc -c <"$f")
    if [ "$size" -lt 8000 ]; then echo "FAIL 基线 $lang 过小（$size B），疑似抓取失败" >&2; fail=1; continue; fi
    for k in "来源: $url" "许可证: $lic"; do
      grep -qF -- "$k" "$f" || { echo "FAIL 基线 $lang 缺来源行：$k" >&2; fail=1; }
    done
    grep -qE '^> 获取日期: [0-9]{4}-[0-9]{2}-[0-9]{2}$' "$f" \
      || { echo "FAIL 基线 $lang 缺 获取日期（YYYY-MM-DD）" >&2; fail=1; }
    echo "OK 基线 $lang ($size B)"
  done <<EOF
$SOURCES
EOF
  exit "$fail"
fi

command -v curl >/dev/null 2>&1 || { echo "fetch-style-baselines: 需要 curl" >&2; exit 3; }
mkdir -p "$OUT"
TODAY="$(date +%F)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

while IFS='|' read -r lang url lic holder title; do
  [ -n "$lang" ] || continue
  raw="$TMP/$lang.raw"
  echo "抓取 $lang <- $url"
  curl -fsSL --max-time 90 "$url" -o "$raw" || { echo "抓取失败：$lang" >&2; exit 4; }
  LANG_NAME="$lang" URL="$url" LIC="$lic" HOLDER="$holder" TITLE="$title" \
  TODAY="$TODAY" RAW="$raw" DEST="$OUT/$lang.md" python3 - <<'PY'
import os, re, sys
from html.parser import HTMLParser

lang = os.environ["LANG_NAME"]
url = os.environ["URL"]
lic = os.environ["LIC"]
holder = os.environ["HOLDER"]
title = os.environ["TITLE"]
today = os.environ["TODAY"]
raw = open(os.environ["RAW"], encoding="utf-8", errors="replace").read()
dest = os.environ["DEST"]


class Text(HTMLParser):
    """把规范页面转成保留结构的纯 markdown（不追求像素级还原）。"""

    SKIP = {"script", "style", "nav", "header", "footer", "aside", "form"}
    BLOCK = {"p", "div", "section", "article", "table", "tr", "ul", "ol", "dl", "br",
             "blockquote", "hr", "main", "body"}

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.out = []
        self.skip = 0
        self.pre = 0
        self.list_depth = 0

    def handle_starttag(self, tag, attrs):
        if tag in self.SKIP:
            self.skip += 1
        if self.skip:
            return
        if tag == "pre":
            self.pre += 1
            self.out.append("\n```\n")
        elif tag in ("h1", "h2", "h3", "h4", "h5", "h6"):
            self.out.append("\n\n" + "#" * int(tag[1]) + " ")
        elif tag == "li":
            self.out.append("\n" + "  " * self.list_depth + "- ")
        elif tag in ("ul", "ol"):
            self.list_depth += 1
            self.out.append("\n")
        elif tag == "dt":
            self.out.append("\n\n**")
        elif tag == "dd":
            self.out.append("\n  ")
        elif tag in ("td", "th"):
            self.out.append(" | ")
        elif tag == "code" and not self.pre:
            self.out.append("`")
        elif tag in self.BLOCK:
            self.out.append("\n")

    def handle_endtag(self, tag):
        if tag in self.SKIP:
            self.skip = max(0, self.skip - 1)
            return
        if self.skip:
            return
        if tag == "pre":
            self.pre = max(0, self.pre - 1)
            self.out.append("\n```\n")
        elif tag in ("ul", "ol"):
            self.list_depth = max(0, self.list_depth - 1)
            self.out.append("\n")
        elif tag == "dt":
            self.out.append("**")
        elif tag == "code" and not self.pre:
            self.out.append("`")
        elif tag in ("p", "div", "section", "article", "table", "tr", "dl", "blockquote", "h1", "h2", "h3", "h4", "h5", "h6"):
            self.out.append("\n")

    def handle_data(self, data):
        if self.skip:
            return
        self.out.append(data if self.pre else re.sub(r"\s+", " ", data))


def strip_html_wrappers(text):
    text = re.sub(r"(?is)<style.*?</style>", " ", text)
    text = re.sub(r"(?is)<script.*?</script>", " ", text)
    text = re.sub(r"(?s)<!--.*?-->", " ", text)
    text = re.sub(r"(?is)<a\s+name=[^>]*>\s*</a>", " ", text)
    text = re.sub(r"(?is)</?div[^>]*>", " ", text)
    text = re.sub(r"(?is)</?span[^>]*>", " ", text)
    return text


def sanitize_links(text):
    """非 http(s)/mailto 的链接去掉 href，只留文字，避免仓库内断链（机检 A7）。"""
    def repl(m):
        label, target = m.group(1), m.group(2).strip()
        if target.startswith(("http://", "https://", "mailto:", "#")):
            return m.group(0)
        return label
    return re.sub(r"\[([^\]\n]*)\]\(([^)\n]*)\)", repl, text)


# 判定依据必须是「整页 HTML」，不能只看首字符：google 的 md 源以 <div> 开头，
# 按首字符判会把 markdown 当 HTML 解析，整段被压成一行（5.20.0 修）。
if "<!doctype" in raw[:400].lower() or "<html" in raw[:400].lower():
    p = Text()
    p.feed(raw)
    body = "".join(p.out)
else:
    body = strip_html_wrappers(raw)

body = sanitize_links(body)
body = re.sub(r"[ \t]+\n", "\n", body)
body = re.sub(r"\n{3,}", "\n\n", body).strip()

# 去掉首个 H1 之前的站点导航（PEP 页面有配色切换、面包屑等），
# 并合并「页面标题 + 文章标题」重复的 H1。
lines = body.splitlines()
h1 = [i for i, l in enumerate(lines) if l.startswith("# ")]
if h1:
    body = "\n".join(lines[h1[0]:])
    lines = body.splitlines()
    h1 = [i for i, l in enumerate(lines) if l.startswith("# ")]
    if len(h1) >= 2 and lines[h1[0]].strip() == lines[h1[1]].strip():
        body = "\n".join(lines[h1[1]:])
body = re.sub(r"\n{3,}", "\n\n", body).strip()

header = (
    "> **本地基线副本**（离线评审用，不要改条文）\n"
    f"> 来源: {url}\n"
    f"> 获取日期: {today}\n"
    f"> 许可证: {lic}（上游版权归 {holder}）\n"
    "> 本副本仅去除 HTML 包装与非 http(s) 链接；条文以上游来源为准。\n"
    "> 快速审查清单见同目录 `CHECKLIST.md`，来源索引见 `README.md`。\n\n"
)

if not body.lstrip().startswith("#"):
    header += f"# {title}\n\n"

open(dest, "w", encoding="utf-8").write(header + body + "\n")
os.chmod(dest, 0o644)
print(f"写入 {dest}（{len(header + body)} 字符）")
PY
done <<EOF
$SOURCES
EOF

echo "完成。跑 --check 复核，或直接看 $OUT/README.md"
