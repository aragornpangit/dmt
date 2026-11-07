#!/usr/bin/env bash
# check-dmt.sh —— 数据驱动的结构与行为检查。
# 数据来源：dmt_contract.yaml、harness_matrix.yaml 与实际技能/文档。
# 用法：bash check-dmt.sh [--verbose] [项目根目录]
# 环境变量：DMT_SKILLS_DIR、DMT_CONTRACT_YAML、DMT_CHECK_VERBOSE=1。
# 默认只输出 FAIL 与最终摘要；--verbose 显示全部 OK 和检查过程。
# 退出码：0=ALL_PASS；1=HAS_FAIL；2=用法错；3=缺依赖。
set -u

VERBOSE="${DMT_CHECK_VERBOSE:-0}"
ROOT_ARG="$PWD"
while [ $# -gt 0 ]; do
  case "$1" in
    --verbose) VERBOSE=1 ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *) ROOT_ARG="$1" ;;
  esac
  shift
done

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO="$(cd -P "$SCRIPT_DIR/../.." && pwd -P)"
ROOT="$(cd -P "$ROOT_ARG" && pwd -P)" || exit 2
if [ -n "${DMT_SKILLS_DIR:-}" ]; then
  SKILLS_DIR="$DMT_SKILLS_DIR"
elif [ "$ROOT" = "$REPO" ]; then
  SKILLS_DIR="$REPO"
else
  SKILLS_DIR="$ROOT/.agents/skills"
fi
CONTRACT_YAML="${DMT_CONTRACT_YAML:-$REPO/dmt-dir/dmt_contract.yaml}"
export DMT_CONTRACT_YAML="$CONTRACT_YAML"

if ! command -v python3 >/dev/null 2>&1 || ! python3 -c 'import yaml' >/dev/null 2>&1; then
  echo "FAIL 需要 python3 + PyYAML"; exit 3
fi
[ -f "$CONTRACT_YAML" ] || { echo "FAIL 结构契约不存在：$CONTRACT_YAML" >&2; exit 2; }

exec 3>&1
if [ "$VERBOSE" != 1 ]; then exec 1>/dev/null; fi
fail=0
ok()  { echo "OK   $*"; }
bad() { echo "FAIL $*" >&2; fail=1; }

# 契约 / OPS 定位：目标项目里 docs/team.md（软链）；仓内维护时用正本目录。
if [ -f "$ROOT/docs/team.md" ]; then
  DOCS_DIR="$ROOT/docs"
elif [ "$ROOT" = "$REPO" ]; then
  DOCS_DIR="$REPO/dmt-dir"   # 维护仓：team.md 在 dmt-dir/ 下
else
  DOCS_DIR="$ROOT/docs"
fi

echo "项目根：    $ROOT"
echo "技能目录：  $SKILLS_DIR"
echo "docs 目录： $DOCS_DIR"
echo "结构契约：  $CONTRACT_YAML"
echo

# ---------- A. 结构断言（原 check-dmt-structure.sh） ----------
echo "===== A. 结构断言 ====="

echo "== A1) 版本同号（dmt_contract.yaml.version = 全部 version_sources） =="
ver="$(python3 -c 'import os,yaml;print(yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["version"])')"
echo "契约版本：$ver"
while IFS= read -r f; do
  [ -n "$f" ] || continue
  path="$REPO/$f"
  if [ ! -f "$path" ]; then
    sk="$(basename "$(dirname "$f")")"; path="$SKILLS_DIR/$sk/SKILL.md"
  fi
  [ -f "$path" ] || { bad "版本源缺失：$f"; continue; }
  case "$f" in
    dmt-dir/team.md) tp="$path"; [ -f "$tp" ] || tp="$DOCS_DIR/team.md"; got="$(head -5 "$tp" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)" ;;
    *) got="$(sed -n 's/^version: *//p' "$path" | head -1)" ;;
  esac
  if [ "$got" = "$ver" ]; then ok "版本同号 $f ($got)"; else bad "版本不同号 $f：$got ≠ $ver"; fi
