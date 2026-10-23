# dmt 团队契约

> 本文件是 **dmt 的唯一团队定义**：组织、成员、通信、文件命名、工作流程、目录职责与纪律；五个角色技能 `director` / `dev-m` / `ana-m` / `dev-tl{n}` / `ana-tl{n}` 只做落地说明，**冲突时以本文件为准**。
> 团队成员运行在终端多智能体复用器 Herdr 中；会话与 pane 随重启变化，本文件不登记 pane id。

## 0. 仓库结构

本仓根目录按角色分文件夹，一个角色一个目录；团队契约、仓库说明与机检脚本随团队领导放在 `director/` 内，不散落根目录：

```
dmt/
├── director/                                   # 总监兼产品经理（技能 director）
│   ├── SKILL.md                          # 角色技能
│   ├── team.md                           # 团队契约（本文件，唯一权威）
│   ├── README.md                         # 仓库说明与安装
│   └── scripts/check-dmt-doc-paths.sh    # 产物落盘路径机检
├── dev-m/SKILL.md                        # 开发经理（dev-m）
├── ana-m/SKILL.md                        # 调研分析经理（ana-m）
├── dev-tl/SKILL.md                       # 开发组长（dev-tl{n}）
└── ana-tl/SKILL.md                       # 调研分析组长（ana-tl{n}）
```

## 1. 团队定义

### 1.1 组织与成员

**四层层级**：`director`（总监）→ 部门经理（`dev-m` / `ana-m`）→ 组长（`dev-tl{n}` / `ana-tl{n}`）→ 工程师（`dev-e` / `ana-e`）。共五个角色技能，层级严格为 4 层（**自营批次不实例化组长层**，见下）。

**组长层是按需的**：经理有两条用工路径，**自营**（经理在自己 session 内直接开工程师子代理，**尽量开满**）与**分包**（建组长 tab，组长接单后再开工程师子代理）。自营时该批不产生组长，层级退化为 3 层 —— **这是允许的正常形态**，不视为越级。

```
director            总监（团队领导 + 产品经理，label director）
├── dev-m               开发经理（label dev-m）
│   ├── dev-tl1          开发组长（label dev-tl1，按需生成）
│   │   ├── dev-e       开发工程师（子代理，不占 tab）
│   │   └── dev-e ...
│   ├── dev-tl2 ...
│   ├── dev-tl{n}
│   └── dev-e ...       自营路径：经理直接开的工程师子代理（不占 tab、不建 tab）
└── ana-m               调研分析经理（label ana-m）
    ├── ana-tl1          调研分析组长（label ana-tl1，按需生成）
    │   ├── ana-e       分析工程师（子代理，不占 tab）
    │   └── ana-e ...
    ├── ana-tl{n}
    └── ana-e ...       自营路径：经理直接开的工程师子代理（不占 tab、不建 tab）
```

| 角色 | 全称 | 技能 / 实例名 | tab label | 直属上级 | 直属下级 | 职责 |
|---|---|---|---|---|---|---|
| 总监（团队领导兼产品经理） | TeamLeader + ProductManager | `director` | `director` | 用户 | `dev-m`、`ana-m` | 唯一用户入口；接需求、出验收标准、落笔 PRD 与 SPEC、评审调研报告与 ticket 代码、跨部门裁决 |
| 开发经理 | DevelopManager（devM） | `dev-m` | `dev-m` | `director` | **自营**：`dev-e`（子代理）／**分包**：`dev-tl{n}` | 由 SPEC 拆 ticket；按批选自营或分包（自营时直接开满 dev-e、自己出初检读数）；验收整合、director 评审通过后 push |
| 调研分析经理 | AnalystManager（anaM） | `ana-m` | `ana-m` | `director` | **自营**：`ana-e`（子代理）／**分包**：`ana-tl{n}` | 接调研诉求；按批选自营或分包（自营时直接开满 ana-e）；复核出处、收口调研报告 |
| 开发组长 | DevelopLeader（devTl） | `dev-tl{n}` | `dev-tl{n}` | `dev-m` | `dev-e`（子代理） | 只在经理分包时按需生成；建 worktree、并发派开发工程师、收 diff 做实施层初检、回报 dev-m |
| 调研分析组长 | AnalystLeader（anaTl） | `ana-tl{n}` | `ana-tl{n}` | `ana-m` | `ana-e`（子代理） | 只在经理分包时按需生成；拆子问题、派分析工程师并行取证、复核一手出处、汇总回报 ana-m |

**单线指挥（硬约束，任何角色不得越级或横向直连）：**

