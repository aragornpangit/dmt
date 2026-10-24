# dmt 团队契约

> 本文件是 **dmt 的唯一团队定义**：组织、成员、通信、文件命名、工作流程、目录职责与纪律；五个角色技能 `dmt-director` / `dmt-dm` / `dmt-am` / `dmt-dtl` / `dmt-atl`（运行 id 为 `director` / `devm` / `anam` / `devtl{n}` / `anatl{n}`）只做落地说明，**冲突时以本文件为准**。
> 团队成员运行在终端多智能体复用器 Herdr 中；会话与 pane 随重启变化，本文件不登记 pane id。

## 0. 仓库结构

本仓根目录按角色分文件夹，一个角色一个目录；团队契约、仓库说明与机检脚本随团队领导放在 `dmt-director/` 内，不散落根目录：

```
dmt/
├── dmt-director/                         # 总监兼产品经理（技能 dmt-director）
│   ├── SKILL.md                          # 角色技能
│   ├── team.md                           # 团队契约（本文件，唯一权威）
│   ├── README.md                         # 仓库说明与安装
│   └── scripts/check-dmt-doc-paths.sh    # 产物落盘路径机检
├── dmt-dm/SKILL.md                        # 开发经理
├── dmt-am/SKILL.md                        # 分析经理
├── dmt-dtl/SKILL.md                       # 开发队长（devtl{n}）
└── dmt-atl/SKILL.md                       # 分析队长（anatl{n}）
```

## 1. 团队定义

### 1.1 组织与成员

**四层层级**：`director`（总监）→ 部门经理（`devm` / `anam`）→ 队长（`devtl{n}` / `anatl{n}`）→ 工程师（`dev-e` / `ana-e`）。共五个角色技能，层级严格为 4 层。

```
director            总监（团队领导 + 产品经理，label director）
├── devm               开发经理（label devm）
│   ├── devtl1          开发队长（pane label devtl1，在 devm 的 tab 内）
│   │   ├── dev-e       开发工程师（子代理，不占 pane）
│   │   └── dev-e ...
│   ├── devtl2 ...
│   └── devtl{n}
└── anam               分析经理（label anam）
    ├── anatl1          分析队长（pane label anatl1，在 anam 的 tab 内）
    │   ├── ana-e       分析工程师（子代理，不占 pane）
    │   └── ana-e ...
    └── anatl{n}
```

| 角色 | 全称 | 技能名 | 运行 id（pane label） | 直属上级 | 直属下级 | 职责 |
|---|---|---|---|---|---|---|
| 总监（团队领导兼产品经理） | TeamLeader + ProductManager | `dmt-director` | `director` | 用户 | `devm`、`anam` | 唯一用户入口；接需求、出验收标准、落笔 PRD 与 SPEC、评审调研报告与 ticket 代码、跨部门裁决 |
| 开发经理 | DevelopManager | `dmt-dm` | `devm` | `director` | `devtl{n}` | 由 SPEC 拆 ticket、按需生成并收回开发队长、验收整合、director 评审通过后 push |
| 分析经理 | AnalystManager | `dmt-am` | `anam` | `director` | `anatl{n}` | 接调研诉求、按需生成并收回分析队长、收口调研报告 |
| 开发队长 | DevelopLeader | `dmt-dtl` | `devtl{n}` | `devm` | `dev-e`（子代理） | 建 worktree、并发派开发工程师、收 diff 做实施层初检、回报 devm |
| 分析队长 | AnalystLeader | `dmt-atl` | `anatl{n}` | `anam` | `ana-e`（子代理） | 拆子问题、派分析工程师并行取证、复核一手出处、汇总回报 anam |

**三层命名（不得混写）**：① **技能名** `dmt-dm` —— 技能注册表、安装目录与 `/dmt-dm` 命令用；② **运行 id** `devm` —— pane label、收件箱目录、方向码与实例号用；③ **称呼** 开发经理 —— 正文、汇报、日志用。例：命令写 `/dmt-dtl`，路径写 `inbox/devtl1/`，正文写「开发队长1 回报：…」。

| 技能名 | 运行 id | 称呼 | 实例称呼 |
|---|---|---|---|
| `dmt-director` | `director` | 总监 | — |
| `dmt-dm` | `devm` | 开发经理 | — |
| `dmt-am` | `anam` | 分析经理 | — |
| `dmt-dtl` | `devtl{n}` | 开发队长 | 开发队长1、开发队长2 … |
| `dmt-atl` | `anatl{n}` | 分析队长 | 分析队长1、分析队长2 … |
| — | `dev-e` | 开发工程师 | 按序号，如「工程师3」 |
| — | `ana-e` | 分析工程师 | 按序号，如「工程师3」 |

