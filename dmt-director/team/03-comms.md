### 1.3 通信方式（收件箱文件 + herdr 门铃）

**操作细节见 [`dmt-director/ops/comms.md`](../ops/comms.md)** —— 方向码、路径、门铃和三态。

### 1.4 依赖的 harness 技能（mattpocock，强制使用）

> **单一来源纪律**：团队常量只在 `team.md`；`OPS.md` 是操作路由。
> 八份技能 `SKILL.md` **只写该角色特有的动作**（怎么干），**不得复述**本文件的团队定义（组织 / 层级 / 权限 / 门禁 / 写操作归属 / 并行口径 / 命名）。技能里凡引用共性口径，**一律写成指针**（「见 `dmt-director/team.md` §X」），把契约变动收敛到一处。
> 判据：改一条团队口径（如并行口径）时，**只应改本文件 + 该角色动手处的指针**，不应再出现「8 份技能都要跟着改同一句」。

**强制口径**：下表技能**不是可选建议** —— 每个角色在其职责动作中**必须**调用；**不得**以「手写更快」「技能没装」为由静默跳过。技能不可用 ⇒ 先装（见本节末尾）；仍不可用 ⇒ 在产物与回报里标注 `[SKILL_UNAVAILABLE]` 并回报 director 裁决。**调用要留痕**（用了哪个、产出在哪）。

| 角色 | 强制技能 | 用在哪 |
|---|---|---|
| `director` | `/grilling`、`/grill-me`、`/grill-with-docs`、`/code-review`、`/to-spec` | 需求问穿、方案自审、契约/文档交叉拷问、抽查、SPEC 定稿 |
| `devm` | `/to-tickets`、`/diagnosing-bugs` | 工单落笔、缺陷分诊与回归定位；**不做代码评审** |
| `devl{n}` | `/code-review`、`/grilling` | 票面歧义拷问、派 reviewer 前自检、汇总证据 |
| `anam` | `/research`、`/grilling`、`/grill-me`、`/grill-with-docs` | 一手取证与证据分级、调研方案自审、证据交叉拷问 |
| `pde{n}` | `/grilling`、`/research`、`/to-spec` | 口径核对、事实取证、SPEC 落笔与核对（`to-tickets` 已移交 devm） |
| `reviewer{n}` | `/code-review` | 逐条核验收标准、判据、diff、证据与测试输出（**写进派发 prompt**） |
| `dev-e` | `/tdd`、`/implement`、`/code-review`、`/diagnosing-bugs` | TDD 实施、按 SPEC 落地、提交前自审、缺陷分诊 |
| `ana-e` | `/research`、`/rea`、`/grilling`、`/grill-me`、`/grill-with-docs` | 取证、竞品逆向（`/rea`，REA 专用）、交叉拷问 |

**子代理技能**：`pde{n}` → `dmt-pde`，`dev-e` → `dmt-de`，`ana-e` → `dmt-ae`，`reviewer{n}` → `dmt-reviewer`；队长技能 `devl{n}` → `dmt-devl`。派发者在 prompt 写技能名：cbc 斜杠调用、**opencode 用 `@<技能名>`**、codex / pi 给 `SKILL.md` 路径；**各 harness 的“调用行 / 要不要给技能文件路径 / 插件前缀”差异按 harness 加载** —— 见 [`../harness/README.md`](../harness/README.md)（共性 [`../harness/COMMON.md`](../harness/COMMON.md) ＋ `pi.md` / `codebuddy.md` / `claude.md` / `codex.md` / `opencode.md`；派发模板见 [`07b-dispatch.md`](07b-dispatch.md)）。

**技能源文件**（技能名与 [`mattpocock/skills`](https://github.com/mattpocock/skills) 上游目录名**逐字一致**；`/rea` 属 REA、不在该仓，保持原名不加链接）：
[`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)、[`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md)、[`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md)、[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)、[`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)、
[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)、[`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md)、[`/tdd`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md)、[`/implement`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/implement/SKILL.md)、[`/diagnosing-bugs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/diagnosing-bugs/SKILL.md)、[`/improve-codebase-architecture`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/improve-codebase-architecture/SKILL.md)（**可选、非强制**，`dmt-dm` 指针里提及）

**通用技能（仅 CodeBuddy pane）**：`cbc-herdr` 仅用于 CodeBuddy 在 herdr 的状态上报；Codex 使用 herdr 原生状态识别，不加载它。`dmt-director` / `dmt-dm` / `dmt-am` / `dmt-devl` 的 cbc 必须登记；其它 harness 与子代理不登记。

**安装**：`npx skills@latest add mattpocock/skills -a <agent>`（pi / opencode / codebuddy / amp / cursor / devin / windsurf）；Codex 用 `codex plugin marketplace add mattpocock/skills`，随后 `codex plugin add mattpocock-skills@mattpocock`。失败时克隆 `https://github.com/mattpocock/skills.git`，把技能目录 copy 到 `~/.agents/skills/` 再软链到 harness 技能目录；Codex 插件与兼容副本二选一，避免同名技能重复登记。

**harness 差异**：`.agents/skills/` 只被 codex / opencode / pi 读取；claude / codebuddy 各用私有目录。目录 / 前缀 / 启动等机器事实见 §1.2 与 [`../../dmt-director/harness_matrix.yaml`](../../dmt-director/harness_matrix.yaml)；技能怎么加载见 [`../harness/`](../harness/README.md)。

**已知缺口**：

- 上游暂无 `to-prd` ⇒ PRD 按 §4.1 模板由 pde 落笔。
- **转发式技能在 pi 上必须降级**：`grill-with-docs` / `grill-me` / `implement` / `tdd` 正文含 `Call the Skill tool with "<其它技能>"`，而 pi **无 Skill 工具** ⇒ 须改为 `read <镜像根>/<其它技能>/SKILL.md`（不降级会静默失效；边缘与实测见 [`../harness/pi.md`](../harness/pi.md) §5.1）。

### 1.5 文件占用（编辑前必须检查）

**操作细节见 [`dmt-director/ops/file-claim.md`](../ops/file-claim.md)**。
