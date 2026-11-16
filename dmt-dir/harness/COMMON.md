# harness 共性适配规则

只适用于矩阵 `harnesses:` 段的 6 个 agent CLI；herdr / Orca 属 harness 运行平台，不是 harness，见 [`README.md`](README.md) 的术语小节。

只有任务需要平台特定能力时才读取本文件和当前平台的一份差异文档；加载技能后按 [`../team/02-runtime.md`](../team/02-runtime.md) 第 1 步完成两轴环境探测。

- 技能到达模型、子代理命名和完成通知优先使用平台原生能力，机器事实以 `harness_matrix.yaml` 为准。
- **启动档使用自动模式**：dmt 需要减少逐次审批阻塞，但自动模式不等于无限权限。各 harness 的参数以 `<harness> --help` 和矩阵 `start_cmd` 为准：CodeBuddy 使用 `--permission-mode auto --subagent-permission-mode auto`；其他 harness 使用各自的自动档。首次进入新项目仍可能有一次目录信任提示或 `hermes skills trust`。
- 子代理只向派发者回报；是否占 pane、是否使用收件箱由部署方式决定。
- 派发时明确输入、边界、产物、判据和回报；技能不可调用时给出文件路径或说明能力缺口。
- 辅助工具与技能按任务选择，不强制外部技能包。工具不可用时采用可验证的替代方案。
- 并发按依赖、收益和实际容量决定，矩阵中的上限不是开满目标。
- 子代理只写指定路径；加载技能不等于开工，不因发现仓库状态而自行修改项目。