**单线指挥（硬约束，任何角色不得越级或横向直连）：**

1. `director` **只**直接指挥 `devm` 与 `anam`；**不得**越级给 `devtl{n}` / `anatl{n}` / 工程师派活或收活。
2. `devm` **只**直接指挥 `devtl{n}`；**不得**直接给 `dev-e` 派活，也不得直接收 dev-e 的回报。
3. `anam` **只**直接指挥 `anatl{n}`；**不得**直接给 `ana-e` 派活，也不得直接收 ana-e 的回报。
4. 队长**只**向本部门经理汇报；`devtl{n}` 与 `anatl{n}` 之间、devm 与 anam 之间**均不直连**，跨部门事项经 `director` 转派。
5. 工程师`dev-e` / `ana-e` **只**向派生他的队长汇报，**不装独立技能**、**不占 pane**、**不走跨 pane 通信**（纪律内嵌在队长的派发 prompt 中）。

### 1.2 运行环境与 pane 生命周期

**身份＝pane label，不是位置、不是 tab。** 每个角色占一个 **pane**，pane label 与角色/实例名同名（`director` / `devm` / `anam` / `devtl{n}` / `anatl{n}`），在同一 workspace 内**唯一**。

- **tab 只是视觉分组**：`director` / `devm` / `anam` 各占一个 tab，tab label 与本人 pane label 同名；**队长不建 tab**，它的 pane 开在**本部门经理的 tab 内**（`devtl{n}` 在 `devm` 的 tab、`anatl{n}` 在 `anam` 的 tab）。
- **识别伙伴一律按 pane label**（`herdr pane list` 过滤 `label`），**不按 tab 内位置、不按 pane id 记忆**：pane id 随重启变化，pane 顺序随 `pane swap` / `pane move` 变化（实测交换后 `pane list` 顺序立即翻转），**只有 label 稳定**。
- **工程师仍是子代理**：`dev-e` / `ana-e` 不占 pane、不装技能、不走跨 pane 通信。
- **团队启动顺序**：用户先备好 `director` tab 并在其中启动 harness；**director 负责创建 `devm`、`anam` 两个 tab，并给各自的 root pane 打上同名 label**，再请用户在这两个 tab 内启动 harness。
- **队长按需生成、用完即关**：经理用 `pane split` 在**自己的 tab 内**开队长 pane 并打 label，编号自 1 单调递增、**已关闭编号不复用**；关闭规则见本节末「队长实例的关闭（用完即关）」。
- **容量**：每加一个队长 pane，经理自己的 pane 宽度减半（118 列终端下 2 个 pane 各 59 列、3 个约 39 列）。同一 tab 内**建议不超过 2 个队长**，更多时分批，或临时 `herdr pane zoom` 放大单个 pane。

```bash
# 按 pane label 解析（label 文字为准，不抄历史 pane id）
HERDR_ENV=1 herdr pane list --workspace "$HERDR_WORKSPACE_ID" \
  | jq -r --arg l "<角色名>" '.result.panes[] | select(.label==$l) | .pane_id'
```

若目标 label 不存在：**停下问用户**，不要猜测 pane id、不要对不存在的会话反复重试。
**迁移兜底**（仅当 label 缺失）：存在同名 tab 且该 tab 只有一个 pane 时，用该 pane；否则仍须停下问用户。

**身份自愈**（每个角色启动后第一件事）：`herdr pane get "$HERDR_PANE_ID"` 读到的 label 与角色名不符（含为空）时，立即 `herdr pane rename "$HERDR_PANE_ID" <角色名>`。队长**不得**用 `herdr tab list` 认自己 —— 它的 tab label 是上级的。

创建 pane：

```bash
# ① 部门经理 tab（director 建）：建完立刻给 root pane 打同名 label
tab_json=$(HERDR_ENV=1 herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label devm)
pane=$(echo "$tab_json" | jq -r '.result.root_pane.pane_id')
HERDR_ENV=1 herdr pane rename "$pane" devm

# ② 队长 pane（经理建）：追加到自己 tab 的右侧，不抢焦点、不建 tab
pane=$(HERDR_ENV=1 herdr pane split "$HERDR_PANE_ID" --direction right --cwd "$PWD" --no-focus \
  | jq -r '.result.pane.pane_id')
HERDR_ENV=1 herdr pane rename "$pane" devtl1
```

