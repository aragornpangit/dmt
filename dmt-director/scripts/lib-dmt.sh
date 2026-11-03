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

# harness 白名单与启动命令（用户 2026-10-31 裁定：默认 codebuddy，备选 pi / opencode / codex）。
# 解析优先级：显式参数 ⇒ $DMT_HARNESS ⇒ codebuddy。非法值 rc=2（错误写 stderr，便于调用方 fail-fast）。
dmt_harness_name() {
  local h="${1:-}"
  case "$h" in ""|-) h="${DMT_HARNESS:-codebuddy}" ;; esac
  case "$h" in
    codebuddy|pi|opencode|codex) printf '%s' "$h" ;;
    *) echo "bad harness: $h (want codebuddy|pi|opencode|codex)" >&2; return 2 ;;
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
    pi)        printf '%s' 'pi' ;;
    opencode)  printf '%s' 'opencode' ;;
    codex)     printf '%s' 'codex' ;;
    *) echo "bad harness: $h" >&2; return 2 ;;
  esac
}
