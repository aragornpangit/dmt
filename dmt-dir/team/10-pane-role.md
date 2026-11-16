# 可选：herdr pane 角色公共动作

只有角色部署在 herdr pane 时使用本页。

- 身份使用唯一 pane label，不依赖 tab 位置或长期缓存 pane id。
- 角色声明所需容量和生命周期意图；具体 tab/pane 创建、移动和关闭由运行脚本执行。
- 本文件只在采用 herdr 多 pane 适配器时读取。默认使用 harness 原生 subagent；忙不过来且任务可独立拆分时，`dmt-dir` / `dmt-dm` / `dmt-am` 才可在自身 tab 内 split 出 `{角色}-helper` 分身；helper 只向派生者单线汇报，任务完成由派生者回收 pane。
- 关闭前确认工作已收口，避免用关闭 tab 连带影响其他 pane。
- 技能调用前缀和子代理方式从 harness 矩阵生成，不手猜。
- 完成、阻塞或需要裁决时向派发者回报目标、结论、产物、证据和未决项。

详细操作见 [`../ops/runtime.md`](../ops/runtime.md)、[`../ops/comms.md`](../ops/comms.md) 和 [`../ops/helper.md`](../ops/helper.md)。