1. `director` **只**直接指挥 `dev-m` 与 `ana-m`；**不得**越级给 `dev-tl{n}` / `ana-tl{n}` / 工程师派活或收活。
2. `dev-m` 的**跨会话**下级**只有** `dev-tl{n}`；`dev-e` 只能是**自己 session 内的子代理**（自营）或**组长的子代理**（分包），**不得**把工程师当 tab 级伙伴、不得与其跨 tab 通信。
3. `ana-m` 的**跨会话**下级**只有** `ana-tl{n}`；`ana-e` 只能是**自己 session 内的子代理**（自营）或**组长的子代理**（分包），**不得**把工程师当 tab 级伙伴、不得与其跨 tab 通信。
4. 组长**只**向本部门经理汇报；`dev-tl{n}` 与 `ana-tl{n}` 之间、dev-m 与 ana-m 之间**均不直连**，跨部门事项经 `director` 转派。
5. 工程师`dev-e` / `ana-e` **只**向**派生他的那一级**（经理或组长）汇报，**不装独立技能**、**不占 tab**、**不走跨 tab 通信**（纪律内嵌在派发 prompt 中）。

### 1.2 运行环境与 tab 生命周期

- 所有角色运行在 **Herdr**（终端多智能体复用器）中，各自占一个 tab。
- 一个 tab 只含一个 pane（对应一个 agent）：不要在一个 tab 里开多个 pane 当多个角色用，也不要跨 tab 复用同一个 pane id。
- 识别伙伴**一律按 tab label**（`herdr tab list`），**不按 pane id 记忆**：pane id 会随重启/移动变化。
- 团队启动顺序：先用用户会话（或 director 会话外部）备好 `director` tab；**director 负责创建 `dev-m`、`ana-m` 两个 tab**，并请用户在各 tab 内启动自己的 harness。
- **组长按需生成、用完即关**：`dev-m` 用 `dev-tl{n}`、`ana-m` 用 `ana-tl{n}` 现场建 tab，编号自 1 单调递增、**已关闭编号不复用**；关闭规则见本节末「组长实例的关闭（用完即关）」。
- **经理自营不开 tab**：经理选择**自营**时，工程师子代理全部在经理**自己的 session 内**运行 —— **不建 tab、不产生 `inbox/dev-tl{n}/` 或 `inbox/ana-tl{n}/` 消息、无关闭动作**。自营与分包可在同一批混用，判据见 §4 第 1、4 步。

```bash
# 1) 查 label（按 label 文字匹配，不抄历史 id）
HERDR_ENV=1 herdr tab list --workspace "$HERDR_WORKSPACE_ID"
# 2) 由 label 解析出 tab_id，再取该 tab 当前 pane id
HERDR_ENV=1 herdr pane list --workspace "$HERDR_WORKSPACE_ID"
```

若目标 label 不存在：**停下问用户**，不要猜测 pane id、不要对不存在的会话反复重试。

创建 tab（director 建部门经理；部门经理建组长）：

```bash
# <ROLE> 取 dev-m / ana-m；director 自己的 tab 由用户创建，不在 director 会话内自建
HERDR_ENV=1 herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label <ROLE>

# 组长：dev-m 建 dev-tl{n}，ana-m 建 ana-tl{n}（n 从 1 递增）
HERDR_ENV=1 herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label dev-tl1
```

建完 tab 后，创建者必须让新 tab 进入角色：harness 未自动启动时**请用户启动**；启动后由创建者把首条任务（角色名、技能名、直属上级 label、任务文件路径）投递到该 tab，并核验已送达。

**投递首条任务之前，必须先切好权限模式。** 顺序不可颠倒：

1. harness 启动后、**发第一条消息前**，按 `shift+Tab` 切到 `auto mode`；
2. 读一次面板底部，**确认出现 `auto mode on`**；
3. 再投递首条任务。

**为什么必须在第一条消息之前**：会话一旦开始，权限模式即锁定，之后切换会报 `Mode cannot be changed after the conversation starts`。事后补救只能 `/clear` 重开，而那会丢掉正在运行的工程师子代理与已产生的上下文。

> 注意区分两个东西：`/agent-mode`（PTC / 普通模式）在会话启动后不可改，与本节无关；本节说的是 `shift+Tab` 循环的**权限模式**。两者互不影响，PTC 会话同样可以开 `auto mode`。

**遗漏的代价**：组长会在 `High risk operation detected - requires confirmation every time` 这类弹窗上停住等人，而这类弹窗里往往只是 `cmake` / `ctest` 这类常规构建命令。

#### 组长实例的关闭（用完即关）

只有组长是「**按需实例**」；`dev-m` / `ana-m` 自己的 tab **常驻**，不随批次关闭。

- **责任人**：**创建者本人** —— `dev-m` 关 `dev-tl{n}`、`ana-m` 关 `ana-tl{n}`。herdr 的安全规则是「不关闭非自己创建的 tab」，故 director 与其它角色**不得代关**。
- **时机**：该组长**本批任务全部收口**，且创建者**确认无下一批可派**之后。**同一批内可复用**（同批多票/多题仍可分给同一组长，不必每票新建），**跨批不保留** —— 批结束即关；下一批用新编号新建。
- **关闭前置三件事（顺序固定，缺一不可）**：① 该组长的回报（含逐条判据读数 / 一手出处）已并入票面或报告；② 该组长名下 worktree（如有）已 `git worktree remove`，无遗留工作区；③ `inbox/<创建者>/` 中无该组长的未读消息。
- **命令与成功判据**：