**让队长 pane 进入角色**（由创建者代启动，不请用户操作）：

```bash
HERDR_ENV=1 herdr pane send-text "$pane" 'codebuddy --permission-mode auto'
HERDR_ENV=1 herdr pane send-keys "$pane" enter
# 等就绪：--source visible 避免命中 scrollback 旧行
HERDR_ENV=1 herdr pane wait-output "$pane" --source visible --match 'auto mode on' --timeout 60000
```

就绪后由创建者投递首条任务（角色名、技能名、直属上级 label、任务文件路径），并 `pane read` 核验**输入框已清空**才算送达（`enter` 常被吞，补发即可）。

**投递首条任务之前，必须先切好权限模式（仅限用户手动启动的会话）。** 顺序不可颠倒：

1. harness 启动后、**发第一条消息前**，按 `shift+Tab` 切到 `auto mode`；
2. 读一次面板底部，**确认出现 `auto mode on`**；
3. 再投递首条任务。

**为什么必须在第一条消息之前**：会话一旦开始，权限模式即锁定，之后切换会报 `Mode cannot be changed after the conversation starts`。事后补救只能 `/clear` 重开，而那会丢掉正在运行的工程师子代理与已产生的上下文。

> 注意区分两个东西：`/agent-mode`（PTC / 普通模式）在会话启动后不可改，与本节无关；本节说的是 `shift+Tab` 循环的**权限模式**。两者互不影响，PTC 会话同样可以开 `auto mode`。

**遗漏的代价**：队长会在 `High risk operation detected - requires confirmation every time` 这类弹窗上停住等人，而这类弹窗里往往只是 `cmake` / `ctest` 这类常规构建命令。

> **由创建者代启动的队长 pane 不走这条流程**：启动命令里已经带了 `--permission-mode auto`，不存在"会话开始后锁死"的窗口期，**不要**再去按 `shift+Tab`（按了反而会切走）。

#### 队长实例的关闭（用完即关）

只有队长是「**按需实例**」；`devm` / `anam` 自己的 pane 与 tab **常驻**，不随批次关闭。

- **责任人**：**创建者本人** —— `devm` 关 `devtl{n}`、`anam` 关 `anatl{n}`。herdr 的安全规则是「不关闭非自己创建的 pane/tab」，故 director 与其它角色**不得代关**。
- **时机**：该队长**本批任务全部收口**，且创建者**确认无下一批可派**之后。**同一批内可复用**（同批多票/多题仍可分给同一队长，不必每票新建），**跨批不保留** —— 批结束即关；下一批用新编号新建。
- **关闭前置三件事（顺序固定，缺一不可）**：① 该队长的回报（含逐条判据读数 / 一手出处）已并入票面或报告；② 该队长名下 worktree（如有）已 `git worktree remove`，无遗留工作区；③ `inbox/<创建者>/` 中无该队长的未读消息。
- **命令与成功判据**：

```bash
# 1) 按 label 解析出当次 pane（禁止抄历史 id）
tl=$(HERDR_ENV=1 herdr pane list --workspace "$HERDR_WORKSPACE_ID" \
  | jq -r '.result.panes[] | select(.label=="devtl1") | .pane_id')
# 2) 关闭；成功判据＝该 label 已从 pane list 消失
HERDR_ENV=1 herdr pane close "$tl"
```

- **禁止 `herdr tab close`**：队长 pane 与经理同 tab，关 tab 会把经理自己一起杀掉（连带本批其它队长）。只许关 pane。
- **风险条款**：关闭 pane 会终止其中 agent 的会话，**context 不可恢复、动作不可逆** ⇒ **禁止先关后收**；关闭必须发生在回报入账与 worktree 回收**之后**。
- **编号**：已关闭编号**不复用**（§2 规则 5）；关闭后向用户一句话报告（关了哪个实例、原因）。

### 1.3 通信方式（收件箱文件 + herdr 门铃）

**正文一律走文件，herdr 只发门铃一句。** 派单、回报、评审结论、裁决请求、缺陷退回，全部先落成收件方收件箱里的一份文件，再用 herdr 敲一句「你有新消息 <文件名>」。**消息里不贴长正文、不贴日志、不贴 diff。**

**允许的直接通信只有上下级这一条线**（其余一律经上级转派）：

