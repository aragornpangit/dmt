# harness 目录（按 harness 加载）

技能的**按 harness 加载**规则放在这里，拆成「一份共性 + 每 harness 一份差异」：

- [`COMMON.md`](COMMON.md) —— 五个 harness（pi / codebuddy / claude / codex / opencode）**共性**。
- [`pi.md`](pi.md) / [`codebuddy.md`](codebuddy.md) / [`claude.md`](claude.md) / [`codex.md`](codex.md) / [`opencode.md`](opencode.md) —— 各 harness **差异**。

**加载协议**（唯一入口是七份角色 `SKILL.md` 的「## 0. 按 harness 加载」）：

1. `bash dmt-director/scripts/harness-detect.sh` 判定本会话 harness（`pi|codebuddy|claude|codex|opencode`；`unknown` ⇒ 回报 director，不得默认）。
2. 读共性与差异：`harness/COMMON.md` + `harness/<harness>.md`。
3. 按差异文件里的「技能到达模型 / 强制技能调用行 / 子代理承载」执行。

**pi 子代理 agent 定义**：`pi-agents/` 给 dmt 四个子代理角色各一份 agent 定义（`inheritSkills: false` ＋ `skills:` 白名单），由 `install-skills.sh --harness pi` 铺到目标项目 `.pi/agents/` —— 解决 pi 子代理「无技能清单、无 Skill 工具」的问题。机制与实测见 [`pi.md`](pi.md) §4.1。

**测试报告与改善清单**：五 harness 的端到端实测见 `logs/2026-11-06-harness-test-report.md`（仓内）；逐 harness 缺陷与改善状态（含判据）见 [`BACKLOG.md`](BACKLOG.md)。

**单一来源**：目录 / 斜杠前缀 / 启动命令 / 并发上限等**机器可读事实**只在 [`../harness_matrix.yaml`](../../dmt-director/harness_matrix.yaml)；本目录 `.md` 是给人 / 模型读的说明，两者一致性由机检（A8）守住。

**操作层**：pane 形态、启动顺序、权限档位复验见 [`../ops/runtime.md`](../ops/runtime.md)；门铃与收件箱见 [`../ops/comms.md`](../ops/comms.md)。