done < <(python3 -c 'import os,yaml;[print(x) for x in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["version_sources"]]')

echo
echo "== A2) 技能 frontmatter 与声明清单 =="
while IFS= read -r skill; do
  skill="${skill% }"; [ -n "$skill" ] || continue
  f="$SKILLS_DIR/$skill/SKILL.md"
  if [ ! -f "$f" ]; then bad "技能缺失 $skill（$f）"; continue; fi
  err="$(python3 - "$f" "$skill" <<'PYFM'
import re, sys, yaml
path, want = sys.argv[1:]
text = open(path, encoding="utf-8").read()
m = re.match(r"\A---\s*\n(.*?)\n---\s*(?:\n|$)", text, re.S)
if not m:
    print("缺少合法 frontmatter")
else:
    try:
        data = yaml.safe_load(m.group(1)) or {}
    except Exception as exc:
        print(f"frontmatter YAML 错误：{exc}")
    else:
        errors = []
        if data.get("name") != want:
            errors.append(f"name={data.get('name')!r}，应为 {want!r}")
        if not isinstance(data.get("version"), (str, int, float)):
            errors.append("version 缺失或类型错误")
        if not isinstance(data.get("description"), str) or not data.get("description", "").strip():
            errors.append("description 缺失或为空")
        print("；".join(errors))
PYFM
)"
  if [ -z "$err" ]; then ok "技能 $skill frontmatter"; else bad "技能 $skill：$err"; fi
done < <(python3 -c 'import os,yaml;[print(k) for k in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["skills"]]')

echo
echo "== A3) 产物目录 / 运行时目录 =="
if [ "$ROOT" = "$REPO" ]; then
  echo "SKIP 维护仓自身 —— 不要求装产物目录"
else
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    if [ -d "$ROOT/$d" ]; then ok "目录 $d"; else bad "目录缺失 $d"; fi
  done < <(python3 -c 'import os,yaml;[print(x) for x in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8")).get("artifact_dirs",[])]')
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    if [ -d "$ROOT/$d" ]; then ok "运行时目录 $d"; else bad "运行时目录缺失 $d"; fi
  done < <(python3 -c 'import os,yaml;[print(x) for x in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8")).get("runtime_dirs",[])]')
fi

echo
echo "== A3b) 操作手册任务拆分与技能预算 =="
if [ "$ROOT" = "$REPO" ]; then
  OPS_SRC="$REPO/dmt-dir/ops"
else
  OPS_SRC="$ROOT/dmt-dir/ops"
fi
while IFS= read -r f; do
  [ -n "$f" ] || continue
  if [ -f "$OPS_SRC/$f" ]; then ok "操作手册 $f"; else bad "操作手册缺失 $f"; fi
done < <(python3 -c 'import os,yaml;[print(x) for x in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8")).get("ops_docs",[])]')
while IFS=$'\t' read -r skill budget; do
  [ -n "$skill" ] || continue
  f="$SKILLS_DIR/$skill/SKILL.md"
  [ -f "$f" ] || continue
  size="$(wc -c < "$f")"
  if [ "$size" -le "$budget" ]; then ok "技能预算 $skill ($size <= $budget B)"; else bad "技能超预算 $skill ($size > $budget B)"; fi
done < <(python3 -c 'import os,yaml;[print(k+"\t"+str(v)) for k,v in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8")).get("skill_budgets",{}).items()]')

echo
echo "== A4) 脚本齐备且可执行 + 已废止脚本不得回潮 =="
while IFS= read -r s; do
  [ -n "$s" ] || continue
  f="$SCRIPT_DIR/$s"
  if [ -x "$f" ]; then ok "脚本可执行 $s"; else bad "脚本缺失或不可执行 $s"; fi