| 发送方 | 收件方 | 方向码 |
|---|---|---|
| `director` | `devm` / `anam` | `director2devm` / `director2anam` |
| `devm` / `anam` | `director` | `devm2director` / `anam2director` |
| `devm` | `devtl{n}` | `devm2devtl{n}` |
| `devtl{n}` | `devm` | `devtl{n}2devm` |
| `anam` | `anatl{n}` | `anam2anatl{n}` |
| `anatl{n}` | `anam` | `anatl{n}2anam` |

**第一步 定位伙伴**（每次重跑，禁止复用上一次的 pane id）：`herdr pane list` 按 **pane label** 取**当前** pane id（label 与角色名同名、全 workspace 唯一）。label 不在列表里 ⇒ **停下问用户**，不猜 pane id、不按 tab 内位置兜底。

**第二步 写收件箱文件**

- 路径：**项目根目录**下的 `inbox/<收件角色>/{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`（`<收件角色>` ∈ `director` / `devm` / `anam` / `devtl{n}` / `anatl{n}`；**不在 `docs/` 下**；目录不存在先 `mkdir -p`）
- `{seq}`：自累计流水号，001 起，一条消息一个号（与 SPEC 的 `spec-seq` 无关）
- `{方向}`：见上表；跨部门事项由 director 转派，不出现 `devm2anam` / `devtl2anatl` 之类
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
5. **任何超过 10 分钟的操作（合并 / 构建 / 真机长跑 / 批量验证），开工前扫一次收件箱，收工后再扫一次。** 长操作期间不回看收件箱，是**已知会漏消息**的行为，不是意外。
   - **Why**：2026-10-23 devm 在 16:00–16:45 做 T6 合并验证（分支跑 ctest → 手工合成冲突 → 合并后再跑 ctest），期间没有回看收件箱，director 的一封裁决信（037）与 TL1 的三封缺口报告（042/043/044）在里面躺了 2.5 小时。**信没丢、门铃也送到了，是收件方在干活时看不见门铃。**
   - **How to apply**：把「扫收件箱」当成操作的**前后置动作**，不是独立任务；扫的时候只看 `ls inbox/<自己>/`，有文件就当场处理，**不要攒着**。攒着的后果是：你基于过时的状态继续决策，而对方以为你已经知道了。

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
5. **队长编号**：`devtl{n}` / `anatl{n}` 的 `{n}` 与 **pane label**、收件箱目录（`inbox/devtl{n}`、`inbox/anatl{n}`）**三处同名**，自 1 递增，已关闭编号不复用。
6. 历史笔误留痕：需求原文的 `ver{seq}`、`YYMMDD-v{seq}` 写法**已作废**，一律以本表为准，历史文件不改名。

## 3. 目录职责

**落盘唯一位置（含负责人与对齐要求）**：

| 唯一目录 | 负责人 | 产物 | 对齐要求 |
|---|---|---|---|
| `docs/pd/prd/` | director | 产品需求文档（PRD） | `{prd-seq}` 独立编号 |
| `docs/pd/spec/` | director | 产品规格书（SPEC，含验收标准） | 与 ticket 共用 `spec-seq` |
| `docs/dev/tickets/` | devm（`dev-e` 证据经队长回报、由 devm 归档） | 开发工单（ticket） | 与 SPEC 共用 `spec-seq` |
| `docs/analyst/` | anam | 市场调研与竞品逆向报告 | 无 |
| `docs/human/human-arch/` | director | 人类架构文档 | 无 |
| `docs/human/human-plan/` | director | 人类计划文档 | 无 |
| `docs/team.md` | director | 团队契约（本文件） | 无 |
| `docs/handoff/` | director / devm | 交接说明（`{director,devm}-{slug}-{YYMMDD-HHMM}-v{N}.md`，**仅在用户要求时写**） | 无 |
| `inbox/<收件角色>/` | 发送方写、收件方读后删 | 角色间消息（运行时通道，**不入库**，**在项目根目录、不在 `docs/` 下**） | 方向与 `{seq}` 见 §1.3 |

