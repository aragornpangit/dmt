# pi 子代理 agent 定义模板（dmt 四个子代理角色）

pi 的 `delegate` 子代理默认 `inheritSkills: false`（无技能清单、无 Skill 工具）。本目录给 dmt 四个**子代理角色**各一份 agent 定义模板，用 `inheritSkills: false` ＋ `skills:` **精确白名单**把「角色技能 ＋ 该角色的强制技能」注入子代理。

> 机制与实测见 [`../pi.md`](../pi.md) §4.1；强制技能清单见 [`../../team/03-comms.md`](../../team/03-comms.md) §1.4。

## 用法

`install-skills.sh --harness pi` 会把本目录铺到目标项目的 **`.pi/agents/`**。派发时 `agent` 字段填对应定义名（不再用 `delegate`）：

```js
await runs.run({ agent: "dmt-dev-e",  prompt: "你是 devl{n} 的 dev-e 子代理。票：..." });
await runs.run({ agent: "dmt-ana-e", prompt: "你是 anam 的 ana-e 子代理。单元：..." });
await runs.run({ agent: "dmt-pde",   prompt: "你是 director 的 pde1 子代理。单元：..." });
await runs.run({ agent: "dmt-reviewer", prompt: "你是 devl{n} 的 reviewer1 子代理。票：..." });
```

**未安装 agent 定义时**仍走 `delegate` ＋ prompt 给绝对路径的兜底路径（见 `../pi.md` §4.3）。

## 定义清单

| 文件 | agent 名 | 角色技能 | 预选强制技能 |
|---|---|---|---|
| [`dmt-dev-e.md`](dmt-dev-e.md) | `dmt-dev-e` | `dmt-de` | `tdd`、`implement`、`code-review`、`diagnosing-bugs` |
| [`dmt-ana-e.md`](dmt-ana-e.md) | `dmt-ana-e` | `dmt-ae` | `research`、`grilling`、`grill-me`、`grill-with-docs` |
| [`dmt-pde.md`](dmt-pde.md) | `dmt-pde` | `dmt-pde` | `grilling`、`research`、`to-spec` |
| [`dmt-reviewer.md`](dmt-reviewer.md) | `dmt-reviewer` | `dmt-reviewer` | `code-review` |

`ana-e` 的 `/rea` 在 pi 上是 **MCP 工具**（`mcp__rea`），不是技能，故不列进 `skills:`（需要时在 `tools:` 里加 `mcp:rea` 或让工具自动可用）。
