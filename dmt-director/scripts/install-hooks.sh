#!/usr/bin/env bash
# 把 dmt 的派发硬约束装成 CodeBuddy hooks
# 用法：
#   bash install-hooks.sh <project-root>     装到 <project>/.codebuddy/settings.json（用 <project>/scripts）
#   bash install-hooks.sh --user             装到 ~/.codebuddy/settings.json（用本仓 scripts，四个经理角色全机生效）
#   --dry-run 只打印目标路径
# 生效角色：director / pm / devm / anam（可用 DMT_DISPATCH_ALL=1 放开到队长）
set -eu
ARG1="${1:?usage: install-hooks.sh <project-root>|--user [--dry-run]}"
DRY=0; [ "${2:-}" = "--dry-run" ] && DRY=1
SELF_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$ARG1" = "--user" ]; then
  CFG="$HOME/.codebuddy/settings.json"
  DIR="$SELF_DIR"
else
  ROOT="$(cd "$ARG1" && pwd)"
  DIR="$ROOT/dmt-director/scripts"
  [ -d "$DIR" ] || { echo "missing $DIR (run install-skills.sh first)" >&2; exit 2; }
  CFG="$ROOT/.codebuddy/settings.json"
fi
if [ "$DRY" = 1 ]; then echo "would write $CFG (scripts: $DIR)"; exit 0; fi
mkdir -p "$(dirname "$CFG")"
# a copied script tree loses the executable bit; the hook runs via `bash` but 4j checks -x
chmod +x "$DIR"/*.sh 2>/dev/null || true
[ -f "$CFG" ] && cp "$CFG" "$CFG.bak-$(date +%Y%m%d%H%M%S)"

python3 - "$CFG" "$DIR" <<'PY'
import json, os, sys
cfg, d = sys.argv[1], sys.argv[2]
data = {}
if os.path.exists(cfg):
    try: data = json.load(open(cfg, encoding="utf-8"))
    except Exception: data = {}
hooks = data.setdefault("hooks", {})
def is_dmt(cmd):
    return ("dispatch-ledger.sh" in cmd) or ("self-work-guard.sh" in cmd)
# drop previous dmt entries so a matcher change cannot leave a duplicate behind
for ev in list(hooks):
    kept = []
    for item in hooks[ev]:
        item["hooks"] = [h for h in item.get("hooks", []) if not is_dmt(h.get("command", ""))]
        if item["hooks"]: kept.append(item)
    hooks[ev] = kept
def add(event, matcher, cmd):
    entry = {"hooks": [{"type": "command", "command": cmd}]}
    if matcher: entry["matcher"] = matcher
    hooks.setdefault(event, []).append(entry)
# matcher "*" everywhere: the scripts filter by tool_name / file path themselves
add("PostToolUse", "*", "bash " + d + "/dispatch-ledger.sh inc - auto")
add("Stop", None, "bash " + d + "/dispatch-ledger.sh check -")
add("PreToolUse", "*", "bash " + d + "/self-work-guard.sh -")
json.dump(data, open(cfg, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print("hooks written to", cfg)
PY
echo "roles governed: director|pm|devm|anam (override with DMT_DISPATCH_ALL=1)"
echo "role is resolved from DMT_ROLE or the herdr pane label; ungoverned sessions exit 0 immediately"
