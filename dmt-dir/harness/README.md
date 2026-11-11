# 可选 harness 适配器

## 术语（两轴，不得混用）

- **harness** = 承载 agent 的 CLI，共 5 个：`pi` / `cbc`(codebuddy) / `claudecode` / `codex-cli` / `opencode`。判据：有自己的技能发现目录、slash 前缀、子代理机制与启动档，即矩阵 `harnesses:` 段。
- **harness 运行平台（harness-runtime-platform）** = 承载 harness 运行的环境，只提供 pane / worktree / 界面 / 编排 / 通信原语，里面跑的仍是某个 harness，**不是 harness**。矩阵分两段、成员各带 `kind`：`runtimes:`（herdr，`kind: pane-runtime`）与 `ades:`（Orca、T3 Code，`kind: ade`）；两段可叠加，不合并成单一枚举。

`harness-detect.sh` 只判定 harness，`runtime-detect.sh` 只判定 harness 运行平台；两者正交，不合并成单一枚举。

实际使用某个平台时读取 [`COMMON.md`](COMMON.md) 与对应一份差异文档：

- [`pi.md`](pi.md)
- [`codebuddy.md`](codebuddy.md)
- [`claude.md`](claude.md)
- [`codex.md`](codex.md)
- [`opencode.md`](opencode.md)

技能目录、调用前缀、启动命令和并发能力以 [`../harness_matrix.yaml`](../harness_matrix.yaml) 为唯一机器事实。pi 的命名子代理模板在 [`pi-agents/`](pi-agents/README.md)。

## 可选 harness 运行平台适配器

运行平台成员不是 harness：其中运行的仍是上面某个 agent。使用时另读对应适配器，机器事实分别在矩阵 `runtimes:` / `ades:` 段，`harnesses:` 段与 `per_harness` 不变：

- [`orca.md`](orca.md) —— Orca worktree、编排派发与终端消息映射（`ades.orca`）。
- herdr 侧（`runtimes.herdr`）见 [`../ops/runtime.md`](../ops/runtime.md)，归 `ops_docs`。

`BACKLOG.md` 是维护资料，不进入角色加载路径。加载角色技能后先按 [`../team/02-runtime.md`](../team/02-runtime.md) 第 1 步探测 harness 与其运行平台；本目录仅在任务需要平台能力时读取。
