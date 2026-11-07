# dmt 团队契约

> **版本 5.19.4 · 2026-11-07** —— 与八份 `SKILL.md` 的 `version:` 同号；不同号即装错。
> **作用域**：本契约全部纪律（权限 / 写操作归属 / 门禁 / pane / 收件箱）**只作用于 dmt 管理的「目标项目」**（`init-project.sh` 初始化的 root）；**维护 `dmt` / `dmt-en` 等技能仓自身时不适用**（维护者可直接 commit / push，无需 director 授权、无需 devm 代推）。
> **路由**：本文件定义常量；任务细节按其分节读取，操作方法按 [`OPS.md`](OPS.md) 路由。冲突以本文件为准。

**路由**：§1 组织 / 运行 / 通信 → [`01-org`](team/01-org.md) / [`02-runtime`](team/02-runtime.md) / [`03-comms`](team/03-comms.md)；§2 命名 → [`04`](team/04-naming.md)；§3 目录 → [`05`](team/05-dirs.md)；§4 工作流 → [`06`](team/06-workflow.md)；§5 纪律 → [`07`](team/07-discipline.md) + [`07b`](team/07b-dispatch.md)；§6/§7/§10 → [`08`](team/08-expression.md) / [`09`](team/09-check.md) / [`10`](team/10-pane-role.md)。操作层见 [`OPS.md`](OPS.md)。

## 组织与指挥

| 角色 | 技能 | 运行 id | 上级 | 下级 |
|---|---|---|---|---|
| 总监兼产品部经理 | `dmt-director` | `director` | 用户 | `devm`、`anam`（+ 自派 `pde{n}` / `reviewer{n}` 副轨） |
| 开发经理 | `dmt-dm` | `devm` | `director` | `devl{n}` |
| 开发队长 | `dmt-devl` | `devl{n}` | `devm` | `dev-e`、`reviewer{n}`（主轨） |
| 分析经理 | `dmt-am` | `anam` | `director` | `ana-e` |
| 产品工程师 | `dmt-pde` | `pde{n}` | `director` | — |
| 开发工程师 | `dmt-de` | `dev-e` | `devl{n}` | — |
| 分析工程师 | `dmt-ae` | `ana-e` | `anam` | — |
| 审核工程师 | `dmt-reviewer` | `reviewer{n}` | 主轨 `devl{n}` / 副轨 `director` | — |

**指挥线**：director → devm → devl{n} → dev-e；director → anam → ana-e；pde 直属 director；reviewer 主轨归 devl、副轨归 director。队长之间不通信；devm 与 anam 不直连；跨部门经 director。

**写操作**：merge / push 只归 devm；队长只 commit，不 push / 不 merge；硬件设备写操作 devm 与 director 均可，同一设备单写者。

**并行**：无依赖任务开满 subagents；共享文件、构建目标、设备或验收顺序必须串行。

**worktree**：统一建在主仓 `.worktrees/{ticket-id}`，分支 `feat/{ticket-id}`；队长持有，`dev-e` 是唯一写者。

**常量**：

| 常量 | 值 | 含义 |
|---|---|---|
| `DEVL_MIN` | `2` | 队长常驻下限，任何时刻不少于 2 个 |
| `DEVL_MAX` | `0` | 不设策略上限，由 pane 高度与 harness 并发决定 |
| `MIN_DEVL_ROWS` | `14` | 单个队长 pane 高度下限；几何上限 `floor(tab_height / 14)` |

**强制技能**：每角色按 [`team/03-comms.md`](team/03-comms.md) §1.4 调用；子代理由派生者按 harness 能力选择斜杠调用或读 `SKILL.md`；不可用先安装，仍不可用标注 `[SKILL_UNAVAILABLE]`。

**helper**：`dmt-devl` **不设 helper**；`director` / `devm` / `anam` 的 helper 规则不变。

**机检**：

```bash
bash dmt-director/scripts/check-dmt.sh <项目根>
```

## 变更记录

全量变更史见 [`CHANGELOG.md`](CHANGELOG.md)（单一来源，本文件不留副本）。
