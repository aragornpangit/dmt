### 1.1 组织与成员

**层级**：`director` → `devm` → `devl{n}` → `dev-e`；`director` → `anam` → `ana-e`；`pde{n}` 直属 director。**reviewer 双轨**：主轨归 devl、副轨归 director；主轨按 `spec-seq` 代码审核，副轨做抽查 / 高风险复验。产品部并入 director，不设产品经理 pane。

```
director            总监兼产品部经理（label director，director tab 左侧）
├── pde{n}             产品工程师（子代理，不占 pane，director 自派；技能 dmt-pde）
├── reviewer{n}        审核工程师·副轨（子代理，不占 pane，director 派做抽查 / 高风险复验；技能 dmt-reviewer）
├── anam               分析经理（label anam，director tab 右侧）
│   ├── ana-e          分析工程师（子代理，不占 pane，anam 直接派；技能 dmt-ae）
│   └── ana-e ...
└── devm               开发经理（label devm，dmt-dev tab 左侧）
    ├── devl1          开发队长（label devl1，dmt-dev tab 右侧；技能 dmt-devl）
    │   ├── dev-e          开发工程师（子代理，不占 pane；技能 dmt-de）
    │   ├── reviewer{n}    审核工程师·主轨（子代理，不占 pane；技能 dmt-reviewer）
    │   └── dev-e ...
    ├── devl2          开发队长（label devl2）
    │   └── ...
    └── devl{n} ...    按票量增加，下限 2（DEVL_MIN=2）
```

| 角色 | 技能名 | 运行 id（pane label） | 直属上级 | 直属下级 | 职责 |
|---|---|---|---|---|---|
| 总监兼产品部经理 | `dmt-director` | `director` | 用户 | `devm`、`anam`（+ 自派 `pde{n}`、`reviewer{n}` 副轨子代理） | 唯一用户入口；接需求与验收口径；**PRD / SPEC 派 `pde{n}` 落笔并定稿**；**工单由 devm 落笔、director 定稿**；落笔人类文档并出文档门禁结论；分派、跨部门裁决、创建并维护经理层 pane/tab；**merge / push 归 devm**；**硬件设备写操作 `devm` 与 `director` 均可**；**代码验收主轨由 devl 派 `reviewer{n}`**；**director 自派 `reviewer{n}` 副轨做抽查 / 高风险复验**（含抽查结论落 `docs/handoff/` 或回报）；不替代 devl 的代码评审 |
| 开发经理 | `dmt-dm` | `devm` | `director` | `devl{n}` | 落笔 `to-tickets`、按依赖排期派单给 `devl{n}`、**管理 `devl` pane 生命周期**（补到 ≥2、按票扩容、回收、崩溃重建）、**裁决队长的疑问与歧义**、**merge**、**push**、向 director 汇报；**不做代码评审、不派 `reviewer{n}`、不直接派 `dev-e`**；不拆改判据 |
| 开发队长 | `dmt-devl` | `devl{n}` | `devm` | `dev-e`、`reviewer{n}`（主轨） | 接票；一票一 worktree（`.worktrees/{ticket-id}`，分支 `feat/{ticket-id}`）；派 `dev-e` 用 `/tdd`、`/implement`、`/code-review` 实施；**按 `spec-seq` 派 `reviewer{n}` 独立评审**（每票新实例）；**汇总自派 subagents 的结果**；reviewer PASS 后上报 devm；**不 push、不 merge、不跨队长通信** |
| 分析经理 | `dmt-am` | `anam` | `director` | `ana-e`（直接派，无依赖单元开满并行） | 接调研诉求；拆子问题、派 `ana-e` 并行取证；复核一手出处、收口调研报告；只向 director 汇报 |
| 产品工程师 | `dmt-pde` | `pde{n}` | `director` | — | 一单元一 pde，落笔 PRD / SPEC；`to-tickets` 已移交 devm，不再由 pde 落笔 |
| 开发工程师 | `dmt-de` | `dev-e` | `devl{n}` | — | 在指定 worktree 内实施、跑测试、显式路径 `add` + `commit`；不 push、不 merge |
| 分析工程师 | `dmt-ae` | `ana-e` | `anam` | — | 单个子问题取证，一手来源优先 |
| 审核工程师 | `dmt-reviewer` | `reviewer{n}` | 主轨 `devl{n}` / 副轨 `director` | — | 对照同 `spec-seq` 的 SPEC 与 ticket 判据逐条验收；只认 ticket、SPEC、diff、证据；输出 PASS / FAIL + 证据清单 |

**三层命名（不得混写）**：① **技能名** `dmt-devl` —— 技能注册表、安装目录与 `/dmt-devl` 命令用；② **运行 id** `devl{n}` —— pane label、收件箱目录、方向码与实例号用；③ **称呼** 开发队长 —— 正文、汇报、日志用。例：命令写 `/dmt-devl`，路径写 `inbox/devl1/`，正文写「开发队长1 回报：…」。

| 技能名 | 运行 id | 称呼 | 实例称呼 |
|---|---|---|---|
| `dmt-director` | `director` | 总监 | — |
| `dmt-pde` | `pde{n}` | 产品工程师 | 产品工程师1、产品工程师2 … |
| `dmt-am` | `anam` | 分析经理 | — |
| `dmt-ae` | `ana-e` | 分析工程师 | 分析工程师1、分析工程师2 … |
| `dmt-dm` | `devm` | 开发经理 | — |
| `dmt-devl` | `devl{n}` | 开发队长 | 队长1、队长2 … |
| `dmt-de` | `dev-e` | 开发工程师 | 按序号，如「工程师3」 |
| `dmt-reviewer` | `reviewer{n}` | 审核工程师 | 评审1、评审2 … |

**单线指挥（硬约束，任何角色不得越级或横向直连）：**

1. `director` **只**直接指挥 `devm`、`anam`，并可自派 `pde{n}`、`reviewer{n}` 副轨；**不得**越级给 `devl{n}` / 工程师派活或收活。
2. `devm` **只**直接指挥 `devl{n}`，**不直接派 `dev-e`、不派 `reviewer{n}`**；`anam` **只**直接派 `ana-e`。
3. `devl{n}` **只**直接指挥 `dev-e` 与 `reviewer{n}` 主轨；**队长之间不得通信**，跨队协调一律经 `devm`。
4. `devm` 与 `anam` 之间**不直连**，跨部门事项经 `director` 转派。
5. 子代理 `dev-e` / `ana-e` / `pde{n}` / `reviewer{n}` **只**向派生他的那一级汇报，**不装独立 pane、不走跨 pane 通信**；每个子代理使用其职责对应技能（`dmt-de` / `dmt-ae` / `dmt-pde` / `dmt-reviewer`），由派生者按 harness 能力选择斜杠调用或读 `SKILL.md`。

**经理自主开工**：`devm` / `anam` 可依用户要求与 tickets 计划直接开工，开工时知会 director。director 默认放行，只有认为不合适时才叫停；不得以未获回复为由拖延。
