# 可选：herdr pane 运行适配器

仅在多 pane 部署时使用。角色身份取唯一 pane label，不依赖 tab 位置或缓存的 pane id。

## 布局与容量

- tab/pane 数量、布局和角色副本由项目容量与任务决定，无固定常驻下限。
- `DEVL_MIN`、`DEVL_MAX`、`DEVL_PER_TAB` 是 `devl-pane.sh` 的可配置参数；默认不强制补员。
- `devm` 通过 `devl-pane.sh` 声明队长容量意图，适配器负责必要的 tab/pane 创建与回收；devm 不另行手工建 tab。
- 重排只调整适配器管理的 pane，不影响其他角色。
- 避免关闭包含其他工作角色的整个 tab；关闭 pane 前核实在办任务与工作区状态。

## 启动

`setup-team.sh` 用于显式部署完整 DMT 团队，不是技能加载步骤：

```bash
bash dmt-director/scripts/setup-team.sh --harness <name>
```

`devl-pane.sh list|add|remove|rebalance|adopt` 按需管理队长；只有配置了非零下限才使用 `ensure-min`。启动命令和就绪方式以 harness 矩阵为准。

权限模式由用户和项目安全策略决定，不能为了门铃或文件访问默认放开危险权限。Codex 沙箱说明见 [`../harness/codex.md`](../harness/codex.md)。

helper 见 [`helper.md`](helper.md)，文件占用见 [`file-claim.md`](file-claim.md)。