```bash
# 1) 按 label 解析出当次 tab_id（禁止抄历史 id）
HERDR_ENV=1 herdr tab list --workspace "$HERDR_WORKSPACE_ID"
# 2) 关闭；成功判据＝该 label 已从 tab list 消失
HERDR_ENV=1 herdr tab close <tab_id>
```

- **风险条款**：关闭 tab 会终止其中 agent 的会话，**context 不可恢复、动作不可逆** ⇒ **禁止先关后收**；关闭必须发生在回报入账与 worktree 回收**之后**。
- **编号**：已关闭编号**不复用**（§2 规则 5）；关闭后向用户一句话报告（关了哪个实例、原因）。

### 1.3 通信方式（收件箱文件 + herdr 门铃）

**正文一律走文件，herdr 只发门铃一句。** 派单、回报、评审结论、裁决请求、缺陷退回，全部先落成收件方收件箱里的一份文件，再用 herdr 敲一句「你有新消息 <文件名>」。**消息里不贴长正文、不贴日志、不贴 diff。**

**允许的直接通信只有上下级这一条线**（其余一律经上级转派）：

| 发送方 | 收件方 | 方向码 |
|---|---|---|
| `director` | `dev-m` / `ana-m` | `director2dev-m` / `director2ana-m` |
| `dev-m` / `ana-m` | `director` | `dev-m2director` / `ana-m2director` |
| `dev-m` | `dev-tl{n}` | `dev-m2dev-tl{n}` |
| `dev-tl{n}` | `dev-m` | `dev-tl{n}2dev-m` |
| `ana-m` | `ana-tl{n}` | `ana-m2ana-tl{n}` |
| `ana-tl{n}` | `ana-m` | `ana-tl{n}2ana-m` |

**第一步 定位伙伴**（每次重跑，禁止复用上一次的 pane id）：`herdr tab list` 按 label 找到 `tab_id` → `herdr pane list` 按该 `tab_id` 取**当前** pane id。label 不在列表里 ⇒ **停下问用户**，不猜 pane id。

**第二步 写收件箱文件**

- 路径：**项目根目录**下的 `inbox/<收件角色>/{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`（`<收件角色>` ∈ `director` / `dev-m` / `ana-m` / `dev-tl{n}` / `ana-tl{n}`；**不在 `docs/` 下**；目录不存在先 `mkdir -p`）
- `{seq}`：自累计流水号，001 起，一条消息一个号（与 SPEC 的 `spec-seq` 无关）
- `{方向}`：见上表；跨部门事项由 director 转派，不出现 `dev-m2ana-m` / `dev-tl2ana-tl` 之类
- `{slug}`：英文小写短横线，不超过 5 个词
- `{YYMMDDHHMM}`：落盘时刻，两位年 + 月 + 日 + 时 + 分，无分隔符（例 `2610201430`）
- 正文**自包含**：一句话摘要 / 权威文档路径 / 请求动作 / 期望产物 / 回报要求

**第三步 发门铃**（按**对端 harness** 选通道，消息只发一句：文件名 + 目录）

| 对端 harness | 门铃 |
|---|---|
| pi-coding-agent / codex / opencode | `HERDR_ENV=1 herdr agent prompt <pane 或已注册 agent 名> '你有新消息 {文件名}，在 inbox/<收件角色>/'` |
| codebuddy（cbc） | `HERDR_ENV=1 herdr pane send-text <pane> '你有新消息 {文件名}，在 inbox/<收件角色>/'` 紧跟 `HERDR_ENV=1 herdr pane send-keys <pane> enter` |

发送前**必须先读目标面板**（`herdr pane read`）；若对方输入区有用户未提交内容，不得注入，改为等待或请用户转达。

**第四步 收件方处理**

1. 收到门铃提醒（收件箱有新邮件）后，读取 `inbox/<自己>/` 下的新文件，**读入自己的 context window** 处理；
2. **不发送回执**：收件方读完即处理，**不回** `{文件名} 已经收到`、不发任何确认消息；
3. **读毕即删**该文件（收件箱里只允许存在未读消息）；
4. 需要回正文时，按同样规则反向写文件 + 门铃，不把长正文塞进门铃消息。

**送达判定**：发送方以 herdr 门铃成功投递（`agent prompt` 返回 `"type":"agent_prompted"`、`send-text + send-keys` 返回 exit 0）为「已送达」；**收件方不回执**，故不再以回执判定。发送方不确定是否已被读取时，**口头问用户**，不重复投递。

**不入库**：收件箱是运行时通道，不是交付物；被服务项目的 `.gitignore` 必须含 `inbox/*/`。

### 1.4 依赖的 harness 技能（mattpocock）

