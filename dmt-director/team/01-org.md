### 1.1 组织与成员

**层级**：`director` → `devm` → `devl{n}` → `dev-e`；`director` → `anam` → `ana-e`；`pde{n}` 直属 director。**reviewer 双轨**：主轨归 devl、副轨归 director；主轨按 `spec-seq` 代码审核，副轨做抽查 / 高风险复验。产品部并入 director，不设产品经理 pane。

**pane 与子代理**：占 pane 的只有 `director`、`anam`、`devm`、`devl{n}`（label 同名；`devl{n}` 由 devm 起，下限 2）。`pde{n}` / `reviewer{n}` / `dev-e` / `ana-e` 都是子代理，不占 pane、不走跨 pane 通信。角色职责与技能见 [`team.md`](../team.md)、[`03-comms.md`](03-comms.md) §1.4。

**单线指挥（硬约束，任何角色不得越级或横向直连）：**

1. `director` 只直接指挥 `devm`、`anam`，并可自派 `pde{n}` 与副轨 `reviewer{n}`；不得越级给 `devl{n}` / 工程师派活或收活。
2. `devm` 只直接指挥 `devl{n}`，不直接派 `dev-e`、不派 `reviewer{n}`；`anam` 只直接派 `ana-e`。
3. `devl{n}` 只直接指挥 `dev-e` 与主轨 `reviewer{n}`；队长之间不得通信，跨队协调经 `devm`。
4. `devm` 与 `anam` 之间不直连，跨部门经 `director` 转派。
5. 子代理只向派生他的那一级汇报，用各自技能（`dmt-de` / `dmt-ae` / `dmt-pde` / `dmt-reviewer`），由派生者按 harness 能力选择斜杠调用或读 `SKILL.md`。

**用户直连经理 + 经理自主开工**：用户可直接向 `devm` / `anam` 派活；`devm` 的直接干活限于工单 / merge / push / pane / 运维（**不含代码实施与代码评审**），`anam` 限于调研取证；开工时知会 director。director 默认放行，只有认为不合适时才叫停；不得以未获回复为由拖延。
