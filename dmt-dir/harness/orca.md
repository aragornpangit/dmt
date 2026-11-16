# ADE 编排适配器：Orca

Orca 是编排层（ADE），不是 harness：其中运行的仍是 [`../harness_matrix.yaml`](../harness_matrix.yaml) `harnesses:` 段里的某个 agent CLI。共性见 [`COMMON.md`](COMMON.md)；机器事实见矩阵 `ades.orca`（`kind: ade`）；`runtimes:` 与 `ades:` 是并列两段，herdr 不是 Orca 的衬底。仅在实际使用 Orca 编排时读取本文；harness 运行平台由 `runtime-detect.sh` 在加载技能后判定，本文不改 `harnesses:` 段或 `per_harness` 清单。

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
- **启动档不受矩阵 `start_cmd` 控制**：`agent launch` 用 Orca 自己的参数表（实测 1.4.237：claude / codebuddy `--dangerously-skip-permissions`、codex `--dangerously-bypass-approvals-and-sandbox`、hermes `--yolo`；**pi 与 opencode 原表缺失**，pi 会起成裸 `pi` 停在目录信任提示）。要统一 yolo，用 `orca-launch.sh <harness> --worktree path:<path>` 起终端 —— 它按矩阵 `start_cmd` 下发并登记台账；完成后 `orca-reap.sh` 回收。
- **本机已打 Orca 本地补丁（2026-11-15）**：在 `orcad-artifacts/.../out/cli/index.js` 的 `YW={` 与 `orcad-server.js` 的 `yA={` 后各插入 `pi:"--approve",opencode:"--auto",`，使 `agent launch` 对 6 个 harness 全部走 yolo。原文件留 `.bak-dmt-yolo` 备份，`node --check` 通过。**Orca 升级会覆盖，升级后需重打**；生效需重启运行时（`systemctl --user restart orca-serve`），重启会结束当前所有终端。
- **handle 只归派发者**：`agent launch` / `terminal create` / `orca-launch.sh` 返回的 handle 由发起者持有，不向上级转交，也不接受越级索取。上级要看进展，收产物（commit SHA、diff、测试输出），不读下级屏幕；`orca terminal read` 只对派发者自己派生的终端使用。
- **派生终端要回收**：`orca-launch.sh` 写入 `<项目根>/.dmt/orca-terminals.tsv`，`orca-reap.sh [--role <name>] [--list|--dry-run]` 按台账关闭；手工起的终端用 `orca terminal close --terminal <handle>`。规则见 [`../team/07-discipline.md`](../team/07-discipline.md)「派生资源的生命周期」。
- **投递三步（回执）**：`orca terminal send` 默认**不追加回车**，必须显式 `--enter`；一律用 `orca terminal send --terminal <id> --text '<msg>' --enter --wait-submit 15`，再复核提交回执（send-text → enter → 复核，见 [`../team/03-comms.md`](../team/03-comms.md)，对应 herdr 的 `pane send-text` + `pane send-keys enter` + `pane read`）。`--wait-submit` 只观察已接受的 prompt，超时返回 input-accepted 收据且**不重发**；传输歧义时用返回的 `--retry-request <id>` 原样重发，不要另拼文本。
- 无依赖单元并行派发用 `orchestration task-create` / `dispatch` / `worker-start`；等待用 `terminal wait --for tui-idle`、`orchestration worker-read` / `ask`，避免无意义轮询。
- 子代理只向派发者回报：`orchestration reply` / `send` 指向派发者 handle，worker 完成走 `worker_done`；角色间互连仍按 [`../team.md`](../team.md) 禁止。
- `orchestration task-list` 等命令从 CLI 裸调会报 `no_active_sender_terminal`，需 `--from <自身终端句柄>` 或在 Orca 终端内带 `ORCA_TERMINAL_HANDLE`。
- 并发上限取矩阵 `harnesses:` 的值与 Orca 当前容量的交集，矩阵不另设 ADE 独立上限。

## 与 herdr 适配器的差异

