# harness 差异：codex（OpenAI Codex CLI）

> 共性见 [`COMMON.md`](COMMON.md)；机器可读事实单一来源 [`../harness_matrix.yaml`](../../dmt-director/harness_matrix.yaml)。

## 1. 技能发现目录

| 级别 | 目录 |
|---|---|
| 项目级 | `.agents/skills/`、`.codex/skills/` |
| 用户级 | `~/.agents/skills/`、`~/.codex/skills/` |

## 2. 启动与权限

- `codex -a never`（`-a never` = 免逐条审批）。自动档判据认 `-a never` / `--ask-for-approval never` / `--yolo`。
- **首次进入项目目录需人工确认 trust（一次性）**：`-a never` 不免这一步；pane 卡在 trust 提示时由 director 手工确认后重跑 `setup-team.sh`。

## 3. 技能调用行

- dmt 角色技能：`/dmt-<角色>`（原名）。
- **mattpocock 插件技能带限定前缀 `mattpocock-skills:<name>`**（由 `lib-dmt.sh: dmt_skill_ref` 按 `harness_matrix.yaml: skill_prefix` 生成）。
- 兼容副本与插件**二选一**，避免同名技能重复登记（shim 见仓根 `scripts/sync-mattpocock-codex-compat.sh`）。

## 4. 技能如何到达模型

- 启动器接受首轮 prompt（矩阵 `first_prompt: true`）⇒ **角色技能与任务随启动一次下发**（`dmt_start_has_first_prompt` 判据），不能指望「启动后再敲斜杠」。
- 子代理：`spawn_agent` 派发、`wait_agent` 收结果；派发模板见 [`../team/07b-dispatch.md`](../team/07b-dispatch.md) 的「Codex harness 承载」。
- herdr 角色 pane 内**没有** `spawn_agent` 接口时不通过 shell 嵌套 `codex exec` 伪造团队，只在本 pane 完成本角色工作并记 `[SUBAGENT_UNAVAILABLE]`。

## 5. 强制技能

`/<name>`；mattpocock 用 `mattpocock-skills:<name>`（如 `mattpocock-skills:code-review`）。

## 6. 两条硬约束（2026-11-06 三角色端到端实测，必须遵守）

### 6.1 sandbox 必须 `danger-full-access`，否则 pane 通信全废

- 默认 `codex -a never` 的 sandbox 是 **Workspace**（受限）。实测在 codex 的 shell 里连 herdr 的 unix socket 直接 `Error: Os { code: 1, kind: PermissionDenied, message: "Operation not permitted" }` ⇒ **`send-msg.sh` 门铃必然跳过**（`WARN: pane label 'director' not found`）、`dmt_pane_by_label` 全空、身份自证与 file-claim 失效。
- 判据对照（同一脚本、同一 pane，只改 sandbox）：

  | sandbox | `herdr pane list` | 门铃 |
  |---|---|---|
  | 默认 `workspace-write` | ❌ PermissionDenied | ❌ WARN，只落文件不发门铃 |
  | `--sandbox danger-full-access` | ✅ | ✅ director 收到并认领收口 |

- ⇒ **dmt 的角色 pane 必须** `codex -a never --sandbox danger-full-access`（矩阵 `start_cmd` 已改）。安全含义：放开文件系统与网络沙箱；仅在受控开发机/容器内使用（与 `--dangerously-bypass-approvals-and-sandbox` 同级的信任假设）。

### 6.2 codex 的 shell 复用**陈旧常驻 shell 环境**（`HERDR_*` 会指向废弃 session）

- 实测：codex 进程自身 `/proc/<pid>/environ` 的 `HERDR_WORKSPACE_ID=w9`、`HERDR_SESSION=bcr-nh` **正确**；但它的 `exec_command`（`bash -lc`）里却是 `w1` / `bcr-nihui`（早已不存在的 session）⇒ 即使启动时用 `env HERDR_…=正确值 … codex` **也无效**（它复用的是统一执行器的常驻 shell，不读父进程 env）。
- 现象：`send-msg.sh` 报 `server_not_running .../sessions/bcr-nihui/herdr.sock`；anam 侧同样报 herdr 不可用。
- **dmt 侧已修（第八十三次）**：`lib-dmt.sh` 新增 `dmt_herdr_env_fix [目标label]` —— 当前 socket 连不上时，扫描 `~/.config/herdr/sessions/*/herdr.sock`，取「含目标 label 且 `cwd==$PWD`」的**唯一**命中并 export 修正（多命中一律不动、不猜）。`send-msg.sh` 在寻址前先调它。
  - 为什么单独一个函数：`pane="$(dmt_pane_by_label …)"` 是**子 shell**，函数内的 export 传不回父进程 ⇒ 会出现「查到了 pane、发送仍走陈旧 socket」（实测到过这一步）。
- codex 自己派子代理（`spawn_agent`）另有独立问题：实测**工具被调用**（三角色分别 1/2/2 次）但**任务载荷没送达**（子代理回「消息队列为空」/角色漂移）⇒ 该轮记 `[SUBAGENT_UNAVAILABLE]`，由本 pane 代行。

## 7. 特有约束

- 并发上限读 `[agents] max_concurrent_threads_per_session`（矩阵 `max_subagents_config`），矩阵静态默认 8。
- 会话树 `tree_mode: herdr`（走 herdr 会话树，不是同进程 fork）。
- `cbc-herdr` **不需要**（herdr 原生识别 codex）。
