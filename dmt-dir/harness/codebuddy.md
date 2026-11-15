# harness 差异：codebuddy

共性见 [`COMMON.md`](COMMON.md)，机器事实见 [`../harness_matrix.yaml`](../harness_matrix.yaml)。

- 项目技能目录为 `.codebuddy/skills/`，用户级为 `~/.codebuddy/skills/`。
- 技能调用为 `/<技能名>`；teammate 可继承技能清单，子代理用唯一角色名并显式说明任务。
- 启动档为 yolo：`codebuddy --dangerously-skip-permissions`（`-y` 同义），子代理另配 `--subagent-permission-mode bypassPermissions`，否则 teammate 可能回 default 档逐条撞审批。首次进入新目录仍可能有一次信任确认。
- 需要 herdr 状态上报时启用 `cbc-herdr`；进程检测同时识别可执行名 `cbc` 与 `codebuddy`。
- 并发实际上限读取矩阵或当前环境配置，不要求开满。
- 无法调用技能时读取对应 `SKILL.md`；无法使用子代理时报告能力缺口。