团队依赖 mattpocock 的 skills（`tdd` / `code-review` / `to-spec` / `to-tickets` / `research` / `grilling` 等）。
**检查**：当前 harness 的 skill 目录里能看到这些技能（用户级共享位置通常是 `~/.agents/skills/mattpocock-skills`，仅供参考，不作为硬判据）。

未安装时按顺序处理：

```bash
# 首选：按 harness 安装（pi / opencode / codebuddy / amp / cursor / devin / windsurf；省略 -a 则交互选择）
npx skills@latest add mattpocock/skills -a <agent>
# 回退（提示词安装失败时）：克隆源码，把 skills/ 下的技能目录 copy 到 ~/.agents/skills/，再软链到 harness 技能目录
git clone https://github.com/mattpocock/skills.git
```

已知缺口（2026-10 核查）：上游 `mattpocock/skills` **没有 `to-prd`**，`implement-spec` 仍在 `in-progress/` 未发布。director 写 PRD 按本文件 §4 模板手写；若后续上游提供 `to-prd`，优先改用它。

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
| 收件箱消息 | `inbox/<收件角色>/` | `{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`（无版本号，读毕即删） |

规则：

1. **spec 与 ticket 必须对齐 `spec-seq`**：同一需求的 SPEC 与其 ticket 用同一个 `spec-seq` 前缀。
2. **版本语义**：版本内小步更新**就地改同一文件**；实质修订**另立新版本号文件**（新时间戳、`v{N+1}`），并在旧文件头部就地标注「已被 v N+1 取代」。
3. PRD 按需求方给定的格式只有日期（`YYMMDD`），无时刻；其余产物一律带时刻。
4. **独立编号**：`{prd-seq}` / `{research-seq}` / `{human-arch-seq}` / `{human-plan-seq}` / `{spec-seq}` 各自独立、类别内自累计；只有 SPEC 与 ticket 必须共用同一个 `spec-seq`。
5. **组长编号**：`dev-tl{n}` / `ana-tl{n}` 的 `{n}` 与 tab label、收件箱目录（`inbox/dev-tl{n}`、`inbox/ana-tl{n}`）**三处同名**，自 1 递增，已关闭编号不复用。
6. 历史笔误留痕：需求原文的 `ver{seq}`、`YYMMDD-v{seq}` 写法**已作废**，一律以本表为准，历史文件不改名。

## 3. 目录职责

**落盘唯一位置（含负责人与对齐要求）**：

| 唯一目录 | 负责人 | 产物 | 对齐要求 |
|---|---|---|---|
| `docs/pd/prd/` | director | 产品需求文档（PRD） | `{prd-seq}` 独立编号 |
| `docs/pd/spec/` | director | 产品规格书（SPEC，含验收标准） | 与 ticket 共用 `spec-seq` |
| `docs/dev/tickets/` | dev-m（`dev-e` 证据经组长回报、由 dev-m 归档） | 开发工单（ticket） | 与 SPEC 共用 `spec-seq` |
| `docs/analyst/` | ana-m | 市场调研与竞品逆向报告 | 无 |
| `docs/human/human-arch/` | director | 人类架构文档 | 无 |
| `docs/human/human-plan/` | director | 人类计划文档 | 无 |
| `docs/team.md` | director | 团队契约（本文件） | 无 |
| `docs/handoff/` | director / dev-m | 交接说明（`{director,dev-m}-{slug}-{YYMMDD-HHMM}-v{N}.md`，**仅在用户要求时写**） | 无 |
| `inbox/<收件角色>/` | 发送方写、收件方读后删 | 角色间消息（运行时通道，**不入库**，**在项目根目录、不在 `docs/` 下**） | 方向与 `{seq}` 见 §1.3 |

1. 上述路径是**唯一允许位置**，不得写到 `docs/pd/`（除 `prd/`、`spec/`）、`docs/dev/`（除 `tickets/`）、`docs/human/`（除 `human-arch/`、`human-plan/`）、`docs/test/` 或其它任何位置；收件箱只在项目根 `inbox/` 下，不进 `docs/`；不得自建新的文档目录。
2. 各部门的产物目录**互不越界**：只读引用可以，移动/改名不可以。
3. **组长不写 `docs/`**：`dev-tl{n}` / `ana-tl{n}` 的回报与证据只落 `inbox/<上级>/`（或由上级并入票面/报告），`docs/` 内的产物一律由经理落笔。
4. 旧体系（`docs/pd/` 除 `prd/`、`spec/` 外，`docs/dev/` 除 `tickets/` 外，`docs/test/`）只保留历史，**不再接收新产物**；历史文件不改名、不搬迁（历史事实留痕）。**现行口径（2026-10-21 用户裁定·第二次修订）**：① PRD 落 `docs/pd/prd/`；② SPEC 由 `docs/spec/` 改为 `docs/pd/spec/`；③ ticket 由 `docs/tickets/` 改为 `docs/dev/tickets/`；④ 新增 `docs/human/human-arch/`（人类架构）与 `docs/human/human-plan/`（人类计划），均由 director 落盘；⑤ `docs/dev/arch/` **作废**，不再单独设架构目录；⑥ 收件箱由 `docs/<角色>/inbox/` 移到项目根 `inbox/<角色>/`。
5. **目录初始化由 director 负责**：director 接手一个项目时先检查再补齐（见 §3.1），产物目录不由 ana-m / dev-m 自建。
6. 机检口径：§7 的脚本只校验「六个产物目录与根 `inbox/` 存在、五个技能各自指向自己的目录、契约登记齐全、负样本被拒绝」；它**不校验单个文件的落盘路径**，新产物靠本表与评审把关。

