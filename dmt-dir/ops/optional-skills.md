# 可选：第三方技能与 MCP 点名表

项目启用本适配器后才读取；通用工具口径见 [`../team/03-comms.md`](../team/03-comms.md)。本表约束**派发者**，不改写角色 `SKILL.md`：派发对应角色时，必须在 prompt 中按名写出下表技能/MCP。B 增强版另行把「必用技能 + 降级」写进每个角色 `SKILL.md` 并由 A6f 机检复核，两处不冲突：本表管派发点名，SKILL.md 管角色自带要求。

| 角色技能 | 派发者必须点名 / 角色必用 | 用途 |
|---|---|---|
| `dmt-dir` | `grill-me`、`grill-with-docs` | 需求问穿、方案与文档交叉拷问 |
| `dmt-pde` | `to-spec` | SPEC 落笔 |
| `dmt-dm` | `to-tickets` | 评估输入并拆成多张 ticket |
| `dmt-de` | `tdd`、`implement`、`code-review` | TDD 实施、按 SPEC 落地、提交前自审 |
| `dmt-reviewer` | `code-review` | 按 ticket 为单位的独立评审 |
| `dmt-ae` | `research`、`rea`（REA MCP） | 一手取证、竞品逆向 |
| `dmt-am` | 无点名项 | 汇总调研；派发 `dmt-ae` 时透传 `research` / `rea` |

角色→技能的机器可读映射在契约 `third_party_skills.role_skills`（A6f 正向机检从此读，不写死在脚本里）。技能名与上游 mattpocock/skills 目录名一致；`rea` 是 REA MCP，不在该仓；上游无 `to-prd`，PRD 按项目模板落笔。

## 派发写法（B 增强版）

- [`../team/07b-dispatch.md`](../team/07b-dispatch.md) 的「角色与技能」行按上表逐项写出，与单元、边界、产物、判据并列。
- 每个角色 `SKILL.md` 边界段自带：必用技能名、按 harness 的调用方式、`[SKILL_UNAVAILABLE]` 降级，三者由 `check-dmt.sh` A6f 逐角色硬校验。
- 调用前缀由 [`../harness_matrix.yaml`](../harness_matrix.yaml) 决定，加载规则见 [`../harness/README.md`](../harness/README.md)；子代理加载方式见 [`../team/07b-dispatch.md`](../team/07b-dispatch.md)「平台适配」。
- 未安装或不可用时标 `[SKILL_UNAVAILABLE]` 并回报派发者，改用直读该技能 `SKILL.md` 绝对路径等可验证替代方法，不静默跳过。

## 产物适配（优先级 1 · A 方案）

`to-spec` / `to-tickets` / `grill-with-docs` 上游默认把产物发布到外部 issue tracker、写 `.scratch/`、套用 ADR/triage 约定，与 dmt 的目录/命名约定冲突。约束（契约 `third_party_skills.artifact_adaptation`）：

> 产物按 [`../team/04-naming.md`](../team/04-naming.md) 与 [`../team/05-dirs.md`](../team/05-dirs.md) 落盘（`docs/pd/spec/`、`docs/dev/tickets/`、`docs/handoff/`），不发布到外部 issue tracker、不写 `.scratch/`、不套用上游 ADR/triage 约定；技能正文与 dmt 约定冲突时以 dmt 约定为准。

采用「点名表 + 角色 SKILL.md 约束行」而非「dmt wrapper 副本」：第三方技能正文只有一处（上游/解锁副本），不引入双源、不随安装分发进目标项目、跨机器一致。代价是技能正文里仍有冲突指令，靠 prompt 中的 dmt 约束压过 —— 这也是 B 增强版把约束写进角色自带要求的原因。

## 条件加载层（优先级 3 · 不进硬保证）

以下技能**不写进** `role_skills`、不受 A6f 硬机检约束；只在可用时按 [`../team/07b-dispatch.md`](../team/07b-dispatch.md) 点名，否则标 `[SKILL_UNAVAILABLE]` 并回退到 dmt 自带约定（`07-discipline.md` / `05-dirs.md`）。契约登记在 `third_party_skills.conditional_skills`。

