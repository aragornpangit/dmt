# dmt 团队契约

> **版本 5.16.15 · 2026-11-04** —— 与七份 `SKILL.md` 的 `version:` 同号；不同号即装错。
> **作用域**：本契约全部纪律（权限 / 写操作归属 / 门禁 / pane / 收件箱）**只作用于 dmt 管理的「目标项目」**（`init-project.sh` 初始化的 root）；**维护 `dmt` / `dmt-en` 等技能仓自身时不适用**（维护者可直接 commit / push，无需 director 授权、无需 devm 代推）。
> **唯一权威**：本文件（规范层）+ [`OPS.md`](OPS.md)（操作层）。七份技能只做落地说明，**冲突以本文件为准**。
> **单一来源纪律（硬规则）**：团队口径只在**本文件及其 `team/` 分节**；技能只写「本角色怎么干」，共性一律写指针（`见 team.md §X`），不得复述。

## 目录索引（细节都在 `team/`，本文件只留骨架）

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
| §10 pane 角色公共动作（三份 pane 技能共用：身份/pane、通信、helper、占用） | [`team/10-pane-role.md`](team/10-pane-role.md) |

> 引用写法统一为 `team.md §X`（X = 上表主题号）；改一条口径只改对应 `team/*.md`，不要动技能。

## 团队骨架（细节见 `team/01-org.md`）

层级：`director`（总监兼产品部经理）→ 经理（`devm` / `anam`）→ 工程师（`dev-e` / `ana-e`；`pde{n}` 直属 director）。`reviewer{n}` **双轨**：主轨归 `devm`（代码审核）、副轨归 `director`（仅抽查 / 高风险复验）。

| 角色 | 技能 | 运行 id | 上级 | 下级 |
|---|---|---|---|---|
| 总监兼产品部经理 | `dmt-director` | `director` | 用户 | `devm`、`anam`（+ 自派 `pde{n}` / `reviewer{n}` 副轨） |
| 开发经理 | `dmt-dm` | `devm` | `director` | `dev-e`、`reviewer{n}`（主轨） |
| 分析经理 | `dmt-am` | `anam` | `director` | `ana-e` |
| 产品工程师 | `dmt-pde` | `pde{n}` | `director` | — |
| 开发工程师 | `dmt-de` | `dev-e` | `devm` | — |
| 分析工程师 | `dmt-ae` | `ana-e` | `anam` | — |
| 审核工程师 | `dmt-reviewer` | `reviewer{n}` | 主轨 `devm` / 副轨 `director` | — |

**写操作归属**（细节见 `team/07-discipline.md` §5.1/§5.4）：merge / push 只归 `devm`；硬件设备写操作 `devm` 与 `director` 均可（同一设备单写者）。

## 强制技能（mattpocock，细节见 `team/03-comms.md` §1.4）

每角色必须调用、不得静默跳过、调用要留痕。`director`（grilling / grill-me / grill-with-docs / code-review / to-spec / to-tickets）、`devm`（code-review / diagnosing-bugs）、`anam`（research / grilling / grill-me / grill-with-docs）、`pde{n}`（grilling / research / to-spec / to-tickets）、`reviewer{n}`（code-review）、`dev-e`（tdd / implement / code-review / diagnosing-bugs）、`ana-e`（research / rea / grilling / grill-me / grill-with-docs）。不可用 ⇒ 先装；仍不可用 ⇒ 标注 `[SKILL_UNAVAILABLE]` 回报 director。

## 机检（细节见 `team/09-check.md`）

```bash
bash dmt-director/scripts/check-dmt.sh <项目根>   # 合并入口：结构断言 + 散文断言
```

改路径 / pane / 并行 / 层级 / 写权限 / 强制技能 / 占用 / 门禁 / 通用技能 / 技能链接 / 收件箱三态 / 派单纪律后必须重跑。

## 变更记录

全量变更史见 [`CHANGELOG.md`](CHANGELOG.md)（单一来源，本文件不留副本）。