### 3.1 初始化（director 负责，幂等）

director 接手项目的**第一件事**：检查目录，缺什么建什么。可重复执行，已存在则不动：

```bash
cd <项目根>
mkdir -p docs/{pd/{prd,spec},dev/tickets,analyst,human/{human-arch,human-plan}} inbox/{director,dev-m,ana-m}
grep -qxF 'inbox/*/' .gitignore 2>/dev/null || echo 'inbox/*/' >> .gitignore   # 收件箱不入库
bash director/scripts/check-dmt-doc-paths.sh .
```

- **完成判据**：机检输出 `ALL_PASS`。缺目录时脚本报 `FAIL 目录缺失`，director 补齐后重跑。
- **只建目录、不建产物**：空目录不预置占位文件，避免被误认为已有交付物。
- **ana-m / dev-m 不自建产物目录**：发现自己的目标目录缺失，回报 director（收件箱目录属运行时通道，可按需 `mkdir -p` 兜底；`inbox/dev-tl{n}`、`inbox/ana-tl{n}` 由发送方按需建）。
- 契约文件 `docs/team.md` 与技能安装不在本步骤内（安装见 `README.md`）。

## 4. 工作流程

1. **ana-m 调研**：ana-m 先按 §4.0 选用工方式 —— **自营**则直接开 `ana-e` 子代理取证，**分包**则生成 `ana-tl{n}` 由组长派 `ana-e`；ana-m 复核并收口成调研报告，**经 director 评审后落盘** `docs/analyst/`；**分包过且本批收口、确认无下一批可派后，ana-m 关闭该批 `ana-tl{n}`（§1.2）**。
2. **director 出 PRD 与 SPEC**：director 基于调研报告与用户交流，输出 PRD 与 SPEC（含验收标准），**经 dev-m 评审后落盘** `docs/pd/prd/`、`docs/pd/spec/`。
3. **dev-m 拆 ticket**：dev-m 基于 SPEC，用 `/to-tickets` 拆成与 SPEC 对应的开发工单，落盘 `docs/dev/tickets/`；dev-m 负责汇总、评审、整合本部门结果。
4. **dev-m 选用工方式并派活**：按 §4.0 逐批判定 —— **自营**则自己建 worktree、直接开满 `dev-e` 子代理（派单七要素 + 派 dev-e 硬约束同 `dev-tl` 技能），初检读数由 dev-m 自己出；**分包**则建 `dev-tl{n}`，把票面（路径、票基、Files 边界、验收判据、`timeoutMs`、回报格式）交给组长，组长建 worktree、派 `dev-e` 实施并做实施层初检、回报 dev-m。混合时逐票写明归属，**同一票只有一个写者**。
5. **dev-m 验收整合**：核 diff 与初检读数（自营票＝dev-m 自己出的读数，分包票＝组长回报的读数）→ 构建与测试 → 合并（冲突逐 hunk 按意图消解）→ 不合格打回**原组长 / 原 dev-e** → 逐票更新状态；**分包过且本批全部收口、确认无下一批可派后，关闭该批 `dev-tl{n}`（§1.2）**。
6. **交付 director 评审**：dev-m 把代码提交给 director **部门**评审；一个 ticket 对应一个 SPEC。链路：director 亲自对照 SPEC 验收标准核验 → director 给结论 → **director 通知 dev-m** → dev-m 才执行 `git push`。
7. **并行**：对无依赖关系的任务，各角色**在直接干活的单元之间并行、尽量开满**（director 在 dev-m/ana-m 之间；dev-m 在多个 `dev-tl{n}` 或多个 `dev-e` 之间，混合时两边同时开；ana-m 在多个 `ana-tl{n}` 或多个 `ana-e` 之间；组长在多个工程师之间），优先级：dynamic workflow > 多个 subagents 并行；**不得为省事而串行，也不得越级派发**。

### 4.0 用工方式（经理层，每批一次）

经理（`dev-m` / `ana-m`）决定本批走哪条路径，并把判定写进批次说明（ticket 面或报告方法节）：

