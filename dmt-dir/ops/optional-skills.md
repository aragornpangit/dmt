# 可选：第三方技能与 MCP 点名表

项目启用本适配器后才读取；通用工具口径见 [`../team/03-comms.md`](../team/03-comms.md)。本表约束**派发者**，不改写 7 份角色 `SKILL.md`：派发对应角色时，必须在 prompt 中按名写出下表技能/MCP。

| 角色技能 | 派发者必须点名 | 用途 |
|---|---|---|
| `dmt-dir` | `grill-me`、`grill-with-docs` | 需求问穿、方案与文档交叉拷问 |
| `dmt-pde` | `to-spec` | SPEC 落笔 |
| `dmt-de` | `tdd`、`implement`、`code-review` | TDD 实施、按 SPEC 落地、提交前自审 |
| `dmt-dm` | `to-tickets` | 依定稿 SPEC 拆工单并直接向 `dmt-de` 派单 |
| `dmt-ae` | `research`、`rea`（REA MCP） | 一手取证、竞品逆向 |

其余角色不预设点名项。技能名与上游 mattpocock/skills 目录名一致；`rea` 是 REA MCP，不在该仓；上游无 `to-prd`，PRD 按项目模板落笔。

## 派发写法

- [`../team/07b-dispatch.md`](../team/07b-dispatch.md) 的「角色与技能」行按上表逐项写出，与单元、边界、产物、判据并列。
- 调用前缀由 [`../harness_matrix.yaml`](../harness_matrix.yaml) 决定，加载规则见 [`../harness/README.md`](../harness/README.md)。
- 未安装或不可用时标 `[SKILL_UNAVAILABLE]` 并回报派发者，改用可验证的替代方法，不静默跳过。

## 已知限制（实证）

- `to-spec` / `to-tickets` / `implement` 带 `disable-model-invocation: true`，按 `skills:` 白名单注入的子代理里会被**静默过滤**；pi 上须在 prompt 给出 `SKILL.md` 路径由子代理 `read`，见 [`../harness/pi.md`](../harness/pi.md)「子代理」。
- Codex 0.166 列得出这些技能但选中时不加载；维护仓 `scripts/sync-mattpocock-codex-compat.sh` 生成剥离 `allow_implicit_invocation: false` 的兼容副本（仓级脚本，不随安装分发）。
- 转发式技能（`grill-with-docs` / `grill-me` / `implement` / `tdd`）依赖 Skill 工具二次调用；无 Skill 工具的平台降级为直读子技能文件。
