# harness 共性（pi / codebuddy / claude / codex / opencode 通用）

> **这是「技能加载」的公共半部**：本文件 ＋ 一份 harness 差异文件（[`pi.md`](pi.md) / [`codebuddy.md`](codebuddy.md) / [`claude.md`](claude.md) / [`codex.md`](codex.md) / [`opencode.md`](opencode.md)）合起来才是完整规则。
> **怎么加载**：八份角色 `SKILL.md` 的「## 0. 按 harness 加载」是唯一入口 —— 先跑 `dmt-director/scripts/harness-detect.sh`，再读本文件（共性）＋ `<harness>.md`（差异）。
> **找不到 / 判不出**：`unknown` ⇒ 回报 director，**不得默认成某个 harness**。

## 1. 技能清单与角色对应

| 角色（运行 id） | 技能目录名 | 形态 |
|---|---|---|
| `director` | `dmt-director` | pane 常驻 |
| `devm` | `dmt-dm` | pane 常驻 |
| `devl{n}` | `dmt-devl` | pane 常驻 |
| `anam` | `dmt-am` | pane 常驻 |
| `pde{n}` | `dmt-pde` | 子代理 |
| `dev-e` | `dmt-de` | 子代理 |
| `ana-e` | `dmt-ae` | 子代理 |
| `reviewer{n}` | `dmt-reviewer` | 子代理 |

技能名 = 目录名；运行 id 只用于 pane label、收件箱目录与方向码（三层不混写，见 [`../team/01-org.md`](../team/01-org.md)）。

## 2. 强制技能口径（五 harness 一致）

- 强制技能**不是建议**：每个角色在其职责动作中**必须**调用；不得以「手写更快」「技能没装」为由静默跳过。
- 不可用 ⇒ 先按 §3 安装；仍不可用 ⇒ 在产物与回报里标注 `[SKILL_UNAVAILABLE]` 并回报 director 裁决。
- **调用要留痕**：回报写明用了哪个技能、产出在哪。
- 逐角色清单是 [`../team/03-comms.md`](../team/03-comms.md) §1.4（**唯一权威**；本文件不复述）。

## 3. 技能源与安装回退

- mattpocock 技能：`npx skills@latest add mattpocock/skills -a <agent>`；失败则克隆 `https://github.com/mattpocock/skills.git`，把技能目录放到**该 harness 认的目录**（见差异文件 §1）。
- 技能名与上游目录名**逐字一致**；`/rea` 属 REA，保持原名（pi 上是 MCP 工具，见 `pi.md` §5）。
- 五个 harness 的**技能发现目录各不相同**（`.agents/skills/` 只覆盖 codex / opencode / pi）⇒ 装到哪个 harness 就软链到哪个目录；`install-skills.sh --harness all` 默认铺三处。

## 4. 技能变更后的重载

技能目录 / 技能名变更后**已在跑的 pane 不会自动看到**：用 `setup-team.sh --reload` 或重开 pane。

## 5. 技能预算与单一来源

每份 `SKILL.md` 有字节预算（`../dmt_contract.yaml: skill_budgets`），超了机检红。共性口径（组织 / 权限 / 门禁 / 并行 / 命名 / harness 差异）**一律写指针**，不写进角色技能。

## 6. 子代理的共同边界

子代理（`pde{n}` / `dev-e` / `ana-e` / `reviewer{n}`）**不占 pane、不进收件箱**，只向派生者回报；**每个子代理都必须加载其职责对应的技能**（`dmt-pde` / `dmt-de` / `dmt-ae` / `dmt-reviewer`），不能只贴技能正文代替调用。**怎么把技能交到子代理手里**是各 harness 的差异（见差异文件 §4 与 `harness_matrix.yaml` 的 `subagent_skill`）：能直接调用的走斜杠（cbc/claude/codex）或 `@<技能名>`（opencode），不能的读 `SKILL.md` 路径（pi/codex）。队长 `devl{n}` 是 pane 角色，自己加载 `/dmt-devl`；它派子代理时按同一规则下发技能（[`../team/07b-dispatch.md`](../team/07b-dispatch.md)）。

## 7. 两条共同纪律（2026-11-05 pi / claude 双侧实测补）

- **产物边界**：子代理**只落 prompt 明确指定的路径**（如 `docs/analyst/evidence/<单元>/`），不得把中间抓取件（`.java` 样本 / `.aar` / HTML 报告 / 日志）堆到 `docs/` 其它目录或项目根。实测有子代理把 26 个抓取件堆进工作目录 ⇒ 会污染 `docs/analyst/evidence/`。
- **加载 ≠ 开工**：技能装载后**停在就绪报到**（等派单），不要因为「读到项目在办件」就自行开工改仓库。实测三个 pane 装载后自发开工，其中 `devm` 真建了 detached worktree（发现越界后自行 `git worktree remove --force` 撤销并声明）⇒ 在 yolo/auto 档下这是可直接写坏仓库的风险。
