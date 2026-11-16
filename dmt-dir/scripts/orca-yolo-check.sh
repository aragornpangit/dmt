#!/usr/bin/env bash
# orca-yolo-check.sh —— Orca 升级后自检（建议 #4／#10 的落地件）
#
# 为什么需要：本机对 Orca artifact 有两处本地改动，**升级会静默覆盖**：
#   ① `pi:"--approve"`（yolo 补丁）——丢了不报错，只退回「逐次审批」，人以为是自己手滑；
#   ② `out/cli/impl/*`（jsonc-parser 子模块）——丢了 `orca agent hooks status` 直接报
#      `Cannot find module './impl/format'`（上游打包缺陷，见 orca-fix-cli-impl.sh）。
#
# **本机有两个 artifact，各有各的消费者（2026-11-17 实测）**：
#   · CLI 侧：`orca` 启动器（`~/.local/bin/orca` 之类）指向 `<artifact>/out/cli/index.js`
#   · 守护侧：daemon 进程的 `--app-version` / `--entry-path` 指向另一个 `<artifact>`
# 二者**不是同一份**（实测 CLI→`…repair-1`、daemon→`0.1.0+033018f7660d`），
# 补丁也分别落在不同目录 ⇒ **只查"最新那个"会漏判**。
#
# 用法：
#   bash orca-yolo-check.sh              # 查 CLI 与 daemon 两侧
#   bash orca-yolo-check.sh --cli DIR    # 只查指定 CLI artifact
#   bash orca-yolo-check.sh --daemon DIR # 只查指定 daemon artifact
#   bash orca-yolo-check.sh --fix        # impl 缺失时调 orca-fix-cli-impl.sh（yolo 补丁不自动重打）
#
# rc：0=两侧所需项齐｜1=yolo 补丁缺失（daemon 侧）｜2=impl 缺失（CLI 侧）｜4=两侧都缺｜3=定位失败
set -u

CLI_ART=""
DAEMON_ART=""
FIX=0
while [ $# -gt 0 ]; do
  case "$1" in
    --cli) CLI_ART="${2:-}"; shift 2 ;;
    --daemon) DAEMON_ART="${2:-}"; shift 2 ;;
    --fix) FIX=1; shift ;;
    -h|--help) sed -n '2,24p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

# ---- CLI 侧：从启动器脚本里抠 artifact 路径
if [ -z "$CLI_ART" ]; then
  launcher="$(command -v orca 2>/dev/null || true)"
  if [ -n "$launcher" ] && [ -r "$launcher" ]; then
    # 启动器里同时出现 runtimes/node 路径与真正 artifact 路径 ⇒ 排除 runtimes/ 再取
    CLI_ART="$(grep -oE '/[^'"'"'"]*orcad-artifacts/linux-x64-glibc/[^/]+/' "$launcher" 2>/dev/null \
      | grep -v '/runtimes/' | head -1)"
  fi
fi

# ---- daemon 侧：从运行中进程的 --app-version 反查
if [ -z "$DAEMON_ART" ]; then
  base="$HOME/.config/orca/orcad-artifacts/linux-x64-glibc"
  ver="$(pgrep -af 'daemon-entry\.js' 2>/dev/null | grep -oE '\-\-app-version [^ ]+' | awk '{print $2}' | head -1)"
  [ -n "$ver" ] && DAEMON_ART="$base/$ver/"
fi

check_one() { # $1=role  $2=dir  $3=需要 impl?(1/0)  $4=需要 yolo?(1/0)
  local role="$1" dir="$2" need_impl="$3" need_yolo="$4"
  [ -n "$dir" ] && [ -d "$dir" ] || { echo "  [$role] 未定位到 artifact"; return 3; }
  local idx="$dir/out/cli/index.js"
  [ -f "$idx" ] || { echo "  [$role] 缺 $idx"; return 3; }
  local yolo impl_missing=0 m
  yolo="$(grep -c 'pi:"--approve"' "$idx" 2>/dev/null || true)"; yolo="${yolo:-0}"
  for m in format edit scanner parser string-intern; do
    [ -f "$dir/out/cli/impl/$m.js" ] || impl_missing=$((impl_missing+1))
  done
  local tag_y="信息" tag_i="信息"
  [ "$need_yolo" = 1 ] && tag_y="必需"
  [ "$need_impl" = 1 ] && tag_i="必需"
  echo "  [$role] $(basename "$dir")  yolo=$yolo/1($tag_y)  impl 缺=$impl_missing/5($tag_i)"
  local rc=0
  [ "$need_yolo" = 1 ] && [ "$yolo" -lt 1 ] && rc=1
  if [ "$need_impl" = 1 ] && [ "$impl_missing" -gt 0 ]; then rc=$(( rc==1 ? 4 : 2 )); fi
  if [ "$FIX" = 1 ] && [ "$impl_missing" -gt 0 ]; then
    local here; here="$(cd "$(dirname "$0")" && pwd)"
    if [ -f "$here/orca-fix-cli-impl.sh" ]; then
      echo "  [$role] --fix: 调 orca-fix-cli-impl.sh --artifact $dir"
      bash "$here/orca-fix-cli-impl.sh" --artifact "$dir" >/dev/null 2>&1 \
        && echo "  [$role] --fix: 已补" || echo "  [$role] --fix: 失败（见 orca-fix-cli-impl.sh 输出）" >&2
    else
      echo "  [$role] --fix: 找不到 orca-fix-cli-impl.sh" >&2
    fi
  fi
  return $rc
}

echo "orca-yolo-check:"
check_one CLI    "$CLI_ART"    1 0; rc_cli=$?
check_one daemon "$DAEMON_ART" 0 1; rc_daemon=$?

rc=0
case "$rc_cli:$rc_daemon" in
  0:0) rc=0 ;;
  3:3|3:0|0:3) rc=3 ;;
  0:1|0:4) rc=1 ;;
  2:0|4:0|2:1|2:4|4:1|4:4) rc=2 ;;
  *) rc=4 ;;
esac

case "$rc" in
  0) echo "  => OK" ;;
  1) echo "  => FAIL：daemon 侧 yolo 补丁缺失（升级覆盖）⇒ 按 orca.md §4 重打 pi:\"--approve\" 并重启 orca-serve" ;;
  2) echo "  => FAIL：CLI 侧 impl 缺失 ⇒ 跑 bash orca-fix-cli-impl.sh（幂等）" ;;
  4) echo "  => FAIL：两侧都有缺失" ;;
  3) echo "  => 无法定位（CLI/daemon 至少一侧）；用 --cli/--daemon 显式指定" ;;
esac
exit $rc