- `send-msg.sh` / `setup-team.sh` 与 `lib-dmt.sh` 的 `dmt_herdr_*` 绑 herdr，在 Orca 里不可用；`msg-done.sh` 只操作文件，可在 Orca 使用；用上文的 Orca 原生命令替代，不伪造多代理。
- 门铃由 `orca terminal send --terminal <id> --text '<msg>' --enter --wait-submit 15` + `orchestration inbox` 承担，替代 `herdr agent prompt`；发送后按三步复核提交。[`../ops/runtime.md`](../ops/runtime.md) 的 pane 布局只适用于 herdr 部署。
- `file-claim.sh` 仍可用于同一 worktree 内多写者协调；跨 worktree 的隔离由 Orca 物理边界保证。

## 实测记录

2026-11-09，Orca 1.4.237：`serve` → `repo add` → `worktree create` → `agent launch --agent pi`。pi 启动屏 `[Skill warnings]` 登记全部 7 个 dmt 技能（项目级优先）；随后读取 `dmt-dir/SKILL.md` 回报 `version 5.19.7` 与工作流第 1 条原文，并明确结论「可用」。

## 运行时稳态：寻址、实例隔离、回收（2026-11-16 实测）

> 本节只写 Orca 运行时纪律，不改 `harnesses:` 段与任何判据。逐条对应本机一手实测。

1. **一角色一 harness，中途不换**：换 harness ＝ 换进程，上下文只能靠自述延续，且 `agentIdentity` 会滞后（曾报 `None`）。要换档就新起 pane 派新角色，不在原 pane 里重启换 CLI。
2. **寻址用 `ORCA_PANE_KEY`（`<tabId>:<leafId>`），不用 handle／title／identity**：
   - `ORCA_TERMINAL_HANDLE` 随 pane 重启（incarnation）失效；发令前用 `orca terminal list --json` 反查当前 handle。
   - `title` 会被对话摘要覆盖（实测本 pane 被写成「执行 dmt-dir 命令」），`agentIdentity` 会滞后 ⇒ 二者只作线索，不作寻址键。
   - 派生台账 `.dmt/orca-terminals.tsv` 已增第 6 列 `pane_key`（`scripts/orca-launch.sh` 写入、`orca-reap.sh` 消费；旧 5 列行按 `-` 补齐）。
3. **改标题用 `rename`，不用 `set-pane-title`**：实测同一 handle 下
   `orca terminal rename --terminal "$ORCA_TERMINAL_HANDLE" --title dmt-dir` ⇒ `ok:true`；
   `orca terminal set-pane-title` 同 handle ⇒ `terminal_handle_stale`。标题仍会被摘要覆盖，覆盖后重跑 `rename`（幂等）。
4. **`orca agent hooks status` 的 `Cannot find module './impl/format'` 已修，升级后会复发**：
   根因是 orca 1.4.237 的 `out/cli/index.js` 内联了 jsonc-parser 主模块，但 UMD 分支仍 `require("./impl/format")`，
   而 bundle 未含 `impl/*` 四个子模块。修法＝把本机 `jsonc-parser`（3.x，UMD 版）的
   `impl/{format,edit,scanner,parser,string-intern}.js` 复制到 `<artifact>/out/cli/impl/`。
   脚本：`scripts/orca-fix-cli-impl.sh`（幂等；`--check` 只判定）。**每次 orca 升级后跑一次**，
   否则 hooks 子系统静默不可用。未修前不得用 hooks 判活，改用 `terminal list --json` 的 `connected`／`agentIdentity`。
5. **Hermes 实例隔离**：本机 gateway 与 agent 共用默认 `~/.hermes`（含 `memory/`、`skills/`、`state.db`），已发生互相覆盖。
   多实例必须各设 `HERMES_HOME`，技能用副本而非共享软链。
6. **裸 shell 及时回收**：`identity=None` 且无前台进程的 pane 属残留，用 `orca terminal close --terminal <handle>` 关；
   关前先 `orca terminal read` 看前台，避免误杀正在跑的命令。
7. **一个证据目录同时只允许一个写者**：同桶并发写会互相覆盖（2026-11-16 135 实测：两路同时跑同一 `raw/`，
   窗口时刻非单调、读数不可采信）。跨角色共桶时按路分桶或先取锁。
8. **长回执落盘、终端只回指针**：回执超一屏必写 `<role>-reply-<ts>.md`，终端回路径＋三行结论；关键结论回写仓内证据桶，`/tmp` 件会丢。
