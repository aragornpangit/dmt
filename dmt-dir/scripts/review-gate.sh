#!/usr/bin/env bash
# review-gate.sh —— 评审静态门的可执行实现（规范基线 → 类型检查 → lint → 测试）。
#
# 为什么要有这个脚本：评审结论不能靠「模型说跑过了」。本脚本把四段门变成真实命令 +
# 退出码 + 可复现输出，评审者只需读结果；任一段 FAIL 即判 FAIL 退回。
# 设计约束：只跑项目已有配置，不自造命令、不安装依赖、不改配置、不降规则。
#
# 用法：
#   bash review-gate.sh [--root <dir>] [--lang python|java|javascript|typescript|cpp|auto]
#                       [--json] [--cmd <stage>=<command>]... [--timeout <sec>]
#   --cmd 可覆盖某段命令（如 --cmd lint="npx eslint src"），主要用于项目自定义命令与自测。
#   --lang 缺省 auto：按清单文件推断主语言；多语言仓库用 --lang 逐个跑。
#
# 输出：每段一行 PASS|FAIL|SKIP <stage> <command> rc=<n>；末行 GATE PASS|GATE FAIL。
# 退出码：0=无 FAIL；1=有 FAIL；2=用法错；3=缺依赖。
set -u

ROOT="$PWD"; LANG_SEL="auto"; JSON=0; TIMEOUT=900
declare -A OVERRIDE=()
while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOT="${2:?missing dir}"; shift ;;
    --lang) LANG_SEL="${2:?missing lang}"; shift ;;
    --json) JSON=1 ;;
    --cmd) k="${2:?missing stage=command}"; shift
           OVERRIDE["${k%%=*}"]="${k#*=}" ;;
    --timeout) TIMEOUT="${2:?missing seconds}"; shift ;;
    -*) echo "unknown arg: $1" >&2; exit 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done
ROOT="$(cd -P "$ROOT" 2>/dev/null && pwd -P)" || { echo "review-gate: 目录不存在" >&2; exit 2; }
[ -d "$ROOT" ] || { echo "review-gate: 目录不存在：$ROOT" >&2; exit 2; }

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# 基线目录：技能仓内 dmt-reviewer/references；安装项目里技能落在各 harness 的技能目录下，
# 逐个候选探测（评审只读本地副本，找不到就标 [BASELINE_MISSING]，不联网补）。
BASELINE_DIR=""
for cand in \
  "$ROOT/dmt-reviewer/references" \
  "$DIR/../../dmt-reviewer/references" \
  "$ROOT/.agents/skills/dmt-reviewer/references" \
  "$ROOT/.claude/skills/dmt-reviewer/references" \
  "$ROOT/.codebuddy/skills/dmt-reviewer/references" \
  "$ROOT/.opencode/skills/dmt-reviewer/references" \
  "$ROOT/.hermes/skills/dmt-reviewer/references" \
  "$ROOT/.pi/agent/skills/dmt-reviewer/references" \
  "${HOME:-/nonexistent}/.agents/skills/dmt-reviewer/references"; do
  [ -d "$cand" ] && { BASELINE_DIR="$(cd -P "$cand" && pwd -P)"; break; }
done

detect_lang() {
  if [ -f "$ROOT/pyproject.toml" ] || [ -f "$ROOT/setup.py" ] || compgen -G "$ROOT/*.py" >/dev/null 2>&1; then echo python; return; fi
  if [ -f "$ROOT/tsconfig.json" ]; then echo typescript; return; fi
  if [ -f "$ROOT/package.json" ]; then echo javascript; return; fi
  if [ -f "$ROOT/pom.xml" ] || [ -f "$ROOT/build.gradle" ] || [ -f "$ROOT/build.gradle.kts" ]; then echo java; return; fi
  if [ -f "$ROOT/CMakeLists.txt" ] || compgen -G "$ROOT/*.cpp" >/dev/null 2>&1; then echo cpp; return; fi
  echo unknown
}

