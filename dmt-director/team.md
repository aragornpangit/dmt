# dmt 协作契约

> **版本 5.19.5 · 2026-11-07** —— 与各角色 `SKILL.md` 同号。
> **作用域**：核心原则适用于使用 dmt 的任务；维护技能仓自身时不触发团队派单、收件箱或发布授权流程。

## 核心原则

1. **明确输入**：目标、范围、产物和验收判据不清楚时先澄清；已有项目约定优先。
2. **按需协作**：角色可独立使用或任意组合，不要求固定人数、层级、pane 或工具。
3. **合理并行**：按依赖、容量和收益决定串并行；共享文件、构建目标和设备须协调写者。
4. **最小写权**：实现者只改分配范围；每个共享工作区只有一个实现写者，发布由获授权者执行。
5. **独立验收**：实现与评审分离；PASS 必须能追溯到判据和证据，验收范围以判据为准。
6. **证据分级**：事实优先使用一手来源，记录可复现步骤，并区分 `[OBS]` / `[INF]` / `[UNK]`。
7. **单线回报**：子代理只向派发者回报结果、证据和未决项；跨域问题由共同协调者收口。
8. **按需加载**：加载角色技能本身不初始化项目、不扫描仓库、不读取适配器或自动开工。

## 角色与模式

`director`、`devm`、`dmt-devl`、`dmt-de`、`dmt-am`、`dmt-ae`、`dmt-pde`、`dmt-reviewer` 是可复用能力，不是必须同时启用的组织编制。完整 DMT 团队模式见 [`team/01-org.md`](team/01-org.md)。

## 按需参考

| 任务 | 文档 |
|---|---|
| 完整团队拓扑 | [`team/01-org.md`](team/01-org.md) |
| 平台与多 pane 适配 | [`team/02-runtime.md`](team/02-runtime.md) |
| 通信与工具选择 | [`team/03-comms.md`](team/03-comms.md) |
| 项目命名与目录 | [`team/04-naming.md`](team/04-naming.md) · [`team/05-dirs.md`](team/05-dirs.md) |
| 工作流与派发 | [`team/06-workflow.md`](team/06-workflow.md) · [`team/07b-dispatch.md`](team/07b-dispatch.md) |
| 工程纪律 | [`team/07-discipline.md`](team/07-discipline.md) |
| 结构检查 | [`team/09-check.md`](team/09-check.md) |
| herdr / inbox / helper | [`OPS.md`](OPS.md) |

历史与维护记录见 `CHANGELOG.md` 和 `logs/`，不进入任务加载路径。
