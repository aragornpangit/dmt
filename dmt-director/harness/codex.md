# harness 差异：codex（OpenAI Codex CLI）

> 共性见 [`COMMON.md`](COMMON.md)；机器可读事实单一来源 [`../harness_matrix.yaml`](../harness_matrix.yaml)。

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

## 6. 特有约束

- 并发上限读 `[agents] max_concurrent_threads_per_session`（矩阵 `max_subagents_config`），矩阵静态默认 8。
- 会话树 `tree_mode: herdr`（走 herdr 会话树，不是同进程 fork）。
- `cbc-herdr` **不需要**（herdr 原生识别 codex）。