1. 上述路径是**唯一允许位置**，不得写到 `docs/pd/`（除 `prd/`、`spec/`）、`docs/dev/`（除 `tickets/`）、`docs/human/`（除 `human-arch/`、`human-plan/`）、`docs/test/` 或其它任何位置；收件箱只在项目根 `inbox/` 下，不进 `docs/`；不得自建新的文档目录。
2. 各部门的产物目录**互不越界**：只读引用可以，移动/改名不可以。
3. **队长不写 `docs/`**：`devtl{n}` / `anatl{n}` 的回报与证据只落 `inbox/<上级>/`（或由上级并入票面/报告），`docs/` 内的产物一律由经理落笔。
4. 旧体系（`docs/pd/` 除 `prd/`、`spec/` 外，`docs/dev/` 除 `tickets/` 外，`docs/test/`）只保留历史，**不再接收新产物**；历史文件不改名、不搬迁（历史事实留痕）。**现行口径（2026-10-21 用户裁定·第二次修订）**：① PRD 落 `docs/pd/prd/`；② SPEC 由 `docs/spec/` 改为 `docs/pd/spec/`；③ ticket 由 `docs/tickets/` 改为 `docs/dev/tickets/`；④ 新增 `docs/human/human-arch/`（人类架构）与 `docs/human/human-plan/`（人类计划），均由 director 落盘；⑤ `docs/dev/arch/` **作废**，不再单独设架构目录；⑥ 收件箱由 `docs/<角色>/inbox/` 移到项目根 `inbox/<角色>/`。
5. **目录初始化由 director 负责**：director 接手一个项目时先检查再补齐（见 §3.1），产物目录不由 anam / devm 自建。
6. 机检口径：§7 的脚本只校验「六个产物目录与根 `inbox/` 存在、五个技能各自指向自己的目录、契约登记齐全、负样本被拒绝」；它**不校验单个文件的落盘路径**，新产物靠本表与评审把关。

### 3.1 初始化（director 负责，幂等）

director 接手项目的**第一件事**：检查目录，缺什么建什么。可重复执行，已存在则不动：

```bash
cd <项目根>
mkdir -p docs/{pd/{prd,spec},dev/tickets,analyst,human/{human-arch,human-plan}} inbox/{director,devm,anam}
grep -qxF 'inbox/*/' .gitignore 2>/dev/null || echo 'inbox/*/' >> .gitignore   # 收件箱不入库
bash dmt-director/scripts/check-dmt-doc-paths.sh .
```

- **完成判据**：机检输出 `ALL_PASS`。缺目录时脚本报 `FAIL 目录缺失`，director 补齐后重跑。
- **只建目录、不建产物**：空目录不预置占位文件，避免被误认为已有交付物。
- **anam / devm 不自建产物目录**：发现自己的目标目录缺失，回报 director（收件箱目录属运行时通道，可按需 `mkdir -p` 兜底；`inbox/devtl{n}`、`inbox/anatl{n}` 由发送方按需建）。
- 契约文件 `docs/team.md` 与技能安装不在本步骤内（安装见 `README.md`）。

## 4. 工作流程

1. **anam 调研**：anam 按需生成 `anatl{n}`，由队长派 `ana-e` 取证；anam 复核并收口成调研报告，**经 director 评审后落盘** `docs/analyst/`；**本批收口且确认无下一批可派后，anam 关闭该批 `anatl{n}`（§1.2）**。
2. **director 出 PRD 与 SPEC**：director 基于调研报告与用户交流，输出 PRD 与 SPEC（含验收标准），**经 devm 评审后落盘** `docs/pd/prd/`、`docs/pd/spec/`。
3. **devm 拆 ticket**：devm 基于 SPEC，用 `/to-tickets` 拆成与 SPEC 对应的开发工单，落盘 `docs/dev/tickets/`；devm 负责汇总、评审、整合本部门结果。
4. **devm 生成开发队长并派票**：devm 按批次建 `devtl{n}`，把票面（路径、票基、Files 边界、验收判据、`timeoutMs`、回报格式）交给队长；队长建 worktree、派 `dev-e` 实施并做实施层初检，回报 devm。
5. **devm 验收整合**：核 diff 与初检读数 → 构建与测试 → 合并（冲突逐 hunk 按意图消解）→ 不合格打回原队长 → 逐票更新状态；**本批全部收口且确认无下一批可派后，关闭该批 `devtl{n}`（§1.2）**。
6. **交付 director 评审**：devm 把代码提交给 director **部门**评审；一个 ticket 对应一个 SPEC。链路：director 亲自对照 SPEC 验收标准核验 → director 给结论 → **director 通知 devm** → devm 才执行 `git push`。
7. **并行**：对无依赖关系的任务，各角色**只在直属下级之间并行**（director 在 dmt-dm/anam 之间；devm 在多个 `devtl{n}` 之间；anam 在多个 `anatl{n}` 之间；队长在多个工程师之间），优先级：dynamic workflow > 多个 subagents 并行；**不得为省事而串行，也不得越级派发**。

