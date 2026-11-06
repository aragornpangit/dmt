# harness 差异：codebuddy（CodeBuddy Code / cbc）

> 共性见 [`COMMON.md`](COMMON.md)；机器可读事实单一来源 [`../harness_matrix.yaml`](../../dmt-director/harness_matrix.yaml)。

## 1. 技能发现目录

| 级别 | 目录 |
|---|---|
| 项目级 | `.codebuddy/skills/` |
| 用户级 | `~/.codebuddy/skills/` |

**不读** `.agents/skills/` ⇒ 装到 cbc 必须软链到 `.codebuddy/skills/`（`install-skills.sh --harness all` 已覆盖三处）。

## 2. 启动与权限

- 代启动：先跑健康门 `auto-review-model.sh --quiet`，再 `CODEBUDDY_AUTO_REVIEW_TIMEOUT_MS=300000 codebuddy --permission-mode auto`。
- 自动档两种，**不要混用**（2026-11-05 实测）：
  - `--permission-mode auto`：每次需审批的工具调用过自动复核器（有 300s 预算与健康门配套，见下）。
  - `-y` / `--dangerously-skip-permissions`：**跳过复核器**，但 `--help` 明示 **HIGH/CRITICAL 风险操作仍会询问**（并非全免）。
  - 判据都读 argv（`dmt_pane_auto_mode` 认 `--permission-mode auto` 与 `--dangerously-skip-permissions`）。
- auto 模式下**每个需审批的工具调用都要过一次复核器** ⇒ 预算与 allow 规则见 [`../ops/permission-notes.md`](../ops/permission-notes.md)。

## 3. 技能调用行

`/<技能名>`，例如 `/dmt-dm`。

## 4. 技能如何到达模型

- teammate **继承技能清单** ⇒ 可直接斜杠调用 `/dmt-de` 等，**无需**读文件路径。
- 子代理：`Agent({ name: "<角色名>" })` —— 角色名直接作 `name`，技能随继承而来（模板见 [`../team/07b-dispatch.md`](../team/07b-dispatch.md)）。

## 5. 强制技能

`/<name>`（如 `/code-review`）。

## 5.1 子代理权限继承（2026-11-06 实测补）

- 矩阵 `start_cmd` 已带 **`--subagent-permission-mode bypassPermissions`**：否则 teammate / 子代理可能回落到 `default` 档，逐条撞审批（表现为「子代理卡住 / 脚本超时」，错因在权限层）。
- 若人工启动会话（不经 `setup-team.sh`），需自行补该参数，或确认用户级 settings 的默认档位已是 auto/bypass。
- 并行数量：`CODEBUDDY_CODE_MAX_CONCURRENT_SUBAGENTS`（矩阵默认 8）。

## 6. 特有约束

- **`cbc-herdr` 必须登记**（`dmt-director` / `dmt-dm` / `dmt-am` 三个 pane）：cbc 不在 herdr 编译期内置支持列表里，靠 `cbc-herdr` 上报 working / idle / blocked，否则 `agent_status` 恒为 `unknown`（就绪判据失效）。
- 前台进程 argv 的 basename 是 **`cbc`**（不是 `codebuddy`）—— 按 argv 判 harness / 判自动档时要认这个别名（`harness-detect.sh` 已内置）。
- 并发上限 `CODEBUDDY_CODE_MAX_CONCURRENT_SUBAGENTS`（矩阵默认 8）。
