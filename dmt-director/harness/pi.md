# harness 差异：pi（pi-coding-agent）

> 共性见 [`COMMON.md`](COMMON.md)；机器可读事实（目录 / 前缀 / 启动 / 并发）单一来源 [`../harness_matrix.yaml`](../harness_matrix.yaml)。
> 本节除标注外**均为 2026-11-05 本机实测**（`harness-detect.sh` 逐 pane 复核 + `pi -p --approve` 会话探针）。

## 1. 技能发现目录

| 级别 | 目录 |
|---|---|
| 项目级 | `.agents/skills/`、`.pi/skills/` |
| 用户级 | `~/.agents/skills/`、`~/.pi/agent/skills/` |

- **项目级 `.agents/skills/` 属 trust-requiring**：启动不带 `--approve` 看不到（只见用户级技能）。
- **`~/.pi/skills/` 不被读取** —— 即使该目录里放了软链也不生效（本机实测该目录存在且满是软链，但无一条被加载）。
- 项目级与用户级同装同名技能时会同时出现（同名冲突时 pi 保留先发现的并告警）。

## 2. 启动与权限

- 代启动命令 `pi --approve`（`lib-dmt.sh: dmt_harness_cmd pi`）。
- `--approve` 同时是**自动档判据**（`dmt_pane_auto_mode` 认它）。pi 没有逐条审批关卡，`--approve` 只关乎项目级资源的 trust。

## 3. 技能调用行（pane 角色）

- **`/skill:<技能名>`**：`/skill:dmt-director`、`/skill:dmt-dm`、`/skill:dmt-am`。
- **写 `/dmt-dm` 不报错，但会被当成普通提问**（静默失效）⇒ 一律经 `lib-dmt.sh: dmt_skill_cmd` 生成，不手敲。

## 4. 技能如何到达模型

| 场景 | 做法 |
|---|---|
| pane 常驻角色 | 由用户或 `setup-team.sh` 在**输入框**敲 `/skill:dmt-<角色>`；pi 把该技能正文注入上下文 |
| 子代理 | pi 的 `delegate` 子代理**无 Skill 工具、也不注入技能清单** ⇒ 派发 prompt 必须给**绝对路径**：`read <技能目录>/dmt-<角色>/SKILL.md` |
| 模型自行发起 | **没有** Skill 工具；只能「读 SKILL.md」或由用户敲 `/skill:` |

- `disable-model-invocation: true` 的技能（mattpocock 的 `to-spec` / `to-tickets` / `implement` / `grill-me` / `grill-with-docs` 等）**不出现在模型可见的技能清单**里，**但 `/skill:<name>` 仍可显式调起**（实测 `/skill:to-spec` 正常展开并注入）。

## 5. 强制技能（mattpocock）在 pi 上的取法

- pane 角色：`/skill:<name>`（如 `/skill:code-review`）；带 `disable-model-invocation` 的**必须显式敲**，模型不会自己想到。
- 子代理：只能读文件，实路径（本机实测可用）：
  - `~/.pi/agent/git/github.com/mattpocock/skills/skills/engineering/<name>/SKILL.md`
  - `~/.pi/agent/git/github.com/mattpocock/skills/skills/productivity/<name>/SKILL.md`
  - **不要**用 `~/.agents/skills/mattpocock-skills/**`：本机 `settings.skills` 已用 `!~/.agents/skills/mattpocock-skills/**` 排除它。
- **`/rea` 在 pi 上不是技能**：REA 以 **MCP 工具**（`mcp__rea`）提供，直接用工具即可。

### 5.1 转发式技能必须降级（2026-11-05 三角色实测）

部分 mattpocock 技能正文只写 `Call the Skill tool with "<其它技能>"`，而 pi **没有 Skill 工具** ⇒ 照正文执行会**静默失效**（技能「跑起来」了，但内部转发步骤不发生）。

**规则**：正文里这类句子一律改为 `read <镜像根>/{engineering,productivity}/<其它技能>/SKILL.md` 再按其执行。受影响的 dmt 强制技能：

| 技能 | 正文要求 | pi 上的降级 |
|---|---|---|
| `grill-with-docs` | `Call the Skill tool twice, for "grilling" and "domain-modeling"` | read `grilling`（productivity/）＋ `domain-modeling`（engineering/） |
| `grill-me` | `Call the Skill tool with "grilling"` | read `grilling` |
| `implement` | `Call the Skill tool with "tdd"` / `"code-review"` | read `tdd` ＋ `code-review` |
| `tdd` | `call the Skill tool with "codebase-design"`（**参考性**，非强制） | read `codebase-design`（可选） |

两条实测注意：

- `grill-with-docs` 正文**只有那一句** ⇒ 不降级等于什么都没做（必须显式 read 两份子技能）。
- 技能目录**不统一**：`grill-with-docs` 在 `engineering/`、**不在** `productivity/` ⇒ 找不到时两个目录都要试（实测有角色先按 `productivity/` 找、误判不存在）。
- 子代理同理，且**不能自动调起下游技能**：派生者必须在 prompt 里给出下一环技能的绝对路径（实测：dev-e 子代理内 `/tdd`、`/code-review` 均调不起）。

## 6. 子代理承载

- `dev-e` / `ana-e` / `pde{n}` / `reviewer{n}` 是**角色语义名**，不是 pi-subagents 的 agent 注册名；按角色名直派报 `Unknown agent: <角色名>`（2026-11-05 实测复现）。
- pi workflow 的 `agent` 字段填内置 **`delegate`**（无预设行为、继承父模型），角色语义写进 prompt。模板见 [`../team/07b-dispatch.md`](../team/07b-dispatch.md) 的「pi harness 承载」。
- **可选增强（尚未接线）**：pi-subagents 支持自定义 agent 定义（`~/.pi/agent/agents/*.md`、项目 `.pi/agents/*.md`、legacy `.agents/**/*.md`），字段含 `inheritSkills` / `skills` / `tools` ⇒ 可为四个子代理角色各注册一份定义，从而支持「按角色名直派」＋ 技能继承 ＋ 工具白名单。当前 dmt 走 `delegate` 降级路径。

## 7. pi 特有约束

- **`cbc-herdr` 不需要**：herdr 原生识别 pi（manifest `pi.toml`；`herdr agent explain` 可见），`agent_status` 直接可信。
- **并发上限未声明**（矩阵 `null`）：pi-subagents 的实际默认是 workflow `maxTasks=8` / `concurrency=4`（另有 `maxConcurrentAsyncRuns` 配置项）—— 派发前按此自判。
- **门铃**：`herdr agent prompt <pane>` 对 pi pane 可用（agent kind = `pi`）；返回非 `agent_prompted` 时回退 `pane send-text` + `pane send-keys enter`（`send-msg.sh` 已内置）。
- **时序风险（未实测）**：`dmt_wait_ready` 只等 `agent_status != unknown`，pi TUI 起得慢 ⇒ `/skill:…` 可能早于输入就绪；启动后请用 `dmt_confirm_role_ready` 以「角色名 ＋ 一次性凭据同时出现在 pane 输出」复核技能确实加载。
