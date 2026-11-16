# dmt

可独立使用、也可组合成团队的多角色软件开发技能库。角色覆盖需求、产品文档、调研、开发协调、实现与独立评审。

通用协作原则见 [`dmt-dir/team.md`](dmt-dir/team.md)；可选完整团队拓扑见 [`dmt-dir/team/01-org.md`](dmt-dir/team/01-org.md)。

## 角色

- `dmt-dir`：需求入口、PRD 起草、任务协调与跨域裁决。
- `dmt-dm`：评估输入、工单拆分、开发安排与授权整合。
- `dmt-de`：指定 worktree 功能分支内的实现、测试与 commit（不 merge / push）。
- `dmt-reviewer`：以 ticket 为单位的独立评审（子代理，不参与被审实现）；静态门为 `dmt-dir/scripts/review-gate.sh`，规范基线在 `dmt-reviewer/references/`（Python / Java / JavaScript / TypeScript / C++，离线可读）。
- `dmt-am`：拆调研、并行派多个 AE、复核证据，并把含 Proposal 的报告写入 `docs/analyst/`。
- `dmt-ae`：单个取证单元的一手来源、可复现结论和证据产物。
- `dmt-pde`：根据已批准 PRD 与调研报告使用 `to-spec` 起草 SPEC。

角色数量和组合由任务决定，不要求固定组织、pane、目录或第三方工具。默认产品线是 DIR 按需派 AM 调研 → AM 汇总含 Proposal 的 `docs/analyst/` 报告 → DIR 写 PRD → PDE 写 SPEC → DIR 批准；默认开发线是 `dmt-dm` 收到已批准 SPEC 后用 `to-tickets` 拆 ticket 并创建 worktree → `dmt-de` 按 tdd/implement/code-review 实现和 commit → 独立 `dmt-reviewer` 审核 commit/diff → `dmt-dm` merge、push 并标记 ticket 完成。启用多 pane 适配器时按 [`dmt-dir/ops/runtime.md`](dmt-dir/ops/runtime.md) 部署，可按需裁剪。

## 脚本分层

- 主流程保留：`install-skills.sh`、`check-dmt.sh`、`harness-matrix.sh`、`review-gate.sh`、`worktree.sh`、`init-project.sh`、`publish.sh`。
- 精简保留：`harness-detect.sh`、`runtime-detect.sh`、`install-third-party-skills.sh`、`fetch-style-baselines.sh`。
- 可选运行适配器：收件箱、helper、herdr/Orca 启动与回收、CodeBuddy 复核健康门、特定二进制兼容补丁；不作为角色开工前置，详见 [`dmt-dir/OPS.md`](dmt-dir/OPS.md)。

## 安装

```bash
bash dmt-dir/scripts/install-skills.sh <项目根>
bash dmt-dir/scripts/install-skills.sh <项目根> --copy
bash dmt-dir/scripts/install-skills.sh <项目根> --harness claude,codebuddy
```

默认使用软链，`--copy` 创建独立副本；`--harness` 只安装指定平台需要的落点。安装器负责技能落点与结构检查，不创建产品目录；维护日志和变更历史不进入核心安装。

显式安装项目技能并建立核心产物目录与可选收件箱：

```bash
bash dmt-dir/scripts/init-project.sh <项目根>
```

初始化不是技能加载步骤；它会安装项目技能、创建核心产物目录，并建立可接收件箱。角色加载后先按 `dmt-dir/team/02-runtime.md` 探测当前 harness 与其运行平台（herdr、Orca；都不是 harness）；默认使用 harness 原生 subagent，差异文档、收件箱、helper 和 herdr/Orca 适配器只在实际使用时读取 `dmt-dir/harness/` 或 `dmt-dir/OPS.md`。

## 检查

```bash
bash dmt-dir/scripts/check-dmt.sh <项目根>
bash dmt-dir/scripts/check-dmt.sh --verbose <项目根>
DMT_SKILLS_DIR="$PWD" bash dmt-dir/scripts/check-dmt.sh "$PWD"  # 维护本仓
```

默认只输出失败和摘要。结构事实由 `dmt_contract.yaml` 与 `harness_matrix.yaml` 驱动；不使用固定中文句子替代行为验证。

## 可选运行配置

`.env.example` 提供本地适配器配置示例，`.env` 不提交。`publish.sh` 默认只推 `origin`，可用 `--remotes` 或 `DMT_PUSH_REMOTES` 显式选择其他 remote；发布频率和授权遵循项目策略。

Codex 默认保持受限沙箱。任何危险权限都需要用户显式选择，不能作为团队通信的默认前提。

## 维护

- 角色正文只写职责与完成条件；共享原则以 `team.md` 为唯一来源。
- 平台机器事实只改 `harness_matrix.yaml`；操作适配器只在对应任务中加载。
- 修改公开技能、脚本接口、契约、矩阵或链接后运行结构检查和相关测试。
- 回归测试：`python3 -m unittest discover -s tests -v`。
- 刷新评审规范基线：`bash scripts/fetch-style-baselines.sh`（五语言原文，带来源/日期/许可证），`--check` 只校验。
- CHANGELOG 仅用于维护，不属于运行时阅读清单。

## 许可证

[MIT](LICENSE) © 2026 aragornpangit
