#!/usr/bin/env bash
# check-dmt.sh —— dmt 合并机检入口（P5：结构断言 + 内容断言，一处运行）
#
# 数据来源（单一来源）：
#   · dmt-director/dmt_contract.yaml  —— 结构事实 + content_assertions（内容断言表）
#   · dmt-director/harness_matrix.yaml —— harness 矩阵
#   · team.md / team/*.md / OPS.md / 各 SKILL.md —— 被检查对象
#
# 用法：bash check-dmt.sh [项目根目录]
#   环境变量：DMT_SKILLS_DIR（技能目录，默认 <root>/.agents/skills）
#             DMT_CONTRACT_YAML（结构契约）
#
# 退出码：0=ALL_PASS；1=HAS_FAIL；2=用法错；3=缺依赖。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/../.." && pwd)"
ROOT="$(cd "${1:-$PWD}" && pwd)" || exit 2
SKILLS_DIR="${DMT_SKILLS_DIR:-$ROOT/.agents/skills}"
CONTRACT_YAML="${DMT_CONTRACT_YAML:-$REPO/dmt-director/dmt_contract.yaml}"
export DMT_CONTRACT_YAML="$CONTRACT_YAML"

if ! command -v python3 >/dev/null 2>&1 || ! python3 -c 'import yaml' >/dev/null 2>&1; then
  echo "FAIL 需要 python3 + PyYAML"; exit 3
fi
[ -f "$CONTRACT_YAML" ] || { echo "FAIL 结构契约不存在：$CONTRACT_YAML"; exit 2; }

fail=0
ok()  { echo "OK   $*"; }
bad() { echo "FAIL $*"; fail=1; }

# 契约 / OPS 定位：目标项目里 docs/team.md（软链）；仓内维护时用正本目录。
if [ -f "$ROOT/docs/team.md" ]; then
  DOCS_DIR="$ROOT/docs"
elif [ "$ROOT" = "$REPO" ]; then
  DOCS_DIR="$REPO/dmt-director"   # 维护仓：team.md 在 dmt-director/ 下
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
    dmt-director/team.md) tp="$path"; [ -f "$tp" ] || tp="$DOCS_DIR/team.md"; got="$(head -5 "$tp" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)" ;;
    *) got="$(sed -n 's/^version: *//p' "$path" | head -1)" ;;
  esac
  if [ "$got" = "$ver" ]; then ok "版本同号 $f ($got)"; else bad "版本不同号 $f：$got ≠ $ver"; fi
done < <(python3 -c 'import os,yaml;[print(x) for x in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["version_sources"]]')

echo
echo "== A2) 技能清单（七个技能各就各位，frontmatter name 一致） =="
while IFS= read -r skill; do
  skill="${skill% }"; [ -n "$skill" ] || continue
  f="$SKILLS_DIR/$skill/SKILL.md"
  if [ ! -f "$f" ]; then bad "技能缺失 $skill（$f）"; continue; fi
  nm="$(sed -n 's/^name: *//p' "$f" | head -1)"
  if [ "$nm" = "$skill" ]; then ok "技能 $skill（name 一致）"; else bad "技能 $skill：frontmatter name=$nm"; fi
done < <(python3 -c 'import os,yaml;[print(k) for k in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["skills"]]')

echo
echo "== A3) 产物目录 / 运行时目录 =="
if [ "$ROOT" = "$REPO" ]; then
  echo "SKIP 维护仓自身 —— 不要求装产物目录"
else
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    if [ -d "$ROOT/$d" ]; then ok "目录 $d"; else bad "目录缺失 $d"; fi
  done < <(python3 -c 'import os,yaml;[print(x) for x in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["artifact_dirs"]]')
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    if [ -d "$ROOT/$d" ]; then ok "运行时目录 $d"; else bad "运行时目录缺失 $d"; fi
  done < <(python3 -c 'import os,yaml;[print(x) for x in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["runtime_dirs"]]')
