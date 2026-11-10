# 各 harness 改善清单（BACKLOG）

> 来源：五 harness 端到端实测（历史测试报告已清理，不随安装分发）。
> 只留未收口项；`DONE` 项已融进仓，见 CHANGELOG。每项必须写「判据」。
> O5（OpenCode v2 `@<skill-id>`）已于 5.19.11 收口，三条判据与证据见 CHANGELOG。

| # | 项 | 判据 | 状态 |
|---|---|---|---|
| X3 | codex `spawn_agent` 载荷不送达（Full Access 下复测同样失败） | 上游修复后才能改判；当前记 `[SUBAGENT_UNAVAILABLE]` 并由本 pane 代行 | **WATCH**（上游缺陷） |
