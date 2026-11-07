# dmt

可独立使用、也可组合成团队的多角色软件开发技能库。角色覆盖需求、产品文档、调研、开发协调、实现与独立评审。

核心原则是明确验收、按依赖协作、共享工作区单写者、实现与评审分离、证据闭环和按需加载。完整说明见 [`dmt-director/team.md`](dmt-director/team.md)。

## 角色

- `dmt-director`：需求入口、任务协调与跨域裁决。
- `dmt-dm`：工单拆分、开发安排与授权整合。
- `dmt-devl`：实施协调、独立评审与交付汇总。
- `dmt-de`：指定工作区内的实现、测试与提交。
- `dmt-am` / `dmt-ae`：调研拆分、取证与报告。
- `dmt-pde`：需求取证与 PRD/SPEC 起草。
- `dmt-reviewer`：独立逐项验收。

角色数量和组合由任务决定，不要求固定组织、pane、目录或第三方工具。

## 安装

```bash
bash dmt-director/scripts/install-skills.sh <项目根>
bash dmt-director/scripts/install-skills.sh <项目根> --copy
bash dmt-director/scripts/install-skills.sh <项目根> --harness claude,codebuddy
```

默认使用软链，`--copy` 创建独立副本；`--harness` 只安装指定平台需要的落点。安装器只分发运行所需文件，维护日志和变更历史不进入核心安装。

显式建立可选 DMT 目录与收件箱：

```bash
bash dmt-director/scripts/init-project.sh <项目根>
```

初始化不是技能加载步骤。平台差异、herdr、收件箱和 helper 只在实际使用时读取 `dmt-director/harness/` 或 `dmt-director/OPS.md`。

## 检查

```bash
bash dmt-director/scripts/check-dmt.sh <项目根>
bash dmt-director/scripts/check-dmt.sh --verbose <项目根>
DMT_SKILLS_DIR="$PWD" bash dmt-director/scripts/check-dmt.sh "$PWD"  # 维护本仓
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
- CHANGELOG 与 logs 仅用于维护，不属于运行时阅读清单。

## 许可证

[MIT](LICENSE) © 2026 aragornpangit
