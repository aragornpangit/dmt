#!/usr/bin/env bash
# dmt 脚本公共库：工作树根 / 角色解析 / pane 查询。被各脚本 source，不单独执行。
# 用法：DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/lib-dmt.sh"
# 目的：同一判据只有一份实现 —— 复制粘贴出来的副本已经分叉过（dry-run 守卫、fail-closed 修复各漏一处）。

# 本库所在目录（source 时解析一次；用于拼「同目录脚本」的绝对路径，免受调用方后续 cd 影响）
DMT_SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 主工作树根：git common dir 的父目录（在 worktree 里跑也指回主树）；非 git 目录回退当前目录
dmt_root() {
  local r
  r="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)"
  if [ -n "$r" ]; then
    case "$r" in */.git) r="${r%/.git}" ;; esac
    printf '%s' "$r"
  else
    git rev-parse --show-toplevel 2>/dev/null || pwd
  fi
}

# 角色解析：参数（空或 "-"）⇒ $DMT_ROLE ⇒ herdr pane label
dmt_role() {
  local r="${1:-}"
  case "$r" in ""|-) r="${DMT_ROLE:-}" ;; esac
  if [ -z "$r" ] && [ -n "${HERDR_PANE_ID:-}" ]; then
    r="$(HERDR_ENV=1 herdr pane list --workspace "${HERDR_WORKSPACE_ID:-}" 2>/dev/null \
      | jq -r --arg p "$HERDR_PANE_ID" '.result.panes[]? | select(.pane_id==$p) | .label' 2>/dev/null | head -1 || true)"
  fi
  printf '%s' "$r"
}

# pane label -> pane id（不存在给空；herdr 不可用也给空）
dmt_pane_by_label() {
  HERDR_ENV=1 herdr pane list --workspace "${HERDR_WORKSPACE_ID:-}" 2>/dev/null \
    | jq -r --arg l "$1" '.result.panes[]? | select(.label==$l) | .pane_id' 2>/dev/null | head -1 || true
}

# pane 的 agent_status（unknown = 该 pane 没有 agent 在跑）
dmt_pane_status() {
  HERDR_ENV=1 herdr pane get "$1" 2>/dev/null \
    | jq -r '.result.pane.agent_status // "unknown"' 2>/dev/null || echo unknown
}

# pane 里前台进程的 argv（空格连接；拿不到给空）
# $DMT_PANE_ARGV 可整体覆盖 —— 仅供机检自测判据（与 $DMT_HARNESS_CMD 同思路的逃生舱）。
dmt_pane_argv() {
  if [ -n "${DMT_PANE_ARGV+x}" ]; then printf '%s' "${DMT_PANE_ARGV}"; return 0; fi
  HERDR_ENV=1 herdr pane process-info --pane "$1" 2>/dev/null \
    | jq -r '.result.process_info.foreground_processes[0].argv // [] | join(" ")' 2>/dev/null || true
}

# 该 pane 的前台 harness 是否跑在「自动批准」档位（2026-11-03 第六十三次立规）。
#
# 为什么需要它：dmt 全靠 pane 自主跑长任务，一旦 pane 落在 default/manual 档，每次工具调用都撞审批 ——
# 现象是「脚本超时 / 命令失败」（2026-11-03 bcr-nh 实测：33 次工具栏 ASK，脚本本体 57ms 正常，
# 另一 pane 标题直接写着 file-claim.sh 审批超时）。不查档位就查不到根因。
#
# 判据一律读 **argv**，不信屏幕文字：
#   屏幕上的 "auto mode on" 只在手动会话首屏出现，之后被输出顶走；而 argv 是恒定事实。
# 各 harness 的自动档参数（与 dmt_harness_cmd 同源）：
#   codebuddy  --permission-mode auto      （另有 -y/--dangerously-skip-permissions）
#   claude     --permission-mode auto      （另有 --dangerously-skip-permissions）
#   codex      -a never / --ask-for-approval never / --yolo（-y 在 codex 里不是批准开关）
#   opencode   --auto / --dangerously-skip-permissions
#   pi         --approve
# 返回：0 = 自动档；1 = 非自动档；2 = 拿不到 argv（无法判定，调用方决定是告警还是放过）
dmt_pane_auto_mode() {
  local pane="$1" argv tok prev=""
  argv="$(dmt_pane_argv "$pane")"
  [ -n "$argv" ] || return 2
  # 逐 token 判，不用 `*"--auto"*` 这种子串匹配 —— 那会把 `--autocompact` 之类误判成自动档。
  for tok in $argv; do
    case "$tok" in
      --permission-mode=auto|--dangerously-skip-permissions|--yolo|--approve) return 0 ;;
      --auto|--dangerously-bypass-approvals-and-sandbox) return 0 ;;
      --ask-for-approval=never) return 0 ;;
      auto) [ "$prev" = "--permission-mode" ] && return 0 ;;
      never) [ "$prev" = "-a" ] || [ "$prev" = "--ask-for-approval" ] && return 0 ;;
    esac
    prev="$tok"
  done
  return 1
}