- **superpowers（三层结合）**：本机仅 claudecode 官方 plugin `superpowers@claude-plugins-official` v7.0.0 提供，技能在版本化 plugin cache 路径，**未铺到 5 个 harness 的技能发现目录**；ECC / pstack 整套不引入。结合方式按三层，契约登记在 `third_party_skills.conditional_skills`：
  - **层 1 纪律同构（首要）**：`verification-before-completion`（Evidence before claims）、`systematic-debugging`（先找根因）、`using-git-worktrees`（先探测已有隔离）、`dispatching-parallel-agents`（独立上下文、精确构造、不继承会话）已作为判据并入 [`../team/07-discipline.md`](../team/07-discipline.md)，dmt 自带、可机检、跨 5 harness 一致，不依赖 plugin。
  - **层 2 条件加载（按角色）**：仅 claudecode 可用时点名 —— `dmt-dir`→`brainstorming`（与 `grill-me` 二选一，不并列）、`dmt-dm`→`using-git-worktrees` / `dispatching-parallel-agents`、`dmt-de`→`systematic-debugging` / `test-driven-development`、`dmt-reviewer`→`verification-before-completion` / `requesting-code-review`；其余 harness 标 `[SKILL_UNAVAILABLE]` 回退层 1。
  - **层 3 禁入与排除**：`using-superpowers`（自动路由，与「按需加载」冲突）、`executing-plans` / `subagent-driven-development`（自带子代理拓扑，绕过两级开发线）、`finishing-a-development-branch`（含 merge/push，给 de 会越权）一律不点名；superpowers 不进 `role_skills` / A6f 硬机检（只有 1/5 harness 可用，写进硬保证即成假保证）。
- **handoff**（交接）：explicit-only 且 `skills-unlocked` 无解锁副本。标准交接产物按 `05-dirs.md` 的 `docs/handoff/` 落盘；要加载 mattpocock `handoff` 技能需先生成解锁副本，否则标 `[SKILL_UNAVAILABLE]`。
- **herdr / orca**：是 harness 运行平台（pane-runtime / ADE），其 CLI 控制说明与内置 guides 不是可点名的 SKILL.md，走 [`../team/02-runtime.md`](../team/02-runtime.md) 适配器路径，不进点名表。

## 落点与前缀

- 9 个技能的清单与 explicit-only 标记在 [`../dmt_contract.yaml`](../dmt_contract.yaml) 的 `third_party_skills:`；用户级落点由 `harness_matrix.yaml` 的 `skills.dir_user`（opencode 另含 `dir_project_extra`）推导。`grilling` 是 `grill-me` / `grill-with-docs` 的转发目标（两者正文会二次调用它），必须与两者一起铺齐，否则转发链断。
- 9 个技能的上游来源登记在同段 `third_party_skills.source_url`，值为 `.env` 变量占位符 `${DMT_MATTPOCOCK_SOURCE_URL}`（内网地址不入库，实际值由本机 `.env` 提供）；派发 `dmt-dir` / `dmt-dm` / `dmt-am` 时用 `dmt_load_env` 展开后按 [`../team/07b-dispatch.md`](../team/07b-dispatch.md) 随 prompt 附带，仅作来源说明，不作为加载或 fetch 地址。
- 维护仓的 `scripts/install-third-party-skills.sh` 幂等铺设扁平软链并可用 `--check` 复验；各 harness 的调用语法（`/`、`mattpocock-skills:`、`@`、`/skill:`）以矩阵为准。
- 5 个 explicit-only 技能（`grill-me`、`grill-with-docs`、`to-spec`、`implement`、`to-tickets`）必须指向已剥离 `allow_implicit_invocation: false` 的解锁副本，否则 codex 列得出却不加载、pi 白名单会过滤。
- 本适配器是可选件：机检对落点缺失只 WARN，硬保证由安装脚本 `--check` 承担；角色自带要求由 A6f 硬校验。实际技能能否进上下文仍以各 harness 运行时为准；OpenCode v2 的 `@<skill-id>` 已于 5.19.11 在 v2.2.5 收口（判据与证据见维护仓 `dmt-dir/CHANGELOG.md`，`@` 纯引用限制见 [`../harness/opencode.md`](../harness/opencode.md)）。

## 已知限制（实证）

- `to-spec` / `to-tickets` / `implement` 带 `disable-model-invocation: true`，按 `skills:` 白名单注入的子代理里会被**静默过滤**；pi 上须在 prompt 给出 `SKILL.md` 路径由子代理 `read`，见 [`../harness/pi.md`](../harness/pi.md)「子代理」。
- Codex 0.166 列得出这些技能但选中时不加载；维护仓 `scripts/sync-mattpocock-codex-compat.sh` 生成剥离 `allow_implicit_invocation: false` 的兼容副本（仓级脚本，不随安装分发）。
- 转发式技能（`grill-with-docs` / `grill-me` / `implement` / `tdd`）依赖 Skill 工具二次调用；无 Skill 工具的平台降级为直读子技能文件。
