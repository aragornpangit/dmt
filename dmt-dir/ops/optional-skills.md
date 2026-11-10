# 可选：第三方技能与 MCP 点名表

项目启用本适配器后才读取；通用工具口径见 [`../team/03-comms.md`](../team/03-comms.md)。本表约束**派发者**，不改写角色 `SKILL.md`：派发对应角色时，必须在 prompt 中按名写出下表技能/MCP。

| 角色技能 | 派发者必须点名 | 用途 |
|---|---|---|
| `dmt-dir` | `grill-me`、`grill-with-docs` | 需求问穿、方案与文档交叉拷问 |
| `dmt-pde` | `to-spec` | SPEC 落笔 |
| `dmt-dm` | `to-tickets` | 评估输入并拆成多张 ticket |
| `dmt-de` | `tdd`、`implement`、`code-review` | TDD 实施、按 SPEC 落地、提交前自审 |
| `dmt-reviewer` | `code-review` | 按 ticket 为单位的独立评审 |
| `dmt-ae` | `research`、`rea`（REA MCP） | 一手取证、竞品逆向 |

其余角色不预设点名项。技能名与上游 mattpocock/skills 目录名一致；`rea` 是 REA MCP，不在该仓；上游无 `to-prd`，PRD 按项目模板落笔。

## 派发写法

- [`../team/07b-dispatch.md`](../team/07b-dispatch.md) 的「角色与技能」行按上表逐项写出，与单元、边界、产物、判据并列。
- 调用前缀由 [`../harness_matrix.yaml`](../harness_matrix.yaml) 决定，加载规则见 [`../harness/README.md`](../harness/README.md)。
- 未安装或不可用时标 `[SKILL_UNAVAILABLE]` 并回报派发者，改用可验证的替代方法，不静默跳过。

## 落点与前缀

- 8 个技能的清单与 explicit-only 标记在 [`../dmt_contract.yaml`](../dmt_contract.yaml) 的 `third_party_skills:`；用户级落点由 `harness_matrix.yaml` 的 `skills.dir_user`（opencode 另含 `dir_project_extra`）推导。
- 维护仓的 `scripts/install-third-party-skills.sh` 幂等铺设扁平软链并可用 `--check` 复验；各 harness 的调用语法（`/`、`mattpocock-skills:`、`@`、`/skill:`）以矩阵为准。
- 5 个 explicit-only 技能（`grill-me`、`grill-with-docs`、`to-spec`、`implement`、`to-tickets`）必须指向已剥离 `allow_implicit_invocation: false` 的解锁副本，否则 codex 列得出却不加载、pi 白名单会过滤。
- 本适配器是可选件：机检对落点缺失只 WARN，硬保证由安装脚本 `--check` 承担。实际技能能否进上下文仍以各 harness 运行时为准；OpenCode v2 的 `@<skill-id>` 已于 5.19.11 在 v2.2.5 收口（判据与证据见维护仓 `dmt-dir/CHANGELOG.md`，`@` 纯引用限制见 [`../harness/opencode.md`](../harness/opencode.md)）。

## 已知限制（实证）

- `to-spec` / `to-tickets` / `implement` 带 `disable-model-invocation: true`，按 `skills:` 白名单注入的子代理里会被**静默过滤**；pi 上须在 prompt 给出 `SKILL.md` 路径由子代理 `read`，见 [`../harness/pi.md`](../harness/pi.md)「子代理」。
- Codex 0.166 列得出这些技能但选中时不加载；维护仓 `scripts/sync-mattpocock-codex-compat.sh` 生成剥离 `allow_implicit_invocation: false` 的兼容副本（仓级脚本，不随安装分发）。
- 转发式技能（`grill-with-docs` / `grill-me` / `implement` / `tdd`）依赖 Skill 工具二次调用；无 Skill 工具的平台降级为直读子技能文件。
