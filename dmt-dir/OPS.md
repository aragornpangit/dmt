# dmt 可选操作适配器

默认流程使用 harness 原生 subagent 和返回通道，不要求下列设施。只有实际使用对应运行机制时才读取，不属于角色技能加载前置条件。

| 任务 | 文档 |
|---|---|
| herdr pane / tab / 启动与容量 | [`ops/runtime.md`](ops/runtime.md) |
| 收件箱消息、认领与收口 | [`ops/comms.md`](ops/comms.md) |
| 多写者文件占用 | [`ops/file-claim.md`](ops/file-claim.md) |
| helper 生命周期 | [`ops/helper.md`](ops/helper.md) |
| 权限问题排查 | [`ops/permission-notes.md`](ops/permission-notes.md) |
| 第三方技能 / MCP 点名 | [`ops/optional-skills.md`](ops/optional-skills.md) |
| 可选运行设施分层 | [`ops/adapter-matrix.md`](ops/adapter-matrix.md) |

主流程只要求核心产物目录。`inbox/`、`locks/`、helper 和 herdr/Orca 派生资源属于可选运行状态，不应进入正式交付物。