done < <(python3 -c 'import os,yaml;[print(x) for x in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["scripts"]]')
while IFS= read -r s; do
  [ -n "$s" ] || continue
  if [ -e "$SCRIPT_DIR/$s" ]; then bad "已废止脚本回潮 $s"; else ok "已废止脚本未回潮 $s"; fi
done < <(python3 -c 'import os,yaml;[print(x) for x in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["forbidden_scripts"]]')

echo
echo "== A5) harness 矩阵完整性 =="
MATRIX="$SCRIPT_DIR/harness-matrix.sh"
if [ ! -x "$MATRIX" ]; then bad "缺 harness-matrix.sh"; else
  while IFS= read -r h; do
    [ -n "$h" ] || continue
    pre="$(bash "$MATRIX" get "$h" slash_prefix 2>/dev/null || true)"
    cmd="$(bash "$MATRIX" get "$h" start_cmd 2>/dev/null || true)"
    dir="$(bash "$MATRIX" get "$h" skills.dir_project 2>/dev/null || true)"
    if [ -n "$pre" ] && [ -n "$cmd" ] && [ -n "$dir" ]; then ok "harness $h（dir=$dir prefix=$pre）"; else bad "harness $h 字段不完整"; fi
  done < <(python3 -c 'import sys,yaml; print("\n".join((yaml.safe_load(open(sys.argv[1],encoding="utf-8")).get("harnesses") or {}).keys()))' "$REPO/dmt-dir/harness_matrix.yaml")
fi

echo
echo "== A6) 技能加载无副作用 =="
while IFS= read -r skill; do
  skill="${skill% }"; [ -n "$skill" ] || continue
  f="$SKILLS_DIR/$skill/SKILL.md"; [ -f "$f" ] || continue
  if grep -qE '每次加载先做|bash[[:space:]]+.*init-project\.sh|每次加载.*harness-detect\.sh' "$f"; then
    bad "技能 $skill 含强制初始化或检测步骤"
  else
    ok "技能 $skill 加载无强制初始化"
  fi
done < <(python3 -c 'import os,yaml;[print(k) for k in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["skills"]]')

echo
echo "== A6b) 按 harness 加载（一份共性 + 每 harness 一份差异） =="
HARNESS_DIR="$REPO/dmt-dir/harness"
HARNESS_MATRIX="$REPO/dmt-dir/harness_matrix.yaml"
if [ -d "$HARNESS_DIR" ]; then
  for f in $(python3 -c '
import os,yaml
d=yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8")).get("harness_docs") or {}
names=[d.get("readme"), d.get("common")] + list(d.get("per_harness") or [])
print(" ".join(n for n in names if n))'); do
    if [ -s "$HARNESS_DIR/$f" ]; then ok "harness 文件 $f"; else bad "harness 文件缺失或为空：$f"; fi
  done
else
  bad "缺 harness 目录：$HARNESS_DIR"
fi
# 危险沙箱只能显式 opt-in，不能成为默认启动条件。
CODEX_CMD="$(bash "$SCRIPT_DIR/harness-matrix.sh" get codex start_cmd 2>/dev/null || true)"
case "$CODEX_CMD" in
  *danger-full-access*) bad "codex 默认启动不得包含 danger-full-access" ;;
  *) ok "codex 默认启动不含危险沙箱" ;;
esac

# pi 子代理 agent 定义模板（三份 + README）；install-skills.sh 铺到 <target>/.pi/agents/
PI_AG="$HARNESS_DIR/pi-agents"
if [ -d "$PI_AG" ]; then
  for f in README.md dmt-de.md dmt-ae.md dmt-pde.md; do
    if [ -s "$PI_AG/$f" ]; then ok "pi agent 定义 $f"; else bad "pi agent 定义缺失或为空：$f"; fi
  done
  # 每份定义都必须用白名单形态（inheritSkills: false + skills:），否则「精确注入」退化为「全量继承」
  for f in "$PI_AG"/dmt-*.md; do
    b="$(basename "$f")"
    if grep -q '^inheritSkills: false' "$f" && grep -q '^skills:' "$f"; then ok "pi agent $b 用白名单（inheritSkills: false + skills:）"; else bad "pi agent $b 缺 inheritSkills: false 或 skills:"; fi
  done
