# 可选：完整 DMT 团队拓扑

只有显式采用完整团队模式时才使用本映射；项目可裁剪角色、数量和协作方向。

```text
产品线：dmt-dir → dmt-pde（定稿 SPEC）
开发线：dmt-dm（读 SPEC，用 to-tickets 自行拆单）→ dmt-dl → dmt-de
分析线：dmt-dir → dmt-am → dmt-ae
独立评审：dmt-dl → 临时子代理（未参与实现）
```

- `dmt-dir` 负责需求与跨域裁决，并安排 `dmt-pde` 定稿 SPEC；**不向 `dmt-dm` 派单**。
- `dmt-dm` 以定稿 SPEC（见 [`05-dirs.md`](05-dirs.md) 的 `docs/pd/spec/`）为输入，用 `to-tickets` 自行拆出工单并向 `dmt-dl` 派单、整合交付；开发线靠 SPEC 产物启动，不靠 `dmt-dir` 的收件箱消息。
- `dmt-am` 负责调研收口；`dmt-dl` 协调实施和独立评审；`dmt-de` 是所分配工作区的唯一实现写者与提交者。
- 代码验收只在开发线内完成；`dmt-dir` 核对需求、文档与调研结论，不抽检开发团队的代码。
- `dmt-pde`、`dmt-de`、`dmt-ae` 通常作为子代理，只向派发者回报。
- 独立评审由 `dmt-dl` 派未参与实现的临时子代理承担（不设专用技能）；跨组共享资源由共同协调者串行化，评审者不能与被审实现者相同。
- 用户可直接调用任意角色。独立使用时服从任务指定的派发关系，不补建其余角色。

多 pane 部署、收件箱和 helper 都是运行适配器，见 [`02-runtime.md`](02-runtime.md) 与 [`../OPS.md`](../OPS.md)；收件箱允许方向见 [`../ops/comms.md`](../ops/comms.md)。
