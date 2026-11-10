# 可选：运行环境与平台适配

角色技能不绑定运行平台。只有任务需要平台特定的技能调用、子代理或多 pane 编排时，才加载对应适配器。

1. 用 `dmt-dir/scripts/harness-detect.sh` 识别当前平台；无法识别时报告派发者，不猜默认值。
2. 读取 [`../harness/COMMON.md`](../harness/COMMON.md) 和当前平台的一份差异文档。
3. 启动命令、技能目录、调用前缀和并发能力以 [`../harness_matrix.yaml`](../harness_matrix.yaml) 为准。
4. 子代理的命名、技能注入和等待方式使用平台原生能力；不可用时明确降级，不伪造多代理。
5. 并发数量按依赖与容量决定；`dmt-dm` 接到工单后对无依赖单元用 workflow 或多个 subagents **一次性开满**、直接派 `dmt-de`（见 `dmt-dm/SKILL.md` 与 [`07-discipline.md`](07-discipline.md)），有依赖或共享资源才串行并写明理由。配置值只是全局上限；显式启用可选协调者 `dmt-dl` 时，其在票批内同样开满，但不得按层各自占满而突破该全局水位。

herdr pane 生命周期见 [`../ops/runtime.md`](../ops/runtime.md)。单纯加载角色技能不执行以上步骤。