### 4.1 PRD 模板（director）

`Problem Statement` / `目标用户与场景` / `方案概述` / `用户故事（可验收）` / `验收标准` / `范围外` / `开放问题`。

### 4.2 SPEC 模板（director）

`Problem Statement` / `Solution` / `User Stories` / `验收标准（逐条可测）` / `实现决策` / `测试接缝` / `Out of Scope` / `变更记录`。
SPEC 必须自包含：每条 User Story 都能转成 ticket 与用例。

## 5. 纪律

### 5.1 Git

1. **禁止 `git add -A` / `git add .`**，提交一律显式列文件路径（优先 `git commit -m "..." -- <path>`，绕过索引），且 `add` 与 `commit` 之间不插入其它动作（避免索引被并发写者扫入）。
2. 工程师（`dev-e`）**只在各自 worktree 内** `git add` + `git commit`，**不得 `git push`**、**不得 merge 主干**；**只有 devm 能 `git push`**，且必须等 director 评审通过并通知后。
3. 提交前先跑 `/code-review`；提交后 `git diff --cached --name-only` 复核暂存区。
4. **同一 worktree 单一写者（含队长本人）**：一个 worktree 从开工到收工，**只有被派到该票的那一个 agent 可以提交**。队长要提交票面 / 文档，**不得**在工程师正在施工的 worktree 里做——走主工作树或另开 worktree。**并发提交不会报错，只会把别人的改动扫进自己的提交**，事后靠 `git show --stat` 才能发现，而那时已经进了历史。
   - **Why**：2026-10-23 devtl1 在 dev-e13 施工的同一 worktree 上并行提交了 4 个 docs commit，没有造成损失，但它自己指出「结果侥幸没事不代表流程对」。**这条规则此前只存在于 director 的记忆里、没写进本文件**——没写下来的规则不算规则。
   - **How to apply**：队长提交前先 `git status` 看有没有别人的未提交改动；有则改用 `git commit -- <自己的路径>` 且**不先 `add`**；发现同 worktree 已有他人改动，停下问 devm，不要自行判断「应该没事」。
5. **合并冲突时「取 main」（`checkout --ours`）只在 main 是分支的严格超集时成立。** 判断办法不是看谁改得多，是**逐项比对「两侧各有哪些行是对方没有的」**；只要有一项只有分支有，就必须手工合成。
   - **Why**：T4 那次 main 是分支票面的严格超集，`--ours` 安全；T6 那次不是——main 有「不劣+最简」「21% vs 85% 口径隔离」，分支有「实测读数 + 2×2 六张表 + 配对 σ 修正」，**取任何一侧都会丢东西**。同一个动作在两次合并里安全性相反，**说明「上次就是这么干的」不构成理由**。
   - **How to apply**：合并前跑一次两侧差异清单（`git diff --stat main...branch` 逐文件看，或直接 `git merge-tree` 预判）；合成后**与分支版本再 diff 一次**，确认差异只剩「main 独有的行」与「人工合成的那几行」，其余逐字节相同。

### 5.2 并行子代理

1. 派发前先做**依赖分析**：只有无依赖任务可并行；共享文件、共享构建目标、有顺序验收关系的任务必须串行。
2. **队长层可测判据**：无依赖单元（票 / 取证单元）**≥2 ⇒ 必须并发派发**；**仅在回报中给出串行理由时可例外**（理由限：依赖 / 共享文件 / 共享构建目标 / 顺序验收关系）。手段优先级：dynamic workflow `runs.all` > 多个 subagents 并行。
3. 每份派发 prompt 必须显式写清：输入（产物路径）、边界、期望产物、回报要求、`timeoutMs`（长链路不短于 45 min）。
4. 子代理一律后台/异步派发，**派完立即结束本轮**，由完成通知唤醒再验收；不做轮询。
5. 开发工程师**每人一个 git worktree**，只在 worktree 内编辑与提交；主工作树只读。
6. 所有子代理结果由**派生他的那一级**复核证据后，才能写入权威文档或进入下一步；经理不直接采信工程师的原始回报。

### 5.3 评审门禁

