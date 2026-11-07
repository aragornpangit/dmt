# harness 目录（按 harness 加载）

- [`COMMON.md`](COMMON.md) —— 五个 harness 共性（技能到达模型、子代理边界、加载协议）。
- [`pi.md`](pi.md) / [`codebuddy.md`](codebuddy.md) / [`claude.md`](claude.md) / [`codex.md`](codex.md) / [`opencode.md`](opencode.md) —— 各 harness 差异。
- [`pi-agents/`](pi-agents/README.md) —— pi 子代理 agent 定义模板（`inheritSkills: false` + `skills:` 白名单）。
- [`BACKLOG.md`](BACKLOG.md) —— 各 harness 缺陷与改善状态；实测报告见 `logs/2026-11-06-harness-test-report.md`。

机器事实（目录 / 前缀 / 启动 / 并发）只在 [`../harness_matrix.yaml`](../harness_matrix.yaml)；加载入口是八份角色 `SKILL.md` 的「## 0. 按 harness 加载」。
