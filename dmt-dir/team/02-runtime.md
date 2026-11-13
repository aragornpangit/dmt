# 可选：harness 运行平台适配

角色技能不绑定运行平台。加载后先完成第 1 步的两轴环境探测；只有任务需要平台特定的技能调用、子代理或多 pane 编排时，才加载对应适配器。

1. 加载后探测两轴：`dmt-dir/scripts/harness-detect.sh` 判定当前 harness（pi / codebuddy / claudecode / codex / opencode 之一），`dmt-dir/scripts/runtime-detect.sh` 判定 harness 运行平台（herdr / orca / t3code / none）；无法识别时报告派发者，不猜默认值。
2. 读取 [`../harness/COMMON.md`](../harness/COMMON.md) 和当前平台的一份差异文档。
3. 启动命令、技能目录、调用前缀和并发能力以 [`../harness_matrix.yaml`](../harness_matrix.yaml) 为准。
4. 子代理的命名、技能注入和等待方式使用平台原生能力；不可用时明确降级，不伪造多代理。
5. 并发数量按依赖与容量决定；`dmt-dm` 接到工单后对无依赖单元用 workflow 或多个 subagents **一次性开满**、直接派 `dmt-de`（见 `dmt-dm/SKILL.md` 与 [`07-discipline.md`](07-discipline.md)），有依赖或共享资源才串行并写明理由。配置值只是全局上限；显式启用可选协调者 `dmt-dl` 时，其在票批内同样开满，但不得按层各自占满而突破该全局水位。
6. 使用 harness 运行平台时另读 [`../harness/README.md`](../harness/README.md) 列出的适配器；herdr / Orca / T3 Code 都不是 harness，不改矩阵 `harnesses:` 段，也不新增 `per_harness` 条目。运行平台分 `runtimes:`（herdr）与 `ades:`（Orca、T3 Code）两段，成员各带 `kind`；`harness-detect.sh` 只判 harness，`runtime-detect.sh` 只判运行平台。

投递通道由第 1 步的运行平台判定结果决定，不按 harness 猜：判为 herdr 时走 [`../ops/runtime.md`](../ops/runtime.md) 的 pane 三步，判为 orca / t3code 时读 [`../harness/orca.md`](../harness/orca.md) 的 `terminal send --enter --wait-submit` 三步；两者都须按 [`03-comms.md`](03-comms.md) 的「回执三步」复核提交。

herdr pane 生命周期见 [`../ops/runtime.md`](../ops/runtime.md)。加载角色技能后执行第 1 步；第 2–6 步仅在任务需要平台能力时执行。