[ "$LANG_SEL" = "auto" ] && LANG_SEL="$(detect_lang)"
case "$LANG_SEL" in python|java|javascript|typescript|cpp) ;; unknown) LANG_SEL="unknown" ;;
  *) echo "review-gate: 不支持的语言 '$LANG_SEL'" >&2; exit 2 ;; esac

TIMEOUT_CMD=()
command -v timeout >/dev/null 2>&1 && TIMEOUT_CMD=(timeout "$TIMEOUT")

ROWS=(); FAILS=0
emit() { # stage status cmd rc note
  local stage="$1" st="$2" cmd="$3" rc="$4" note="${5:-}"
  [ "$st" = FAIL ] && FAILS=$((FAILS + 1))
  ROWS+=("$stage|$st|$cmd|$rc|$note")
  [ "$JSON" = 1 ] && return 0
  if [ -n "$note" ]; then printf '%s %-11s %s rc=%s（%s）\n' "$st" "$stage" "$cmd" "$rc" "$note"
  else printf '%s %-11s %s rc=%s\n' "$st" "$stage" "$cmd" "$rc"; fi
}

run_stage() { # stage cmd...
  local stage="$1"; shift
  if [ -n "${OVERRIDE[$stage]:-}" ]; then set -- "${OVERRIDE[$stage]}"; fi
  local cmd="$*"
  local log; log="$(mktemp)"
  ( cd "$ROOT" && ${TIMEOUT_CMD[@]+"${TIMEOUT_CMD[@]}"} bash -lc "$cmd" ) >"$log" 2>&1
  local rc=$?
  if [ "$rc" -eq 0 ]; then
    emit "$stage" PASS "$cmd" "$rc"; rm -f "$log"; return 0
  fi
  # ALLOW_SKIP_RC：某些工具用非零码表达「没有可检查对象」（如 pytest rc=5 无测试），
  # 那不是失败，按 SKIP 记并写进 note，避免假 FAIL 逼实现者造测试。
  case " ${ALLOW_SKIP_RC:-} " in
    *" $rc "*)
      emit "$stage" SKIP "$cmd" "$rc" "rc=$rc 表示无可检查对象"; rm -f "$log"; return 0 ;;
  esac
  emit "$stage" FAIL "$cmd" "$rc"
  echo "--- $stage 输出（末 30 行）---" >&2
  tail -n 30 "$log" >&2
  rm -f "$log"
  return 1
}

skip_stage() { emit "$1" SKIP "${2:--}" 0 "$3"; }

# ---------- 0) 规范基线（本地副本） ----------
if [ "$LANG_SEL" = unknown ]; then
  skip_stage baseline - "语言未识别，标 [BASELINE_MISSING]"
elif [ -n "$BASELINE_DIR" ] && [ -s "$BASELINE_DIR/$LANG_SEL.md" ]; then
  emit baseline PASS "references/$LANG_SEL.md" 0
else
  emit baseline SKIP "references/$LANG_SEL.md" 0 "基线缺失，标 [BASELINE_MISSING]"
fi

has() { command -v "$1" >/dev/null 2>&1; }

