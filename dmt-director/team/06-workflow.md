## 4. 工作流程

1. **anam 调研**：anam **直接派 `ana-e` 子代理（无依赖单元开满并行）** 拆子问题并行取证；anam 复核一手出处并收口成调研报告，**经 director 评审后落盘** `docs/analyst/`；**任务收口即由 anam 收口，该批 `ana-e` 子代理随收口回收**。
2. **director 召唤 `pde{n}` 出 PRD、SPEC**：director 与用户谈定边界、范围外与验收口径后，列产品单元清单并**开满 `pde1…pde{n}` 并行落笔**（一单元一 pde，无依赖单元一个不漏地同时派出），由 `pde{n}` **落笔**写 `docs/pd/prd/`、`docs/pd/spec/`，director 逐份验收定稿：基于调研报告写 PRD 与 SPEC（[`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)，含逐条可测的验收标准），**按文档门禁自评审**（验收标准逐条可测、`spec-seq` 对齐、切片可独立验证、Files 不重叠、依赖无环；用 [`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md) 与 [`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md) 拷问），通过后就地改状态行为 `状态：已通过` 并交 devm 出票。
3. **devm 落笔工单**：devm 读定稿的 SPEC，用 [`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md) 按 tracer-bullet 纵向切片，落笔 `docs/dev/tickets/`（文件头 `状态：待评审`），交 director 定稿（文档门禁）；**devm 不拆改判据**，缺项回报 director 补。
4. **devm 派单给队长**：devm 按依赖排期，把票面（路径、票基、Files 边界、验收判据、`timeoutMs`、回报格式）派给 `devl{n}`；无依赖票可同时派给多个队长。**devm 不直接派 `dev-e`**。
5. **devl 实施**：devl 在 `.worktrees/{ticket-id}`（分支 `feat/{ticket-id}`）内派 `dev-e`，用 `/tdd`、`/implement`、`/code-review` 实施；`dev-e` 是 worktree 唯一写者，负责 `add` + `commit`；队长不另开写者。
6. **devl 评审与汇总**：devl 按 `spec-seq` 派 `reviewer{n}` 独立评审（每票新实例，只认 ticket / SPEC / diff / 证据）；FAIL 打回 `dev-e`，PASS 后汇总交付包上报 devm。
7. **devm 合并与发布**：devm 做合并前机检（diff 可应用、测试绿、reviewer PASS 证据在、`spec-seq` 对齐），通过后 merge / push；每完成一票 push 一次，并向 director 汇报。
8. **并行**：无依赖任务开满 subagents；真依赖才串行并写明理由。派发模板见 [`team/07b-dispatch.md`](07b-dispatch.md)。

### 4.1 PRD 模板（`pde{n}` 落笔，director 定稿）

`Problem Statement` / `目标用户与场景` / `方案概述` / `用户故事（可验收）` / `验收标准` / `范围外` / `开放问题`。

### 4.2 SPEC 模板（`pde{n}` 落笔，director 定稿）

`Problem Statement` / `Solution` / `User Stories` / `验收标准（逐条可测）` / `实现决策` / `测试接缝` / `Out of Scope` / `变更记录`。
SPEC 必须自包含：每条 User Story 都能转成 ticket 与用例。

### 4.3 工单模板（`pde{n}` 落笔，director 定稿）

`目标` / `输入 SPEC 小节` / `验收判据（逐条可测）` / `Files 范围` / `构建补件（**凡票涉 gradle／clean build 必须写**：新 worktree 需补 `local.properties`(sdk.dir) ＋ `app/src/main/jni/` 两个 vendored 目录软链（`opencv-mobile-4.13.0-android`／`ncnn-20260526-android-vulkan` → 主仓同路径）＋ `ANDROID_HOME`；均 gitignored、非交付物）` / `依赖（票号）` / `timeoutMs` / `状态` / `实施状态（devl 追加、devm 汇总）`。
工单由 `devm` 用 [`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md) 按 tracer-bullet 纵向切片、director 定稿；**编号按依赖序、`spec-seq` 与 SPEC 严格对齐**；`Files 范围` 互不重叠，`依赖` 必须无环。
