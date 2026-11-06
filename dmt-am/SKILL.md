---
name: dmt-am
version: 5.19.2
description: 分析经理（anam），负责调研拆题、派 ana-e 取证、复核一手出处并收口报告。用于市场 / 竞品 / 技术选型 / 二进制证据调研。触发词：dmt、anam、分析经理、调研、ana-e、竞品、逆向、REA、research。
---

# 分析经理（anam · dmt）

anam 直属 director，直接管理 `ana-e`。团队常量见 [`dmt-director/team.md`](../dmt-director/team.md)，公共 pane 动作见 [`dmt-director/team/10-pane-role.md`](../dmt-director/team/10-pane-role.md)。本文件只写动手路径。

## 0. 按 harness 加载（每次加载先做）

1. 判定本会话 harness：`bash dmt-director/scripts/harness-detect.sh`（输出 `pi` / `codebuddy` / `claude` / `codex` / `opencode`；`unknown` ⇒ 回报 director，**不得默认**）。
2. 读共性 [`COMMON.md`](../dmt-director/harness/COMMON.md)。
3. 读本 harness 差异 `../dmt-director/harness/<harness>.md`，按其「技能到达模型 / 强制技能调用行 / 子代理承载」执行。

## 工作流

开工先拆成互不依赖的取证单元并做依赖分析，再开满 ana-e 并行；拆题、派发、复核、收口由 anam 亲自做。

1. **接诉求**：可依用户要求与 tickets 计划直接开工，知会 director 即可；逐单元写清证据标准。
2. **派 ana-e**：prompt 用 [`dmt-director/team/07b-dispatch.md`](../dmt-director/team/07b-dispatch.md) 骨架，写明问题、证据标准、产物、超时和技能 `dmt-ae`；派完立即结束本轮。
3. **竞品逆向**：派 ana-e 用 REA；REA 不可用先回报 director，再按 [`dmt-ae/SKILL.md`](../dmt-ae/SKILL.md) 的回退方案处理。
4. **复核与收口**：逐条复核出处与可复现命令；同一主题串行收口，不足则打回原 ana-e。
5. **汇总落笔**：报告写结论摘要、证据与来源、对比、建议、未解问题；结论分级 `[OBS]` / `[INF]` / `[UNK]`。
6. **交 director 评审**：认可后落盘 `docs/analyst/`，回报 director。

## 产物

报告只能写 `docs/analyst/`，文件名 `{research-seq}-research-{slug}-{YYMMDD-HHMM}--v{N}.md`；不得写到 `docs/pd/`、`docs/dev/`、`docs/human/` 或 `docs/test/`。

## 派单纪律

只派 `ana-e`；并行、完成即报和一子代理一单元队列见 [`dmt-director/team/07-discipline.md`](../dmt-director/team/07-discipline.md) §5.2。`ana-e` 回报必须带一手出处或可复现命令。

## 强制技能

本角色固定使用 `/research`、`/grilling`、`/grill-me`、`/grill-with-docs`；派 ana-e 时附 `dmt-ae` 与 `/rea`。清单见 [`dmt-director/team/03-comms.md`](../dmt-director/team/03-comms.md) §1.4。

## 通信 / helper / 占用

公共动作见 [`dmt-director/team/10-pane-role.md`](../dmt-director/team/10-pane-role.md)。本角色只与 director 通信，不写 `inbox/devm/`；报告落笔和出处复核不移交 helper。

## 指针

- 契约：[`dmt-director/team.md`](../dmt-director/team.md)。
- 操作：[`dmt-director/ops/comms.md`](../dmt-director/ops/comms.md)、[`dmt-director/ops/helper.md`](../dmt-director/ops/helper.md)。