else
  bad "缺 pi agent 定义目录：$PI_AG"
fi
# install-skills.sh 必须会把模板铺到 .pi/agents/
if grep -q '\.pi/agents' "$SCRIPT_DIR/install-skills.sh"; then ok "install-skills.sh 铺 .pi/agents"; else bad "install-skills.sh 未铺 .pi/agents"; fi

# harness 名集合：契约 per_harness ↔ 矩阵 key（两处必须一一对应）
declared="$(python3 -c '
import os,yaml
d=yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8")).get("harness_docs") or {}
print(" ".join(sorted(x[:-3] for x in (d.get("per_harness") or []) if x.endswith(".md"))))')"
from_matrix="$(python3 -c '
import sys,yaml
print(" ".join(sorted((yaml.safe_load(open(sys.argv[1],encoding="utf-8")).get("harnesses") or {}).keys())))' "$HARNESS_MATRIX")"
if [ "$declared" = "$from_matrix" ]; then ok "harness 差异文件与矩阵 key 一致（$declared）"; else bad "harness 差异文件与矩阵 key 不一致：契约=[$declared] 矩阵=[$from_matrix]"; fi
# 技能加载不要求 harness 检测；仅适配器自身需要自测。
# 检测脚本自测：五 harness + 未知（未知必须 rc=1，不得沉默默认）
DETECT="$SCRIPT_DIR/harness-detect.sh"
if [ -x "$DETECT" ]; then ok "harness-detect.sh 可执行"; else bad "harness-detect.sh 缺失或不可执行"; fi
detect_case() {
  local argv="$1" want="$2" out rc
  out="$(env -i PATH="$PATH" HOME="${HOME:-/tmp}" DMT_PANE_ARGV="$argv" DMT_DETECT_NO_PARENT=1 bash "$DETECT" 2>/dev/null)"; rc=$?
  if [ "$out" = "$want" ]; then ok "harness-detect: [$argv] ⇒ $want"; else bad "harness-detect: [$argv] ⇒ [$out]（期望 $want）"; fi
  return 0
}
if [ -x "$DETECT" ]; then
  while IFS= read -r h; do
    [ -n "$h" ] && detect_case "$h" "$h"
  done < <(python3 -c 'import sys,yaml; print("\n".join((yaml.safe_load(open(sys.argv[1],encoding="utf-8")).get("harnesses") or {}).keys()))' "$HARNESS_MATRIX")
  detect_case "node /x/bin/cbc -c" codebuddy
  unknown_out="$(env -i PATH="$PATH" HOME="${HOME:-/tmp}" DMT_PANE_ARGV="/usr/bin/vim" DMT_DETECT_NO_PARENT=1 bash "$DETECT" 2>/dev/null)"; unknown_rc=$?
  if [ "$unknown_out" = "unknown" ] && [ "$unknown_rc" = 1 ]; then ok "harness-detect: 判不出 ⇒ unknown（rc=1）"; else bad "harness-detect: 判不出时应输出 unknown 且 rc=1（实得 out=$unknown_out rc=$unknown_rc）"; fi
