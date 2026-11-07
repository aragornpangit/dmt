### 1.2 运行环境与 pane 生命周期

**操作细节见 [`ops/runtime.md`](../ops/runtime.md)** —— pane/tab、启动、权限、`devl` pane 生命周期。

**harness 机器事实**（发现目录 / 启动命令 / 调用前缀 / 并发）只在 [`harness_matrix.yaml`](../harness_matrix.yaml)；加载规则见 [`harness/README.md`](../harness/README.md)（共性 + 每 harness 差异）。要点：Codex 插件技能用 `mattpocock-skills:<name>`，技能随首轮 prompt 下发；门铃按 pane label 解析；pi 启动带 `--approve`。

**约束**：

1. 技能调用统一经 `lib-dmt.sh: dmt_skill_cmd`（opencode `@<name>`，如 `@dmt-dm`；pi `/skill:<name>`；其余 `/<name>`）。
2. 启动后必须用 `dmt_pane_auto_mode` 读 argv 复验自动档；非自动档用 `setup-team.sh --force-start` 重开。
3. pane 角色四类（`director` / `devm` / `anam` / `devl{n}`）；子代理技能由派生者按 `subagent_skill` 指定。`dmt-devl` 不设 helper。

八份角色 `SKILL.md` 的「## 0. 按 harness 加载」是唯一入口：先 `harness-detect.sh` 判定，再读共性 + 差异。
