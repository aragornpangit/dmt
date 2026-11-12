# 可选：派发模板

按任务裁剪字段，不为简单工作堆砌流程。

```text
角色与技能：<能力或技能路径>
单元：<一句话目标>
输入：<需求、代码、资料及位置>
边界：<允许与禁止修改的范围>
产物：<位置与格式>
判据：<逐项可测>
验证：<命令、来源或证据要求>
回报：<结果、证据、未决项；只报派发者>
约束：<时间、资源、安全或平台要求，按需>
```

启用第三方技能适配器时，「角色与技能」行按 [`../ops/optional-skills.md`](../ops/optional-skills.md) 与契约 `third_party_skills.role_skills` 逐项写出本角色**必用**技能/MCP；点名即硬要求，不可用标 `[SKILL_UNAVAILABLE]` 并回报派发者，改用直读该技能 `SKILL.md` 绝对路径等可验证替代方法，不静默跳过。产物适配（`to-spec` / `to-tickets` / `grill-with-docs`）按契约 `artifact_adaptation` 写明落盘口径，压过技能正文里的外部 tracker / `.scratch/` 指令。条件加载技能（superpowers 单点 / `handoff`）只在可用 harness 追加，缺席时回退 [`07-discipline.md`](07-discipline.md) 的自带判据。

派发 `dmt-dir` / `dmt-dm` / `dmt-am` 三个派发者角色时，prompt 另附 8 个技能的上游来源：契约 `third_party_skills.source_url` 只登记 `.env` 变量占位符 `${DMT_MATTPOCOCK_SOURCE_URL}`（内网地址不入库），派发前用 `dmt_load_env`（`lib-dmt.sh`）从 `.env` 展开为实际 URL 再写入 prompt，让角色及其子代理上下文一并带上；该 URL 只作来源登记，不作为加载或 fetch 地址（落点仍以已解锁副本为准）。`dmt-dir`（grill-me / grill-with-docs）、`dmt-dm`（to-tickets）按点名表点名；`dmt-am` 无点名项，仅带来源链接，供向下游 `dmt-ae` 派发时透传。

独立评审额外写明（由 `dmt-dm` 派未参与该 ticket 实现的临时子代理承担，**加载 `dmt-reviewer` 技能**、以 ticket 为单位审查；仅当显式启用可选协调者 `dmt-dl` 时由其代派）：

```text
你未参与本单元实现，只依据 ticket 票面判据、功能分支 commit 和可复现证据逐项验收。
按 ticket 为单位给出 PASS / FAIL 并挂证据；无证据不得判 PASS。
不得修改实现或判据；不执行 merge / push / 发布，只向派发者回报。
```

## 平台适配

- 优先使用平台原生命名子代理、技能注入和完成通知。
- 无法命名子代理时，可在 prompt 中明确角色并给出技能文件路径。
- pi 使用已安装的 `pi-agents/` 角色定义；未安装时用 `delegate` + 技能绝对路径回退，二者都不是全局唯一方式。
- 平台不支持子代理时报告能力缺口，在当前上下文完成可独立处理的部分，不伪造派发。
- 子代理加载 `dmt-reviewer` 的方式按 harness：cbc 用子代理 invoke；claudecode / codex 在 prompt 给出 `dmt-reviewer/SKILL.md` 绝对路径由子代理 `read`（codex 的 `dmt_skill_ref()` 对 `dmt-*` 返回裸名）；opencode 用 `@dmt-reviewer`；pi 用 `pi-agents/dmt-reviewer.md` 命名 agent。调用前缀以 [`../harness_matrix.yaml`](../harness_matrix.yaml) 为准。
- 具体机制见 [`../harness/README.md`](../harness/README.md)，仅在实际使用时读取。
