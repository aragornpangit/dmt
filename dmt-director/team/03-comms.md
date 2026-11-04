### 1.3 通信方式（收件箱文件 + herdr 门铃）

**操作细节见 [`dmt-director/OPS.md`](dmt-director/OPS.md) §2** —— 方向码表、收件箱路径与 `{seq}`、门铃通道（`agent prompt` 优先 / `send-text` 回退）、三态（`.doing/` / `.seq`）。

### 1.4 依赖的 harness 技能（mattpocock，强制使用）

> **单一来源纪律（2026-11-04 第七十七次，硬规则）**：**团队口径只有一个权威 = 本文件**（`team.md`）；`OPS.md` 是操作层。
> 七份技能 `SKILL.md` **只写该角色特有的动作**（怎么干），**不得复述**本文件的团队定义（组织 / 层级 / 权限 / 门禁 / 写操作归属 / 并行口径 / 命名）。技能里凡引用共性口径，**一律写成指针**（「见 `dmt-director/team.md` §X」），把契约变动收敛到一处。
> 判据：改一条团队口径（如并行口径）时，**只应改本文件 + 该角色动手处的指针**，不应再出现「7 份技能都要跟着改同一句」。

**强制口径**：下表技能**不是可选建议** —— 每个角色在其职责动作中**必须**调用；**不得**以「手写更快」「技能没装」为由静默跳过。技能不可用 ⇒ 先装（见本节末尾）；仍不可用 ⇒ 在产物与回报里标注 `[SKILL_UNAVAILABLE]` 并回报 director 裁决。**调用要留痕**（用了哪个、产出在哪）。

| 角色 | 强制技能 | 用在哪 |
|---|---|---|
| `director` | `/grilling`、`/grill-me`、`/grill-with-docs`、`/code-review`、`/to-spec`、`/to-tickets` | 需求问穿、方案自审、契约/文档交叉拷问、抽查、SPEC 与工单落笔 |
| `devm` | `/code-review`、`/diagnosing-bugs` | 评审整合前自审；缺陷分诊与回归定位 |
| `anam` | `/research`、`/grilling`、`/grill-me`、`/grill-with-docs` | 一手取证与证据分级、调研方案自审、证据交叉拷问 |
| `pde{n}` | `/grilling`、`/research`、`/to-spec`、`/to-tickets` | 口径核对、事实取证、SPEC/工单拆解与核对（与 director 同一套） |
| `reviewer{n}` | `/code-review` | 逐条核验收标准、判据、diff、证据与测试输出（**写进派发 prompt**） |
| `dev-e` | `/tdd`、`/implement`、`/code-review`、`/diagnosing-bugs` | TDD 实施、按 SPEC 落地、提交前自审、缺陷分诊 |
| `ana-e` | `/research`、`/rea`、`/grilling`、`/grill-me`、`/grill-with-docs` | 取证、竞品逆向（`/rea`，REA 专用）、交叉拷问 |

**子代理角色技能（四个，2026-11-04 第六十七次新增 / 统一命名）**：`pde{n}` / `dev-e` / `ana-e` / `reviewer{n}` 各自一份技能 —— `dmt-pde` / `dmt-de` / `dmt-ae` / `dmt-reviewer`（**技能名与运行 id 一一对应**；**派发者**：`pde{n}` 由 `director`、`dev-e` / `reviewer{n}` 由 `devm`、`ana-e` 由 `anam`）。派生者把**对应技能名**写进派发 prompt：cbc 下 teammate 继承技能清单、可直接斜杠调用（如 `/dmt-de`）；**pi 下 `delegate` 子代理不注入技能清单、也没有 Skill 工具**，必须写成「`read <技能目录>/dmt-<角色>/SKILL.md` 并按其中「强制技能」节执行」。**实测（2026-11-04）**：cbc teammate 能列出 `dmt-pde` 等技能；pi `delegate` 子代理的 system prompt **无 skills 段**、工具集**无 Skill 工具**（只能 `read` 文件）—— 故「技能名写进 prompt」在 pi 下必须配「读文件路径」，否则不可执行。

**技能源文件**（技能名与 [`mattpocock/skills`](https://github.com/mattpocock/skills) 上游目录名**逐字一致**；`/rea` 属 REA、不在该仓，保持原名不加链接）：
[`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)、[`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md)、[`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md)、[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)、[`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)、
[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)、[`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md)、[`/tdd`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md)、[`/implement`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/implement/SKILL.md)、[`/diagnosing-bugs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/diagnosing-bugs/SKILL.md)、[`/improve-codebase-architecture`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/improve-codebase-architecture/SKILL.md)（**可选、非强制**，`dmt-dm` 指针里提及）

**通用技能（pane 常驻角色）**：`cbc-herdr`（CodeBuddy 在 herdr 的状态上报，让 `herdr pane list` 的 `agent_status` 可信）—— `dmt-director` / `dmt-dm` / `dmt-am` 三份技能都必须登记；`dmt-pde`（子代理技能）不登记；子代理不占 pane，不需要。

**安装**：`npx skills@latest add mattpocock/skills -a <agent>`（pi / opencode / codebuddy / amp / cursor / devin / windsurf）；失败时克隆 `https://github.com/mattpocock/skills.git`，把 `skills/` 下技能目录 copy 到 `~/.agents/skills/` 再软链到 harness 技能目录。

**harness 差异（2026-11-04 探针实测，更正第六十二次的「交集」结论）**：只有 `codex` / `opencode` / `pi` 读 `.agents/skills/`（项目级与用户级同理），**`claude` 与 `codebuddy` 都不读**——它们各自只认私有目录（`.claude/skills/` / `.codebuddy/skills/`）；`opencode` 额外兼容 `.claude/skills/`。⇒ **装到哪个 harness 就必须软链到那个 harness 认的目录**，不存在「只装一处、五者共用」的落点（原「`~/.agents/skills/` 是五者唯一交集」的说法经实测作废）。详见 §1.2「harness 兼容」。

**已知缺口（2026-10 核查）**：上游无 `to-prd`，`implement-spec` 仍在 `in-progress/` 未发布 ⇒ PRD 由 `pde{n}` 按 §4.1 模板落笔、director 定稿；若上游提供 `to-prd`，优先改用。

### 1.5 文件占用（编辑前必须检查）

**操作细节见 [`dmt-director/OPS.md`](dmt-director/OPS.md) §3** —— `file-claim.sh` 的 check / claim / release、`rc=3` 处置、TTL 30 分钟、worktree 不豁免。
