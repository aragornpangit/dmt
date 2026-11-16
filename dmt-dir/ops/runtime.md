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

启动档使用各 harness 的自动模式（参数见矩阵 `start_cmd`，以 `<harness> --help` 实测）。首次进入新项目仍有一次目录信任或 `hermes skills trust`，那是信任门槛。CodeBuddy 使用 `--permission-mode auto`，不默认全放行；Codex 当前矩阵的自动档会连沙箱一并放行，说明见 [`../harness/codex.md`](../harness/codex.md)。

## 派生资源回收

派生的 pane / terminal / 进程由派生者负责回收（规则见 [`../team/07-discipline.md`](../team/07-discipline.md)「派生资源的生命周期」）：

- herdr：`herdr pane close <id>`；helper pane 用 `close-helper.sh`（带收件箱安检）。
- Orca：`orca-launch.sh` 起终端并登记 `.dmt/orca-terminals.tsv`，完成后用 `orca-reap.sh` 回收；手工起的终端用 `orca terminal close --terminal <handle>`。
- 长期角色 pane（`dmt-dir` / `dmt-dm` / `dmt-am`）是部署设施，不在回收范围。

helper 见 [`helper.md`](helper.md)，文件占用见 [`file-claim.md`](file-claim.md)。
