# harness 共性适配规则

只适用于矩阵 `harnesses:` 段的 6 个 agent CLI；herdr / Orca 属 harness 运行平台，不是 harness，见 [`README.md`](README.md) 的术语小节。

只有任务需要平台特定能力时才读取本文件和当前平台的一份差异文档；加载技能后按 [`../team/02-runtime.md`](../team/02-runtime.md) 第 1 步完成两轴环境探测。

- 技能到达模型、子代理命名和完成通知优先使用平台原生能力，机器事实以 `harness_matrix.yaml` 为准。
- **启动档统一 yolo（免逐次审批）**：dmt 靠 pane 自主跑长任务，落在 default / manual 档会把每次工具调用变成审批等待（表现为脚本超时、命令失败）。各 harness 的具体参数一律以 `<harness> --help` 实测为准，逐项写在矩阵 `start_cmd`：codebuddy / claude `--dangerously-skip-permissions`，codex `--dangerously-bypass-approvals-and-sandbox`，hermes `--yolo`，opencode `--auto`，pi `--approve`（pi 无 yolo 开关）。首次进入新项目仍可能有一次目录信任提示（claude / codex / pi）或 `hermes skills trust`，那是信任门槛，不是审批档。
- 子代理只向派发者回报；是否占 pane、是否使用收件箱由部署方式决定。
- 派发时明确输入、边界、产物、判据和回报；技能不可调用时给出文件路径或说明能力缺口。
- 辅助工具与技能按任务选择，不强制外部技能包。工具不可用时采用可验证的替代方案。
- 并发按依赖、收益和实际容量决定，矩阵中的上限不是开满目标。
- 子代理只写指定路径；加载技能不等于开工，不因发现仓库状态而自行修改项目。
