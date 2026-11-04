## 4. 工作流程

1. **anam 调研**：anam **直接派 `ana-e` 子代理（无依赖单元开满并行）** 拆子问题并行取证；anam 复核一手出处并收口成调研报告，**经 director 评审后落盘** `docs/analyst/`；**任务收口即由 anam 收口，该批 `ana-e` 子代理随收口回收**。
2. **director 召唤 `pde{n}` 出 PRD、SPEC 与工单**：director 与用户谈定边界、范围外与验收口径后，列产品单元清单并**开满 `pde1…pde{n}` 并行落笔**（一单元一 pde，无依赖单元一个不漏地同时派出），由 `pde{n}` **落笔**写 `docs/pd/prd/`、`docs/pd/spec/`、`docs/dev/tickets/`，director 逐份验收定稿：基于调研报告写 PRD 与 SPEC（[`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)，含逐条可测的验收标准），再用 [`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md) 把 SPEC 拆成开发工单，分别写 `docs/pd/prd/`、`docs/pd/spec/`、`docs/dev/tickets/`（文件头 `状态：待评审`），**按文档门禁自评审**（验收标准逐条可测、`spec-seq` 对齐、切片可独立验证、Files 不重叠、依赖无环；用 [`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md) 与 [`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md) 拷问），通过后就地改状态行为 `状态：已通过` 并交 devm 排期。
3. **devm 接单**：devm 读 `docs/dev/tickets/` 的本批票面（`pde{n}` 落笔、director 定稿、已过文档门禁），核 `spec-seq` 对齐与判据齐备后按依赖排期；**devm 不拆票、不改判据**，缺项回报 director 补。devm 负责评审、整合本部门交付物。
4. **devm 直接派工程师（无依赖票开满并行）**：devm **直接派生 `dev-e` 子代理**（一票一 worktree，无依赖票开满并行），把票面（路径、票基、Files 边界、验收判据、`timeoutMs`、回报格式）交给工程师实施；devm 自己建 worktree、收 diff 做**实施层初检**、复核一手出处。anam 同理**直接派 `ana-e`**（拆子问题、开满并行取证，复核一手出处）。
5. **devm 验收整合（实施层）**：核 diff 与初检读数（自己收子代理回报并自做初检）→ 构建与测试 → 不合格打回原实施者；**本步不 merge、不写「实施状态」**（merge 的唯一时点见第 6 条）；**任务收口即报（`OPS.md` §2），该批 `dev-e` 子代理随收口回收**。
6. **（merge 时点：本部门 `reviewer{n}` 验收通过之后；director 只抽查）** devm 代码门禁评审 → devm 派 `reviewer{n}` 独立验收 → devm merge/push：ticket 代码干完后由 devm 按代码门禁评审（逐条对照 SPEC 判据、核 diff 与证据，先不 merge）→ **devm 按票数派 `reviewer1…reviewer{n}` 子代理**（一票一 reviewer，无依赖票开满并行）对照相同 spec-seq 的 SPEC 验收标准与 ticket 判据逐条验收；**四条硬约束**：① **实例独立**（不得与实施该票的 `dev-e` 同实例；不采信 devm / `dev-e` 的结论，只认 ticket ＋ SPEC ＋ diff ＋ 证据）；② **证据为准**（逐条 PASS/FAIL 挂证据路径，无证据的「通过」视为不通过）；③ **结论平行可见**（`reviewer{n}` 的逐条结论与证据路径**随 devm 向 director 的回报一并给出** —— director 不参与验收裁定，但看得到；2026-11-04 第七十次立）；④ **抽查下限 ＋ 高风险复验 ＋ 留痕**（director **每批至少抽 1 票**（副轨 `reviewer{n}`）；**高风险票 —— 设备 / SHA / 门禁 / 破坏性变更类 —— 100% 复验**，由 director **自派 `reviewer{n}` 副轨**执行（副轨与 devm 主轨 `reviewer{n}` 实例独立）；复验结论与证据**必须留痕**（写 `docs/handoff/` 或回报），不做口头结论；发现验收不实 ⇒ 打回 devm 重验）。验收通过 ⇒ **devm 直接执行 merge 与 push**（每 ticket 一推，不再等 director 通知）；不通过 ⇒ 打回 `dev-e` 返工，不得先 merge/push。硬件设备写操作由 `devm` 或 `director` 执行。`reviewer{n}` 是子代理、不占 pane、不装技能（`/code-review` 写进派发 prompt）；director 不代推、不代 merge。
7. **并行（无依赖任务一律开满，2026-11-04 用户裁定）**：对无依赖关系的任务，各角色**必须开满 subagents 并行**（director 在 devm/anam 之间，产品单元在多个 `pde{n}` 之间；devm 在多个 `dev-e` 之间；anam 在多个 `ana-e` 之间），优先级：dynamic workflow > 多个 subagents 并行；**该口径适用于总监与经理；开满到 harness 并发上限，不得自行留一手串行**；只有真依赖（共享文件 / 共享构建目标 / 顺序验收 / 同一设备 / 同一 REA 会话）才串行且须写明理由，**不得越级派发**。**director 自己的无依赖工作（评审前证据预检、文档交叉核对、外部事实取证、产品取证）同样必须开满子代理并行**，结论由本人落笔。

### 4.1 PRD 模板（`pde{n}` 落笔，director 定稿）

`Problem Statement` / `目标用户与场景` / `方案概述` / `用户故事（可验收）` / `验收标准` / `范围外` / `开放问题`。

### 4.2 SPEC 模板（`pde{n}` 落笔，director 定稿）

`Problem Statement` / `Solution` / `User Stories` / `验收标准（逐条可测）` / `实现决策` / `测试接缝` / `Out of Scope` / `变更记录`。
SPEC 必须自包含：每条 User Story 都能转成 ticket 与用例。

### 4.3 工单模板（`pde{n}` 落笔，director 定稿）

`目标` / `输入 SPEC 小节` / `验收判据（逐条可测）` / `Files 范围` / `依赖（票号）` / `timeoutMs` / `状态` / `实施状态（devm 追加）`。
工单由 `pde{n}` 用 [`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md) 按 tracer-bullet 纵向切片、director 定稿；**编号按依赖序、`spec-seq` 与 SPEC 严格对齐**；`Files 范围` 互不重叠，`依赖` 必须无环。