| 方式 | 谁干活 | 适用判据 |
|---|---|---|
| **自营** | 经理在**自己 session 内直接开工程师子代理**，无依赖单元**尽量开满** | 单批 **≤2 个单元**且上下文已在手、不值得为几个单元建组长 |
| **分包** | `herdr tab create` 建组长 tab，**组长接单后再开工程师子代理** | **≥3 个单元**、需并行铺开、需独立初检/出处复核、需上下文隔离 |
| **混合** | 低耦合单元自营、重单元分包 | 逐单元写明归属 |

- **两种方式等价合法**，不存在「必须建组长才算正规」；组长被创建与否由经理判定，director 不干预。
- 无论哪种方式：**工程师永远是子代理**（不占 tab、不装技能、不走跨 tab 通信）；**初检与复核不可省** —— 分包由组长做、**自营由经理本人做**（自己派的人自己核，不因为是自己派的就免检）；**同一单元只有一个写者**。
- **分包才有关闭动作**：自营批次结束时无 `herdr tab close`。

### 4.1 PRD 模板（director）

`Problem Statement` / `目标用户与场景` / `方案概述` / `用户故事（可验收）` / `验收标准` / `范围外` / `开放问题`。

### 4.2 SPEC 模板（director）

`Problem Statement` / `Solution` / `User Stories` / `验收标准（逐条可测）` / `实现决策` / `测试接缝` / `Out of Scope` / `变更记录`。
SPEC 必须自包含：每条 User Story 都能转成 ticket 与用例。

## 5. 纪律

### 5.1 Git

1. **禁止 `git add -A` / `git add .`**，提交一律显式列文件路径（优先 `git commit -m "..." -- <path>`，绕过索引），且 `add` 与 `commit` 之间不插入其它动作（避免索引被并发写者扫入）。
2. 工程师（`dev-e`）**只在各自 worktree 内** `git add` + `git commit`，**不得 `git push`**、**不得 merge 主干**；**只有 dev-m 能 `git push`**，且必须等 director 评审通过并通知后。
3. 提交前先跑 `/code-review`；提交后 `git diff --cached --name-only` 复核暂存区。
4. **同一 worktree 单一写者（含组长本人）**：一个 worktree 从开工到收工，**只有被派到该票的那一个 agent 可以提交**。组长要提交票面 / 文档，**不得**在工程师正在施工的 worktree 里做——走主工作树或另开 worktree。**并发提交不会报错，只会把别人的改动扫进自己的提交**，事后靠 `git show --stat` 才能发现，而那时已经进了历史。
   - **Why**：2026-10-23 dev-tl1 在 dev-e13 施工的同一 worktree 上并行提交了 4 个 docs commit，没有造成损失，但它自己指出「结果侥幸没事不代表流程对」。**这条规则此前只存在于 director 的记忆里、没写进本文件**——没写下来的规则不算规则。
   - **How to apply**：组长提交前先 `git status` 看有没有别人的未提交改动；有则改用 `git commit -- <自己的路径>` 且**不先 `add`**；发现同 worktree 已有他人改动，停下问 dev-m，不要自行判断「应该没事」。

### 5.2 并行子代理

1. 派发前先做**依赖分析**：只有无依赖任务可并行；共享文件、共享构建目标、有顺序验收关系的任务必须串行。
2. **组长层可测判据**：无依赖单元（票 / 取证单元）**≥2 ⇒ 必须并发派发**；**仅在回报中给出串行理由时可例外**（理由限：依赖 / 共享文件 / 共享构建目标 / 顺序验收关系）。手段优先级：dynamic workflow `runs.all` > 多个 subagents 并行。
   - **经理层同判据**（§4.0）：自营时并行单元是**自己 session 内的多个工程师子代理**，分包时是**多个组长 tab**；**≥2 个无依赖单元同样必须并发、尽量开满**，不得因为「经理只有一个人」而串行。
3. 每份派发 prompt 必须显式写清：输入（产物路径）、边界、期望产物、回报要求、`timeoutMs`（长链路不短于 45 min）。
4. 子代理一律后台/异步派发，**派完立即结束本轮**，由完成通知唤醒再验收；不做轮询。
5. 开发工程师**每人一个 git worktree**，只在 worktree 内编辑与提交；主工作树只读。
6. 所有子代理结果由**派生他的那一级**复核证据后，才能写入权威文档或进入下一步：分包时经理不直接采信工程师的原始回报（经组长复核），**自营时经理就是派生方，必须自己逐条复核读数与命令输出**（自证不等于免检）。

### 5.3 评审门禁