fi

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
  for h in codebuddy claude codex opencode pi; do
    pre="$(bash "$MATRIX" get "$h" slash_prefix 2>/dev/null || true)"
    cmd="$(bash "$MATRIX" get "$h" start_cmd 2>/dev/null || true)"
    dir="$(bash "$MATRIX" get "$h" skills.dir_project 2>/dev/null || true)"
    if [ -n "$pre" ] && [ -n "$cmd" ] && [ -n "$dir" ]; then ok "harness $h（dir=$dir prefix=$pre）"; else bad "harness $h 字段不完整"; fi
  done
  for h in codebuddy claude codex opencode; do
    [ "$(bash "$MATRIX" get "$h" slash_prefix)" = "/" ] && ok "$h 前缀 /" || bad "$h 前缀应为 /"
  done
  [ "$(bash "$MATRIX" get pi slash_prefix)" = "/skill:" ] && ok "pi 前缀 /skill:" || bad "pi 前缀应为 /skill:"
fi

echo
echo "== A6) 单一来源纪律（技能指针到 team.md，不复述共性口径） =="
while IFS= read -r skill; do
  skill="${skill% }"; [ -n "$skill" ] || continue
  f="$SKILLS_DIR/$skill/SKILL.md"; [ -f "$f" ] || continue
  if grep -qE 'team\.md|docs/team\.md' "$f"; then ok "技能 $skill 指针到 team.md"; else bad "技能 $skill 未指针到 team.md"; fi
done < <(python3 -c 'import os,yaml;[print(k) for k in yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"],encoding="utf-8"))["skills"]]')

# ---------- B. 内容断言（原 check-dmt-doc-paths.sh 的散文 grep，收口到 YAML） ----------
echo
echo "===== B. 内容断言（dmt_contract.yaml: content_assertions） ====="
# 把 YAML 断言表展开成 TAB 分隔行：path<TAB>require<TAB>forbid<TAB>who
ASSERT_TSV="$(python3 - <<'PY'
import os, yaml
m = yaml.safe_load(open(os.environ["DMT_CONTRACT_YAML"], encoding="utf-8"))
for group, spec in (m.get("content_assertions") or {}).items():
    for path, rules in (spec.get("files") or {}).items():
        req = "|".join(rules.get("require", []))
        forb = "|".join(rules.get("forbid", []))
        print(f"{group}\t{path}\t{req}\t{forb}")
PY
)"
while IFS=$'\t' read -r group tmpl req forb; do
  [ -n "$tmpl" ] || continue
  path="$tmpl"
  path="${path//\{docs\}/$DOCS_DIR}"
  path="${path//\{skills\}/$SKILLS_DIR}"
  path="${path//\{scripts\}/$SCRIPT_DIR}"
  path="${path//\{repo\}/$REPO}"
  # team/*.md 只随 dmt-director/ 安装（不软链进 docs/）；缺失时回退到安装副本。
  if [ ! -f "$path" ]; then
    case "$tmpl" in
      "{docs}/team/"*) alt="$ROOT/dmt-director/${tmpl#\{docs\}/}"; [ -f "$alt" ] && path="$alt" ;;
    esac
  fi
  who="$group:$(basename "$(dirname "$path")")/$(basename "$path")"
  if [ ! -f "$path" ]; then bad "$who 文件不存在（$path）"; continue; fi
  if [ -n "$req" ]; then
    miss=""
    while IFS= read -r r; do
      [ -n "$r" ] || continue
      grep -qF -- "$r" "$path" 2>/dev/null || miss="$miss [$r]"
    done < <(printf '%s' "$req" | tr '|' '\n')
    if [ -n "$miss" ]; then bad "$who 缺要求串：$miss"; else ok "$who 含全部要求串"; fi
  fi
  if [ -n "$forb" ]; then
    hit=""
    while IFS= read -r p; do
      [ -n "$p" ] || continue
      if grep -qE -- "$p" "$path" 2>/dev/null; then hit="$hit /$p/"; fi
    done < <(printf '%s' "$forb" | tr '|' '\n')
    if [ -n "$hit" ]; then bad "$who 含禁用串：$hit"; else ok "$who 不含禁用串"; fi
  fi
done <<< "$ASSERT_TSV"

echo
if [ "$fail" = 0 ]; then echo "ALL_PASS"; else echo "HAS_FAIL"; fi
exit "$fail"
