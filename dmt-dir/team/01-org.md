# 开发线与分析线拓扑

默认开发线为**两级**：`dmt-dm` 直接派 `dmt-de`，独立评审由 `dmt-dm` 另派临时子代理。`dmt-dl` 只是**可选协调者**，不是默认层级；项目可裁剪角色、数量和协作方向。

```text
产品线：dmt-dir → dmt-pde（定稿 SPEC）
          └─（可选派单）→ dmt-dm
开发线（默认）：dmt-dm（读 SPEC，用 to-tickets 拆单）→ dmt-de（无依赖单元并行）
                └→ 独立评审子代理（dmt-dm 另派，未参与实现）
可选扩展：dmt-dm → dmt-dl（票批大、需独立上下文时按需派生，完成即回收）
分析线：dmt-dir → dmt-am → dmt-ae
```

- `dmt-dir` 负责需求与跨域裁决，并安排 `dmt-pde` 定稿 SPEC；需要时也可直接向 `dmt-dm` 派单。
- `dmt-dm` 以定稿 SPEC（见 [`05-dirs.md`](05-dirs.md) 的 `docs/pd/spec/`）为输入，用 `to-tickets` 自行拆出工单，**直接向 `dmt-de` 派单**（无依赖单元一次开满）、另派未参与实现的临时子代理独立评审、整合交付；开发线默认靠 SPEC 产物启动，不依赖 `dmt-dir` 的派单。
- 开发线内部的派单、工作安排、进度与结果回报由开发线自行闭环，不需 `dmt-dir` 确认；只有需求 / SPEC 或验收口径变更、以及跨域冲突才交 `dmt-dir` 裁决。
- `dmt-am` 负责调研收口；`dmt-de` 是所分配 worktree 功能分支的唯一实现写者与 committer。
- 开发线 Git 权限按**两级 ＋ 独立评审 gate**：`dmt-de` 在功能分支 commit、`dmt-dm` 另派与实现者不同的临时子代理基于该 commit 独立评审、评审通过后由 `dmt-dm` merge / push；一个实施单元一个隔离 worktree（独立 index）+ 独立分支，详见 [`07-discipline.md`](07-discipline.md)。
- 代码验收只在开发线内完成；`dmt-dir` 核对需求、文档与调研结论，不抽检开发团队的代码。
- `dmt-pde`、`dmt-de`、`dmt-ae` 通常作为子代理，只向派发者回报；回报含一手证据路径，汇总不得只留摘要而丢证据。
- 独立评审由 `dmt-dm` 派未参与实现的临时子代理承担（不设专用技能）；跨组共享资源由共同协调者串行化，评审者不能与被审实现者相同。
- **可选协调者 `dmt-dl`**：仅当票批大到需要独立上下文隔离时由 `dmt-dm` 按需派生，持有 worktree 与票批、组织一线自检；不是默认层级，完成任务即回收。启用时的 pane／通信适配器见 [`02-runtime.md`](02-runtime.md) 与 [`../ops/runtime.md`](../ops/runtime.md)。
- 用户可直接调用任意角色。独立使用时服从任务指定的派发关系，不补建其余角色。

多 pane 部署、收件箱和 helper 都是运行适配器，见 [`02-runtime.md`](02-runtime.md) 与 [`../OPS.md`](../OPS.md)；收件箱允许方向见 [`../ops/comms.md`](../ops/comms.md)。
