# dmt 团队契约

> **版本 5.14.0 · 2026-11-03** —— 与四个技能 `SKILL.md` 的 `version:` 字段同号；抽查时先看这一行确认装载版本，两者不一致即视为装错。
> **作用域（Scope，必读）**：本契约的全部纪律 —— 角色权限、**写操作归属（装机 / `git push` / merge）**、门禁、pane 生命周期、收件箱规范 —— **只作用于 dmt 工作流所管理的「目标项目」**（即用 `init-project.sh <项目根>` 初始化的那个 project root，团队在其中开发被交付的软件）。
> **不适用于技能仓自身的维护**：维护 `dmt` / `dmt-en` / 其他技能仓时，上述归属纪律**不生效** —— 维护者（人或其他 agent）可直接 `git add` / `git commit` / `git push`，**无需 director 授权、也不需 devm 代推**；装机权限同理只约束「目标项目中的设备写操作」。
> 本文件（规范层）与 [`OPS.md`](OPS.md)（操作层）**共同构成 dmt 的团队定义**：组织、成员、通信、文件命名、工作流程、目录职责与纪律；四个技能 `dmt-director` / `dmt-pde` / `dmt-dm` / `dmt-am`（`dmt-director` 运行 id `director`；`dmt-pde` 是 `pde{n}` 产品工程师子代理技能、不占 pane；`dmt-dm` / `dmt-am` 运行 id 为 `devm` / `anam`）只做落地说明，**冲突时以本文件为准**。
> 团队成员运行在终端多智能体复用器 Herdr 中；会话与 pane 随重启变化，本文件不登记 pane id。

## 0. 仓库结构

按角色分文件夹，一个角色一个目录：`dmt-director/`（技能、团队契约 `team.md`、说明与机检脚本）、`dmt-pde/`、`dmt-dm/`、`dmt-am/`。**目录树、安装与维护说明以 [`dmt-director/README.md`](dmt-director/README.md) 为准，此处不重复。**

## 1. 团队定义

### 1.1 组织与成员

**层级**：`director`（总监兼产品部经理）→ 部门经理（`devm` / `anam`）→ 工程师（`dev-e` / `ana-e`；`pde{n}` 直属 `director`）。产品部并入总监 —— `director` 写 PRD / SPEC / 工单时**召唤 `pde{n}` 子代理落笔**（一单元一 pde、按需求开），director 定口径、逐份验收并出文档门禁结论；人类文档由 director 落笔；产品支撑同用 `pde{n}`（`dmt-pde` 技能，**不占 tab 不占 pane**）；不设产品经理 pane、不设队长层。共四个技能。

```
director            总监兼产品部经理（label director，屏幕左侧）
├── pde{n}             产品工程师（子代理，不占 tab 不占 pane，director 自派）
├── devm               开发经理（label devm，pane 在 director 的 tab 内右侧）
│   ├── dev-e          开发工程师（子代理，不占 pane，devm 直接派）
│   └── dev-e ...
└── anam               分析经理（label anam，独立 tab）
    ├── ana-e          分析工程师（子代理，不占 pane，anam 直接派）
    └── ana-e ...
```

| 角色 | 技能名 | 运行 id（pane label） | 直属上级 | 直属下级 | 职责 |
|---|---|---|---|---|---|
| 总监兼产品部经理 | `dmt-director` | `director` | 用户 | `devm`、`anam`（+ 自派 `pde{n}` / `reviewer{n}` 子代理） | 唯一用户入口；接需求与验收口径、**写 PRD / SPEC / 工单时召唤 `pde{n}` 落笔**（一单元一 pde、按需求开；director 定口径、验收定稿）、落笔人类文档并出文档门禁结论、分派、跨部门裁决、创建并维护经理层 pane/tab；**装机**；merge / push 归 devm（director 只抽查，不代推）；不替代 devm 的代码评审 |
| 开发经理 | `dmt-dm` | `devm` | `director` | `dev-e`（直接派，按需求开） | 接单（`pde{n}` 落笔、director 定稿的 ticket）、排期派活、建 worktree 并派 `dev-e` 实施、收 diff 做实施层初检、**代码门禁**：ticket 代码的评审责任人；整合开发部门交付物；**代码库管理**：merge 与 push 由 devm 执行（装机归 director）；**不拆票** |
| 分析经理 | `dmt-am` | `anam` | `director` | `ana-e`（直接派，按需求开） | 接调研诉求；拆子问题、派 `ana-e` 并行取证；复核一手出处、收口调研报告 |

**三层命名（不得混写）**：① **技能名** `dmt-dm` —— 技能注册表、安装目录与 `/dmt-dm` 命令用；② **运行 id** `devm` —— pane label、收件箱目录、方向码与实例号用；③ **称呼** 开发经理 —— 正文、汇报、日志用。例：命令写 `/dmt-dm`，路径写 `inbox/devm/`，正文写「开发经理 回报：…」。

| 技能名 | 运行 id | 称呼 | 实例称呼 |
|---|---|---|---|
| `dmt-director` | `director` | 总监 | — |
| `dmt-pde` | `pde{n}` | 产品工程师 | 产品工程师1、产品工程师2 … |
| — | `reviewer{n}` | 验收评审 | 评审1、评审2 … |
| `dmt-dm` | `devm` | 开发经理 | — |
| `dmt-am` | `anam` | 分析经理 | — |
| — | `dev-e` | 开发工程师 | 按序号，如「工程师3」 |
| — | `ana-e` | 分析工程师 | 按序号，如「工程师3」 |

