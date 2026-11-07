# 可选 pi 子代理模板

本目录用命名 agent + `skills:` 白名单注入 DMT 角色技能。安装 pi 适配器后，优先使用与任务对应的 agent 名：

- `dmt-de`
- `dmt-ana-e`
- `dmt-pde`
- `dmt-reviewer`

模板只预选角色自身技能，其他工具按任务和环境自行选择。pi 无通用 Skill 工具，需要技能正文时读取对应 `SKILL.md`。

未安装命名定义时，用 `delegate` 并在 prompt 中给出角色技能绝对路径。机制见 [`../pi.md`](../pi.md)。