fi
# cbc / codebuddy pane 门铃直发判据（只认目标 pane 的 argv，不读发方 $DMT_HARNESS）
LIB="$SCRIPT_DIR/lib-dmt.sh"
if [ -f "$LIB" ]; then
  cbc_case() {
    local argv="$1" want="$2" rc
    DMT_PANE_ARGV="$argv" bash -c '. "$1"; dmt_pane_is_cbc probe >/dev/null 2>&1' _ "$LIB"; rc=$?
    if [ "$rc" = "$want" ]; then ok "dmt_pane_is_cbc: [$argv] ⇒ rc=$rc"; else bad "dmt_pane_is_cbc: [$argv] ⇒ rc=$rc（期望 $want）"; fi
    return 0
  }
  cbc_case "node /x/bin/cbc -c"                       0
  cbc_case "/x/bin/codebuddy --permission-mode auto" 0
  cbc_case "node /x/bin/pi --approve"                1
  cbc_case "/usr/bin/vim"                            1
else
  bad "缺 lib-dmt.sh，cbc 门铃判据无法自测"
fi
# 收件箱方向矩阵自测（BACKLOG A5）：ops/comms.md 的允许方向表必须由 send-msg.sh 强制，
# 非法方向 rc=2 且不落盘。用 --check-dir，只跑校验、无副作用。
SEND="$SCRIPT_DIR/send-msg.sh"
dir_case() {
  local to="$1" from="$2" want="$3" rc
  bash "$SEND" "$to" "$from" probe /dev/null --check-dir >/dev/null 2>&1; rc=$?
  if [ "$rc" = "$want" ]; then ok "send-msg 方向: $from -> $to ⇒ rc=$rc"; else bad "send-msg 方向: $from -> $to ⇒ rc=$rc（期望 $want）"; fi
  return 0
}
if [ -f "$SEND" ]; then
  # 用户裁定：dmt-dir 只安排 pde 定稿 SPEC，不向 dmt-dm 派单；开发线由 SPEC 驱动。
  dir_case dmt-dm       dmt-dir         2
  dir_case dmt-am       dmt-dir         0
  dir_case dmt-dir   dmt-dm             0
  dir_case dmt-dir   dmt-am             0
  dir_case dmt-dl1      dmt-dm             0
  dir_case dmt-dm       dmt-dl1            0
  dir_case dmt-dm       dmt-dm-helper      0
  dir_case dmt-dir   dmt-dir-helper  0
  dir_case dmt-dl2      dmt-dl1            2
  dir_case dmt-dl1      dmt-dir         2
  dir_case dmt-dl1      dmt-am             2
  dir_case dmt-dir   dmt-dl1            2
  dir_case dmt-am       dmt-dl1            2
  dir_case dmt-am       dmt-dm             2
  dir_case dmt-dm       dmt-am             2
  dir_case dmt-dm       dmt-dm             2
else
  bad "缺 send-msg.sh，方向矩阵无法自测"
fi

echo
echo "== A6c) pi agent 白名单可注入性 =="
# pi 的 skills 白名单不能包含会被 disable-model-invocation 过滤的技能。
# 找不到技能时只 WARN；可选辅助技能不构成核心安装依赖。
A6C_OUT="$(python3 - "$REPO" "$ROOT" <<'PYSK'
import os, re, sys, glob
repo, root = sys.argv[1], sys.argv[2]
home = os.path.expanduser("~")
roots = [
    os.path.join(root, ".agents", "skills"),
    os.path.join(repo, ""),
    os.path.join(home, ".agents", "skills"),
    os.path.join(home, ".pi", "agent", "skills"),
]

def find(name):
    for r in roots:
        p = os.path.join(r, name, "SKILL.md")
        if os.path.isfile(p):
            return p
    p = os.path.join(repo, name, "SKILL.md")
    return p if os.path.isfile(p) else None

for f in sorted(glob.glob(os.path.join(repo, "dmt-dir", "harness", "pi-agents", "dmt-*.md"))):
    txt = open(f, encoding="utf-8").read()
    m = re.search(r"^skills:\s*(.+)$", txt, re.M)
    base = os.path.basename(f)
    if not m:
        print("WARN\t%s\t(no skills field)" % base)
        continue
    for n in [x.strip() for x in m.group(1).split(",") if x.strip()]:
        p = find(n)
        if not p:
            print("WARN\t%s\t%s\tnot installed in this environment" % (base, n))
            continue
        head = open(p, encoding="utf-8").read()[:1200]
        if re.search(r"^disable-model-invocation:\s*true", head, re.M):
            print("FAIL\t%s\t%s\tfiltered by disable-model-invocation (move to prompt path)" % (base, n))
        else:
            print("OK\t%s\t%s" % (base, n))
