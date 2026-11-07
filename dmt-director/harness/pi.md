# harness 差异：pi（pi-coding-agent）

> 共性见 [`COMMON.md`](COMMON.md)；机器事实见 [`../harness_matrix.yaml`](../../dmt-director/harness_matrix.yaml)。除标注外均为 2026-11-05 本机实测。

## 1. 技能发现目录

项目级**只认** `.agents/skills/`（trust-requiring，启动不带 `--approve` 看不到）；用户级 `~/.agents/skills/`、`~/.pi/agent/skills/`；`~/.pi/skills/` 不生效。项目级与用户级同名会同时出现（保留先发现的并告警）。

## 2. 启动与权限

代启动 `pi --approve`；`--approve` 同时是自动档判据（`dmt_pane_auto_mode` 认它），pi 无逐条审批关卡。pane 内技能一律经 `dmt_skill_cmd` 生成 **`/skill:<技能名>`**；写 `/dmt-dm` 不报错但被当普通提问（静默失效）。

## 3. 两个硬限制

1. **没有 Skill 工具** —— 模型不能自己「调用技能」，只能读 `SKILL.md`。正文进上下文只有三条路：敲 `/skill:<name>`、启动参数 `--skill <path>`、系统提示的 `<available_skills>` 目录（由 `inheritSkills` / `skills` 决定）。
2. **子代理默认不继承技能** —— 内置 `delegate` 是 `inheritSkills: false`（system prompt 无 `<available_skills>` 段），所以子代理既敲不了 `/skill:` 也没清单。

## 4. 子代理侧：自定义 agent 定义

pi-subagents 支持自定义 agent（`~/.pi/agent/agents/**/*.md`、`<项目>/.pi/agents/**/*.md`），frontmatter 关键字段 `inheritSkills` / `skills` / `skillPath`。三档：

- 内置 `delegate`：无清单，技能靠 prompt 给路径；
- `inheritSkills: false` + `skills: [...]`：精确白名单（四个子代理角色用这档）；
- `inheritSkills: true`：保留父的全量目录（`skills` 不裁剪）。

dmt 落地：`pi-agents/` 给四个子代理各一份定义，`install-skills.sh --harness pi` 铺到项目 `.pi/agents/`。不允许改 agent 定义时，派发 prompt 给绝对路径 `read <技能目录>/dmt-<角色>/SKILL.md`。

## 5. 强制技能在 pi 上的取法

- pane：`/skill:<name>`；带 `disable-model-invocation` 的必须显式敲。
- 子代理：读 `~/.pi/agent/git/github.com/mattpocock/skills/skills/{engineering,productivity}/<name>/SKILL.md`；不要用 `~/.agents/skills/mattpocock-skills/**`（已被 `settings.skills` 排除）。
- `/rea` 在 pi 上是 MCP 工具（`mcp__rea`），不是技能。

### 5.1 转发式技能必须降级

技能正文写 `Call the Skill tool with "<其它技能>"`，pi 没有 Skill 工具 ⇒ 改为 `read <镜像根>/{engineering,productivity}/<其它技能>/SKILL.md`。受影响：

- `grill-with-docs` → read `grilling` + `domain-modeling`（正文只有这一句，不降级等于没做）；
- `grill-me` → read `grilling`；
- `implement` → read `tdd` + `code-review`；
- `tdd` → read `codebase-design`（可选）。

目录不统一（`grill-with-docs` 在 `engineering/`），找不到时两个目录都试。子代理不能自动调起下游技能，派生者必须在 prompt 给绝对路径。

## 6. 已知坑

- 同名技能重复注册（`tdd` / `code-review` 各两份）⇒ 用 `skills:` 点名，只留一份。
- `disable-model-invocation: true` 的技能会被 `skills:` 静默过滤 ⇒ 只把无该标记的写进 `skills:`，其余由 prompt 给路径。
- `delegate` 的 tools 不含 `subagent`；项目级 agent 定义受 trust 约束。

## 7. pi 特有约束

- **`cbc-herdr` 不需要**：herdr 原生识别 pi（manifest `pi.toml`），`agent_status` 直接可信。
- **并发上限 8**（pi-subagents 默认 `maxTasks=8` / `concurrency=4`，可按调用覆盖；`maxConcurrentAsyncRuns` 限制顶层异步运行数，`0`=不限）。
- **门铃**：`herdr agent prompt <pane>` 对 pi 可用；返回非 `agent_prompted` 时回退 `pane send-text` + `send-keys enter`（`send-msg.sh` 已内置）。
- **时序风险**：`dmt_wait_ready` 只等 `agent_status != unknown`，pi TUI 起得慢 ⇒ `/skill:…` 可能早于输入就绪；启动后用 `dmt_confirm_role_ready` 以「角色名 ＋ 一次性凭据同现于 pane 输出」复核。