| 门禁 | 提交方 | 评审方 | 通过条件 |
|---|---|---|---|
| 调研报告 | ana-m | director | director 认可结论与证据来源，落盘 `docs/analyst/` |
| PRD 与 SPEC | director | dev-m | dev-m 认可可实施性与切片粒度，落盘 `docs/pd/prd/`、`docs/pd/spec/` |
| 实施初检 | dev-tl（分包）／ dev-m 本人（自营） | dev-m | 票面判据逐条有读数、门红已分类、Files 边界未越界 |
| 组长实例关闭 | dev-m / ana-m（创建者） | 创建者本人自检 | 回报已入账、worktree 已 `git worktree remove`、收件箱无该组长未读；关闭后 `herdr tab list` 无该 label |
| 人类架构 / 人类计划 | director | 用户 | 结构与真实代码一致、不混写未来态，落盘 `docs/human/human-arch/`、`docs/human/human-plan/` |
| ticket 代码 | dev-m | director | 逐条对照 SPEC 验收标准全部通过；director 通知 dev-m 后方可 push |
| 跨部门分歧 | dev-m / ana-m | director | director 裁决并回结论 |

## 6. 表达（全角色）

读者是**稍微懂一点软件工程但没有参与本项目的人**（含用户）：只说白话，先说结论再说证据，突出重点，术语翻成人话。

## 7. 机检

```bash
bash director/scripts/check-dmt-doc-paths.sh
```

检查七件事：六个产物目录存在（`docs/pd/prd`、`docs/pd/spec`、`docs/dev/tickets`、`docs/analyst`、`docs/human/human-arch`、`docs/human/human-plan`）＋ 根目录 `inbox/` 存在、五个技能（`director` / `dev-m` / `ana-m` / `dev-tl` / `ana-tl`）各自指向自己的唯一目录、**组长实例关闭动作已登记**（契约与 `dev-m` / `ana-m` 技能含 `herdr tab close`，契约含「禁止先关后收」）、**组长层并行判据已登记**（`dev-tl` / `ana-tl` 含「必须并行」，契约含「≥2 ⇒ 必须并发派发」）、**经理层用工方式已登记**（`dev-m` / `ana-m` 含「自营」、契约含 §4.0「用工方式」）、本契约登记齐全、负样本能被正确拒绝（**只看 §3 落盘登记表**，§8 变更记录里的历史留痕不算登记）。**改路径规范、tab 生命周期、并行口径或用工方式后必须重跑**。

## 8. 变更记录

