# harness 差异：opencode

共性见 [`COMMON.md`](COMMON.md)，机器事实见 [`../harness_matrix.yaml`](../harness_matrix.yaml)。

- 项目技能目录可用 `.agents/skills/`、`.claude/skills/`、`.opencode/skills/`；使用复数目录名。
- 技能显式引用为 `@<技能名>`，**仅当消息为纯 `@<skill-id>` 时**才注入技能正文（v2.2.5 实测：user message 的 `skills` part 带 `<skill_content>`，`files` / `agents` 为空）。带附加文本或一条消息里多个 `@` 引用时 `skills=[]`，此时改用 `skill({id})` 或直读 `SKILL.md`。
- 同名文件与技能共存时 `@` 选中 skill 而非文件（v2.2.5 实测：`to-spec` / `to-spec.md` decoy 存在时仍 `skills=[to-spec]`、`files=[]`）。
- `skill({id})` 按 id 加载仍可用（v2.2.5 实测 `TOOL` part `name="skill"`、`status="completed"`）；不可用时读取 `SKILL.md`。
- 子代理 prompt 中显式给出技能引用或路径，以及输入、边界、产物和判据。
- 权限模式由用户和项目安全策略决定，不默认跳过审批。
- 并发入口和启动行为以当前版本与矩阵为准；未声明上限时按任务和容量自判。
- herdr 门铃发送后需确认输入已被接受，不能只凭写入终端判断送达；`agent prompt` 对 opencode 可能返回 `agent_prompt_stalled`（不限于首启），需复核 pane 输出并补 `pane send-keys <pane> enter`。
