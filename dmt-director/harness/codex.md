# harness 差异：codex（OpenAI Codex CLI）

> 共性见 [`COMMON.md`](COMMON.md)；机器事实见 [`../harness_matrix.yaml`](../../dmt-director/harness_matrix.yaml)。

## 1. 发现目录与启动

- 项目级 `.agents/skills/`、`.codex/skills/`；用户级 `~/.agents/skills/`、`~/.codex/skills/`。
- `codex -a never`（免逐条审批）；自动档判据认 `-a never` / `--ask-for-approval never` / `--yolo`。
- **首次进项目目录需人工确认 trust（一次性）**，`-a never` 不免；卡在 trust 提示时由 director 手工确认后重跑 `setup-team.sh`。

## 2. 技能调用行

- dmt 角色技能：`/dmt-<角色>`（原名）。
- mattpocock 插件技能带前缀 **`mattpocock-skills:<name>`**（`lib-dmt.sh: dmt_skill_ref` 按矩阵 `skill_prefix` 生成）。
- 兼容副本与插件**二选一**，避免同名重复登记（shim 见仓根 `scripts/sync-mattpocock-codex-compat.sh`）。

## 3. 技能如何到达模型

- 启动器接受首轮 prompt（矩阵 `first_prompt: true`）⇒ 角色技能与任务随启动一次下发（`dmt_start_has_first_prompt` 判据），不能指望启动后再敲斜杠。
- 子代理：`spawn_agent` 派发、`wait_agent` 收结果；模板见 [`../team/07b-dispatch.md`](../team/07b-dispatch.md)。
- 没有 `spawn_agent` 接口时不得用 shell 嵌套 `codex exec` 伪造团队，只做本 pane 工作并记 `[SUBAGENT_UNAVAILABLE]`。

## 4. 两条硬约束（2026-11-06 三角色实测）

### 4.1 sandbox 必须 `danger-full-access`，否则 pane 通信全废

默认 sandbox 是 Workspace（受限）：codex shell 连 herdr unix socket 直接 `PermissionDenied` ⇒ 门铃必跳过（`WARN: pane label … not found`）、`dmt_pane_by_label` 全空、身份自证与 file-claim 失效。同脚本同 pane 只改 sandbox 的对照：`workspace-write` ❌ / `danger-full-access` ✅。

⇒ 角色 pane 必须 `codex -a never --sandbox danger-full-access`（矩阵 `start_cmd` 已改）。安全含义：放开文件系统与网络沙箱，仅在受控开发机 / 容器内使用。

### 4.2 shell 复用陈旧常驻环境（`HERDR_*` 指向废弃 session）

codex 进程自身 `environ` 正确，但 `exec_command`（`bash -lc`）里是旧 session ⇒ 启动时 `env HERDR_…` 也无效（复用统一执行器的常驻 shell，不读父进程 env）。现象：`send-msg.sh` 报 `server_not_running …/herdr.sock`。

已修：`lib-dmt.sh: dmt_herdr_env_fix [目标label]` —— 当前 socket 连不上时扫 `~/.config/herdr/sessions/*/herdr.sock`，取「含目标 label 且 `cwd==$PWD`」的唯一命中并 export（多命中不动、不猜）；`send-msg.sh` 寻址前先调它。必须是函数：`pane="$(dmt_pane_by_label …)"` 是子 shell，函数内 export 传不回父进程。

## 5. 特有约束

- 并发上限读 `[agents] max_concurrent_threads_per_session`（矩阵 `max_subagents_config`），静态默认 8。
- 会话树 `tree_mode: herdr`（走 herdr 会话树，不是同进程 fork）。
- `cbc-herdr` 不需要（herdr 原生识别 codex）。
