# dmt

可独立使用、也可组合成团队的多角色软件开发技能库。角色覆盖需求、产品文档、调研、开发协调、实现与独立评审。

通用协作原则见 [`dmt-dir/team.md`](dmt-dir/team.md)；可选完整团队拓扑见 [`dmt-dir/team/01-org.md`](dmt-dir/team/01-org.md)。

## 角色

- `dmt-dir`：需求入口、任务协调与跨域裁决。
- `dmt-dm`：评估输入、工单拆分、开发安排与授权整合。
- `dmt-de`：指定 worktree 功能分支内的实现、测试与 commit（不 merge / push）。
- `dmt-reviewer`：以 ticket 为单位的独立评审（子代理，不参与被审实现）。
- `dmt-am`：调研拆分、取证复核与报告汇总。
- `dmt-ae`：单个取证单元的一手来源与可复现结论。
- `dmt-pde`：需求取证与 PRD/SPEC 起草。

角色数量和组合由任务决定，不要求固定组织、pane、目录或第三方工具；**默认开发线为两级**：`dmt-dm` 收到 SPEC / 需求 / bug 后评估并用 `to-tickets` 拆成 ticket → 逐一派 `dmt-de`（tdd / implement / code-review）→ 完工后另派加载 `dmt-reviewer` 技能的子代理按 ticket 独立评审 → 通过后 `dmt-dm` merge / push；票批需要独立上下文隔离时由 `dmt-dm` 按需派生临时协调子代理、完成即回收。启用完整团队适配器时按 [`dmt-dir/ops/runtime.md`](dmt-dir/ops/runtime.md) 的默认布局部署，可按需裁剪。开发线的 Git 权限分层见 [`dmt-dir/team/07-discipline.md`](dmt-dir/team/07-discipline.md)。

## 安装

```bash
bash dmt-dir/scripts/install-skills.sh <项目根>
bash dmt-dir/scripts/install-skills.sh <项目根> --copy
bash dmt-dir/scripts/install-skills.sh <项目根> --harness claude,codebuddy
```

默认使用软链，`--copy` 创建独立副本；`--harness` 只安装指定平台需要的落点。安装器只分发运行所需文件，维护日志和变更历史不进入核心安装。

显式建立可选 DMT 目录与收件箱：

```bash
bash dmt-dir/scripts/init-project.sh <项目根>
```

初始化不是技能加载步骤。角色加载后先按 `dmt-dir/team/02-runtime.md` 探测当前 harness 与其运行平台（herdr、Orca、T3 Code；都不是 harness）；差异文档、适配器、收件箱和 helper 只在实际使用时读取 `dmt-dir/harness/` 或 `dmt-dir/OPS.md`。

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
- CHANGELOG 仅用于维护，不属于运行时阅读清单。

## 许可证

[MIT](LICENSE) © 2026 aragornpangit
