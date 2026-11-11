#!/usr/bin/env bash
# 把可选第三方技能铺到 5 个 harness 的用户级技能发现目录（幂等）。
# 清单来自 dmt_contract.yaml；落点来自 harness_matrix.yaml（经 harness-matrix.sh）。
# 仓级维护脚本，不随 install-skills.sh 分发到目标项目。
set -euo pipefail

REPO="$(cd -P "$(dirname "$0")/.." && pwd -P)"
MATRIX="$REPO/dmt-dir/scripts/harness-matrix.sh"
CONTRACT="$REPO/dmt-dir/dmt_contract.yaml"
HOME_DIR="${HOME:?HOME unset}"
UNLOCKED="$HOME_DIR/.agents/skills-unlocked"
CANONICAL="$HOME_DIR/.agents/skills/mattpocock-skills/skills"

usage() {
  printf '%s\n' \
    "Usage: $0 [--dry-run|--check] [--harness all|pi,codex,...] [--prune-broken]" \
    "" \
    "  --dry-run       只打印将建立的软链" \
    "  --check         只校验落点可读性与 explicit-only 解锁状态" \
    "  --harness       只处理指定 harness（harness_matrix.yaml 的 key，默认 all）" \
    "  --prune-broken  删除落点目录内断链的 dmt-* 软链（改名遗留）"
}

MODE=link
HARNESS=all
PRUNE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) MODE=dry ;;
    --check) MODE=check ;;
    --harness) HARNESS="${2:?missing harness list}"; shift ;;
    --prune-broken) PRUNE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

[ -x "$MATRIX" ] || { echo "install-third-party-skills: 缺 $MATRIX" >&2; exit 3; }
[ -f "$CONTRACT" ] || { echo "install-third-party-skills: 缺 $CONTRACT" >&2; exit 3; }

NAMES="$(python3 - "$CONTRACT" <<'PY'
import sys, yaml
c = yaml.safe_load(open(sys.argv[1], encoding="utf-8"))
for n in (c.get("third_party_skills") or {}).get("names", []):
    print(n)
PY
)"
EXPLICIT="$(python3 - "$CONTRACT" <<'PY'
import sys, yaml
c = yaml.safe_load(open(sys.argv[1], encoding="utf-8"))
for n in (c.get("third_party_skills") or {}).get("explicit_only", []):
    print(n)
PY
)"
[ -n "$NAMES" ] || { echo "契约 third_party_skills.names 为空" >&2; exit 3; }

if [ "$HARNESS" = all ]; then
  HS="$(bash "$MATRIX" list)"
else
  HS="$(printf '%s' "$HARNESS" | tr ',' '\n')"
fi

DIRS=""
for h in $HS; do
  d="$(bash "$MATRIX" get "$h" skills.dir_user)"
  [ -n "$d" ] && DIRS="$DIRS $d"
  if [ "$h" = opencode ]; then
    e="$(bash "$MATRIX" get "$h" skills.dir_project_extra)"
    [ -n "$e" ] && DIRS="$DIRS $e"
  fi
done
TARGETS=""
for d in $DIRS; do
  case " $TARGETS " in *" $d "*) ;; *) TARGETS="$TARGETS $d" ;; esac
done
[ -n "$TARGETS" ] || { echo "未解析到任何落点" >&2; exit 3; }

# 单一解锁源：5 个 explicit-only 走 skills-unlocked（已剥离 allow_implicit_invocation），
# 其余 3 个走上游正本；源缺失即报错，不静默跳过。
resolve_src() {
  local n="$1" sub
  if [ -f "$UNLOCKED/$n/SKILL.md" ]; then printf '%s' "$UNLOCKED/$n"; return 0; fi
  for sub in engineering productivity misc in-progress deprecated; do
    if [ -f "$CANONICAL/$sub/$n/SKILL.md" ]; then printf '%s' "$CANONICAL/$sub/$n"; return 0; fi
  done
  return 1
}

is_explicit() {
  local n="$1" x
  for x in $EXPLICIT; do [ "$x" = "$n" ] && return 0; done
  return 1
}

bad=0
for rel in $TARGETS; do
  dir="$HOME_DIR/$rel"
  echo "--- $rel ---"
  for n in $NAMES; do
    src="$(resolve_src "$n")" || { echo "源技能缺失：$n（$UNLOCKED 或 $CANONICAL）" >&2; exit 3; }
    dst="$dir/$n"
    case "$MODE" in
      check)
        if [ ! -f "$dst/SKILL.md" ]; then
          echo "  MISS $n"; bad=1; continue
        fi
        real="$(readlink -f "$dst")"
        oa="$real/agents/openai.yaml"
        if is_explicit "$n" && [ -f "$oa" ] && grep -q 'allow_implicit_invocation: false' "$oa"; then
          echo "  FAIL $n 仍带 explicit-only 标记：$real"; bad=1
        else
          echo "  OK   $n"
        fi
        ;;
      dry)
        echo "  would link $n -> $src"
        ;;
      link)
        mkdir -p "$dir"
        if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$src" ]; then
          echo "  SKIP $n（已指向 $src）"
          continue
        fi
        # 断链或实体目录先清理，避免 ln -sfn 把链接建到目录里面（同 install-skills.sh）
        if [ -L "$dst" ] || [ -e "$dst" ]; then rm -rf -- "$dst"; fi
        ln -sfn "$src" "$dst"
        echo "  LINK $n -> $src"
        ;;
    esac
  done
done

if [ "$PRUNE" = 1 ]; then
  echo "--- prune broken dmt-* links ---"
  for rel in $TARGETS .codex/skills; do
    dir="$HOME_DIR/$rel"
    [ -d "$dir" ] || continue
    for l in "$dir"/dmt-*; do
      [ -L "$l" ] || continue
      [ -e "$l" ] && continue
      echo "  PRUNE $rel/$(basename "$l") -> $(readlink "$l")"
      if [ "$MODE" != dry ] && [ "$MODE" != check ]; then rm -- "$l"; fi
    done
  done
fi

echo
if [ "$MODE" = check ]; then
  if [ "$bad" = 0 ]; then echo "ALL_LINKED"; else echo "HAS_GAP" >&2; exit 1; fi
else
  echo "调用前缀以 dmt-dir/harness_matrix.yaml 为准（/ 、mattpocock-skills: 、@ 、/skill:）。"
fi
