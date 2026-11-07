# harness 差异：claude

共性见 [`COMMON.md`](COMMON.md)，机器事实见 [`../harness_matrix.yaml`](../harness_matrix.yaml)。

- 项目技能目录为 `.claude/skills/`，用户级为 `~/.claude/skills/`；opencode 也可能共用该项目目录。
- 技能调用为 `/<技能名>`；无法调起时读取技能文件路径。
- 子代理使用平台原生机制，派发字段见 [`../team/07b-dispatch.md`](../team/07b-dispatch.md)。
- 权限模式由用户和项目安全策略决定。自动审批服务不可用或限流时报告失败，不默认切换到跳过权限模式。
- 用户配置可能使实际权限与 argv 不一致，判断失败时以实际配置为准。
- 并发能力和环境变量以矩阵为准；上限不是并行目标。
