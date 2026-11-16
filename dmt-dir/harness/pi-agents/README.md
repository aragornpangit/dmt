# 可选 pi 子代理模板

本目录用命名 agent + `skills:` 白名单注入 DMT 角色技能。安装 pi 适配器后，优先使用与任务对应的 agent 名：

- `dmt-de`
- `dmt-ae`
- `dmt-pde`
- `dmt-reviewer`

`skills:` 是**白名单而非附加项**：`inheritSkills: false` 时子代理以 `--no-skills` 启动，只有列在这里的技能会进入子代理的 `<available_skills>` 目录。因此必须同时列出角色技能本身与契约 `role_skills` 的全部条目，漏列等于子代理不知道该技能存在：

| 模板 | `skills:` |
|---|---|
| `dmt-de` | `dmt-de, tdd, implement, code-review` |
| `dmt-reviewer` | `dmt-reviewer, code-review` |
| `dmt-pde` | `dmt-pde, to-spec` |
| `dmt-ae` | `dmt-ae, research` |

`dmt-ae` 契约里的 `rea` 本机未安装，列进去只会恒报 missing，故不列；需要时先铺该技能再补。

pi 无通用 Skill 工具，子代理按注入目录里的描述自行决定，命中后 `read` 对应 `SKILL.md`。带 `disable-model-invocation: true` 的技能会被注入环节过滤，所以白名单必须指向 `skills-unlocked` 解锁副本。

未安装命名定义时，用 `delegate` 并在 prompt 中给出角色技能绝对路径。机制见 [`../pi.md`](../pi.md)。
