## 4. 工作流程

1. **anam 调研**：anam 直接派 `ana-e`（无依赖单元开满并行）拆子问题取证；anam 复核一手出处收口成报告，经 director 评审后落盘 `docs/analyst/`；该批子代理随收口回收。
2. **director 召唤 `pde{n}` 出 PRD、SPEC**：与用户谈定边界、范围外与验收口径后，列产品单元清单并开满 `pde{n}` 并行落笔；director 逐份定稿，按文档门禁自评（判据逐条可测、`spec-seq` 对齐、切片可独立验证、Files 不重叠、依赖无环），通过后改 `状态：已通过` 交 devm 出票。
3. **devm 落笔工单**：读定稿 SPEC，按 tracer-bullet 纵向切片落笔 `docs/dev/tickets/`（文件头 `状态：待评审`），交 director 定稿；**devm 不拆改判据**，缺项回报 director 补。
4. **devm 派单给队长**：按依赖排期，把票面（路径、票基、Files 边界、判据、`timeoutMs`、回报格式）派给 `devl{n}`；无依赖票可同时派多个队长。**devm 不直接派 `dev-e`**。
5. **devl 实施**：在 `.worktrees/{ticket-id}`（分支 `feat/{ticket-id}`）内派 `dev-e` 实施；`dev-e` 是 worktree 唯一写者，负责 `add` + `commit`；队长不另开写者。
6. **devl 评审与汇总**：按 `spec-seq` 派 `reviewer{n}` 独立评审（每票新实例，只认 ticket / SPEC / diff / 证据）；FAIL 打回 `dev-e`，PASS 后汇总交付包上报 devm。
7. **devm 合并与发布**：合并前机检（diff 可应用、测试绿、reviewer PASS 证据在、`spec-seq` 对齐），通过后 merge / push；每完成一票 push 一次并向 director 汇报。合并后通知 devl 删 worktree / 本地分支，devm 更新票面终态；回滚归 devm。
8. **并行**：无依赖任务开满 subagents，真依赖才串行并写明理由；模板见 [`07b-dispatch.md`](07b-dispatch.md)。

### 4.1 PRD 模板（`pde{n}` 落笔，director 定稿）

`Problem Statement` / `目标用户与场景` / `方案概述` / `用户故事（可验收）` / `验收标准` / `范围外` / `开放问题`。

### 4.2 SPEC 模板（`pde{n}` 落笔，director 定稿）

`Problem Statement` / `Solution` / `User Stories` / `验收标准（逐条可测）` / `实现决策` / `测试接缝` / `Out of Scope` / `变更记录`。每条 User Story 都必须能转成 ticket 与用例。

### 4.3 工单模板（`devm` 落笔，director 定稿）

`目标` / `输入 SPEC 小节` / `验收判据（逐条可测）` / `Files 范围` / `构建补件（票涉 gradle 或 clean build 必写：SDK / vendored 依赖 / 环境变量，均 gitignored、非交付物）` / `依赖（票号）` / `timeoutMs` / `状态` / `实施状态（devl 追加、devm 汇总）`。

编号按依赖序、`spec-seq` 与 SPEC 严格对齐；`Files 范围` 互不重叠，`依赖` 必须无环。