| 门禁 | 提交方 | 评审方 | 通过条件 |
|---|---|---|---|
| 调研报告 | anam | director | director 认可结论与证据来源，落盘 `docs/analyst/` |
| PRD 与 SPEC | director | devm | devm 认可可实施性与切片粒度，落盘 `docs/pd/prd/`、`docs/pd/spec/` |
| 实施初检 | devtl | devm | 票面判据逐条有读数、门红已分类、Files 边界未越界 |
| 队长实例关闭 | devm / anam（创建者） | 创建者本人自检 | 回报已入账、worktree 已 `git worktree remove`、收件箱无该队长未读；关闭后 `herdr pane list` 无该 label |
| 人类架构 / 人类计划 | director | 用户 | 结构与真实代码一致、不混写未来态，落盘 `docs/human/human-arch/`、`docs/human/human-plan/` |
| ticket 代码 | devm | director | 逐条对照 SPEC 验收标准全部通过；director 通知 devm 后方可 push |
| 跨部门分歧 | devm / anam | director | director 裁决并回结论 |

## 6. 表达（全角色）

读者是**稍微懂一点软件工程但没有参与本项目的人**（含用户）：只说白话，先说结论再说证据，突出重点，术语翻成人话。

## 7. 机检

```bash
bash dmt-director/scripts/check-dmt-doc-paths.sh
```

检查**七项**：① 六个产物目录存在（`docs/pd/prd`、`docs/pd/spec`、`docs/dev/tickets`、`docs/analyst`、`docs/human/human-arch`、`docs/human/human-plan`）＋ 根目录 `inbox/` 存在；② 五个技能（`dmt-director` / `dmt-dm` / `dmt-am` / `dmt-dtl` / `dmt-atl`）各自指向自己的唯一目录；③ **队长实例关闭动作已登记**（契约与 `dmt-dm` / `dmt-am` 技能含 `herdr pane close`，契约含「禁止先关后收」与「只许关 pane」）；④ **身份识别已登记**（契约与五个技能含 `pane label`，契约含「不按 tab 内位置」）；⑤ **队长层并行判据已登记**（`dmt-dtl` / `dmt-atl` 含「必须并行」，契约含「≥2 ⇒ 必须并发派发」）；⑥ 本契约登记齐全；⑦ 负样本能被正确拒绝（**只看 §3 落盘登记表**，§8 变更记录里的历史留痕不算登记）。**改路径规范、pane 生命周期或并行口径后必须重跑**。

## 8. 变更记录

