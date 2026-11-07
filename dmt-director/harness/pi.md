# harness 差异：pi

共性见 [`COMMON.md`](COMMON.md)，机器事实见 [`../harness_matrix.yaml`](../harness_matrix.yaml)。

## 技能与权限

- 项目级技能目录为 `.agents/skills/`；用户级可用 `~/.agents/skills/`、`~/.pi/agent/skills/`。
- pane 中显式调用为 `/skill:<技能名>`；普通 `/name` 可能只被当作提问。
- 项目技能可见性和权限由当前 pi 配置决定，启动参数见矩阵。

## 子代理

pi 没有通用 Skill 工具，子代理默认也不一定继承技能。优先使用项目 `.pi/agents/` 或用户级命名 agent 定义：

- `inheritSkills: false` + `skills:` 可精确注入角色技能。
- 未安装命名定义时，用内置 `delegate` 并在 prompt 中给出角色技能的绝对路径。
- 带 `disable-model-invocation: true` 的技能可能从 `skills:` 过滤，需直接读取文件。
- 需要调用另一个技能而平台不支持时，读取其 `SKILL.md`，不要假设调用成功。

`pi-agents/` 提供 DMT 角色模板。具体并发、门铃和启动时序以当前版本实测与矩阵为准；容量上限不是并行目标。