**单线指挥（硬约束，任何角色不得越级或横向直连）：**

1. `director` **只**直接指挥 `devm`、`anam`，并可自派 `pde{n}` 等子代理；**不得**越级给工程师派活或收活。
2. `devm` **只**直接派生 `dev-e` 子代理、`anam` **只**直接派生 `ana-e` 子代理 —— **经理一律直接派工程师子代理（按需求开，派多少不设上限）**，不再经任何中间层（队长层已取消）。
3. `devm` 与 `anam` 之间**不直连**，跨部门事项经 `director` 转派。
4. 工程师 `dev-e` / `ana-e` / `pde{n}` **只**向派生他的总监或经理汇报，**不装独立技能**（技能写进派发 prompt，见 §1.4）、**不占 pane**、**不走跨 pane 通信**。

**经理自主开工（畅通无阻，用户裁定 2026-10-26）**：`devm` / `anam` **可依用户要求与 tickets 计划直接干活**，不需要 director 派单、不等事前批准 —— **开工时知会 director 一句**（收件箱 + 门铃：干什么、依据哪份要求 / ticket）即算合规。**director 默认放行**：只有觉得不合适时才出面制止（门铃叫停 + 说明理由），否则**畅通无阻**；不得以「director 未回复」「未获批准」为由拖延开工，director 也不设事前审批。

### 1.2 运行环境与 pane 生命周期

**操作细节见 [`dmt-director/OPS.md`](dmt-director/OPS.md) §1** —— pane/tab 形态、身份＝`pane label`、启动顺序、helper 生命周期、首条消息前的权限模式。

### 1.3 通信方式（收件箱文件 + herdr 门铃）

**操作细节见 [`dmt-director/OPS.md`](dmt-director/OPS.md) §2** —— 方向码表、收件箱路径与 `{seq}`、门铃通道（`agent prompt` 优先 / `send-text` 回退）、三态（`.doing/` / `.seq`）。

### 1.4 依赖的 harness 技能（mattpocock，强制使用）

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

