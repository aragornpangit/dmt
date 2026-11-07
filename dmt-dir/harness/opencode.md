# harness 差异：opencode

共性见 [`COMMON.md`](COMMON.md)，机器事实见 [`../harness_matrix.yaml`](../harness_matrix.yaml)。

- 项目技能目录可用 `.agents/skills/`、`.claude/skills/`、`.opencode/skills/`；使用复数目录名。
- 技能显式引用为 `@<技能名>`；不可用时尝试平台 `skill({id})`，再不可用时读取 `SKILL.md`。
- 子代理 prompt 中显式给出技能引用或路径，以及输入、边界、产物和判据。
- 权限模式由用户和项目安全策略决定，不默认跳过审批。
- 并发入口和启动行为以当前版本与矩阵为准；未声明上限时按任务和容量自判。
- herdr 门铃发送后需确认输入已被接受，不能只凭写入终端判断送达。