- **2026-10-24（用户裁定·第十次：身份改 pane label ＋ 队长 pane 进经理 tab）**：① **回退此前的「自营 / 分包」双路径** —— 经理层只保留**在本 tab 内开队长 pane**一条路（队长再开工程师子代理），工程师永远只是队长的子代理，经理不直接派 dev-e；§4.0 整节删除，§1.1 规则 2/3/5、§4 工作流、§5.2、§5.3、机检 4b 同步回退。② **身份从「tab label + tab 内第一个 pane」改为「pane label」**：pane label 与角色/实例名同名、全 workspace 唯一；**不再依赖 pane 在 tab 内的位置**（实测 `pane swap` 后 `pane list` 顺序立即翻转，"第一个 pane"会静默指错人）。③ **队长 pane 开在经理自己的 tab 内**：`herdr pane split "$HERDR_PANE_ID" --direction right --no-focus` + `pane rename`，不建 tab；tab 退化为视觉分组。④ **队长 pane 由创建者代启动**：`pane send-text 'codebuddy --permission-mode auto'` + `pane send-keys enter`，就绪判据 `wait-output --source visible --match 'auto mode on'`；因此队长**不走** `shift+Tab` 切权限模式那套流程（那条只对用户手动启动的会话有效）。⑤ **关闭改 `herdr pane close`**，并**明令禁止 `herdr tab close`** —— 队长与经理同 tab，关 tab 会连带杀掉经理与本批其它队长。⑥ **身份自愈**：每个角色启动后核对 `$HERDR_PANE_ID` 的 label，不符即 `pane rename`；队长不得用 `tab list` 认自己。⑦ 容量提示：同一 tab 建议 ≤2 个队长 pane，超出分批或用 `pane zoom`。同步改动：五个技能（`dmt-dm` / `dmt-am` / `dmt-dtl` / `dmt-atl` 与 `dmt-director`）、`README.md`、机检脚本。
- **2026-10-22（用户裁定·组织调整）**：项目定名 **dmt**，组织固定为**四层层级** `director → 部门经理 → 队长 → 工程师` —— ① 顶层 `director`（总监，兼产品经理），直属下级只有 `devm` 与 `anam`；② 开发经理 `devm`，下辖 n 个开发队长 `devtl{n}`（label 同名，由 devm 用 `herdr tab create --label` 按需生成），队长下辖开发工程师 `dev-e`；③ 分析经理 `anam`，下辖 n 个分析队长 `anatl{n}`，队长下辖分析工程师 `ana-e`；④ 任何角色只与直属上下级通信，跨部门经 director 转派。
- **2026-10-21（用户裁定）**：① PRD 类别**复活**，落盘路径由 `docs/prd/` 改为 `docs/pd/prd/`（`docs/prd/` 作废）；② 新增 `docs/dev/arch/`——**软件设计架构**落点，devm 落盘、director 评审，命名 `{seq}-arch-{slug}-{YYMMDD-HHMM}--v{N}.md`。
- **2026-10-21（用户裁定·第二次）**：目录结构重排 —— ① 收件箱移到项目根 `inbox/<director|devm|anam>/`，不再进 `docs/`（`.gitignore` 用 `inbox/*/`）；② SPEC 由 `docs/spec/` 改为 `docs/pd/spec/`；③ ticket 由 `docs/tickets/` 改为 `docs/dev/tickets/`；④ 新增 `docs/human/human-arch/`、`docs/human/human-plan/`（均 director 落盘），`docs/dev/arch/` 作废。
- **2026-10-21（用户裁定·第三次）**：序号按产物类别拆分 —— PRD `{prd-seq}`、调研报告 `{research-seq}`、人类架构 `{human-arch-seq}`、人类计划 `{human-plan-seq}`，各自独立、类别内自累计；SPEC 与 ticket 仍共用 `{spec-seq}`；收件箱消息保留 `{seq}` 消息流水号。
- **2026-10-21（用户裁定·第四次）**：目录由 **director 初始化时检查并补齐**（新增 §3.1，幂等命令 + 完成判据 `ALL_PASS`）；anam / devm 不自建产物目录，缺失时回报 director。
- **2026-10-22（用户裁定·第五次）**：目录重命名 —— ① 调研报告目录 `docs/research/` 改为 `docs/analyst/`（仍属 anam）；② `docs/user/` 改为 `docs/human/`，其下 `user-arch/`→`human-arch/`、`user-plan/`→`human-plan/`（仍属 director）；③ 机检脚本 `check-pda-doc-paths.sh` 改名为 `check-dmt-doc-paths.sh`，内部 `PDA_SKILLS_DIR`→`DMT_SKILLS_DIR`、负样本 `docs/not-a-pda-output-dir/`→`docs/not-a-dmt-output-dir/`。
- **2026-10-22（用户裁定·第六次）**：收件箱协议简化 —— 收件方收到门铃提醒后读入 context window、**不发送回执**、读毕即删；送达以门铃成功投递为准，不再以回执判定。
- **2026-10-22（用户裁定·第八次）**：**队长层并行口径统一并加可测判据**。此前 `devtl` 写「**可**多票并行」、`anatl` 写「**必须并行**」，两层口径不一致，且最该有资源约束的队长层反而没写。① `devtl` / `anatl` 第 3 步统一为同一句式：**无依赖单元必须并行、尽量铺满**（同一回复内并发派发，dynamic workflow `runs.all` 首选，其次多个 subagents；派完立即结束本轮、不轮询）；**只有**依赖 / 共享文件 / 共享构建目标 / 顺序验收关系才串行，**串行须在回报里写明理由**；并发度受资源约束（开发队长：**同一 worktree 内禁并发构建**；分析队长：同一输入文件 / 同一设备 / 同一 REA 会话不得并发）。② `team.md` §5.2 新增**队长层可测判据**「无依赖单元 ≥2 ⇒ 必须并发派发，仅在回报中给出串行理由时可例外」。③ 机检新增三条静态断言。
- **2026-10-22（机检修正，非用户裁定）**：修正 §7 负样本断言的自相矛盾 —— 原脚本用 `grep 'docs/not-a-dmt-output-dir/' "$CONTRACT"` 判「坏路径是否被误判为存在」，而 §8 变更记录（第五次）**必须**留痕该负样本名 ⇒ 断言恒红（改动前的 `HEAD` 版本同样 `HAS_FAIL`，为**既有缺陷**）。现改为**只查 §3「落盘唯一位置」登记表**（限定表格行 `grep -E '^\|'`），历史留痕不再误伤，判据牙仍在（把坏路径写进登记表即报 FAIL）。