**技能源文件**（技能名与 [`mattpocock/skills`](https://github.com/mattpocock/skills) 上游目录名**逐字一致**；`/rea` 属 REA、不在该仓，保持原名不加链接）：
[`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)、[`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md)、[`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md)、[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)、[`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)、
[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)、[`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md)、[`/tdd`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md)、[`/implement`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/implement/SKILL.md)、[`/diagnosing-bugs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/diagnosing-bugs/SKILL.md)

**通用技能（pane 常驻角色）**：`cbc-herdr`（CodeBuddy 在 herdr 的状态上报，让 `herdr pane list` 的 `agent_status` 可信）—— `dmt-director` / `dmt-dm` / `dmt-am` 三份技能都必须登记；`dmt-pde`（子代理技能）不登记；子代理不占 pane，不需要。

**安装**：`npx skills@latest add mattpocock/skills -a <agent>`（pi / opencode / codebuddy / amp / cursor / devin / windsurf）；失败时克隆 `https://github.com/mattpocock/skills.git`，把 `skills/` 下技能目录 copy 到 `~/.agents/skills/` 再软链到 harness 技能目录。

**已知缺口（2026-10 核查）**：上游无 `to-prd`，`implement-spec` 仍在 `in-progress/` 未发布 ⇒ PRD 由 `pde{n}` 按 §4.1 模板落笔、director 定稿；若上游提供 `to-prd`，优先改用。

### 1.5 文件占用（编辑前必须检查）

**操作细节见 [`dmt-director/OPS.md`](dmt-director/OPS.md) §3** —— `file-claim.sh` 的 check / claim / release、`rc=3` 处置、TTL 30 分钟、worktree 不豁免。

## 2. 文件命名规范（权威）

序号按产物类别各自独立、类别内自累计（001 起）：`{prd-seq}`（PRD）、`{research-seq}`（调研报告）、`{human-arch-seq}`（人类架构）、`{human-plan-seq}`（人类计划）、`{spec-seq}`（SPEC 与 ticket 共用）；收件箱消息另用 `{seq}` 消息流水号。`{slug}` 简短语义（英文小写短横线，不超过 5 个词），`{YYMMDD-HHMM}` 年月日与时刻，`v{N}` 同一文件原地升级的版本号。

| 产物 | 目录 | 文件名 |
|---|---|---|
| 调研报告 | `docs/analyst/` | `{research-seq}-research-{slug}-{YYMMDD-HHMM}--v{N}.md` |
| 产品需求文档 PRD | `docs/pd/prd/` | `{prd-seq}-prd-{slug}-{YYMMDD}-v{N}.md` |
| 规格书 SPEC | `docs/pd/spec/` | `{spec-seq}-spec-{slug}-{YYMMDD-HHMM}--v{N}.md` |
| 开发工单 ticket | `docs/dev/tickets/` | `{spec-seq}-ticket-{slug}-{YYMMDD-HHMM}--v{N}.md` |
| 人类架构 | `docs/human/human-arch/` | `{human-arch-seq}-arch-{slug}-{YYMMDD-HHMM}--v{N}.md` |
| 人类计划 | `docs/human/human-plan/` | `{human-plan-seq}-plan-{slug}-{YYMMDD-HHMM}--v{N}.md` |
| 收件箱消息 | `inbox/<收件角色>/` | `{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`（无版本号；认领后进 `.doing/`，办完删除） |

规则：

1. **spec 与 ticket 必须对齐 `spec-seq`**：同一需求的 SPEC 与其 ticket 用同一个 `spec-seq` 前缀。
2. **版本语义**：版本内小步更新**就地改同一文件**；实质修订**另立新版本号文件**（新时间戳、`v{N+1}`），并在旧文件头部就地标注「已被 v N+1 取代」。
3. PRD 按需求方给定的格式只有日期（`YYMMDD`），无时刻；其余产物一律带时刻。
4. 历史笔误留痕：需求原文的 `ver{seq}`、`YYMMDD-v{seq}` 写法**已作废**，一律以本表为准，历史文件不改名。

## 3. 目录职责

**落盘唯一位置（含负责人与对齐要求）**：

| 唯一目录 | 负责人 | 产物 | 对齐要求 |
|---|---|---|---|
| `docs/pd/prd/` | `pde{n}`（落笔）/ director（定稿） | 产品需求文档（PRD） | `{prd-seq}` 独立编号 |
| `docs/pd/spec/` | `pde{n}`（落笔）/ director（定稿） | 产品规格书（SPEC，含验收标准） | 与 ticket 共用 `spec-seq` |
| `docs/dev/tickets/` | `pde{n}`（落笔）/ director（票面编号与定稿）；devm 只在票面末尾追加「实施状态」一节 | 开发工单（ticket） | 与 SPEC 共用 `spec-seq` |
| `docs/analyst/` | anam | 市场调研与竞品逆向报告 | 无 |
| `docs/analyst/evidence/{research-seq}-{slug}/` | anam | 调研一手证据（采样产物／原始日志／manifest） | 与报告同号；须带 `manifest.txt`（文件名＋大小＋sha256＋采样命令） |
| `docs/human/human-arch/` | director | 人类架构文档 | 无 |
| `docs/human/human-plan/` | director | 人类计划文档 | 无 |
| `dmt-director/team.md`（仓内正本、唯一权威；`install-skills.sh` **软链**到 `docs/team.md` 供机检读取） | director | 团队契约（本文件） | 软链跟随正本、恒同版本（`--copy` 模式除外） |
| `docs/handoff/` | director / devm | 交接说明（`{director,devm}-{slug}-{YYMMDD-HHMM}-v{N}.md`，**仅在用户要求时写**） | 无 |
| `inbox/<收件角色>/` | 发送方写、收件方读后删 | 角色间消息（运行时通道，**不入库**，**在项目根目录、不在 `docs/` 下**） | 方向与 `{seq}` 见 `OPS.md` §2 |

1. 上述路径是**唯一允许位置**，不得写到 `docs/pd/`（除 `prd/`、`spec/`）、`docs/dev/`（除 `tickets/`）、`docs/human/`（除 `human-arch/`、`human-plan/`）、`docs/test/` 或其它任何位置；收件箱只在项目根 `inbox/` 下，不进 `docs/`；不得自建新的文档目录。
2. 各部门的产物目录**互不越界**：只读引用可以，移动/改名不可以。
3. **工程师不写 `docs/`**：`dev-e` / `ana-e` 的回报走**子代理返回值**（`OPS.md` §2 的方向码只覆盖 pane 角色，工程师不写收件箱、不发门铃），证据文件由上级并入票面 / 报告；`docs/` 内的产物只由 `pde{n}`（落笔）/ 经理 / 总监写入。
4. **旧体系只保留历史**：`docs/pd/`（除 `prd/`、`spec/`）、`docs/dev/`（除 `tickets/`）、`docs/test/`、`docs/dev/arch/` 均**不再接收新产物**；历史文件不改名、不搬迁（留痕）。**现行落盘口径见上表**（2026-10-21 起的路径变更史见 `CHANGELOG.md` / §8）。
5. **目录初始化由 director 负责**：director 接手一个项目时先检查再补齐（见 §3.1），产物目录不由 anam / devm 自建。
6. 机检口径：§7 的脚本按该节列出的十八项逐条断言；它**不校验单个文件的落盘路径**，新产物靠本表与评审把关。

### 3.1 初始化（director 负责，幂等）

director 接手项目的**第一件事**：检查目录，缺什么建什么。可重复执行，已存在则不动：

```bash
bash dmt-director/scripts/init-project.sh <项目根>   # 省略参数＝当前目录
```

脚本做三件事：建六个产物目录 + 三个收件箱（`inbox/director/`、`inbox/devm/`、`inbox/anam/`）+ `locks/`；把 `inbox/*/`、`locks/` 写进 `.gitignore`（已存在则跳过）；跑机检直到 `ALL_PASS`。

- **完成判据**：机检输出 `ALL_PASS`。缺目录时脚本报 `FAIL 目录缺失`，director 补齐后重跑。
- **只建目录、不建产物**：空目录不预置占位文件，避免被误认为已有交付物。
- **`locks/` 是运行时通道**：文件占用登记（`OPS.md` §3），不入库；缺失时脚本会自建，director 初始化时顺手建好。
- **anam / devm 不自建产物目录**：发现自己的目标目录缺失，回报 director（收件箱目录属运行时通道，可按需 `mkdir -p` 兜底）。
- 契约文件 `dmt-director/team.md` 与技能安装不在本步骤内（安装见 `README.md`）。

## 4. 工作流程

1. **anam 调研**：anam **直接派 `ana-e` 子代理（按需求开）** 拆子问题并行取证；anam 复核一手出处并收口成调研报告，**经 director 评审后落盘** `docs/analyst/`；**任务收口即由 anam 收口，该批 `ana-e` 子代理随收口回收**。
2. **director 召唤 `pde{n}` 出 PRD、SPEC 与工单**：director 与用户谈定边界、范围外与验收口径后，列产品单元清单并**按需求开 `pde1…pde{n}`**（一单元一 pde），由 `pde{n}` **落笔**写 `docs/pd/prd/`、`docs/pd/spec/`、`docs/dev/tickets/`，director 逐份验收定稿：基于调研报告写 PRD 与 SPEC（[`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)，含逐条可测的验收标准），再用 [`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md) 把 SPEC 拆成开发工单，分别写 `docs/pd/prd/`、`docs/pd/spec/`、`docs/dev/tickets/`（文件头 `状态：待评审`），**按文档门禁自评审**（验收标准逐条可测、`spec-seq` 对齐、切片可独立验证、Files 不重叠、依赖无环；用 [`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md) 与 [`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md) 拷问），通过后就地改状态行为 `状态：已通过` 并交 devm 排期。
3. **devm 接单**：devm 读 `docs/dev/tickets/` 的本批票面（`pde{n}` 落笔、director 定稿、已过文档门禁），核 `spec-seq` 对齐与判据齐备后按依赖排期；**devm 不拆票、不改判据**，缺项回报 director 补。devm 负责评审、整合本部门交付物。
4. **devm 直接派工程师（按需求开）**：devm **直接派生 `dev-e` 子代理**（一票一 worktree、按需求开），把票面（路径、票基、Files 边界、验收判据、`timeoutMs`、回报格式）交给工程师实施；devm 自己建 worktree、收 diff 做**实施层初检**、复核一手出处。anam 同理**直接派 `ana-e`**（拆子问题、并行取证，复核一手出处）。
5. **devm 验收整合（实施层）**：核 diff 与初检读数（自己收子代理回报并自做初检）→ 构建与测试 → 不合格打回原实施者；**本步不 merge、不写「实施状态」**（merge 的唯一时点见第 6 条）；**任务收口即报（`OPS.md` §2），该批 `dev-e` 子代理随收口回收**。
6. **（唯一 merge 时点：director 代码验收通过之后）** devm 评审 → director 验收 → devm merge/push：ticket 代码干完后由 devm 按代码门禁评审（逐条对照 SPEC 判据、核 diff 与证据，先不 merge）→ 交 director；director 按票数派 reviewer1…reviewer{n} 子代理（一票一 reviewer，无依赖票并行、按需求开）对照相同 spec-seq 的 SPEC 验收标准与 ticket 判据逐条验收；验收通过 ⇒ 通知 devm（收件箱 + 门铃）执行 merge 与 push（每 ticket 一推）；不通过 ⇒ 打回 devm 返工，不得先 merge/push。装机仍归 director。reviewer{n} 是子代理、不占 pane、不装技能（/code-review 写进派发 prompt），逐条核验收标准、判据、diff、证据与测试输出；director 不代推、不代 merge。
7. **并行（按需）**：对无依赖关系的任务，各角色**可在直属下级之间并行**（director 在 devm/anam 之间，产品单元在多个 `pde{n}` 之间；devm 在多个 `dev-e` 之间；anam 在多个 `ana-e` 之间），优先级：dynamic workflow > 多个 subagents 并行；**并行与否、一次并行几路由各角色按任务规模自定（不强制并行、不强制派满），但不得越级派发**。**director 自己的无依赖工作（评审前证据预检、文档交叉核对、外部事实取证、产品取证）同样可按需用子代理铺开**，结论由本人落笔。

### 4.1 PRD 模板（`pde{n}` 落笔，director 定稿）

`Problem Statement` / `目标用户与场景` / `方案概述` / `用户故事（可验收）` / `验收标准` / `范围外` / `开放问题`。

### 4.2 SPEC 模板（`pde{n}` 落笔，director 定稿）

`Problem Statement` / `Solution` / `User Stories` / `验收标准（逐条可测）` / `实现决策` / `测试接缝` / `Out of Scope` / `变更记录`。
SPEC 必须自包含：每条 User Story 都能转成 ticket 与用例。

### 4.3 工单模板（`pde{n}` 落笔，director 定稿）

`目标` / `输入 SPEC 小节` / `验收判据（逐条可测）` / `Files 范围` / `依赖（票号）` / `timeoutMs` / `状态` / `实施状态（devm 追加）`。
工单由 `pde{n}` 用 [`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md) 按 tracer-bullet 纵向切片、director 定稿；**编号按依赖序、`spec-seq` 与 SPEC 严格对齐**；`Files 范围` 互不重叠，`依赖` 必须无环。

## 5. 纪律

### 5.1 Git

1. **禁止 `git add -A` / `git add .`**，提交一律显式列文件路径（优先 `git commit -m "..." -- <path>`，绕过索引），且 `add` 与 `commit` 之间不插入其它动作（避免索引被并发写者扫入）。
2. **代码库归 devm 管理：merge 与 push 只归 devm**（**作用域＝目标项目**：本条的 push / merge 归属只约束 dmt 工作流所管理的项目仓库；**维护 `dmt` / `dmt-en` 等技能仓自身时不受此限**，见文件头「作用域（Scope）」）：`git push` 与合并主干（merge）**只有 `devm` 能执行**；`director` 保留抽查权（抽查后由 devm 推送）；`anam` / 工程师**一律不得 push、不得 merge 主干**。工程师（`dev-e`）只在各自 worktree 内 `git add` + `git commit`，**不得 push**、**不得 merge 主干**。
3. 提交前先跑 [`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)；提交后 `git diff -- <显式路径>` 复核改动内容（第 15 条强化：`git commit -m … -- <路径>` 不经索引，故不查 `--cached`）。
4. **同一 worktree 单一写者（无豁免）**：一个 worktree 从开工到收工，**只有被派到该票的那一个 agent 可以提交**。任何人要提交自己的文档 / 记录，**不得**在工程师正在施工的 worktree 里做——走主工作树或另开 worktree。**并发提交不会报错，只会把别人的改动扫进自己的提交**，事后靠 `git show --stat` 才能发现，而那时已经进了历史。

   - **How to apply**：提交前先 `git status` 看有没有别人的未提交改动；有则改用 `git commit -- <自己的路径>` 且**不先 `add`**；发现同 worktree 已有他人改动，停下问 devm，不要自行判断「应该没事」。
5. **推送节奏（devm）**：① **至少每完成一个 ticket 推送一次**到 GitLab（`10.223.36.12:808`），推送信息含 `{spec-seq}-ticket-{slug}` 与一句话结果（`publish.sh` 默认推 `gitlab origin` 双远端：GitLab 为主、GitHub 镜像；只推 GitLab 时用 `--remotes gitlab`）；② **至少每小时**巡检一次 `git status --porcelain`，有新建或修改文件就按显式路径提交并推送（不必等 ticket 收口）。巡检与推送结果在下一次回报里一句话说明（推了什么、跳过什么、为什么）。
   - 命令：`bash dmt-director/scripts/publish.sh -m '<message>' -- <显式路径...>`；`--auto` 由 `git status --porcelain` 枚举改动路径（仍是显式路径，不使用 `git add -A`），`--no-push` 只提交。
6. **合并冲突时「取 main」（`checkout --ours`）只在 main 是分支的严格超集时成立。** 判断办法不是看谁改得多，是**逐项比对「两侧各有哪些行是对方没有的」**；只要有一项只有分支有，就必须手工合成。

   - **How to apply**：合并前跑一次两侧差异清单（`git diff --stat main...branch` 逐文件看，或直接 `git merge-tree` 预判）；合成后**与分支版本再 diff 一次**，确认差异只剩「main 独有的行」与「人工合成的那几行」，其余逐字节相同。

### 5.2 并行子代理

1. 派发前先做**依赖分析**：只有无依赖任务适合并行；共享文件、共享构建目标、有顺序验收关系的任务**必须串行**。
2. **经理层路径（硬约束）**：`devm` / `anam` **一律直接派工程师子代理（按需求开，派多少不设上限）** —— `devm` 派 `dev-e`（一票一 worktree）、`anam` 派 `ana-e`，**不开任何中间层 pane**（队长层已取消）。自己干还是派子代理、一次派几个，**由派发者按任务规模与上下文自行判断**；工程师子代理随任务收口回收。
3. **按需并行（`director` / `devm` / `anam` 全体派发角色；2026-11-02 用户裁定：取消 max-subagents 机制，铺满不再强制、不设并发上限）**：无依赖任务**适合并行**（同一回复内并发派出后台子代理），但**不强制并行、不强制派满、不设并发上限、无理由白名单** —— 任务小就自做或只派一个，任务大就多派几个，均合规；唯一的硬约束仍是第 1 条依赖面与第 7 条 worktree 单写者。**随本裁定一并废止**（机制脚本已删除）：开工先落账再派发、每波按上限拆波补派、并发位计数开口、回报第一行交账及其理由白名单；并发度完全交回派发者自判，director 抽查不以此为打回依据。
   - **agent 名承载（pi harness 专用，2026-10-31 第五十六次立规）**：`dev-e` / `ana-e` / `pde{n}` / `reviewer{n}` 是**角色语义名**，**不是 pi-subagents 的 agent 注册名** —— pi harness 里没有（也不应有）叫 `ana-e` 的 agent 定义，workflow `runs.run/all` 的 `agent` 字段**必须填内置承载 agent（`delegate`：无预设行为、继承父模型，技能与角色语义全量写进派发 prompt）**，按角色名直派必报 `Unknown agent: ana-e` 派发失败（实例：2026-10-31 anam 派 u-f1/u-f2/u-f3 三单元，`agent: 'ana-e'` 三发三败，改 `agent: 'delegate'` 重派即成）。技能随 prompt 下发的契约语义（§1.4「不装独立技能」）与 `delegate` 承载方式**配套成立**：prompt 里写「你是 anam 的 ana-e 子代理」定角色，agent 字段只管承载。cbc harness 不受此条约束（teammate `Agent` 带 name 即角色名）。
   - **手段**：cbc 可用 **teammate 方式**（`Agent` 带 `name` 建 team、多成员同批派出）；pi 用 dynamic workflow `runs.all`（`agent` 字段填 `delegate`，见上条）；其它 harness 用多个并行子代理。
4. **产品工作（director 自派 `pde{n}`）**：产品线无 pane、无队长层，无依赖产品单元按需求并发派 `pde{n}`（一单元一 `pde{n}`，派发手段同第 3 条）；`director` 的评审前预检同理。
5. 每份派发 prompt 必须显式写清：输入（产物路径）、边界、期望产物、回报要求、`timeoutMs`（长链路不短于 45 min）；**并带「文件写入纪律」三句**（2026-10-27 第五十三次立规）：① 改 bash 文件用**单引号 heredoc**（`cat <<'EOF' … EOF`）或 Write/Edit 工具；② **不得把脚本正文放进 JS 模板字符串**（bash 的 `${VAR:-默认}` / `${1:?msg}` 与 JS 模板字符串 `${expr}` 逐字符相同，会被当插值求值，报 `Unexpected token ':'` / `Expected a closing '}' …`）；③ **Edit 的 `oldString`（锚点）必须唯一**（不唯一就带足上下文或 `replace_all`，否则报 `Found N matches … replace_all is false`）。**派发 prompt 照骨架填空，不要现编**：
    `你是 <角色> 的子代理。单元：<一句话>。输入：<路径>。边界：<Files>。产物：<路径与格式>。判据：<可测>。回报：<格式>。超时：<timeoutMs>。文件写入纪律：改 bash 文件用单引号 heredoc 或 Write/Edit，禁止把脚本正文放进 JS 模板字符串；Edit 的 oldString 必须唯一。`
    > reviewer{n} 变体（验收专用，`/code-review` 为模板常量，不得替换或省略）：`你是 director 的 reviewer{n} 子代理。必须调用 /code-review 技能逐条验收。票：<ticket 路径>。SPEC：<对应 spec-seq 路径>。输入：<diff、证据、测试输出路径>。判据：照 ticket 验收标准逐条核。回报：逐条通过/不通过 + 结论。超时：<timeoutMs>。`
6. 子代理一律后台/异步派发，**派完立即结束本轮**，由完成通知唤醒再验收；不做轮询。
7. 开发工程师**每人一个 git worktree**，只在 worktree 内编辑与提交；主工作树只读。
8. 所有子代理结果由**派生他的那一级**复核证据后，才能写入权威文档或进入下一步；经理不直接采信工程师的原始回报。
9. **一子代理一单元队列（2026-10-27 事故后立规，复盘见 `logs/2026-10-27-serial-queue-incident.md`）**：
    - **在途子代理只收同一单元的纠正 / 收窄**；**新单元一律另派子代理**（另开 worktree），**不得**用 `SendMessage` 追加成队列。
    - **追加前先做「文件面矩阵」**：逐条写 `单元 | 触达文件 | 与在途单元是否重叠`。重叠才可排队（须列出具体重叠文件路径）；不重叠 ⇒ **立即另派**。
    - **队列消息会过期**：依赖上级裁定的追加，要么写明「以最新裁定为准」，要么等裁定落地再派；否则子代理会按已作废的规格做完一轮。
    - **判据（越界即另派）**：同一子代理收到第二个新单元的指派（界面读数 `N queued ≥ 2`）即违规。
    - **复用 vs 新派的唯一判据**：问「这条要求会不会改变他正在做的事的**验收面**？」不会 ⇒ 复用（缺陷修正 / 收窄）；会 ⇒ 新派（哪怕同票同主题）。

### 5.3 评审门禁

| 门禁 | 提交方 | 评审方 | 通过条件 |
|---|---|---|---|
| 调研报告 | anam | director | director 认可结论与证据来源；**anam 落盘** `docs/analyst/` |
| PRD / SPEC / 工单 | `pde{n}`（落笔，director 召唤） | **director（文档门禁自评）**，用户可抽查 | 验收标准逐条可测、`spec-seq` 对齐、切片可独立验证、Files 不重叠、依赖无环；通过后状态行改 `状态：已通过` |
| 实施初检 | devm（自做，或自派子代理初检后本人复核） | devm | 票面判据逐条有读数、门红已分类、Files 边界未越界 |
| helper 回收 | `director` / `devm` / `anam`（创建者＝本体） | 创建者本人自检 | 成果已入账、worktree 已 `git worktree remove`、本体收件箱该 helper 方向无未收口；关闭后 `herdr pane list` 无 `{角色}-helper` label |
| 人类架构 / 人类计划 | director | **director（文档门禁自评）** + 用户 | 结构与真实代码一致、不混写未来态，落盘 `docs/human/human-arch/`、`docs/human/human-plan/` |
| ticket 代码 | 开发部门（devm 直接派 `dev-e`） | **devm（代码门禁）** | 逐条对照 SPEC 判据通过、diff 与证据核对无误；PASS 后写「实施状态」，**merge 待 director 代码验收通过** |
| 代码验收（spec-seq 对齐） | devm（评审 PASS 后提交待验收） | **director（派 reviewer{n} 逐条验收）** | 与同 spec-seq 的 SPEC 验收标准、ticket 判据逐条对齐（diff 与证据无误）；通过后通知 devm merge / push |
| 跨部门分歧 | devm / anam | director | director 裁决并回结论 |

### 5.4 读数纪律（性能窗）

1. **dump 开关必须随窗登记**：`obb_roi_dump_enabled`（`yolo11ncnn.cpp:1063`，默认 off）开时每帧算 raw sha256，占全进程 CPU **13.3%**、detect 线程约 95% ⇒ 实测 `detect_fps_measured` **1.79**（原记 0.76，经 004 订正 —— 0.76 属跨轮残留快照）vs 生产档 **3.86**。**dump-on 窗的 fps／耗时对比一律作废**，不得进任何结论；开窗前必须核 `diagnostics_state` 并把该值写进口径行。
2. **跨构建绝对值禁比**：不同 so／APK 的毫秒数不可互比（设备现装、语料、仓内 APK 三者不同源）；比值（如 detect 前向占比 f）可跨构建比，但须挂横幅说明。
3. **「停」要复验**：`force-stop` 后必须 `pidof <pkg>` 为空才算停；下级回报的「已停」不可直接采信。
4. **快照必须同时满足两条才算本窗**：① 在本窗 `new.list` 内；② `build_sha256` 与同窗其余快照**一致**。任一条不满足 ⇒ **跨轮残留**，禁用于任何对账（含 `detect_ms`／`fps`／`decode_ms`）。
5. **装机权限（只归 director）**：`adb install`／`uninstall`／覆写设备 `bcr_t36_calib.txt`／`bcr_detect_probe.trigger`／`dump_prefs`／`force-stop` 等**写操作，只许 `director` 执行**；`devm`／`anam`／工程师**一律禁装、禁写设备**（需要装机时回报 director，由 director 自己动手，不转授权）。装机后必报 **APK `sha256` ＋ `lastUpdateTime` ＋ `pidof` 空**。

## 6. 表达（全角色）

读者是**稍微懂一点软件工程但没有参与本项目的人**（含用户）：只说白话，先说结论再说证据，突出重点，术语翻成人话。

## 7. 机检

```bash
bash dmt-director/scripts/check-dmt-doc-paths.sh
```

检查**十八项（机检共 25 组断言：①–⑱–主判据 ＋ 2b / 3b / 4b–4p 专项组）**：① 六个产物目录存在（`docs/pd/prd`、`docs/pd/spec`、`docs/dev/tickets`、`docs/analyst`、`docs/human/human-arch`、`docs/human/human-plan`）＋ 根目录 `inbox/` 存在；② 四个技能（`dmt-director` / `dmt-pde` / `dmt-dm` / `dmt-am`）各自指向自己的唯一目录（PRD / SPEC / 工单 / 人类文档归 `dmt-director`；`dmt-pde` 为 `pde{n}` 子代理技能，不占 pane）；③ **helper 纯分身语义与回收动作已登记**（契约与 `dmt-director` / `dmt-dm` / `dmt-am` 技能含 `close-helper.sh`，契约含「禁止先关后收」与「只许关 pane」；契约含「一次性下发」「不接受任何输入框内容」「单向汇报」「没有自己的 inbox」，`spawn-helper.sh` 含「一次性下发」）；④ **身份识别已登记**（契约与四个技能含 `pane label`，契约含「不按 tab 内位置」）；⑤ **并行判据已登记**（`dmt-dm` / `dmt-am` 含「依赖分析」，契约含「依赖分析」「不强制派满」「不设并发上限」）；⑥ **经理层路径已登记**（`dmt-dm` / `dmt-am` 含「直接派」，契约含「经理一律直接派工程师子代理」，契约与两技能含「按需求开」，`dmt-dm` / `dmt-am` 含 `teammate`）；⑦ **装机与推送归属已登记**（装机：契约含「只许 `director` 执行」（反引号）；推送与合并：契约含「merge 与 push 只归 devm」、`dmt-dm` 含「push 与 merge 归 devm」、`dmt-director` 含「不代推」、负向断言「git push 后紧跟只由 director」不得出现、契约含「至少每完成一个 ticket 推送一次」与「至少每小时」）；⑧ **mattpocock 强制技能已逐角色登记**（契约含「强制使用」与角色表；技能侧 `dmt-director`（/grilling、/grill-me、/grill-with-docs、/code-review、/to-spec、/to-tickets）、`dmt-pde`（/grilling、/research、/to-spec、/to-tickets）、`dmt-dm`（/code-review、/diagnosing-bugs）、`dmt-am`（/research、/grilling、/grill-me、/grill-with-docs）各含自己的强制技能名（4e 逐条断言）；`reviewer{n}` 行含 `/review`（= `/code-review`）；工程师执行技能已登记（`dev-e` 行含 `/tdd` `/implement` `/code-review` `/diagnosing-bugs`、`ana-e` 行含 `/research` `/rea` `/grilling` `/grill-me` `/grill-with-docs`））；⑨ **文件占用已登记**（契约含「文件占用」与 `file-claim`，四个技能各含 `file-claim`，脚本 `dmt-director/scripts/file-claim.sh` 存在）；⑩ **评审门禁归属已登记**（契约与 `dmt-director` 含「文档门禁」、契约与 `dmt-dm` 含「代码门禁」、`dmt-director` 含「不替代」）；⑪ **cbc-herdr 通用技能已登记**（三份 pane 角色技能 `dmt-director` / `dmt-dm` / `dmt-am` 各含 `cbc-herdr`，`dmt-pde` 子代理技能不需要）；⑫ **技能链接与上游一致**（契约与四个技能都含 `raw.githubusercontent.com`；技能名与 `mattpocock/skills` 目录名逐字一致，机检只验链接存在、不验 URL 目录名）；⑬ **确定性动作已脚本化**（公共库 `lib-dmt.sh`；`launch.sh` / `init-project.sh` / `setup-team.sh` / `spawn-helper.sh` / `close-helper.sh` / `send-msg.sh` / `msg-take.sh` / `msg-done.sh` / `publish.sh` / `file-claim.sh` / `install-skills.sh` / `check-dmt-doc-paths.sh` 共 13 个存在且可执行）；⑭ **收件箱三态已登记**（契约含 `.doing/`、 `.seq`、`msg-take.sh`、`msg-done.sh`，三份 pane 角色技能各含 `msg-take.sh`）；⑮ **按需派发与完成即报已登记**（OPS 与 `dmt-director` / `dmt-dm` / `dmt-am` 含「完成即报」，三份 pane 技能各含「依赖分析」；4l-b 负向断言：2026-11-02 用户裁定「不强制派满、不设并发上限」后，契约正文与四技能正文不得再出现饱和派发表述 —— 每波上限拆波、开工先落账、并发位计数开口、CAP 探测脚本与派发账本脚本名及其输出格式）；⑯ **契约表格登记齐全**（`docs/pd/prd/`、`docs/pd/spec/`、`docs/dev/tickets/`、`docs/analyst/`、`docs/human/human-arch/`、`docs/human/human-plan/`、`inbox/` 七项都在 §3 表中出现）；⑰ **契约头部带版本号与日期且与四个技能同号**（`team.md` 头部 `版本 X.Y.Z · YYYY-MM-DD`，四份 `SKILL.md` 的 `version:` 与之一致，脚本 4m）；⑱ 负样本能被正确拒绝（**只看契约的表格登记行**，§8 变更记录里的历史留痕不算登记）。**改路径规范、pane 生命周期、并行口径、角色层级、写权限、强制技能、文件占用、评审门禁、通用技能、技能链接、收件箱三态、派发 prompt 文件写入纪律、pi agent 名承载或脚本接口后必须重跑。**

## 8. 变更记录

**历史明细（第一次～第五十九次）见 [`dmt-director/CHANGELOG.md`](dmt-director/CHANGELOG.md)；此处只留最新一条。**

- **2026-11-03（用户要求·第六十次：cbc auto 模式复核超时加固 —— 抬预算 / 复核模型换本地 / 脚本 allow 规则，版本 `5.14.0`）**：机队 pane 一律以 `codebuddy --permission-mode auto` 启动，而 auto 模式下**每个需审批的工具调用都要过一次自动复核**（agent `autoModeClassifier`，prompt 为整段会话上下文、实测 28.5–29.5k tokens，最多 8 轮，**默认 90s 硬上限**）。2026-11-03 16:55 实测一条 `file-claim.sh check` 被判失败 —— 脚本本体 57ms 正常返回，真正挂的是并行的复核请求：先撞 `status=500` 再连撞 `status=429`（企业网关限流；同日 `ModelsProductProvider` 已累计 1987 次连续失败并退避 300000ms），重试退避吃光整段预算 ⇒ 日志 `[auto-review] no verdict tool=Bash failure=timeout durationMs=90002: auto review timed out before it reached a verdict`，UI 显示「Automatic approval review timed out while evaluating the requested approval.」。**注意识别**：错因在权限层，现象却像脚本坏了（本次即被误读为 `file-claim.sh` 故障）。① **抬预算（两条路冗余）** —— `lib-dmt.sh` 的 `dmt_harness_cmd()` codebuddy 分支前置 `CODEBUDDY_AUTO_REVIEW_TIMEOUT_MS=300000`（机队 pane 显式带；`$DMT_HARNESS_CMD` 仍可整体覆盖）；用户级 `~/.codebuddy/settings.json` 的 `env` 块同键兜底（覆盖**手动启动**的会话，脚本管不到）。该键是官方逃生舱（二进制 `resolveAutoReviewTimeoutMs()` 读 `process.env`，`0 < n ≤ 2^31-1`，默认 90000），settings 一路经 `env` 拦截器注入 `process.env`；**可证伪验证**：把该值临时改成 `1` 重跑 ⇒ 日志立刻出现 `no verdict ... durationMs=140/133`，证明它真的到达 resolver，不是「改完就算」。② **复核模型换本地** —— `subagents.agents.autoModeClassifier.model = custom-local:Qwen3.8-27b`（本地 sglang `http://10.223.32.29:30000`），把复核流量从企业网关挪走；同批探针实测复核 `durationMs=8018`（TTFT 2.99s，两轮出裁决），对比走网关的 13s / 36s / 39s 明显收敛。**代价**：复核器是自动放行闸门，27B 本地模型的判定质量弱于网关模型；不放心就把该行删掉改回走网关。③ **allow 规则** —— 用户级 `permissions.allow` 共 48 条 = `dmt-director/scripts/` 下 12 个契约脚本 ×（路径无关的相对前缀 `bash dmt-director/scripts/X.sh:*` ∪ 三个绝对安装位置），命中即 allow、不进复核；实测 `bash dmt-director/scripts/file-claim.sh list .` 全程无 `[auto-review]` 行，同批非白名单命令仍走复核。**规则语义（读二进制得，登记以免下次踩空）**：只认 `Bash(<前缀>:*)`（去掉 `:*` 后按「首词相等／全等／前缀+空格」匹配）；**含 `*` 通配的规则在 auto 模式下被 `filterDangerousAllowRules` 判危险而整条忽略**（日志留 `Ignoring dangerous allow rule ... because it bypasses the auto reviewer`）；命令含 `>`／`<` 等重定向一律不套规则。**版本升 `5.14.0`**（四技能 `version:` 同号）。**Why**：复核是安全闸，但它把「企业网关的可用性」变成「机队所有写操作的可用性」—— 网关一抖，正常命令被判失败，且错因显示在权限层、易被误判为脚本故障。三条路各自独立失效，故一起上：抬预算治超时、换本地模型治限流、allow 规则治「本来就不用复核的命令不该付复核代价」；落点只在公共库 `lib-dmt.sh` 与用户级配置，不散进各地副本。**已跑**：`bash dmt-director/scripts/check-dmt-doc-paths.sh` 全绿（25 组断言，本次未改断言）、`bash -n` 语法检查通过。