PYSK
)"
a6c_fail=0
while IFS=$'\t' read -r st who what extra; do
  [ -n "${st:-}" ] || continue
  case "$st" in
    OK)   ok "pi agent $who: $what 可注入" ;;
    WARN) ok "pi agent $who: $what 跳过（$extra）" ;;
    FAIL) bad "pi agent $who: $what —— $extra"; a6c_fail=1 ;;
  esac
done <<< "$A6C_OUT"
[ "$a6c_fail" = 0 ] || fail=1

echo "== A6d) 仓级脚本登记（仅维护仓） =="
if [ -d "$REPO/dmt-dm" ] && [ -d "$REPO/scripts" ]; then
  while IFS= read -r rp; do
    [ -n "$rp" ] || continue
    if [ -f "$REPO/$rp" ]; then
      [ -x "$REPO/$rp" ] && ok "仓级脚本 $rp" || bad "仓级脚本 $rp 不可执行"
    else
      bad "仓级脚本缺失 $rp"
    fi
  done < <(python3 - "$CONTRACT_YAML" <<'PYCS'
import sys, yaml
c = yaml.safe_load(open(sys.argv[1], encoding="utf-8"))
for p in (c.get("repo_scripts") or []):
    print(p)
PYCS
)
  for f in "$REPO"/scripts/*; do
    [ -e "$f" ] || continue
    rel="scripts/$(basename "$f")"
    grep -q "$rel" "$CONTRACT_YAML" || bad "仓级脚本未登记：$rel"
  done
else
  echo "SKIP 安装项目无仓级维护脚本"
fi

echo "== A7) 文档相对链接可达 =="
while IFS=$'\t' read -r src target dest; do
  [ -n "$src" ] || continue
  if [ -e "$dest" ]; then
    ok "链接 ${src#$REPO/} -> $target"
  else
    bad "断链 ${src#$REPO/} -> $target（按源文件目录解析）"
  fi
done < <(python3 - "$REPO" "$DOCS_DIR" <<'PY'
import os, re, sys
roots = list(dict.fromkeys(map(os.path.abspath, sys.argv[1:])))
files = []
for root in roots:
    for dirpath, dirnames, names in os.walk(root, followlinks=False):
        dirnames[:] = [d for d in dirnames if d not in {
            ".git", ".archify", ".worktrees", "changelog", "logs", "node_modules"
        }]
        files.extend(os.path.join(dirpath, name) for name in names if name.endswith(".md"))
pattern = re.compile(r"!?\[[^\]]*\]\(([^)\s]+)(?:\s+[^)]*)?\)")
seen = set()
for src in sorted(set(files)):
    try:
        text = open(src, encoding="utf-8").read()
    except OSError:
        continue
    text = re.sub(r"```.*?```", " ", text, flags=re.S)
    text = re.sub(r"`[^`]*`", " ", text)
    for raw in pattern.findall(text):
        target = raw.split("#", 1)[0].split("?", 1)[0].strip()
        if len(target) >= 2 and target[0] == "<" and target[-1] == ">":
            target = target[1:-1]
        if not target or target.startswith(("http://", "https://", "mailto:", "/")):
            continue
        key = (src, target)
        if key in seen:
            continue
        seen.add(key)
        dest = os.path.abspath(os.path.join(os.path.dirname(src), target))
        print(f"{src}\t{target}\t{dest}")
PY
)

echo
if [ "$fail" = 0 ]; then echo "ALL_PASS" >&3; else echo "HAS_FAIL" >&3; fi
exit "$fail"
