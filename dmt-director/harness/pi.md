# harness 差异：pi（pi-coding-agent）

> 共性见 [`COMMON.md`](COMMON.md)；机器可读事实（目录 / 前缀 / 启动 / 并发）单一来源 [`../harness_matrix.yaml`](../../dmt-director/harness_matrix.yaml)。
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

**pi 的两个硬限制**（2026-11-05 实测）：

1. **没有 Skill 工具** —— 模型不能自己「调用技能」，只能读 `SKILL.md`；技能正文进上下文只有三条路：用户/派发者敲 `/skill:<name>`、启动参数 `--skill <path>`、系统提示里的 `<available_skills>` 目录（由 `inheritSkills` / `skills` 决定是否有）。
2. **子代理默认不继承技能** —— 内置 `delegate` 的 agent 定义是 `inheritSkills: false`（实测：其 system prompt **没有** `<available_skills>` 段），所以子代理里既敲不了 `/skill:` 也没清单。

### 4.1 子代理侧：用自定义 agent 定义注入技能（推荐正解）

pi-subagents 允许自定义 agent（`~/.pi/agent/agents/**/*.md` 用户级、`<项目>/.pi/agents/**/*.md` 项目级），frontmatter 支持三个关键字段：`inheritSkills`、`skills`、`skillPath`。

**实测三档粒度**（同一项目、同一派发方式，只改 agent 定义）：

| agent 定义 | 子代理 system prompt 里的 `<available_skills>` | 适用 |
|---|---|---|
| 内置 `delegate`（`inheritSkills: false`，无 `skills`） | **无** | 一次性脚本活；技能靠 prompt 给路径 |
| `inheritSkills: false` + `skills: dmt-pde` | **只有 `dmt-pde`**（精确白名单） | **推荐给 dmt 四个子代理角色**（最小权限） |
| `inheritSkills: true` + `skills: [...]` | **全量技能目录**（dmt-* 七个 + tdd/code-review 等） | 需要自主发现的通用 agent |

⇒ **dmt 的落地形态**：给 `dev-e` / `ana-e` / `pde{n}` / `reviewer{n}` 各写一份 agent 定义，`inheritSkills: false` ＋ `skills:` 精确列出该角色的角色技能与强制技能。模板见 [`pi-agents/`](pi-agents/README.md)（`install-skills.sh --harness pi` 会铺到项目 `.pi/agents/`）。

**注意语义**：`skills` 是「选定子集」，`inheritSkills: true` 是「保留父的整个目录」；两者同时给时**以白名单为准的前提是 `inheritSkills: false`**（实测 `inheritSkills: true` 时是全量，`skills` 不裁剪）。

### 4.2 pane 侧：启动参数或斜杠命令把技能装进去

| 途径 | 实测 | 说明 |
|---|---|---|
| `pi --skill <技能目录>` | ✅ 装载成功（**项目级路径也可，无需 `--approve`**） | 一个 pane 可重复 `--skill` 多次；适合「启动即带角色技能」 |
| `pi --approve` ＋ 项目 `.agents/skills/` | ✅ 自动发现 | 不带 `--approve` 时只看到文件、不进清单（实测：模型答「磁盘上有但未加载」） |
| 输入框 `/skill:dmt-<角色>` | ✅ | 写 `/dmt-<角色>` 不报错但**静默变普通提问** |
| 用户级 `~/.agents/skills/`、`~/.pi/agent/skills/` | ✅ | 无需 approve |

**实测补充（2026-11-06，三个真实子代理回抄 `<available_skills>`）**：

| agent 定义 | `skills:` 声明 | 实际注入 | 被过滤 |
|---|---|---|---|
| `dmt-dev-e` | `dmt-de, tdd, implement, code-review, diagnosing-bugs` | `dmt-de, tdd, code-review, diagnosing-bugs` | `implement` |
| `dmt-pde` | `dmt-pde, grilling, research, to-spec, to-tickets` | `dmt-pde, grilling, research` | `to-spec`、`to-tickets` |
| `dmt-ana-e` | `dmt-ae, research, grilling, grill-me, grill-with-docs` | `dmt-ae, research, grilling` | `grill-me`、`grill-with-docs` |

⇒ 被过滤的一律是 `disable-model-invocation: true`。**静默丢弃、无告警**，所以「声明了就等于有了」是错的，必须实测。

### 4.3 兜底（现状保留）

都不适用时（例如不允许改 agent 定义）：派发 prompt 里给**绝对路径** `read <技能目录>/dmt-<角色>/SKILL.md`，并按 `§5.1` 处理转发式技能。这条永远有效，但依赖模型照 prompt 执行、且每个下游技能都要逐条给路径。

### 4.4 已知坑

- **同名技能重复注册**：实测子代理清单里 `tdd` / `code-review` 各出现两次（`~/.agents/skills/mattpocock-skills/...` 与 pi git 包各一份）⇒ 用 `skills:` 显式点名可避开歧义；两个都装时优先保留一份。
- **`delegate` 的 tools 白名单不含 `subagent`**（其定义 `tools: read, grep, find, ls, bash, edit, write, contact_supervisor`）⇒ 子代理不能再派子代理；需要嵌套时在自定义 agent 里加 `allowNestedSubagents: true` 或 `tools: subagent`。
- **项目级 agent 定义同样受 trust 约束**：Pi 未批准项目 trust 时忽略项目 agent（`agentScope` 回退为 user）。
- `disable-model-invocation: true` 的技能（`to-spec` / `to-tickets` / `implement` / `grill-me` / `grill-with-docs` 等）**不出现在模型可见清单**，`/skill:<name>` 可显式调起；但 **写进自定义 agent 的 `skills:` 同样会被过滤**（2026-11-06 实测证伪了此前「不受该标记阻挡」的记载）：声明 5 个只注入 4 个、`to-spec`/`to-tickets` 双双静默丢弃，且**不报错**。⇒ `skills:` 只写「无该标记」的技能；被过滤的技能改由 agent prompt 给 `SKILL.md` 路径、让子代理 `read`（`pi-agents/` 四份已按此整形）。

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
- **并发上限**：矩阵已填 **8**（pi-subagents 默认 workflow `maxTasks=8` / `concurrency=4`，可按调用 `concurrency` 覆盖；另有 `maxConcurrentAsyncRuns` 限制顶层异步运行数，`0`=不限）。
- **门铃**：`herdr agent prompt <pane>` 对 pi pane 可用（agent kind = `pi`）；返回非 `agent_prompted` 时回退 `pane send-text` + `pane send-keys enter`（`send-msg.sh` 已内置）。
- **时序风险（未实测）**：`dmt_wait_ready` 只等 `agent_status != unknown`，pi TUI 起得慢 ⇒ `/skill:…` 可能早于输入就绪；启动后请用 `dmt_confirm_role_ready` 以「角色名 ＋ 一次性凭据同时出现在 pane 输出」复核技能确实加载。
