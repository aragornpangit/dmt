#!/usr/bin/env bash
# 把 dmt 的派发硬约束装成 CodeBuddy hooks（写 <project>/.codebuddy/settings.json）
# 用法：bash install-hooks.sh <project-root> [--dry-run]
# 依赖：python3（合并 JSON）
set -eu
TARGET="${1:?usage: install-hooks.sh <project-root> [--dry-run]}"
DRY=0; [ "${2:-}" = "--dry-run" ] && DRY=1
ROOT="$(cd "$TARGET" && pwd)"
DIR="$ROOT/scripts"
[ -d "$DIR" ] || { echo "missing $DIR (run install-skills.sh first)" >&2; exit 2; }
CFG="$ROOT/.codebuddy/settings.json"
if [ "$DRY" = 1 ]; then echo "would write $CFG"; exit 0; fi
mkdir -p "$ROOT/.codebuddy"
python3 - "$CFG" "$DIR" <<'PY'
import json, os, sys
cfg, d = sys.argv[1], sys.argv[2]
data = {}
if os.path.exists(cfg):
    try: data = json.load(open(cfg, encoding="utf-8"))
    except Exception: data = {}
hooks = data.setdefault("hooks", {})
def add(event, matcher, cmd):
    arr = hooks.setdefault(event, [])
    for item in arr:
        for h in item.get("hooks", []):
            if h.get("command") == cmd: return
    entry = {"hooks": [{"type": "command", "command": cmd}]}
    if matcher: entry["matcher"] = matcher
    arr.append(entry)
add("PostToolUse", "Agent", "bash " + d + "/dispatch-ledger.sh inc \"$DMT_ROLE\" auto")
add("Stop", None, "bash " + d + "/dispatch-ledger.sh check \"$DMT_ROLE\"")
add("PreToolUse", "Edit|Write|MultiEdit", "bash " + d + "/self-work-guard.sh \"$DMT_ROLE\" \"$CLAUDE_FILE_PATH\"")
json.dump(data, open(cfg, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print("hooks written to", cfg)
PY
echo "note: export DMT_ROLE=<director|pm|devm|anam|devtl{n}|anatl{n}> in the pane before starting the agent"
