# harness 差异：codebuddy

共性见 [`COMMON.md`](COMMON.md)，机器事实见 [`../harness_matrix.yaml`](../harness_matrix.yaml)。

- 项目技能目录为 `.codebuddy/skills/`，用户级为 `~/.codebuddy/skills/`。
- 技能调用为 `/<技能名>`；teammate 可继承技能清单，子代理用唯一角色名并显式说明任务。
- 技能是否进模型可见列表只看 `SKILL.md` frontmatter 的 `disable-model-invocation: true`（置 true 后只剩手敲 `/<技能名>`）；`agents/openai.yaml` 的 `allow_implicit_invocation` 是 codex 专有字段，codebuddy 不读。第三方 explicit-only 技能必须指向 `~/.agents/skills-unlocked/<name>`，用 `install-third-party-skills.sh --check` 复验。
- 启动档为自动模式：`codebuddy --permission-mode auto --subagent-permission-mode auto`。首次进入新目录仍可能有一次信任确认；`auto` 不等于全放行，仍受 CodeBuddy 的权限策略约束。
- 需要 herdr 状态上报时启用 `cbc-herdr`；进程检测同时识别可执行名 `cbc` 与 `codebuddy`。
- 并发实际上限读取矩阵或当前环境配置，不要求开满。
- 无法调用技能时读取对应 `SKILL.md`；无法使用子代理时报告能力缺口。
