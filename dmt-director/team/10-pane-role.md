# 可选：herdr pane 角色公共动作

只有角色部署在 herdr pane 时使用本页。

- 身份使用唯一 pane label，不依赖 tab 位置或长期缓存 pane id。
- 角色声明所需容量和生命周期意图；具体 tab/pane 创建、移动和关闭由运行脚本执行。
- `devm` 通过 `devl-pane.sh` 表达队长容量需求，适配器可为此创建新 tab；不另行手工重复建 tab。
- 关闭前确认工作已收口，避免用关闭 tab 连带影响其他 pane。
- 技能调用前缀和子代理方式从 harness 矩阵生成，不手猜。
- 完成、阻塞或需要裁决时向派发者回报目标、结论、产物、证据和未决项。

详细操作见 [`../ops/runtime.md`](../ops/runtime.md)、[`../ops/comms.md`](../ops/comms.md) 和 [`../ops/helper.md`](../ops/helper.md)。
