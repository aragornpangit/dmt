# 可选：完整 DMT 团队拓扑

只有显式采用完整团队模式时才使用本映射；项目可裁剪角色、数量和协作方向。

```text
director → devm → dmt-devl → dmt-de
director → anam → ana-e
director → pde
dmt-devl → dmt-reviewer（须独立于实现者）
```

- `director` 负责需求与跨域裁决，`devm` 负责工单与整合，`anam` 负责调研收口。
- `dmt-devl` 协调实施和独立评审；`dmt-de` 是所分配工作区的唯一实现写者与提交者。
- 代码验收只在开发线内完成；director 核对需求、文档与调研结论，不抽检开发团队的代码。
- `pde`、`dmt-de`、`ana-e`、`dmt-reviewer` 通常作为子代理，只向派发者回报。
- 跨组共享资源由共同协调者串行化；评审者不能与被审实现者相同。
- 用户可直接调用任意角色。独立使用时服从任务指定的派发关系，不补建其余角色。

多 pane 部署、收件箱和 helper 都是运行适配器，见 [`02-runtime.md`](02-runtime.md) 与 [`../OPS.md`](../OPS.md)。
