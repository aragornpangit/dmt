## 4. 工作流程

1. **anam 调研**：anam **直接派 `ana-e` 子代理（无依赖单元开满并行）** 拆子问题并行取证；anam 复核一手出处并收口成调研报告，**经 director 评审后落盘** `docs/analyst/`；**任务收口即由 anam 收口，该批 `ana-e` 子代理随收口回收**。
2. **director 召唤 `pde{n}` 出 PRD、SPEC 与工单**：director 与用户谈定边界、范围外与验收口径后，列产品单元清单并**开满 `pde1…pde{n}` 并行落笔**（一单元一 pde，无依赖单元一个不漏地同时派出），由 `pde{n}` **落笔**写 `docs/pd/prd/`、`docs/pd/spec/`、`docs/dev/tickets/`，director 逐份验收定稿：基于调研报告写 PRD 与 SPEC（[`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)，含逐条可测的验收标准），再用 [`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md) 把 SPEC 拆成开发工单，分别写 `docs/pd/prd/`、`docs/pd/spec/`、`docs/dev/tickets/`（文件头 `状态：待评审`），**按文档门禁自评审**（验收标准逐条可测、`spec-seq` 对齐、切片可独立验证、Files 不重叠、依赖无环；用 [`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md) 与 [`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md) 拷问），通过后就地改状态行为 `状态：已通过` 并交 devm 排期。
3. **devm 接单**：devm 读 `docs/dev/tickets/` 的本批票面（`pde{n}` 落笔、director 定稿、已过文档门禁），核 `spec-seq` 对齐与判据齐备后按依赖排期；**devm 不拆票、不改判据**，缺项回报 director 补。devm 负责评审、整合本部门交付物。
4. **devm 直接派工程师（无依赖票开满并行）**：devm **直接派生 `dev-e` 子代理**（一票一 worktree，无依赖票开满并行），把票面（路径、票基、Files 边界、验收判据、`timeoutMs`、回报格式）交给工程师实施；devm 自己建 worktree、收 diff 做**实施层初检**、复核一手出处。anam 同理**直接派 `ana-e`**（拆子问题、开满并行取证，复核一手出处）。
5. **devm 实施层验收**：核 diff 与证据，构建与测试，不合格打回原实施者；本步不 merge。
6. **独立验收与发布**：devm 代码门禁 → devm 派 `reviewer{n}` 独立验收 → devm merge / push。门禁和独立性细则见 [`team/07-discipline.md`](07-discipline.md) §5.3。
7. **并行**：无依赖任务开满 subagents；真依赖才串行并写明理由。派发模板见 [`team/07b-dispatch.md`](07b-dispatch.md)。

### 4.1 PRD 模板（`pde{n}` 落笔，director 定稿）

`Problem Statement` / `目标用户与场景` / `方案概述` / `用户故事（可验收）` / `验收标准` / `范围外` / `开放问题`。

### 4.2 SPEC 模板（`pde{n}` 落笔，director 定稿）

`Problem Statement` / `Solution` / `User Stories` / `验收标准（逐条可测）` / `实现决策` / `测试接缝` / `Out of Scope` / `变更记录`。
SPEC 必须自包含：每条 User Story 都能转成 ticket 与用例。

### 4.3 工单模板（`pde{n}` 落笔，director 定稿）

`目标` / `输入 SPEC 小节` / `验收判据（逐条可测）` / `Files 范围` / `构建补件（**凡票涉 gradle／clean build 必须写**：新 worktree 需补 `local.properties`(sdk.dir) ＋ `app/src/main/jni/` 两个 vendored 目录软链（`opencv-mobile-4.13.0-android`／`ncnn-20260526-android-vulkan` → 主仓同路径）＋ `ANDROID_HOME`；均 gitignored、非交付物）` / `依赖（票号）` / `timeoutMs` / `状态` / `实施状态（devm 追加）`。
工单由 `pde{n}` 用 [`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md) 按 tracer-bullet 纵向切片、director 定稿；**编号按依赖序、`spec-seq` 与 SPEC 严格对齐**；`Files 范围` 互不重叠，`依赖` 必须无环。
