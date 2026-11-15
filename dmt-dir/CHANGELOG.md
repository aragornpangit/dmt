# dmt 团队契约 · 变更记录

> 当前版本 `5.19.12`。历史明细已随维护件清理，不随安装分发；收口项按版本追加于下。

## 5.19.12 · 2026-11-15

- **文档口径收敛**：`team.md` 角色清单补 `dmt-reviewer`；`ops/runtime.md` 改为「默认只需要 `dmt-dm` pane，不需要 `dmt-dir-am` tab」；明确 PRD 由 `dmt-dir` 起草、`dmt-pde` 只写 SPEC；`harness/README.md` 的 harness 名统一为矩阵键 `codex`；`07b-dispatch.md` 写明 opencode 必须用单独一条纯 `@dmt-reviewer`；`harness/orca.md` 去掉「herdr 是 Orca 衬底」的误述，并把 `msg-done.sh` 从 herdr 绑定清单移出。
- **第三方技能转发链**：`third_party_skills.names` 增补 `domain-modeling`（`grill-with-docs` 的第二个转发目标），同步 9→10 计数；`disable-model-invocation` 口径区分为上游正本 / `skills-unlocked` 解锁副本 / codex 兼容副本。
- **新增 harness `hermes`**：矩阵新增 `hermes`（`hermes chat --yolo`、`/` 前缀、`delegate_task` 子代理、`~/.hermes/skills` 用户落点、`.agents/skills` 项目落点需 `hermes skills trust`）；新增 `harness/hermes.md`，两轴探测、安装、机检与测试同步覆盖 6 个 harness。
- **清理与注释**：`.env.example` 移除已无消费方的 `DMT_GITLAB_*`；`lib-dmt.sh` 修正 opencode 前缀注释；`ops/helper.md`、`ops/comms.md` 标注 herdr 平台范围；`launch.sh` 区分旧 max-subagents hooks 与 git hooks；`04-naming.md` 澄清无父票使用独立全局工单序列，并标注历史件迁移为一次性说明；CHANGELOG 落点计数改为 4 个唯一目录 / 28；opencode / codex 的版本敏感断言标注为本机未复测。
- 版本号升至 `5.19.12`。

## 5.19.11 · 2026-11-10

- **维护件补录（2026-11-11 ~ 2026-11-13）**：
  - `dmt-reviewer` 恢复为按 ticket 审查的独立评审角色，开发线固化「dm 评估 → to-tickets → de(tdd/implement/code-review) → reviewer 独立评审 → dm merge/push」五步。
  - B 增强版：`third_party_skills.role_skills` 硬保证层、产物适配（`artifact_adaptation`）、superpowers 三层条件加载；A6f 正向机检与测试同源读取契约。
  - Orca 投递纪律：`orca terminal send` 必须显式 `--enter`，按「发送文本 → 回车 → 复核回执」三步执行，超时不重发。
  - 彻底移除 dmt-dl 协调者机制：删除 `dl-pane.sh`、`setup-team.sh` 的 dl 分支、收件箱方向、`init-project.sh` 的 dl inbox、机检用例与相关文档；`dl-pane.sh` 列入 `forbidden_scripts` 防回潮。
  - 运行平台收敛为 herdr / Orca：移除 t3code 矩阵段、探测白名单、机检与测试用例。
- **O5 收口（OPEN → DONE）**：OpenCode v2 统一用 `@<skill-id>` 加载技能，三条判据全部通过。
  - 取证环境：opencode **v2.2.5** `--auto`；herdr 0.9.5 独立 workspace（`--no-focus`）。**驱动方运行在 Orca ADE，非 herdr pane 内 agent**；herdr 是经 CLI 控制的外部服务。证据为 session `ses_e3b3a2c53ffef76URnEk9vs5dN`（`~/.local/share/opencode/opencode.db`）user message 的结构化 `skills` / `files` / `agents` 字段，非模型自述。
  - ① 纯 `@to-spec` → `skills=[{"id":"to-spec", "text":"<skill_content …>"（3262 字符）}]`、`files=[]`、`agents=[]`；模型按技能正文拒绝在空目录开工。
  - ② cwd 放入 `to-spec` 与 `to-spec.md` 两个同名 decoy 后再次纯 `@to-spec` → 仍 `skills=[to-spec]`、`files=[]`，decoy 未进上下文 ⇒ 选中 skill 而非文件。
  - ③ `skill({id})` → `TOOL` part `name="skill"`、`input={"id":"code-review"}`、`status="completed"`，回复 `code-review`。
- **新增限制（已写入 `harness/opencode.md`）**：`@` 仅在消息为**纯 `@<skill-id>`** 时注入技能；带附加文本或一条消息多个 `@` 引用时 `skills=[]`。`herdr agent prompt` 对 opencode 可能返回 `agent_prompt_stalled`（不限于首启），需复核 pane 输出并补 `send-keys enter`。
- **顺带修复**：恢复 `dmt-reviewer` 后 5 个 harness 的用户级落点缺该技能，已补齐（4 个唯一目录，codex/opencode 共用 `.agents/skills`；7 角色 × 4 目录 = 28/28）；纯 `@dmt-reviewer` 实测 `skills=[('dmt-reviewer',730)]`。
