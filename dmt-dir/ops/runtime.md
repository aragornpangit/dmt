# 可选：herdr pane 运行适配器

仅在多 pane 部署时使用。角色身份取唯一 pane label，不依赖 tab 位置或缓存的 pane id。

## 布局与容量

默认开发线为两级（`dmt-dm` 直接派 `dmt-de`，独立评审由其另派临时子代理），只需要 `dmt-dm` pane；**不需要 `dmt-dir-am` tab**。以下为显式启用可选完整团队适配器时的默认布局，项目可按需裁剪：

- tab `dmt-dir-am`：`dmt-dir` 左 60%、`dmt-am` 右 40%。
- tab `dmt-dm`：`dmt-dm` 独占。
- 避免关闭包含其他工作角色的整个 tab；关闭 pane 前核实在办任务与工作区状态。

## 启动

`setup-team.sh` 用于显式部署完整 DMT 团队，不是技能加载步骤：

```bash
bash dmt-dir/scripts/setup-team.sh --harness <name>
```

`setup-team.sh` 部署上述布局。启动命令和就绪方式以 harness 矩阵为准。

权限模式由用户和项目安全策略决定，不能为了门铃或文件访问默认放开危险权限。Codex 沙箱说明见 [`../harness/codex.md`](../harness/codex.md)。

helper 见 [`helper.md`](helper.md)，文件占用见 [`file-claim.md`](file-claim.md)。