# 就绪判据：轮询 agent_status 不再是 unknown。
# 不要用 wait-output 匹配屏幕文字 —— 对已在跑的 pane 它会立刻命中历史输出，等于没有判据。
dmt_wait_ready() {
  local pane="$1" limit="${2:-60}" i=0 st
  while [ "$i" -lt "$limit" ]; do
    st="$(dmt_pane_status "$pane")"
    if [ "$st" != "unknown" ]; then echo "ready ($st): $pane"; return 0; fi
    sleep 1; i=$((i + 1))
  done
  echo "WARN: $pane still unknown after ${limit}s" >&2
  return 1
}

# harness 白名单与启动命令（默认 codebuddy；备选 pi / opencode / codex / claude）。
# 2026-11-03 第六十二次：补齐 claude（Claude Code），并把「技能如何被调起」抽成 dmt_skill_cmd ——
# 五个 harness 的技能发现目录与斜杠写法并不一致，写死一种会在别的 harness 上静默失效。
# 解析优先级：显式参数 ⇒ $DMT_HARNESS ⇒ codebuddy。非法值 rc=2（错误写 stderr，便于调用方 fail-fast）。
dmt_harness_name() {
  local h="${1:-}"
  case "$h" in ""|-) h="${DMT_HARNESS:-codebuddy}" ;; esac
  case "$h" in
    codebuddy|pi|opencode|codex|claude) printf '%s' "$h" ;;
    # 常见别名（herdr 侧 agent 名为 claude，别名 claude-code）
    claudecode|claude-code) printf '%s' 'claude' ;;
    *) echo "bad harness: $h (want codebuddy|pi|opencode|codex|claude)" >&2; return 2 ;;
  esac
}

# 技能调用命令：按 harness 生成「往 pane 里输入的那一行」。
# 实测（2026-11-03，五个 harness 各自 `--help` + 端到端探针）：
#   · claude / codebuddy / codex / opencode ⇒ `/dmt-dm`（技能名直接作斜杠命令）
#   · pi                                   ⇒ `/skill:dmt-dm`（pi 1.5.0 的 enableSkillCommands 注册为 skill:<name>）
# `pi -p /dmt-dm` 不展开；`pi -p /skill:dmt-dm` 正常展开 —— 写错前缀会静默变成普通提问。
dmt_skill_cmd() {
  local h="${1:-codebuddy}" name="${2:?dmt_skill_cmd <harness> <skill-name>}"
  case "$h" in
    pi) printf '/skill:%s' "$name" ;;
    *)  printf '/%s' "$name" ;;
  esac
}

# harness 启动命令。$DMT_HARNESS_CMD 可整体覆盖（逃生舱：任意 harness / 额外参数）。
# codebuddy 分支在启动前做两件事（机队所有 pane 共用这一处实现）：
#   ① `auto-review-model.sh` 健康门 —— 探活本地复核端点：可达 ⇒ 复核器钉本地（避开企业网关限流）；
#      不可达 ⇒ 摘钉、回退 cbc 内置链路（网关模型）。**钉了模型会禁用 cbc 内置 fallback**
#      （二进制 `resolveAutoReviewModels()` 一钉即 early-return），所以才需要这道门（详见脚本头注释）。
#   ② 前置 `CODEBUDDY_AUTO_REVIEW_TIMEOUT_MS=300000` —— auto 模式下每个需审批的工具调用都要过一次
#      复核器（默认 90s 硬上限，含整段会话上下文），企业网关抖动/429 时极易 no verdict ⇒ 整条命令被判失败。
#      用户级 settings.json 的 `env` 块同键兜底（覆盖手动启动的会话），两条路都留，任一失效仍生效。
dmt_harness_cmd() {
  local h="${1:-codebuddy}"
  if [ -n "${DMT_HARNESS_CMD:-}" ]; then printf '%s' "$DMT_HARNESS_CMD"; return 0; fi
  case "$h" in
    codebuddy) printf '%s' "bash '$DMT_SCRIPTS_DIR/auto-review-model.sh' --quiet; CODEBUDDY_AUTO_REVIEW_TIMEOUT_MS=300000 codebuddy --permission-mode auto" ;;
    # pi：`--approve` 必带 —— 项目级 .agents/skills 属「trust-requiring」，不批准则不装载
    # （实测 2026-11-03：无 --approve 只见用户级技能，项目内 dmt-* 一个都看不到）。
    pi)        printf '%s' 'pi --approve' ;;
    # opencode：`--auto` 预批权限，与 codebuddy 的 auto 同义；否则 pane 里会卡在授权提示。
    opencode)  printf '%s' 'opencode --auto' ;;
    # codex：`-a never` 免逐条审批。**首次进入项目目录仍需人工确认 trust（一次性）**。
    codex)     printf '%s' 'codex -a never' ;;
    # claude：Claude Code 的自动模式档位名就是 auto（实测可用）。
    claude)    printf '%s' 'claude --permission-mode auto' ;;
    *) echo "bad harness: $h" >&2; return 2 ;;
  esac
}
