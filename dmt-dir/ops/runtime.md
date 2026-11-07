# 可选：herdr pane 运行适配器

仅在多 pane 部署时使用。角色身份取唯一 pane label，不依赖 tab 位置或缓存的 pane id。

## 布局与容量

以下为可选完整团队适配器的默认布局，项目可按需裁剪：

- tab `dmt-dir-am`：`dmt-dir` 左 60%、`dmt-am` 右 40%。
- tab `dmt-dm`：`dmt-dm` 左 30%、`dmt-dl1` 右上、`dmt-dl2` 右下（固定两个开发队长）。
- `DL_MIN`、`DL_MAX`（默认 2）、`DM_WIDTH`（默认 0.3）是 `dl-pane.sh` 的可配置参数。
- `dmt-dm` 通过 `dl-pane.sh` 维护队长容量与布局重排；dmt-dm 不另行手工建 tab。
- 重排只调整适配器管理的 pane，不影响其他角色。
- 避免关闭包含其他工作角色的整个 tab；关闭 pane 前核实在办任务与工作区状态。

## 启动

`setup-team.sh` 用于显式部署完整 DMT 团队，不是技能加载步骤：

```bash
bash dmt-dir/scripts/setup-team.sh --harness <name>
```

`dl-pane.sh list|ensure-min|add|remove|rebalance|adopt` 维护两个队长；`setup-team.sh` 部署上述默认布局。启动命令和就绪方式以 harness 矩阵为准。

权限模式由用户和项目安全策略决定，不能为了门铃或文件访问默认放开危险权限。Codex 沙箱说明见 [`../harness/codex.md`](../harness/codex.md)。

helper 见 [`helper.md`](helper.md)，文件占用见 [`file-claim.md`](file-claim.md)。
