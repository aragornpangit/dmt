# dmt 团队契约 · 变更记录

> 当前版本 `5.19.11`。历史明细已随维护件清理（删除前备份于 /tmp），不随安装分发；收口项按版本追加于下。

## 5.19.11 · 2026-11-10

- **O5 收口（OPEN → DONE）**：OpenCode v2 统一用 `@<skill-id>` 加载技能，三条判据全部通过。
  - 取证环境：opencode **v2.2.5** `--auto`；herdr 0.9.5 独立 workspace（`--no-focus`）。**驱动方运行在 Orca ADE，非 herdr pane 内 agent**；herdr 是经 CLI 控制的外部服务。证据为 session `ses_e3b3a2c53ffef76URnEk9vs5dN`（`~/.local/share/opencode/opencode.db`）user message 的结构化 `skills` / `files` / `agents` 字段，非模型自述。
  - ① 纯 `@to-spec` → `skills=[{"id":"to-spec", "text":"<skill_content …>"（3262 字符）}]`、`files=[]`、`agents=[]`；模型按技能正文拒绝在空目录开工。
  - ② cwd 放入 `to-spec` 与 `to-spec.md` 两个同名 decoy 后再次纯 `@to-spec` → 仍 `skills=[to-spec]`、`files=[]`，decoy 未进上下文 ⇒ 选中 skill 而非文件。
  - ③ `skill({id})` → `TOOL` part `name="skill"`、`input={"id":"code-review"}`、`status="completed"`，回复 `code-review`。
- **新增限制（已写入 `harness/opencode.md`）**：`@` 仅在消息为**纯 `@<skill-id>`** 时注入技能；带附加文本或一条消息多个 `@` 引用时 `skills=[]`。`herdr agent prompt` 对 opencode 可能返回 `agent_prompt_stalled`（不限于首启），需复核 pane 输出并补 `send-keys enter`。
- **顺带修复**：恢复 `dmt-reviewer` 后 5 个用户级技能落点缺该技能，已补齐（7 角色 × 5 落点 = 35/35）；纯 `@dmt-reviewer` 实测 `skills=[('dmt-reviewer',730)]`。
