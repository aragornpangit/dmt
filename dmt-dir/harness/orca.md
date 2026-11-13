# ADE 编排适配器：Orca

Orca 是编排层（ADE），不是 harness：其中运行的仍是 [`../harness_matrix.yaml`](../harness_matrix.yaml) `harnesses:` 段里的某个 agent CLI。共性见 [`COMMON.md`](COMMON.md)；机器事实见矩阵 `ades.orca`（`kind: ade`），harness 运行平台衬底见 `runtimes.herdr`（`kind: pane-runtime`）。仅在实际使用 Orca 编排时读取本文；harness 运行平台由 `runtime-detect.sh` 在加载技能后判定，本文不改 `harnesses:` 段或 `per_harness` 清单。

## 运行时

1. `orca serve --no-pairing --json` 起 headless runtime（前台常驻），`orca open --json` 起桌面端；先 `orca status --json` 确认 `runtime.state=ready`。
2. 未启动时 `status` 报 `stale_bootstrap/disconnected`，`worktree` / `terminal` / `orchestration` 等命令报 `runtime_unavailable`；这是状态问题，不是技能不兼容。
3. Linux 上裸 `orca` 可能是 GNOME screen reader；可执行文件按当前会话规则选择（`ORCA_CLI_COMMAND` / `orca-ide` / `orca-dev`），不要硬编码。

## 技能

- `install-skills.sh <worktree> --copy --harness all` 把 7 个角色技能铺到三处落点；worktree 内 `check-dmt.sh` 应 `ALL_PASS`。
- `orca skills installed --json` 列出用户安装的技能（含 dmt-\*，各带 selector id）；项目级 `.agents/skills` 优先于用户级同名技能。
- `orca skills list/get` 只服务 Orca 自带的版本匹配指南，`skills get dmt-dir` 报 `Unknown skill topic`，不是缺陷。
- `orca skills share` 会发布外链，需 Settings → Share Skills 与用户显式授权，不作为团队通信默认前提。
- 终端里的 agent 若无 Skill 工具（如 pi），按 [`pi.md`](pi.md) 降级为直接读取 `SKILL.md`，不要假设斜杠命令可用。

## 工作区与派发

- 一个实施单元一个 worktree：`orca repo add --path <path>` → `orca worktree create --repo path:<path> --name <name> --setup skip --json`，对应 [`../team/07-discipline.md`](../team/07-discipline.md) 的隔离要求。
- `orca agent launch --agent <id> --worktree path:<path> --surface terminal --json` 返回 terminal handle；首轮 prompt 用 `orca terminal send` 注入，不假定启动即接受 prompt。
- **投递三步（回执）**：`orca terminal send` 默认**不追加回车**，必须显式 `--enter`；一律用 `orca terminal send --terminal <id> --text '<msg>' --enter --wait-submit 15`，再复核提交回执（send-text → enter → 复核，见 [`../team/03-comms.md`](../team/03-comms.md)，对应 herdr 的 `pane send-text` + `pane send-keys enter` + `pane read`）。`--wait-submit` 只观察已接受的 prompt，超时返回 input-accepted 收据且**不重发**；传输歧义时用返回的 `--retry-request <id>` 原样重发，不要另拼文本。
- 无依赖单元并行派发用 `orchestration task-create` / `dispatch` / `worker-start`；等待用 `terminal wait --for tui-idle`、`orchestration worker-read` / `ask`，避免无意义轮询。
- 子代理只向派发者回报：`orchestration reply` / `send` 指向派发者 handle，worker 完成走 `worker_done`；角色间互连仍按 [`../team.md`](../team.md) 禁止。
- `orchestration task-list` 等命令从 CLI 裸调会报 `no_active_sender_terminal`，需 `--from <自身终端句柄>` 或在 Orca 终端内带 `ORCA_TERMINAL_HANDLE`。
- 并发上限取矩阵 `harnesses:` 的值与 Orca 当前容量的交集，矩阵不另设 ADE 独立上限。

## 与 herdr 适配器的差异

- `send-msg.sh` / `msg-done.sh` / `setup-team.sh` / `dl-pane.sh` 与 `lib-dmt.sh` 的 `dmt_herdr_*` 绑 herdr，在 Orca 里不可用；用上文的 Orca 原生命令替代，不伪造多代理。
- 门铃由 `orca terminal send --terminal <id> --text '<msg>' --enter --wait-submit 15` + `orchestration inbox` 承担，替代 `herdr agent prompt`；发送后按三步复核提交。[`../ops/runtime.md`](../ops/runtime.md) 的 pane 布局只适用于 herdr 部署。
- `file-claim.sh` 仍可用于同一 worktree 内多写者协调；跨 worktree 的隔离由 Orca 物理边界保证。

## 实测记录

2026-11-09，Orca 1.4.237：`serve` → `repo add` → `worktree create` → `agent launch --agent pi`。pi 启动屏 `[Skill warnings]` 登记全部 7 个 dmt 技能（项目级优先）；随后读取 `dmt-dir/SKILL.md` 回报 `version 5.19.7` 与工作流第 1 条原文，并明确结论「可用」。