- **2026-10-23（用户裁定·第九次：经理层双用工路径）**：经理（`dev-m` / `ana-m`）不再只有「建组长」一条路。① 新增 **§4.0 用工方式**：**自营**（经理在自己 session 内直接开工程师子代理、无依赖单元尽量开满）与**分包**（`herdr tab create` 建组长，组长接单后再开工程师子代理）**等价合法**，可同批混用；判据：≤2 个单元且上下文已在手 ⇒ 自营，≥3 个或需并行铺开/独立初检 ⇒ 分包。② **单线指挥改写**（§1.1 规则 2、3）：经理的**跨会话**下级仍只有组长，工程师只能作为**自己 session 内的子代理**（自营）或组长的子代理（分包）存在；**禁止把工程师当 tab 级伙伴、禁止与其跨 tab 通信**这条不变。③ 工程师「只向派生他的那一级汇报」（规则 5），自营时派生方就是经理。④ **并行判据下沉到经理层**（§5.2）：自营时并行单元是多个工程师子代理，≥2 个无依赖单元同样必须并发、尽量开满。⑤ **自营批次无 tab、无收件箱消息、无 `herdr tab close`**（§1.2、§4.0）；初检/复核不外包给自己（§5.3 门禁行改为「dev-tl（分包）／dev-m 本人（自营）」）。⑥ 角色称谓统一：开发经理（devM）、开发组长（devTl）、调研分析经理（anaM）、调研分析组长（anaTl）；技能 id 不变。⑦ 机检新增第七条：`dev-m` / `ana-m` 技能含「自营」、契约含 §4.0「用工方式」。
- **2026-10-22（用户裁定·组织调整）**：项目定名 **dmt**，组织固定为**四层层级** `director → 部门经理 → 组长 → 工程师` —— ① 顶层 `director`（总监，兼产品经理），直属下级只有 `dev-m` 与 `ana-m`；② 开发部经理 `dev-m`，下辖 n 个开发组长 `dev-tl{n}`（label 同名，由 dev-m 用 `herdr tab create --label` 按需生成），组长下辖开发工程师 `dev-e`；③ 分析部经理 `ana-m`，下辖 n 个分析组长 `ana-tl{n}`，组长下辖分析工程师 `ana-e`；④ 任何角色只与直属上下级通信，跨部门经 director 转派。
- **2026-10-21（用户裁定）**：① PRD 类别**复活**，落盘路径由 `docs/prd/` 改为 `docs/pd/prd/`（`docs/prd/` 作废）；② 新增 `docs/dev/arch/`——**软件设计架构**落点，dev-m 落盘、director 评审，命名 `{seq}-arch-{slug}-{YYMMDD-HHMM}--v{N}.md`。
- **2026-10-21（用户裁定·第二次）**：目录结构重排 —— ① 收件箱移到项目根 `inbox/<director|dev-m|ana-m>/`，不再进 `docs/`（`.gitignore` 用 `inbox/*/`）；② SPEC 由 `docs/spec/` 改为 `docs/pd/spec/`；③ ticket 由 `docs/tickets/` 改为 `docs/dev/tickets/`；④ 新增 `docs/human/human-arch/`、`docs/human/human-plan/`（均 director 落盘），`docs/dev/arch/` 作废。
- **2026-10-21（用户裁定·第三次）**：序号按产物类别拆分 —— PRD `{prd-seq}`、调研报告 `{research-seq}`、人类架构 `{human-arch-seq}`、人类计划 `{human-plan-seq}`，各自独立、类别内自累计；SPEC 与 ticket 仍共用 `{spec-seq}`；收件箱消息保留 `{seq}` 消息流水号。
- **2026-10-21（用户裁定·第四次）**：目录由 **director 初始化时检查并补齐**（新增 §3.1，幂等命令 + 完成判据 `ALL_PASS`）；ana-m / dev-m 不自建产物目录，缺失时回报 director。
- **2026-10-22（用户裁定·第五次）**：目录重命名 —— ① 调研报告目录 `docs/research/` 改为 `docs/analyst/`（仍属 ana-m）；② `docs/user/` 改为 `docs/human/`，其下 `user-arch/`→`human-arch/`、`user-plan/`→`human-plan/`（仍属 director）；③ 机检脚本 `check-pda-doc-paths.sh` 改名为 `check-dmt-doc-paths.sh`，内部 `PDA_SKILLS_DIR`→`DMT_SKILLS_DIR`、负样本 `docs/not-a-pda-output-dir/`→`docs/not-a-dmt-output-dir/`。
- **2026-10-22（用户裁定·第六次）**：收件箱协议简化 —— 收件方收到门铃提醒后读入 context window、**不发送回执**、读毕即删；送达以门铃成功投递为准，不再以回执判定；并明确一个 herdr tab 只含一个 pane（一个 agent）。
- **2026-10-22（用户裁定·第七次）**：**组长 tab 实例生命周期补齐收尾——「用完即关」**（此前只定义了「按需生成」这一半）。① **责任人**＝创建者本人（`dev-m` 关 `dev-tl{n}`、`ana-m` 关 `ana-tl{n}`），非创建者不得代关（对齐 herdr「不关非自己创建的 tab」）；② **时机**＝本批全部收口且创建者确认无下一批可派，**批内可复用、批间不保留**（若采「空闲超时自动关」型判据，必须先定义观测窗口与运行时长）；③ **关闭前置三件事**（回报入账、worktree 已 remove、收件箱无该组长未读）**顺序固定、缺一不可**；④ **命令** `herdr tab close <tab_id>`（`tab_id` 由当次 `herdr tab list` 按 label 解析），**成功判据**＝该 label 从 `tab list` 消失；⑤ **禁止先关后收** —— 关闭 tab 即终止该 agent 会话、context 不可恢复、动作不可逆；⑥ 部门经理 `dev-m` / `ana-m` 的 tab **常驻**，不随批次关闭（在本裁定范围外）。同步改动：`dev-m` / `ana-m` 技能各新增「收回组长实例（用完即关）」步骤，`README.md` 口径改为「按需生成、用完即关」，机检脚本新增两条静态断言。
- **2026-10-22（用户裁定·第八次）**：**组长层并行口径统一并加可测判据**。此前 `dev-tl` 写「**可**多票并行」、`ana-tl` 写「**必须并行**」，两层口径不一致，且最该有资源约束的组长层反而没写。① `dev-tl` / `ana-tl` 第 3 步统一为同一句式：**无依赖单元必须并行、尽量铺满**（同一回复内并发派发，dynamic workflow `runs.all` 首选，其次多个 subagents；派完立即结束本轮、不轮询）；**只有**依赖 / 共享文件 / 共享构建目标 / 顺序验收关系才串行，**串行须在回报里写明理由**；并发度受资源约束（开发组长：**同一 worktree 内禁并发构建**；分析组长：同一输入文件 / 同一设备 / 同一 REA 会话不得并发）。② `team.md` §5.2 新增**组长层可测判据**「无依赖单元 ≥2 ⇒ 必须并发派发，仅在回报中给出串行理由时可例外」。③ 机检新增三条静态断言。
- **2026-10-22（机检修正，非用户裁定）**：修正 §7 负样本断言的自相矛盾 —— 原脚本用 `grep 'docs/not-a-dmt-output-dir/' "$CONTRACT"` 判「坏路径是否被误判为存在」，而 §8 变更记录（第五次）**必须**留痕该负样本名 ⇒ 断言恒红（改动前的 `HEAD` 版本同样 `HAS_FAIL`，为**既有缺陷**）。现改为**只查 §3「落盘唯一位置」登记表**（限定表格行 `grep -E '^\|'`），历史留痕不再误伤，判据牙仍在（把坏路径写进登记表即报 FAIL）。
