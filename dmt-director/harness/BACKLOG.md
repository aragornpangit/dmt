# 各 harness 改善清单（BACKLOG）

> 来源：五 harness 端到端实测（`logs/2026-11-06-harness-test-report.md`，英文摘要 `.en.md`）。
> 只留未收口项；`DONE` 项已融进仓，见 CHANGELOG。每项必须写「判据」。

| # | 项 | 判据 | 状态 |
|---|---|---|---|
| X3 | codex `spawn_agent` 载荷不送达（Full Access 下复测同样失败） | 上游修复后才能改判；当前记 `[SUBAGENT_UNAVAILABLE]` 并由本 pane 代行 | **WATCH**（上游缺陷） |
| O5 | OpenCode v2 统一用 `@<skill-id>` 加载技能 | 2.2.5 pane 中 `herdr agent prompt <pane> '@to-spec'` 能让技能正文进上下文；同名文件时选中 skill 而非文件；`skill({id})` 仍可用 | **OPEN**（契约已改，复测待补） |
