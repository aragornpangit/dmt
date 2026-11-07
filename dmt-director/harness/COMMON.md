# harness 共性（pi / codebuddy / claude / codex / opencode 通用）

> 本文件 + 一份 harness 差异文件 = 完整加载规则。入口是八份角色 `SKILL.md` 的「## 0. 按 harness 加载」——先跑 `harness-detect.sh`，再读本文件 + `<harness>.md`；`unknown` ⇒ 回报 director，**不得默认**。
> **按需读**：启动只读本文件 + 本 harness 差异；`team.md` / `03-comms` / `07-discipline` / `ops/` 只在对应动作时读，不要一次全读。

## 1. 角色与技能

角色 / 技能 / 形态的唯一表在 [`../team.md`](../team.md)；强制技能清单在 [`../team/03-comms.md`](../team/03-comms.md) §1.4。本文件不复述。

## 2. 强制技能口径

- 强制技能**不是建议**：必须调用；不得以「手写更快」「技能没装」为由跳过。
- 不可用 ⇒ 先按 [`../team/03-comms.md`](../team/03-comms.md) §1.4 安装；仍不可用 ⇒ 标注 `[SKILL_UNAVAILABLE]` 并回报 director。
- **调用要留痕**：回报写明用了哪个技能、产出在哪。

## 3. 技能安装与重载

- 技能名与上游目录名**逐字一致**；`/rea` 属 REA，保持原名（pi 上是 MCP 工具，见 `pi.md` §5）。
- 安装与回退见 [`../team/03-comms.md`](../team/03-comms.md) §1.4。
- 技能目录 / 名称变更后，已运行的 pane 不会自动看到：用 `setup-team.sh --reload` 或重开 pane。

## 4. 子代理边界

子代理（`pde{n}` / `dev-e` / `ana-e` / `reviewer{n}`）**不占 pane、不进收件箱**，只向派生者回报；必须加载其职责对应的技能。队长 `devl{n}` 是 pane 角色，自己加载 `/dmt-devl`；它派子代理时按同一规则下发技能。技能如何交到子代理手里见各 harness 差异 §4 与 `harness_matrix.yaml` 的 `subagent_skill`。

## 5. 两条共同纪律

- **产物边界**：子代理只落 prompt 明确指定的路径，不把中间抓取件堆到 `docs/` 其它目录或项目根。
- **加载 ≠ 开工**：技能装载后停在就绪报到（等派单），不因「读到项目在办件」就自行开工改仓库。