case "$LANG_SEL" in
  python)
    if has mypy; then run_stage typecheck mypy . || true
    elif has pyright; then run_stage typecheck pyright || true
    else skip_stage typecheck - "mypy/pyright 未安装"; fi
    if has ruff; then run_stage lint ruff check . || true
    elif has flake8; then run_stage lint flake8 . || true
    else skip_stage lint - "ruff/flake8 未安装"; fi
    if has pytest; then ALLOW_SKIP_RC=5 run_stage test python3 -m pytest -q || true
    else skip_stage test - "pytest 未安装"; fi
    ;;
  typescript)
    if [ -f "$ROOT/tsconfig.json" ] && [ -x "$ROOT/node_modules/.bin/tsc" ]; then run_stage typecheck ./node_modules/.bin/tsc --noEmit || true
    elif [ -f "$ROOT/tsconfig.json" ] && has tsc; then run_stage typecheck tsc --noEmit || true
    else skip_stage typecheck - "无 tsconfig.json 或 tsc 未安装"; fi
    if [ -x "$ROOT/node_modules/.bin/eslint" ]; then run_stage lint ./node_modules/.bin/eslint . || true
    elif has eslint; then run_stage lint eslint . || true
    else skip_stage lint - "eslint 未安装"; fi
    if has node && [ -f "$ROOT/package.json" ] && grep -q '"test"[[:space:]]*:' "$ROOT/package.json"; then run_stage test npm test --silent || true
    else skip_stage test - "package.json 无 test 脚本"; fi
    ;;
  javascript)
    skip_stage typecheck - "JS 无独立类型检查（需 TS 或 JSDoc + checkJs）"
    if [ -x "$ROOT/node_modules/.bin/eslint" ]; then run_stage lint ./node_modules/.bin/eslint . || true
    elif has eslint; then run_stage lint eslint . || true
    else skip_stage lint - "eslint 未安装"; fi
    if has node && [ -f "$ROOT/package.json" ] && grep -q '"test"[[:space:]]*:' "$ROOT/package.json"; then run_stage test npm test --silent || true
    else skip_stage test - "package.json 无 test 脚本"; fi
    ;;
  java)
    if [ -f "$ROOT/pom.xml" ] && has mvn; then run_stage typecheck mvn -q -DskipTests compile || true
    elif [ -f "$ROOT/build.gradle" ] && has gradle; then run_stage typecheck gradle compileJava -q || true
    elif [ -f "$ROOT/build.gradle.kts" ] && has gradle; then run_stage typecheck gradle compileJava -q || true
    else skip_stage typecheck - "无 pom.xml/build.gradle 或构建工具未安装"; fi
    skip_stage lint - "checkstyle 配置因项目而异，按项目命令用 --cmd lint=... 指定"
    if [ -f "$ROOT/pom.xml" ] && has mvn; then run_stage test mvn -q test || true
    elif has gradle; then run_stage test gradle test -q || true
    else skip_stage test - "构建工具未安装"; fi
    ;;
  cpp)
    skip_stage typecheck - "C++ 编译入口因项目而异，按项目命令用 --cmd typecheck=... 指定"
    cpp_files="$(git -C "$ROOT" ls-files '*.cc' '*.cpp' '*.cxx' '*.h' '*.hpp' 2>/dev/null | head -200 || true)"
    if [ -f "$ROOT/.clang-format" ] && has clang-format && [ -n "$cpp_files" ]; then
      run_stage lint clang-format --dry-run --Werror $cpp_files || true
    else
      skip_stage lint - "无 .clang-format、无源文件或 clang-format 未安装"
    fi
    if [ -d "$ROOT/build" ] && has ctest; then run_stage test ctest --test-dir build --output-on-failure || true
    else skip_stage test - "无 build 目录或 ctest 未安装"; fi
    ;;
  unknown)
    skip_stage typecheck - "语言未识别"
    skip_stage lint - "语言未识别"
    skip_stage test - "语言未识别"
    ;;
esac

if [ "$JSON" = 1 ]; then
  python3 - "$FAILS" "${ROWS[@]}" <<'PY'
import json, sys
fails = int(sys.argv[1])
rows = []
for r in sys.argv[2:]:
    stage, st, cmd, rc, note = (r.split("|") + ["", "", "", "", ""])[:5]
    rows.append({"stage": stage, "status": st, "command": cmd, "rc": int(rc or 0), "note": note})
print(json.dumps({"gate": "FAIL" if fails else "PASS", "fails": fails, "stages": rows}, ensure_ascii=False, indent=2))
PY
else
  if [ "$FAILS" -gt 0 ]; then echo "GATE FAIL（$FAILS 段未过）"; else echo "GATE PASS"; fi
fi
[ "$FAILS" -eq 0 ] || exit 1
exit 0
