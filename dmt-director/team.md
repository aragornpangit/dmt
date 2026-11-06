# dmt 团队契约

> **版本 5.19.0 · 2026-11-06** —— 与八份 `SKILL.md` 的 `version:` 同号；不同号即装错。
> **作用域**：本契约全部纪律（权限 / 写操作归属 / 门禁 / pane / 收件箱）**只作用于 dmt 管理的「目标项目」**（`init-project.sh` 初始化的 root）；**维护 `dmt` / `dmt-en` 等技能仓自身时不适用**（维护者可直接 commit / push，无需 director 授权、无需 devm 代推）。
> **路由**：本文件定义常量；任务细节按其分节读取，操作方法按 [`OPS.md`](OPS.md) 路由。冲突以本文件为准。

## 任务路由

| 主题 | 位置 |
|---|---|
| §1.1 组织与成员（层级 / 组织图 / 角色表 / 三层命名 / 单线指挥 / 自主开工） | [`team/01-org.md`](team/01-org.md) |
| §1.2 运行环境与 pane 生命周期（harness 兼容 / 权限档位复验） | [`team/02-runtime.md`](team/02-runtime.md) |
| §1.3 通信 / §1.4 强制技能 / §1.5 文件占用 | [`team/03-comms.md`](team/03-comms.md) |
| §2 文件命名规范（权威） | [`team/04-naming.md`](team/04-naming.md) |
| §3 目录职责 / §3.1 初始化 | [`team/05-dirs.md`](team/05-dirs.md) |
| §4 工作流程（PRD / SPEC / 工单模板） | [`team/06-workflow.md`](team/06-workflow.md) |
| §5 纪律（Git / 并行子代理 / 评审门禁 / 读数纪律） | [`team/07-discipline.md`](team/07-discipline.md)（派发 prompt 模板与 pi 承载见 [`team/07b-dispatch.md`](team/07b-dispatch.md)） |
| §6 表达规范 | [`team/08-expression.md`](team/08-expression.md) |
| §7 机检清单 | [`team/09-check.md`](team/09-check.md) |
| §10 pane 角色公共动作 | [`team/10-pane-role.md`](team/10-pane-role.md) |
| 操作层总路由 | [`OPS.md`](OPS.md) |

## 组织与指挥

层级：`director`（总监兼产品部经理）→ `devm`（开发经理）→ `devl{n}`（开发队长）→ `dev-e`（开发工程师）；`director` → `anam`（分析经理）→ `ana-e`；`pde{n}` 直属 director。`reviewer{n}` **双轨**：主轨归 `devl{n}`（按 `spec-seq` 代码审核）、副轨归 `director`（抽查 / 高风险复验）。

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

**部门**：

| 部门 | 负责人 | 成员 | 职能 |
|---|---|---|---|
| 产品部（并入 director） | `director` | `pde{n}` | 需求澄清、PRD / SPEC 落笔与定稿、文档门禁、验收口径、人类文档 |
| 分析部 | `anam` | `ana-e` | 调研拆题、竞品 / 技术取证、一手出处复核、调研报告收口 |
| 开发部 | `devm` | `devl{n}` → `dev-e` | 工单落笔与派发、实施、代码评审、合并与发布 |
| 审核（双轨，不设独立部门） | 主轨 `devl{n}` / 副轨 `director` | `reviewer{n}` | 按 `spec-seq` 独立验收代码，只认 ticket / SPEC / diff / 证据 |

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
