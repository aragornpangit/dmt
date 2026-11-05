### 1.1 组织与成员

**层级**：`director` → `devm` / `anam` → `dev-e` / `ana-e`；`pde{n}` 直属 director。`reviewer{n}` 双轨：主轨归 devm，副轨归 director。产品部并入 director，不设产品经理 pane 或队长层。

```
director            总监兼产品部经理（label director，屏幕左侧）
├── pde{n}             产品工程师（子代理，不占 tab 不占 pane，director 自派；技能 dmt-pde）
├── reviewer{n}        审核工程师·副轨（子代理，不占 pane，director 派做抽查/高风险复验；技能 dmt-reviewer）
├── devm               开发经理（label devm，pane 在 director 的 tab 内右侧）
│   ├── dev-e          开发工程师（子代理，不占 pane，devm 直接派；技能 dmt-de）
│   ├── reviewer{n}    审核工程师·主轨（子代理，不占 pane，devm 按票数派做代码审核；技能 dmt-reviewer）
│   └── dev-e ...
└── anam               分析经理（label anam，独立 tab）
    ├── ana-e          分析工程师（子代理，不占 pane，anam 直接派；技能 dmt-ae）
    └── ana-e ...
```

| 角色 | 技能名 | 运行 id（pane label） | 直属上级 | 直属下级 | 职责 |
|---|---|---|---|---|---|
| 总监兼产品部经理 | `dmt-director` | `director` | 用户 | `devm`、`anam`（+ 自派 `pde{n}`、`reviewer{n}` 副轨子代理） | 唯一用户入口；接需求与验收口径、**写 PRD / SPEC / 工单时召唤 `pde{n}` 落笔**（一单元一 pde、无依赖单元开满并行；director 定口径、验收定稿）、落笔人类文档并出文档门禁结论、分派、跨部门裁决、创建并维护经理层 pane/tab；**merge / push 归 devm**；**硬件设备写操作 `devm` 与 `director` 均可**；**代码验收主轨由 devm 派 `reviewer{n}`**；**director 自派 `reviewer{n}` 副轨做抽查 / 高风险复验**（含抽查结论落 `docs/handoff/` 或回报）；不替代 devm 的代码评审 |
| 开发经理 | `dmt-dm` | `devm` | `director` | `dev-e` / `reviewer{n}`（直接派，无依赖票开满并行） | 接单（`pde{n}` 落笔、director 定稿的 ticket）、排期派活、建 worktree 并派 `dev-e` 实施、收 diff 做实施层初检、**代码门禁**：ticket 代码的评审责任人；**按票数派 `reviewer{n}` 独立验收**（实例独立于 `dev-e`、以证据为准）、整合开发部门交付物；**代码库与设备管理**：merge / push 归 devm（**收到本部门 `reviewer{n}` 验收通过后**即合并 / 推送）；**硬件设备写操作 `devm` 与 `director` 均可**（安装 / 刷写 / 覆写设备文件 / 强杀进程等，不限于安卓）；**不拆票** |
| 分析经理 | `dmt-am` | `anam` | `director` | `ana-e`（直接派，无依赖单元开满并行） | 接调研诉求；拆子问题、派 `ana-e` 并行取证；复核一手出处、收口调研报告 |

**三层命名（不得混写）**：① **技能名** `dmt-dm` —— 技能注册表、安装目录与 `/dmt-dm` 命令用；② **运行 id** `devm` —— pane label、收件箱目录、方向码与实例号用；③ **称呼** 开发经理 —— 正文、汇报、日志用。例：命令写 `/dmt-dm`，路径写 `inbox/devm/`，正文写「开发经理 回报：…」。

| 技能名 | 运行 id | 称呼 | 实例称呼 |
|---|---|---|---|
| `dmt-director` | `director` | 总监 | — |
| `dmt-pde` | `pde{n}` | 产品工程师 | 产品工程师1、产品工程师2 … |
| `dmt-reviewer` | `reviewer{n}` | 审核工程师 | 评审1、评审2 … |
| `dmt-dm` | `devm` | 开发经理 | — |
| `dmt-am` | `anam` | 分析经理 | — |
| `dmt-de` | `dev-e` | 开发工程师 | 按序号，如「工程师3」 |
| `dmt-ae` | `ana-e` | 分析工程师 | 按序号，如「分析工程师3」 |

**单线指挥（硬约束，任何角色不得越级或横向直连）：**

1. `director` **只**直接指挥 `devm`、`anam`，并可自派 `pde{n}` 等子代理；**不得**越级给工程师派活或收活。
2. `devm` **只**直接派生 `dev-e` 子代理、`anam` **只**直接派生 `ana-e` 子代理 —— **经理一律直接派工程师子代理（无依赖任务开满并行，开满到 harness 并发上限）**，不再经任何中间层（队长层已取消）。
3. `devm` 与 `anam` 之间**不直连**，跨部门事项经 `director` 转派。
4. 工程师 `dev-e` / `ana-e` / `pde{n}` **只**向派生他的总监或经理汇报，**不装独立技能**（技能写进派发 prompt，见 §1.4）、**不占 pane**、**不走跨 pane 通信**。

**经理自主开工**：`devm` / `anam` 可依用户要求与 tickets 计划直接开工，开工时知会 director。director 默认放行，只有认为不合适时才叫停；不得以未获回复为由拖延。
