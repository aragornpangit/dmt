# 可选运行适配器矩阵

主流程不依赖本表。以下能力保留为按需工具，避免删除已有实测能力，但不得成为角色开工前置。

| 类别 | 脚本 / 文档 | 启用条件 |
|---|---|---|
| 收件箱 | `send-msg.sh`、`msg-take.sh`、`msg-done.sh`、`comms.md` | 跨 pane 角色不能使用原生返回通道 |
| helper | `spawn-helper.sh`、`helper-report.sh`、`close-helper.sh`、`helper.md` | 仅 herdr 多 pane，且本体验收容量不足 |
| 团队布局 | `launch.sh`、`setup-team.sh`、`runtime.md` | 显式部署完整 herdr 团队 |
| Orca | `orca-launch.sh`、`orca-reap.sh`、`orca-fix-cli-impl.sh`、`harness/orca.md` | 使用 Orca ADE 与派生终端 |
| CodeBuddy 复核 | `auto-review-model.sh`、`permission-notes.md` | 使用本地复核端点并需要健康门 |
| 维护 | `bump-version.sh`、`install-git-hooks.sh` | 维护技能仓自身 |

`check-dmt.sh --verbose` 的 A4 会校验主流程脚本与可选脚本均已登记；登记表示可执行物与测试职责清晰，不表示主流程必须运行全部脚本。
