# harness 差异：codebuddy

共性见 [`COMMON.md`](COMMON.md)，机器事实见 [`../harness_matrix.yaml`](../harness_matrix.yaml)。

- 项目技能目录为 `.codebuddy/skills/`，用户级为 `~/.codebuddy/skills/`。
- 技能调用为 `/<技能名>`；teammate 可继承技能清单，子代理用唯一角色名并显式说明任务。
- 权限模式由用户和项目安全策略决定；矩阵中的启动参数是可选自动化配置，不是角色加载要求。
- 需要 herdr 状态上报时启用 `cbc-herdr`；进程检测同时识别可执行名 `cbc` 与 `codebuddy`。
- 并发实际上限读取矩阵或当前环境配置，不要求开满。
- 无法调用技能时读取对应 `SKILL.md`；无法使用子代理时报告能力缺口。
