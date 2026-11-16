# 开发线与分析线拓扑

默认开发线为**两级**：`dmt-dm` 评估输入后用 `to-tickets` 拆成 ticket、直接派 `dmt-de`，完工后另派加载 `dmt-reviewer` 技能的子代理按 ticket 独立评审，通过才 merge / push。项目可裁剪角色、数量和协作方向。

```text
产品线：dmt-dir（按需派研究）→ dmt-am（多个 dmt-ae 并行取证）→ dmt-am（docs/analyst/ 报告含 Proposal）
        → dmt-dir（PRD）→ dmt-pde（SPEC）→ dmt-dir 审核批准 → dmt-dm
开发线（默认）：dmt-dm（评估 SPEC/需求/bug → to-tickets 拆 ticket）→ dmt-de（tdd/implement/code-review，无依赖 ticket 并行）
                └→ dmt-reviewer 子代理（按 ticket 审查，dmt-dm 另派、未参与实现）→ dmt-dm merge/push
```

- `dmt-dir` 负责需求与跨域裁决；需求存在选型、复用、竞品或架构不确定性时派 `dmt-am`，常规明确需求可跳过外部调研并记录原因。
- `dmt-am` 按来源或问题把调研拆成独立单元，并行派多个 `dmt-ae`；AE 只回报证据，AM 复核后写唯一报告到 `docs/analyst/`，报告必须含 Proposal。
- `dmt-dir` 根据用户需求和含 Proposal 的调研报告（如有）亲自起草 PRD；再安排 `dmt-pde` 用 `to-spec` 据 PRD 起草 SPEC。DIR 审核批准 SPEC 后，把路径与版本交给 `dmt-dm`。
- `dmt-dm` 只从已批准 SPEC 启动，用 `to-tickets` 自行拆出工单并先建 worktree，再**直接向 `dmt-de` 派单**（无依赖单元一次开满）；完工后另派加载 `dmt-reviewer` 技能的独立评审子代理审核 commit/diff，评审通过才 merge、push 并标记 ticket 完成。
- 开发线内部的派单、工作安排、进度与结果回报由开发线自行闭环，不需 `dmt-dir` 确认；只有需求 / SPEC 或验收口径变更、以及跨域冲突才交 `dmt-dir` 裁决。
- `dmt-am` 是调研报告的唯一权威写者；`dmt-de` 是所分配 worktree 功能分支的唯一实现写者与 committer，但不自建 worktree。
- 开发线 Git 权限按**两级 ＋ 独立评审 gate**：`dmt-de` 在功能分支 commit、`dmt-dm` 另派与实现者不同且加载 `dmt-reviewer` 技能的临时子代理基于该 commit 按 ticket 独立评审、评审通过后由 `dmt-dm` merge / push；一个实施单元一个隔离 worktree（独立 index）+ 独立分支，由 `worktree.sh add <ticket>` 建、`worktree.sh remove <ticket>` 收，详见 [`07-discipline.md`](07-discipline.md)。
- 代码验收只在开发线内完成；`dmt-dir` 核对需求、文档与调研结论，不抽检开发团队的代码。
- **观测通道沿汇报线单向向下持有**：`dmt-dm` 持有 `dmt-de` / `dmt-reviewer` 的 pane / terminal 句柄，`dmt-am` 持有 `dmt-ae` 的；`dmt-dir` 不得索取、接收或读取这些下级的句柄与屏幕。`dmt-dir` 想核验开发或调研进展，只用上级可见的可复核产物（commit SHA、diff、测试输出、报告与证据路径），不看下级实时屏幕。
- `dmt-pde`、`dmt-de`、`dmt-ae` 通常作为子代理，只向派发者回报；回报含一手证据路径，汇总不得只留摘要而丢证据。
- 独立评审由 `dmt-dm` 派未参与实现的临时子代理承担，**加载 `dmt-reviewer` 技能**、以 ticket 为单位审查；跨组共享资源由共同协调者串行化，评审者不能与被审实现者相同。
- 用户可直接调用任意角色。独立使用时服从任务指定的派发关系，不补建其余角色。

默认通过 harness 原生 subagent 和返回通道协作，不需要多 pane、收件箱或 helper。只有实际采用这些运行适配器时才读 [`02-runtime.md`](02-runtime.md) 与 [`../OPS.md`](../OPS.md)；收件箱允许方向见 [`../ops/comms.md`](../ops/comms.md)。
