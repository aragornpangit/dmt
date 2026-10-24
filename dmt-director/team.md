# dmt 团队契约

> 本文件是 **dmt 的唯一团队定义**：组织、成员、通信、文件命名、工作流程、目录职责与纪律；六个角色技能 `dmt-director` / `dmt-pm` / `dmt-dm` / `dmt-am` / `dmt-dtl` / `dmt-atl`（运行 id 为 `director` / `pm` / `devm` / `anam` / `devtl{n}` / `anatl{n}`）只做落地说明，**冲突时以本文件为准**。
> 团队成员运行在终端多智能体复用器 Herdr 中；会话与 pane 随重启变化，本文件不登记 pane id。

## 0. 仓库结构

本仓根目录按角色分文件夹，一个角色一个目录；团队契约、仓库说明与机检脚本随团队领导放在 `dmt-director/` 内，不散落根目录：

```
dmt/
├── dmt-director/                         # 总监（技能 dmt-director）
│   ├── SKILL.md                          # 角色技能
│   ├── team.md                           # 团队契约（本文件，唯一权威）
│   ├── README.md                         # 仓库说明与安装
│   └── scripts/                          # 机检 / 文件占用 / 初始化 / 建团队 / 开队长 / 关队长 / 发消息 / 推送 / 安装
├── dmt-pm/SKILL.md                        # 产品部经理（pm）
├── dmt-dm/SKILL.md                        # 开发经理
├── dmt-am/SKILL.md                        # 分析经理
├── dmt-dtl/SKILL.md                       # 开发队长（devtl{n}）
└── dmt-atl/SKILL.md                       # 分析队长（anatl{n}）
```

## 1. 团队定义

### 1.1 组织与成员

**层级**：`director`（总监）→ 部门经理（`pm` / `devm` / `anam`）→ 队长（`devtl{n}` / `anatl{n}`，**仅开发与分析两部有**）→ 工程师（`dev-e` / `ana-e` / `pm-e`）。产品部只有三层 —— `pm` 直接派生 `pm-e` 子代理，不设队长。共六个角色技能。

```
director            总监（团队领导，label director）
├── pm                 产品部经理（label pm，pane 在 director 的 tab 内右侧）
│   └── pm-e           产品工程师（子代理，不占 pane）
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
| 总监（团队领导） | TeamLeader | `dmt-director` | `director` | 用户 | `pm`、`devm`、`anam` | 唯一用户入口；接需求与验收口径、分派、跨部门裁决、创建并维护经理层 pane/tab；**发布**（抽查后 push）与**装机**；不替代 pm 的文档评审与 devm 的代码评审 |
| 产品部经理 | ProductManager | `dmt-pm` | `pm` | `director` | `pm-e`（子代理） | 落笔 PRD、SPEC（[`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)）、开发工单（[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)）、人类架构与人类计划；**文档门禁**：PRD / SPEC / 工单的评审责任人；用子代理并行做产品取证与核对 |
| 开发经理 | DevelopManager | `dmt-dm` | `devm` | `director` | `dev-e`（≤4 自派）或 `devtl{n}`（>4） | 接单（pm 的 ticket）、排期派活、**代码门禁**：ticket 代码的评审责任人；整合开发部门交付物；**不拆票、不 push**（装机与 push 归 director） |
| 分析经理 | AnalystManager | `dmt-am` | `anam` | `director` | `ana-e`（≤4 自派）或 `anatl{n}`（>4） | 接调研诉求；按排队数选自派子代理或开队长 pane；复核出处、收口调研报告 |
| 开发队长 | DevelopLeader | `dmt-dtl` | `devtl{n}` | `devm` | `dev-e`（子代理） | 建 worktree、并发派开发工程师、收 diff 做实施层初检、回报 devm |
| 分析队长 | AnalystLeader | `dmt-atl` | `anatl{n}` | `anam` | `ana-e`（子代理） | 拆子问题、派分析工程师并行取证、复核一手出处、汇总回报 anam |

**三层命名（不得混写）**：① **技能名** `dmt-dm` —— 技能注册表、安装目录与 `/dmt-dm` 命令用；② **运行 id** `devm` —— pane label、收件箱目录、方向码与实例号用；③ **称呼** 开发经理 —— 正文、汇报、日志用。例：命令写 `/dmt-dtl`，路径写 `inbox/devtl1/`，正文写「开发队长1 回报：…」。

| 技能名 | 运行 id | 称呼 | 实例称呼 |
|---|---|---|---|
| `dmt-director` | `director` | 总监 | — |
| `dmt-pm` | `pm` | 产品部经理 | — |
| `dmt-dm` | `devm` | 开发经理 | — |
| `dmt-am` | `anam` | 分析经理 | — |
| `dmt-dtl` | `devtl{n}` | 开发队长 | 开发队长1、开发队长2 … |
| `dmt-atl` | `anatl{n}` | 分析队长 | 分析队长1、分析队长2 … |
| — | `dev-e` | 开发工程师 | 按序号，如「工程师3」 |
| — | `ana-e` | 分析工程师 | 按序号，如「工程师3」 |
| — | `pm-e` | 产品工程师 | 按序号，如「产品工程师2」 |

**单线指挥（硬约束，任何角色不得越级或横向直连）：**

1. `director` **只**直接指挥 `pm`、`devm`、`anam`；**不得**越级给 `devtl{n}` / `anatl{n}` / 工程师派活或收活。
2. `pm` **只**直接指挥 `pm-e`（子代理）与对 `director` 汇报；**不得**联系 `devm` / `anam` / 队长 / 任何工程师。
3. `devm` **只**直接指挥 `devtl{n}`，或**在排队任务 ≤4 时自己派生 `dev-e` 子代理**；`anam` 同理，阈值同为 **≤4**（`anatl{n}` / 自派 `ana-e`）。
4. 队长**只**向本部门经理汇报；`devtl{n}` 与 `anatl{n}` 之间、`pm` / `devm` / `anam` 三者之间**均不直连**，跨部门事项经 `director` 转派。
5. 工程师 `dev-e` / `ana-e` / `pm-e` **只**向派生他的经理或队长汇报，**不装独立技能**（技能写进派发 prompt，见 §1.4）、**不占 pane**、**不走跨 pane 通信**。

### 1.2 运行环境与 pane 生命周期

**身份＝pane label，不是位置、不是 tab。** 每个常驻角色占一个 **pane**（工程师是子代理、不占 pane），pane label 与角色/实例名同名（`director` / `pm` / `devm` / `anam` / `devtl{n}` / `anatl{n}`），在同一 workspace 内**唯一**。

- **tab 只是视觉分组**：`devm` / `anam` 各占一个 tab，tab label 与本人 pane label 同名；**`pm` 不占 tab**，它的 pane 开在 **`director` 的 tab 内、director pane 右侧**；**队长不建 tab**，它的 pane 开在**本部门经理的 tab 内**（`devtl{n}` 在 `devm` 的 tab、`anatl{n}` 在 `anam` 的 tab）。
- **识别伙伴一律按 pane label**（`herdr pane list` 过滤 `label`），**不按 tab 内位置、不按 pane id 记忆**：pane id 随重启变化，pane 顺序随 `pane swap` / `pane move` 变化（实测交换后 `pane list` 顺序立即翻转），**只有 label 稳定**。
- **工程师仍是子代理**：`dev-e` / `ana-e` / `pm-e` 不占 pane、不装技能（技能随派发 prompt 下发）、不走跨 pane 通信。
- **团队启动顺序（director 全自动拉起经理层）**：用户先备好 `director` tab 并在其中启动 harness；**director 第一件事是给自己正名 —— 先把 tab label 改成 `director`，再把 pane label 改成 `director`（顺序不可颠倒）**。随后 director **在右侧 split 出 `pm` pane**（`pane split <director pane> --direction right`，herdr 0.9.5 无 `pane create`，建 pane 的等价动作就是 split），再**创建 `devm`、`anam` 两个 tab 并给各自的 root pane 打上同名 label**。三个 pane 都由 director **代启动** harness（`pane send-text 'codebuddy --permission-mode auto'` + `send-keys enter`，就绪判据 `wait-output --source visible --match 'auto mode on'`），就绪后输入角色斜杠命令 **`/dmt-pm`**（pm pane）、**`/dmt-dm`**（devm pane）、**`/dmt-am`**（anam pane）装载角色技能。**不请用户手动在经理 tab 里启动 harness**；经理 pane 同样不走 `shift+Tab` 切权限模式那套流程（启动命令已带 `--permission-mode auto`）。
- **director 独占创建与维护**：`pm` / `devm` / `anam` 的 pane、tab 与 label 只由 director 建、只由 director 改；开工前巡检三个 label，缺失/漂移就 `pane rename` 或重建 pane 并重走「代启动 + 输技能命令」。下级**不得**自行新建或改名自己的 pane/tab。
- **director 的 tab 内有两个 pane**（director + pm）⇒ **禁止 `herdr tab close`**：关 tab 会连带杀掉 pm 与 director 自己；只许关 pane，且 director 不关 pm（pm 常驻）。
- **队长按排队数生成、用完即关**：经理**只在排队任务超过阈值时**用 `pane split` 在**自己的 tab 内**开队长 pane 并打 label（**未超阈值由经理自己派生工程师子代理，不开 pane**），编号自 1 单调递增、**已关闭编号不复用**；**阈值：`devm` >4、`anam` >4**；关闭规则见本节末「队长实例的关闭（用完即关）」。
- **容量**：队长 pane **竖排在右侧一列** ⇒ 每加一个队长，**右侧那一列的高度**被均分（经理 pane 宽度不变）。同一 tab 内**建议不超过 3 个队长**，更多时分批，或临时 `herdr pane zoom` 放大单个 pane。

```bash
# 按 pane label 解析（label 文字为准，不抄历史 pane id）
HERDR_ENV=1 herdr pane list --workspace "$HERDR_WORKSPACE_ID" \
  | jq -r --arg l "<角色名>" '.result.panes[] | select(.label==$l) | .pane_id'
```

若目标 label 不存在：**停下问用户**，不要猜测 pane id、不要对不存在的会话反复重试。
**迁移兜底**（仅当 label 缺失）：存在同名 tab 且该 tab 只有一个 pane 时，用该 pane；否则仍须停下问用户。**`pm` 例外**：它与 `director` 同 tab，该 tab 恒有两个 pane，**不得**用 tab 兜底，必须按 label 或请用户重建。

**身份自愈**（每个角色启动后第一件事）：`herdr pane get "$HERDR_PANE_ID"` 读到的 label 与角色名不符（含为空）时，立即 `herdr pane rename "$HERDR_PANE_ID" <角色名>`。队长与 `pm` **不得**用 `herdr tab list` 认自己 —— 它们的 tab label 都是上级的（队长在经理 tab、pm 在 director tab）。

**创建 pane（用脚本，不手敲）**：

```bash
# director：给自己正名（tab→pane）+ 建 pm/devm/anam + 代启动 + 输角色技能（幂等）
bash dmt-director/scripts/setup-team.sh

# 经理：开队长 pane（第 1 个在经理右侧、第 2 个起在上一队长下方）+ 代启动 + 输队长技能
bash dmt-director/scripts/spawn-leader.sh devm 1
bash dmt-director/scripts/spawn-leader.sh anam 1

# 经理：关队长 pane（收件箱有未读会拒绝；确需强关加 --force）
bash dmt-director/scripts/close-leader.sh devm 1
```

脚本内部仍是 `herdr pane split/rename/send-text/send-keys/wait-output`，并做 label 幂等检查与就绪等待；`--dry-run` 只打印命令、`--no-start` 只建 pane 不启动 harness。**布局只能在 split 时定对**：实测同一 tab 内 `pane move` 返回 `changed:false`／`reason:same_tab`，所以脚本固定「第 1 个 right、后续 down」。

**让队长 pane 进入角色**：由 `spawn-leader.sh` 一并完成（代启动 → 等 `auto mode on` → 输 `/dmt-dtl` 或 `/dmt-atl`）。就绪后由创建者投递首条任务（角色名、技能名、直属上级 label、任务文件路径），并用 `pane read` 核验输入框已清空。

**投递首条任务之前，必须先切好权限模式（仅限用户手动启动的会话）。** 顺序不可颠倒：

1. harness 启动后、**发第一条消息前**，按 `shift+Tab` 切到 `auto mode`；
2. 读一次面板底部，**确认出现 `auto mode on`**；
3. 再投递首条任务。

**为什么必须在第一条消息之前**：会话一旦开始，权限模式即锁定，之后切换会报 `Mode cannot be changed after the conversation starts`。事后补救只能 `/clear` 重开，而那会丢掉正在运行的工程师子代理与已产生的上下文。

> 注意区分两个东西：`/agent-mode`（PTC / 普通模式）在会话启动后不可改，与本节无关；本节说的是 `shift+Tab` 循环的**权限模式**。两者互不影响，PTC 会话同样可以开 `auto mode`。

**遗漏的代价**：队长会在 `High risk operation detected - requires confirmation every time` 这类弹窗上停住等人，而这类弹窗里往往只是 `cmake` / `ctest` 这类常规构建命令。

> **由创建者代启动的队长 pane 不走这条流程**：启动命令里已经带了 `--permission-mode auto`，不存在"会话开始后锁死"的窗口期，**不要**再去按 `shift+Tab`（按了反而会切走）。

#### 队长实例的关闭（用完即关）

只有队长是「**按需实例**」；`pm` / `devm` / `anam` 自己的 pane（`pm` 的 pane 在 director tab 内）**常驻**，不随批次关闭。

- **责任人**：**创建者本人** —— `devm` 关 `devtl{n}`、`anam` 关 `anatl{n}`。herdr 的安全规则是「不关闭非自己创建的 pane/tab」，故 director 与其它角色**不得代关**。
- **时机**：该队长**本批任务全部收口**，且创建者**确认无下一批可派**之后。**同一批内可复用**（同批多票/多题仍可分给同一队长，不必每票新建），**跨批不保留** —— 批结束即关；下一批用新编号新建。
- **关闭前置三件事（顺序固定，缺一不可）**：① 该队长的回报（含逐条判据读数 / 一手出处）已并入票面或报告；② 该队长名下 worktree（如有）已 `git worktree remove`，无遗留工作区；③ `inbox/<创建者>/` 中无该队长的未读消息。
- **命令与成功判据**：`bash dmt-director/scripts/close-leader.sh devm 1`（anam 换成 `anam`）。脚本按 label 解析 pane、检查收件箱是否为空（非空拒绝，需 `--force`），关闭后以 `herdr pane list` 中该 label 消失为成功。
- **禁止 `herdr tab close`**：队长 pane 与经理同 tab，关 tab 会把经理自己一起杀掉（连带本批其它队长）。只许关 pane。
- **风险条款**：关闭 pane 会终止其中 agent 的会话，**context 不可恢复、动作不可逆** ⇒ **禁止先关后收**；关闭必须发生在回报入账与 worktree 回收**之后**。
- **编号**：已关闭编号**不复用**（§2 规则 5）；关闭后向用户一句话报告（关了哪个实例、原因）。

### 1.3 通信方式（收件箱文件 + herdr 门铃）

**正文一律走文件，herdr 只发门铃一句。** 派单、回报、评审结论、裁决请求、缺陷退回，全部先落成收件方收件箱里的一份文件，再用 herdr 敲一句「你有新消息 <文件名>」。**消息里不贴长正文、不贴日志、不贴 diff。**

**允许的直接通信只有上下级这一条线**（其余一律经上级转派）：

| 发送方 | 收件方 | 方向码 |
|---|---|---|
| `director` | `pm` / `devm` / `anam` | `director2pm` / `director2devm` / `director2anam` |
| `pm` / `devm` / `anam` | `director` | `pm2director` / `devm2director` / `anam2director` |
| `devm` | `devtl{n}` | `devm2devtl{n}` |
| `devtl{n}` | `devm` | `devtl{n}2devm` |
| `anam` | `anatl{n}` | `anam2anatl{n}` |
| `anatl{n}` | `anam` | `anatl{n}2anam` |

**第一步 定位伙伴**（每次重跑，禁止复用上一次的 pane id）：`herdr pane list` 按 **pane label** 取**当前** pane id（label 与角色名同名、全 workspace 唯一）。label 不在列表里 ⇒ **停下问用户**，不猜 pane id、不按 tab 内位置兜底。

**第二步 写收件箱文件**

- 路径：**项目根目录**下的 `inbox/<收件角色>/{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`（`<收件角色>` ∈ `director` / `pm` / `devm` / `anam` / `devtl{n}` / `anatl{n}`；**不在 `docs/` 下**；目录不存在先 `mkdir -p`）
- `{seq}`：自累计流水号，001 起，一条消息一个号（与 SPEC 的 `spec-seq` 无关）
- `{方向}`：见上表；跨部门事项由 director 转派，不出现 `devm2anam` / `devtl2anatl` 之类
- `{slug}`：英文小写短横线，不超过 5 个词
- `{YYMMDDHHMM}`：落盘时刻，两位年 + 月 + 日 + 时 + 分，无分隔符（例 `2610201430`）
- 正文**自包含**：一句话摘要 / 权威文档路径 / 请求动作 / 期望产物 / 回报要求

**用脚本**：`bash dmt-director/scripts/send-msg.sh <收件角色> <自己> <slug> <正文文件>` —— 自动算 `{seq}`、时刻与方向码，写文件后按 label 发门铃（`agent prompt` 返回非 `agent_prompted` 时回退 `send-text` + `send-keys`；label 不存在时只写文件并告警）。

**第三步 发门铃**（按**对端 harness** 选通道，消息只发一句：文件名 + 目录）

| 对端 harness | 门铃 |
|---|---|
| **codebuddy / pi-coding-agent / codex / opencode2 / opencode** | 优先 `HERDR_ENV=1 herdr agent prompt <pane> '你有新消息 {文件名}，在 inbox/<收件角色>/'`（**一次调用自带 Enter 提交**，返回 `"type":"agent_prompted"` 即送达；**codebuddy 面板同样适用**，2026-10-24 实测） |
| 回退（**仅当**对端是其它 harness，或 `agent prompt` 返回非 `agent_prompted`） | `HERDR_ENV=1 herdr pane send-text <pane> '…'` 紧跟 `HERDR_ENV=1 herdr pane send-keys <pane> enter`，投后 `pane read` 核验输入框已清空 |

发送前**必须先读目标面板**（`herdr pane read`）；若对方输入区有用户未提交内容，不得注入，改为等待或请用户转达。

**第四步 收件方处理**

1. 收到门铃提醒（收件箱有新邮件）后，读取 `inbox/<自己>/` 下的新文件，**读入自己的 context window** 处理；
2. **不发送回执**：收件方读完即处理，**不回** `{文件名} 已经收到`、不发任何确认消息；
3. **读毕即删**该文件（收件箱里只允许存在未读消息）；
4. 需要回正文时，按同样规则反向写文件 + 门铃，不把长正文塞进门铃消息。
5. **任何超过 10 分钟的操作（合并 / 构建 / 真机长跑 / 批量验证），开工前扫一次收件箱，收工后再扫一次。** 长操作期间不回看收件箱，是**已知会漏消息**的行为，不是意外。
   - **Why**：2026-10-23 devm 在 16:00–16:45 做 T6 合并验证（分支跑 ctest → 手工合成冲突 → 合并后再跑 ctest），期间没有回看收件箱，director 的一封裁决信（037）与 TL1 的三封缺口报告（042/043/044）在里面躺了 2.5 小时。**信没丢、门铃也送到了，是收件方在干活时看不见门铃。**
   - **How to apply**：把「扫收件箱」当成操作的**前后置动作**，不是独立任务；扫的时候只看 `ls inbox/<自己>/`，有文件就当场处理，**不要攒着**。攒着的后果是：你基于过时的状态继续决策，而对方以为你已经知道了。

**送达判定**：以 `herdr agent prompt` 返回 `"type":"agent_prompted"` 为「已送达」；走回退通道时以 `send-text + send-keys` 返回 exit 0 **且** `pane read` 见正文为「已送达」；**收件方不回执**，故不再以回执判定。发送方不确定是否已被读取时，**口头问用户**，不重复投递。

**不入库**：收件箱与 `locks/` 都是运行时通道，不是交付物；被服务项目的 `.gitignore` 必须含 `inbox/*/` 与 `locks/`。

### 1.4 依赖的 harness 技能（mattpocock，强制使用）

**强制口径**：下表技能**不是可选建议** —— 每个角色在其职责动作中**必须**调用；**不得**以「手写更快」「技能没装」为由静默跳过。技能不可用 ⇒ 先按本节末尾安装；仍不可用 ⇒ 在产物与回报里标注 `[SKILL_UNAVAILABLE]` 并回报 director，由 director 裁决（**不得静默降级**）。**调用要留痕**：回报写明用了哪个技能、产出落在哪个文件。

| 角色 | 强制技能 | 用在哪 |
|---|---|---|
| `director` | [`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)、[`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md)、[`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md)、[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md) | 接需求问穿验收口径；方案自审；契约与文档交叉拷问；抽查代码 |
| `pm` | [`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)、[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)、[`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)、[`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md)、[`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md) | SPEC、开发工单、需求澄清与开放问题推演、文档门禁自评与交叉拷问 |
| `devm` | [`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)、[`/diagnosing-bugs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/diagnosing-bugs/SKILL.md) | 评审整合前自审；缺陷分诊与回归定位 |
| `devtl` | [`/tdd`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md)、[`/implement`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/implement/SKILL.md)、[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)、[`/diagnosing-bugs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/diagnosing-bugs/SKILL.md) | 实施、提交前自审、门红定位 |
| `anam` | [`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md)、[`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)、[`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md)、[`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md) | 取证方法与证据分级、子问题拆解与反证、调研方案自审、证据与文档交叉拷问 |
| `anatl` | [`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md)、[`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)、[`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md)、[`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md) | 取证方法与证据分级、子问题拆解与反证、方案自审与交叉拷问 |
| `pm-e` | [`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)、[`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md) | 口径核对、产品事实取证（**写进派发 prompt**） |
| `dev-e` | [`/tdd`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md)、[`/implement`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/implement/SKILL.md)、[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md) | 实施与提交（**写进派发 prompt**） |
| `ana-e` | [`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md)、`/rea`、[`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md) | 取证（含 REA 逆向）与反证（**写进派发 prompt**） |

**命名与源文件**：上表技能名与 [`mattpocock/skills`](https://github.com/mattpocock/skills) 上游目录名**逐字一致**（路径形如 `skills/<category>/<name>/SKILL.md`），所有链接一律指向 `raw.githubusercontent.com` 的源文件。`/rea`（REA，竞品逆向）**不属于** mattpocock/skills，保持原名、不加链接。

**通用技能（所有 pane 常驻角色）**：`cbc-herdr` —— CodeBuddy 在 herdr 里的状态上报（`working` / `idle` / `blocked`），让 `herdr pane list` 的 `agent_status` 可信；`director` / `pm` / `devm` / `anam` / `devtl` / `anatl` 六份技能**都必须登记**。工程师是子代理、不占 pane，不需要加载。

**检查**：当前 harness 的 skill 目录里能看到这些技能（用户级共享位置通常是 `~/.agents/skills/mattpocock-skills`，仅供参考，不作为硬判据）。

未安装时按顺序处理：

```bash
# 首选：按 harness 安装（pi / opencode / codebuddy / amp / cursor / devin / windsurf；省略 -a 则交互选择）
npx skills@latest add mattpocock/skills -a <agent>
# 回退（提示词安装失败时）：克隆源码，把 skills/ 下的技能目录 copy 到 ~/.agents/skills/，再软链到 harness 技能目录
git clone https://github.com/mattpocock/skills.git
```

已知缺口（2026-10 核查）：上游 `mattpocock/skills` **没有 `to-prd`**，`implement-spec` 仍在 `in-progress/` 未发布。pm 写 PRD 按本文件 §4 模板手写；若后续上游提供 `to-prd`，优先改用它。

### 1.5 文件占用（编辑前必须检查）

**模型参考 Orca**：Orca 的做法是先看「谁在这个 worktree / 终端里活跃」，再决定能不能动手；它没有文件级锁 API，而 dmt 跑在 herdr，所以本团队在「看活跃会话」之上再加一层**文件级占用登记**。

**硬规则：任何角色在编辑（写入 / 追加 / 删除）任何文件之前，必须先 `check`；占用到手才能改；改完立刻 `release`。**

```bash
bash dmt-director/scripts/file-claim.sh check   <path> <owner>   # rc=0 可写；rc=3 他人占用
bash dmt-director/scripts/file-claim.sh claim   <path> <owner>   # 登记占用（重复调用＝续期）
bash dmt-director/scripts/file-claim.sh release <path> <owner>   # 释放（只有持有者能释放）
bash dmt-director/scripts/file-claim.sh list                     # 看全部占用
```

- `<owner>` 写「角色:实例」，如 `pm`、`devm`、`devtl1`、`dev-e3`。
- 记录落在项目根 `locks/`（运行时通道，**不入库**，`.gitignore` 含 `locks/`）。
- **rc=3 ⇒ 停手**：等对方释放、改做别的文件，或回报上级协调；**不得绕过、不得删别人的锁**。
- **TTL 默认 30 分钟**：过期锁视为可抢占，抢占时必须在回报里写明「接管过期锁 `<path>`（原持有者 `<owner>`）」。超过 30 分钟的任务在收工前重新 `claim` 续期。
- **Orca 附加检查**：`orca status` 可连通时，编辑前再跑 `orca worktree ps`，看同一 worktree 是否有 `live:>0` 的 agent；有则在回报里说明「同 worktree 有活跃会话，已确认不冲突」再动手。
- **例外**：`inbox/` 的消息文件由发送方新建、收件方删除，**不走占用登记**（文件名含 seq 与时刻，天然不冲突）；`locks/` 自身也不登记。
- **worktree 不是豁免**：一票一 worktree 只保证分支隔离，同一 worktree 仍可能有多个写者（队长 + 工程师），照样要登记。

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
| `docs/pd/prd/` | pm | 产品需求文档（PRD） | `{prd-seq}` 独立编号 |
| `docs/pd/spec/` | pm | 产品规格书（SPEC，含验收标准） | 与 ticket 共用 `spec-seq` |
| `docs/dev/tickets/` | pm（票面内容与编号）；devm 只在票面末尾追加「实施状态」一节 | 开发工单（ticket） | 与 SPEC 共用 `spec-seq` |
| `docs/analyst/` | anam | 市场调研与竞品逆向报告 | 无 |
| `docs/analyst/evidence/{research-seq}-{slug}/` | anam | 调研一手证据（采样产物／原始日志／manifest） | 与报告同号；须带 `manifest.txt`（文件名＋大小＋sha256＋采样命令） |
| `docs/human/human-arch/` | pm | 人类架构文档 | 无 |
| `docs/human/human-plan/` | pm | 人类计划文档 | 无 |
| `docs/team.md` | director | 团队契约（本文件） | 无 |
| `docs/handoff/` | director / devm | 交接说明（`{director,devm}-{slug}-{YYMMDD-HHMM}-v{N}.md`，**仅在用户要求时写**） | 无 |
| `inbox/<收件角色>/` | 发送方写、收件方读后删 | 角色间消息（运行时通道，**不入库**，**在项目根目录、不在 `docs/` 下**） | 方向与 `{seq}` 见 §1.3 |

1. 上述路径是**唯一允许位置**，不得写到 `docs/pd/`（除 `prd/`、`spec/`）、`docs/dev/`（除 `tickets/`）、`docs/human/`（除 `human-arch/`、`human-plan/`）、`docs/test/` 或其它任何位置；收件箱只在项目根 `inbox/` 下，不进 `docs/`；不得自建新的文档目录。
2. 各部门的产物目录**互不越界**：只读引用可以，移动/改名不可以。
3. **队长不写 `docs/`**：`devtl{n}` / `anatl{n}` 的回报与证据只落 `inbox/<上级>/`（或由上级并入票面/报告），`docs/` 内的产物一律由经理落笔。
4. 旧体系（`docs/pd/` 除 `prd/`、`spec/` 外，`docs/dev/` 除 `tickets/` 外，`docs/test/`）只保留历史，**不再接收新产物**；历史文件不改名、不搬迁（历史事实留痕）。**现行口径（2026-10-21 用户裁定·第二次修订）**：① PRD 落 `docs/pd/prd/`；② SPEC 由 `docs/spec/` 改为 `docs/pd/spec/`；③ ticket 由 `docs/tickets/` 改为 `docs/dev/tickets/`；④ 新增 `docs/human/human-arch/`（人类架构）与 `docs/human/human-plan/`（人类计划），**现由 pm 落盘**（2026-10-24 起；本条其余内容为历史口径）；⑤ `docs/dev/arch/` **作废**，不再单独设架构目录；⑥ 收件箱由 `docs/<角色>/inbox/` 移到项目根 `inbox/<角色>/`。
5. **目录初始化由 director 负责**：director 接手一个项目时先检查再补齐（见 §3.1），产物目录不由 anam / devm 自建。
6. 机检口径：§7 的脚本按该节列出的十四项逐条断言；它**不校验单个文件的落盘路径**，新产物靠本表与评审把关。

### 3.1 初始化（director 负责，幂等）

director 接手项目的**第一件事**：检查目录，缺什么建什么。可重复执行，已存在则不动：

```bash
bash dmt-director/scripts/init-project.sh <项目根>   # 省略参数＝当前目录
```

脚本做三件事：建六个产物目录 + 四个收件箱 + `locks/`；把 `inbox/*/`、`locks/` 写进 `.gitignore`（已存在则跳过）；跑机检直到 `ALL_PASS`。

- **完成判据**：机检输出 `ALL_PASS`。缺目录时脚本报 `FAIL 目录缺失`，director 补齐后重跑。
- **只建目录、不建产物**：空目录不预置占位文件，避免被误认为已有交付物。
- **`locks/` 是运行时通道**：文件占用登记（§1.5），不入库；缺失时脚本会自建，director 初始化时顺手建好。
- **pm / anam / devm 不自建产物目录**：发现自己的目标目录缺失，回报 director（收件箱目录属运行时通道，可按需 `mkdir -p` 兜底；`inbox/devtl{n}`、`inbox/anatl{n}` 由发送方按需建）。
- 契约文件 `docs/team.md` 与技能安装不在本步骤内（安装见 `README.md`）。

## 4. 工作流程

1. **anam 调研**：anam 按阈值（≤4 自派 `ana-e`，>4 开 `anatl{n}`）派取证；anam 复核并收口成调研报告，**经 director 评审后落盘** `docs/analyst/`；**本批收口且确认无下一批可派后，anam 关闭该批 `anatl{n}`（§1.2）**。
2. **director 定口径 → pm 出 PRD、SPEC 与工单**：director 与用户谈定边界、范围外与验收口径后派给 pm；pm 基于调研报告落笔 PRD 与 SPEC（[`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)，含逐条可测的验收标准），再用 [`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md) 把 SPEC 拆成开发工单，分别写 `docs/pd/prd/`、`docs/pd/spec/`、`docs/dev/tickets/`（文件头 `状态：待评审`），**由 pm 按文档门禁自评审**（验收标准逐条可测、`spec-seq` 对齐、切片可独立验证、Files 不重叠、依赖无环），通过后 pm 就地改状态行为 `状态：已通过` 并交 director 做口径确认与排期；director **不逐条评审文档**，只在口径冲突时裁决。
3. **devm 接单**：devm 读 `docs/dev/tickets/` 的本批票面（pm 落笔、director 已 PASS），核 `spec-seq` 对齐与判据齐备后按依赖排期；**devm 不拆票、不改判据**，缺项回报 director 转 pm 补。devm 负责评审、整合本部门交付物。
4. **devm 按排队数派活**：**排队任务 ≤4 ⇒ 自己派生 `dev-e` 子代理**（不开 pane、一票一 worktree）；**>4 ⇒ 建 `devtl{n}`**（优先 cbc + `/dmt-dtl`），把票面（路径、票基、Files 边界、验收判据、`timeoutMs`、回报格式）交给队长，队长建 worktree、派 `dev-e` 实施并做实施层初检。anam 阈值同为 ≤4 / >4（≤4 自派 `ana-e`，>4 建 `anatl{n}`）。
5. **devm 验收整合**：核 diff 与初检读数（≤4 路径自己收子代理回报并自做初检）→ 构建与测试 → 合并（冲突逐 hunk 按意图消解）→ 不合格打回原派生者 → 逐票在票面末尾追加「实施状态」（不改判据）；**本批全部收口且确认无下一批可派后，关闭该批 `devtl{n}`（§1.2）**。
6. **devm 评审代码，director 发布**：ticket 代码干完后由 **devm 按代码门禁评审**（逐条对照 SPEC 判据、核 diff 与证据、合并、写「实施状态」），devm PASS 即代码通过。devm 把评审结论与证据交 director，director **抽查**后自己提交并 `git push` 到 GitLab（至少每完成一个 ticket 推一次）；devm / 队长 / 工程师不 push。
7. **并行**：对无依赖关系的任务，各角色**只在直属下级之间并行**（director 在 pm/devm/anam 之间；pm 在多个 `pm-e` 之间；devm 在多个 `dev-e` 或 `devtl{n}` 之间；anam 在多个 `ana-e` 或 `anatl{n}` 之间；队长在多个工程师之间），优先级：dynamic workflow > 多个 subagents 并行；**不得为省事而串行，也不得越级派发**。**director 与 pm 自己的无依赖工作（评审前证据预检、文档交叉核对、外部事实取证）同样用子代理并行**，结论由本人落笔。

### 4.1 PRD 模板（pm）

`Problem Statement` / `目标用户与场景` / `方案概述` / `用户故事（可验收）` / `验收标准` / `范围外` / `开放问题`。

### 4.2 SPEC 模板（pm）

`Problem Statement` / `Solution` / `User Stories` / `验收标准（逐条可测）` / `实现决策` / `测试接缝` / `Out of Scope` / `变更记录`。
SPEC 必须自包含：每条 User Story 都能转成 ticket 与用例。

### 4.3 工单模板（pm）

`目标` / `输入 SPEC 小节` / `验收判据（逐条可测）` / `Files 范围` / `依赖（票号）` / `timeoutMs` / `状态` / `实施状态（devm 追加）`。
工单由 pm 用 [`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md) 按 tracer-bullet 纵向切片；**编号按依赖序、`spec-seq` 与 SPEC 严格对齐**；`Files 范围` 互不重叠，`依赖` 必须无环。

## 5. 纪律

### 5.1 Git

1. **禁止 `git add -A` / `git add .`**，提交一律显式列文件路径（优先 `git commit -m "..." -- <path>`，绕过索引），且 `add` 与 `commit` 之间不插入其它动作（避免索引被并发写者扫入）。
2. **推送只归 director**：`git push` **只有 director 能执行**；`pm` / `devm` / `anam` / 队长 / 工程师**一律不得 push**。工程师（`dev-e`）只在各自 worktree 内 `git add` + `git commit`，**不得 push**、**不得 merge 主干**。
3. 提交前先跑 [`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)；提交后 `git diff --cached --name-only` 复核暂存区。
4. **同一 worktree 单一写者（含队长本人）**：一个 worktree 从开工到收工，**只有被派到该票的那一个 agent 可以提交**。任何人要提交自己的文档 / 记录，**不得**在工程师正在施工的 worktree 里做——走主工作树或另开 worktree。**并发提交不会报错，只会把别人的改动扫进自己的提交**，事后靠 `git show --stat` 才能发现，而那时已经进了历史。
   - **Why**：2026-10-23 devtl1 在 dev-e13 施工的同一 worktree 上并行提交了 4 个 docs commit，没有造成损失，但它自己指出「结果侥幸没事不代表流程对」。**这条规则此前只存在于 director 的记忆里、没写进本文件**——没写下来的规则不算规则。
   - **How to apply**：队长提交前先 `git status` 看有没有别人的未提交改动；有则改用 `git commit -- <自己的路径>` 且**不先 `add`**；发现同 worktree 已有他人改动，停下问 devm，不要自行判断「应该没事」。
5. **推送节奏（director）**：① **至少每完成一个 ticket 推送一次**到 GitLab（`10.223.36.12:808`），推送信息含 `{spec-seq}-ticket-{slug}` 与一句话结果；② **至少每小时**巡检一次 `git status --porcelain`，有新建或修改文件就按显式路径提交并推送（不必等 ticket 收口）。巡检与推送结果在下一次回报里一句话说明（推了什么、跳过什么、为什么）。
   - 命令：`bash dmt-director/scripts/publish.sh -m '<message>' -- <显式路径...>`；`--auto` 由 `git status --porcelain` 枚举改动路径（仍是显式路径，不使用 `git add -A`），`--no-push` 只提交。
6. **合并冲突时「取 main」（`checkout --ours`）只在 main 是分支的严格超集时成立。** 判断办法不是看谁改得多，是**逐项比对「两侧各有哪些行是对方没有的」**；只要有一项只有分支有，就必须手工合成。
   - **Why**：T4 那次 main 是分支票面的严格超集，`--ours` 安全；T6 那次不是——main 有「不劣+最简」「21% vs 85% 口径隔离」，分支有「实测读数 + 2×2 六张表 + 配对 σ 修正」，**取任何一侧都会丢东西**。同一个动作在两次合并里安全性相反，**说明「上次就是这么干的」不构成理由**。
   - **How to apply**：合并前跑一次两侧差异清单（`git diff --stat main...branch` 逐文件看，或直接 `git merge-tree` 预判）；合成后**与分支版本再 diff 一次**，确认差异只剩「main 独有的行」与「人工合成的那几行」，其余逐字节相同。

### 5.2 并行子代理

1. 派发前先做**依赖分析**：只有无依赖任务可并行；共享文件、共享构建目标、有顺序验收关系的任务必须串行。
2. **经理层路径判据（可测）**：开工前数**当前未收口的排队任务数** —— **`devm`：≤4 ⇒ 自己派生 `dev-e`（不开 pane），>4 ⇒ 开 `devtl{n}` pane**；**`anam`：≤4 ⇒ 自己派生 `ana-e`，>4 ⇒ 开 `anatl{n}` pane**。两条都**优先 cbc harness**（`codebuddy --permission-mode auto` + `auto mode on` + `/dmt-dtl` 或 `/dmt-atl`）。路径由排队数决定，不由便利程度决定；已开出的队长 pane 批内复用。
3. **饱和派发（`devm` / `anam` 严责）**：开工前先数**无依赖单元数 N**（可并行的票 / 子问题），**必须一次开满 N 个子代理**（一单元一子代理），**同一回复内全部派出，并发数 = 单元数**；**少开一个即为违规**，除非在回报里写明该单元被串行的理由（理由限：依赖 / 共享文件 / 共享构建目标 / 顺序验收关系 / 同一设备或同一 REA 会话）。**不许**「先开一个看看」「省得管理」这类降并发。cbc harness 可用 **teammate 方式**（`Agent` 带 `name` 建 team、多成员同批派出）达到同等并发；pi 用 dynamic workflow `runs.all`。**director 抽查以「并发数 vs 无依赖单元数」为判据**，不等且无理由即打回。
4. **队长层可测判据**：无依赖单元（票 / 取证单元）**≥2 ⇒ 必须并发派发**，并同样适用第 3 条的**开满**要求（队长对 N 个单元开 N 个工程师）；**仅在回报中给出串行理由时可例外**（理由同上）。手段优先级：dynamic workflow `runs.all`（pi）> 多个 subagents 并行（cbc 用 Agent/team 或 teammate）。
5. **产品部**：`pm` 无队长层，无依赖产品单元 **≥2 ⇒ 必须并发派 `pm-e`**（cbc 用 Agent 子代理 / team，pi 用 dynamic workflow）；`director` 的评审前预检同理。
6. 每份派发 prompt 必须显式写清：输入（产物路径）、边界、期望产物、回报要求、`timeoutMs`（长链路不短于 45 min）。
7. 子代理一律后台/异步派发，**派完立即结束本轮**，由完成通知唤醒再验收；不做轮询。
8. 开发工程师**每人一个 git worktree**，只在 worktree 内编辑与提交；主工作树只读。
9. 所有子代理结果由**派生他的那一级**复核证据后，才能写入权威文档或进入下一步；经理不直接采信工程师的原始回报。

### 5.3 评审门禁

| 门禁 | 提交方 | 评审方 | 通过条件 |
|---|---|---|---|
| 调研报告 | anam | director | director 认可结论与证据来源；**anam 落盘** `docs/analyst/` |
| PRD / SPEC / 工单 | pm（起草） | **pm（文档门禁）**；director 只在口径冲突时裁决 | 验收标准逐条可测、`spec-seq` 对齐、切片可独立验证、Files 不重叠、依赖无环；通过后状态行改 `状态：已通过` |
| 实施初检 | devtl（>4 路径）/ devm（≤4 自派路径） | devm | 票面判据逐条有读数、门红已分类、Files 边界未越界 |
| 队长实例关闭 | devm / anam（创建者） | 创建者本人自检 | 回报已入账、worktree 已 `git worktree remove`、收件箱无该队长未读；关闭后 `herdr pane list` 无该 label |
| 人类架构 / 人类计划 | pm | **pm（文档门禁）** + 用户 | 结构与真实代码一致、不混写未来态，落盘 `docs/human/human-arch/`、`docs/human/human-plan/` |
| ticket 代码 | 开发部门（>4 经 `devtl{n}`、≤4 由 devm 自派 `dev-e`） | **devm（代码门禁）** | 逐条对照 SPEC 判据通过、diff 与证据核对无误；PASS 后合并并写「实施状态」 |
| 发布 | devm | director | 抽查评审结论与证据后 `git push`（每 ticket 一推；**不替代 devm 的代码评审**） |
| 跨部门分歧 | pm / devm / anam | director | director 裁决并回结论 |

### 5.4 读数纪律（性能窗）

1. **dump 开关必须随窗登记**：`obb_roi_dump_enabled`（`yolo11ncnn.cpp:1063`，默认 off）开时每帧算 raw sha256，占全进程 CPU **13.3%**、detect 线程约 95% ⇒ 实测 `detect_fps_measured` **1.79**（原记 0.76，经 004 订正 —— 0.76 属跨轮残留快照）vs 生产档 **3.86**。**dump-on 窗的 fps／耗时对比一律作废**，不得进任何结论；开窗前必须核 `diagnostics_state` 并把该值写进口径行。
2. **跨构建绝对值禁比**：不同 so／APK 的毫秒数不可互比（设备现装、语料、仓内 APK 三者不同源）；比值（如 detect 前向占比 f）可跨构建比，但须挂横幅说明。
3. **「停」要复验**：`force-stop` 后必须 `pidof <pkg>` 为空才算停；队长回报的「已停」不可直接采信。
4. **快照必须同时满足两条才算本窗**：① 在本窗 `new.list` 内；② `build_sha256` 与同窗其余快照**一致**。任一条不满足 ⇒ **跨轮残留**，禁用于任何对账（含 `detect_ms`／`fps`／`decode_ms`）。**Why**：`new.list` 只能证明「文件是这次新出现的」，证明不了「它属于这次会话」——2026-10-24 004 窗就有 1 份 `a676c083`（旧构建）快照混在 `new.list` 里（`detect_frames=172`、`window_ms=30106`，比同窗第 2 份早 33.8 s）；同一坑此前已三次（62 s 窗、`keys.tsv` 混入、`67528008`）。
5. **装机权限（只归 director）**：`adb install`／`uninstall`／覆写设备 `bcr_t36_calib.txt`／`bcr_detect_probe.trigger`／`dump_prefs`／`force-stop` 等**写操作，只许 `director` 执行**；`pm`／`devm`／`anam`／队长／工程师**一律禁装、禁写设备**（需要装机时回报 director，由 director 自己动手，不转授权）。装机后必报 **APK `sha256` ＋ `lastUpdateTime` ＋ `pidof` 空**。**Why**：2026-10-24 T1（host-only 票）的 dev-e 自行装机、覆写 calib 并 force-stop 了他人 `pid=23862` 的进程；用户随后裁定装机与推送都收归 director 一人。

**Why**：2026-10-24 的 f 补测窗（dump 开）一度被当作性能窗；同日某队长报「App 已 force-stop」，实测 pid 仍在。**没写下来的纪律不算纪律**。

## 6. 表达（全角色）

读者是**稍微懂一点软件工程但没有参与本项目的人**（含用户）：只说白话，先说结论再说证据，突出重点，术语翻成人话。

## 7. 机检

```bash
bash dmt-director/scripts/check-dmt-doc-paths.sh
```

检查**十五项**：① 六个产物目录存在（`docs/pd/prd`、`docs/pd/spec`、`docs/dev/tickets`、`docs/analyst`、`docs/human/human-arch`、`docs/human/human-plan`）＋ 根目录 `inbox/` 存在；② 六个技能（`dmt-director` / `dmt-pm` / `dmt-dm` / `dmt-am` / `dmt-dtl` / `dmt-atl`）各自指向自己的唯一目录（PRD / SPEC / 工单 / 人类文档归 `dmt-pm`）；③ **队长实例关闭动作已登记**（契约与 `dmt-dm` / `dmt-am` 技能含 `close-leader.sh`，契约含「禁止先关后收」与「只许关 pane」）；④ **身份识别已登记**（契约与六个技能含 `pane label`，契约含「不按 tab 内位置」）；⑤ **队长层并行判据已登记**（`dmt-dtl` / `dmt-atl` 含「必须并行」，契约含「≥2 ⇒ 必须并发派发」）；⑥ **经理层路径判据与饱和派发已登记**（`dmt-dm` 含「≤4」「>4」、`dmt-am` 含「≤4」「>4」，契约含「≤4 ⇒ 自己派生 `dev-e`」与「≤4 ⇒ 自己派生 `ana-e`」；契约含「并发数 = 单元数」，`dmt-dm` / `dmt-am` 含「开满」与 `teammate`）；⑦ **装机与推送归属已登记**（契约含「只有 director 能执行」与「只许 director 执行」、`dmt-director` 含 `git push`、`dmt-dm` 含「不得 push」、契约含「至少每完成一个 ticket 推送一次」与「至少每小时」）；⑧ **mattpocock 强制技能已逐角色登记**（契约含「强制使用」与角色表；`dmt-director` 含 [`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)+[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)、`dmt-pm` 含 [`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)+[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)、`dmt-dm` 含 [`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)、`dmt-dtl` 含 [`/tdd`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md)、`dmt-atl` 含 [`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md)）；⑨ **文件占用已登记**（契约含「文件占用」与 `file-claim`，六个技能各含 `file-claim`，脚本 `scripts/file-claim.sh` 存在）；⑩ **评审门禁归属已登记**（契约与 `dmt-pm` 含「文档门禁」、契约与 `dmt-dm` 含「代码门禁」、`dmt-director` 含「不替代」）；⑪ **cbc-herdr 通用技能已登记**（六个 pane 角色技能各含 `cbc-herdr`）；⑫ **技能链接与上游一致**（契约与六个技能都含 `raw.githubusercontent.com`，技能名与 `mattpocock/skills` 目录名逐字一致）；⑬ 本契约登记齐全；⑭ 负样本能被正确拒绝（**只看 §3 落盘登记表**，§8 变更记录里的历史留痕不算登记）。**改路径规范、pane 生命周期、并行口径、角色层级、写权限、强制技能、文件占用... [truncated]

## 8. 变更记录

- **2026-10-24（用户裁定·第二十八次：经理层饱和派发，`devm` / `anam` 严责）**：无依赖任务**必须开满子代理** —— 无依赖单元数 N ⇒ 同一回复内派出 N 个子代理，**并发数 = 单元数**；少开一个即为违规，除非在回报里写明串行理由（依赖 / 共享文件 / 共享构建目标 / 顺序验收关系 / 同一设备或同一 REA 会话）；**cbc 可用 teammate 方式**（`Agent` 带 `name` 建 team、多成员同批派出）。① §5.2 新增第 3 条「饱和派发（`devm` / `anam` 严责）」，原 3–8 顺延为 4–9，队长层条款并入「开满」要求；② §7 机检 ⑥ 增加「并发数 = 单元数」「开满」「teammate」断言（机检仍为十五项，断言落在 4b）；③ `dmt-am` 派题步骤与派单纪律 2、`dmt-dm` 排期/派票/派单纪律 4 改为「一次开满」并写明 cbc teammate；④ `dmt-director` 抽查增加**并发度抽查**（无依赖单元数 vs 实际并发子代理数，不等且无理由即打回）；⑤ `README.md` 机检说明同步。

- **2026-10-24（用户裁定·第二十七次：anam 阈值与 devm 统一为 4）**：分析经理 `anam` 开队长 pane 的门槛由「排队子问题 >2」改为「**>4**」，`≤4` 时自己派生 `ana-e` 子代理 —— 与 `devm` 的 4 个阈值对齐，两个部门用同一把尺。同步改动：§1.1 组织表与规则 3、§4 工作流第 1 条与第 4 条、§5.2 经理层路径判据、§7 机检 ⑥、`dmt-am` / `dmt-atl` 两份技能、`README.md`（角色表与机检说明）、机检脚本 4b 断言（`≤4` / `>4`）。

- **2026-10-24（用户裁定·第二十六次：确定性动作脚本化）**：把「结果确定」的指令从散文改成脚本，正文只留判据与例外。新增 `scripts/init-project.sh`（建目录 + `.gitignore` + 机检）、`setup-team.sh`（director 正名 + 建 pm/devm/anam + 代启动 + 输技能，幂等）、`spawn-leader.sh`（按 right/down 规则开队长 pane + 代启动 + 输 `/dmt-dtl`｜`/dmt-atl`）、`close-leader.sh`（label 解析 + 收件箱非空拒绝 + 只关 pane）、`send-msg.sh`（自动 seq/时刻/方向 + 门铃回退）、`publish.sh`（显式路径提交 + 推 GitLab/GitHub，`--auto` 仍不用 `git add -A`）、`install-skills.sh`（软链或复制六技能 + 契约 + 脚本 + 初始化）。§1.2 / §1.3 / §3.1 / §5.1 与六个技能改为调用脚本；机检新增 4j（九个脚本存在且可执行），判据十四项 → 十五项。
- **2026-10-24（全面审计修复，非用户裁定）**：逐文件核对后修复以下过期／矛盾／无效内容：① **`pm` 与 `director` 同 tab** ⇒ 迁移兜底与「不得用 tab list 认自己」补 `pm` 例外，避免按 tab 兜底指错 pane。② §1.2 创建 pane 的 bash 块里，一条 `>` 注记误落在代码围栏内（会被当成命令）⇒ 移出围栏。③ §3 历史口径「人类架构/计划由 director 落盘」改为**现由 pm 落盘**；§3 机检口径由「五/六项」旧描述改为指向 §7 十四项。④ §4 调研步骤补 anam 阈值（≤2/>2）；验收整合由「逐票更新状态」改为「追加实施状态（不改判据）」。⑤ §5.1 第 4 条「队长要提交票面/文档」已过期（票面由 pm 落笔、队长不写 docs）⇒ 改为「任何人提交自己的文档/记录」。⑥ **§5.3 与 §5.4 顺序颠倒** ⇒ 5.3 评审门禁在前、5.4 读数纪律在后。⑦ 人类架构/计划评审方由「director + 用户」改为「pm（文档门禁）+ 用户」，与文档门禁归属一致；ticket 代码提交方补注 ≤4 路径。⑧ 重复的「第十七次」变更记录改为「第十七次附」。⑨ README：队长生成阈值残留 `>2` 改为 devm >4 / anam >2；工作流里「devm 评可实施性」改为 pm 文档门禁自评；脚本树与软链补 `file-claim.sh`；`pi-subagents` 标注**仅 pi harness**（cbc 用 Agent/team）。⑩ `dmt-am` 缺失「编辑前检查占用」一节 ⇒ 补齐，机检 4f 覆盖六个技能。⑪ `dmt-dm` / `dmt-am` 的「跳过第 4/3、6 步」与实际步骤不符（派票/派题并未跳过）⇒ 改为只跳过第 6 步。⑫ `dmt-director` 调研评审后「落盘」的施动者改为 anam。⑬ 六个技能与 README 的 `pi-subagents` 说明统一为「仅 pi harness」。机检 `ALL_PASS`（十四项）。
- **2026-10-24（用户裁定·第十八次：§5.1 增「APK 不入仓」）**：`*.apk` 一律不提交，只留 `tools/apk-manifest.tsv`（路径＋大小＋sha256＋构建 sha）；存量 APK 另裁。落地点＝T4 票面新增判据 **T4-f**（新增提交零 APK ＋ 清单在库）。依据＝GitHub 仓 2.16 GB、历史 10+ 个 41 MB debug APK。
- **2026-10-24（用户裁定·第二十五次：技能名与上游对齐并加 raw 链接）**：① 团队使用的 11 个 mattpocock 技能名与 [`mattpocock/skills`](https://github.com/mattpocock/skills) 上游目录名**逐字核对一致**（`grilling` / `grill-me` / `grill-with-docs` / `code-review` / `to-spec` / `to-tickets` / `research` / `tdd` / `implement` / `diagnosing-bugs` / `improve-codebase-architecture`）。② 文档中所有技能提及改为 markdown 链接，指向 `https://raw.githubusercontent.com/mattpocock/skills/main/skills/<category>/<name>/SKILL.md`（`grilling`、`grill-me` 在 `productivity`，其余在 `engineering`），已逐条 HTTP 200 验证。③ `/rea`（REA 竞品逆向）不属该仓，保持原名、不加链接。④ 机检新增 4i 断言（契约与六个技能都含 `raw.githubusercontent.com`），判据十三项 → 十四项。同步改动：`README.md`、`team.md`、六个技能。
- **2026-10-24（用户裁定·第二十四次：ana-e 加 `/rea`；devtl 加 [`/implement`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/implement/SKILL.md)；devm 阈值放宽到 4）**：① `ana-e` 的强制技能增加 **`/rea`**（竞品逆向必须走 REA），由 `anatl` 写进派发 prompt；§1.4 表同步。② `devtl` 的强制技能增加 **[`/implement`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/implement/SKILL.md)**（用户口述「/implements」，实际技能名 [`/implement`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/implement/SKILL.md)）。③ **`devm` 的队长层阈值由 >2 改为 >4**：排队任务 ≤4 时 devm 自己派生 `dev-e`，>4 才开 `devtl{n}`；`anam` 阈值保持 ≤2 / >2。④ 同步改动：`dmt-dm` / `dmt-dtl` / `dmt-atl` / `team.md`（§1.1、§1.2、§4、§5.2、§5.3、§7）/ `README.md` / 机检 4b（改为 devm ≤4、anam ≤2）与 4e（新增 `/rea`、[`/implement`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/implement/SKILL.md) 断言）。
- **2026-10-24（用户裁定·第二十三次：全员加载 `cbc-herdr`）**：① 六个 pane 常驻角色（`director` / `pm` / `devm` / `anam` / `devtl` / `anatl`）的技能清单统一登记 **`cbc-herdr`**（CodeBuddy 在 herdr 的 `working` / `idle` / `blocked` 状态上报，让 `herdr pane list` 的 `agent_status` 可信）。② 工程师是子代理、不占 pane，不加载该技能。③ 用户口述的「herdr-cbc」按实际技能名 **`cbc-herdr`** 落地。④ 机检新增 4h 断言，判据十二项 → 十三项。同步改动：六个技能、`README.md`、`team.md` §1.4。
- **2026-10-24（用户裁定·第二十二次：director / pm / anam 增配 [`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md) 与 [`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md)）**：① `director` 增 [`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md)（需求与裁决方案自审）、[`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md)（契约与文档交叉拷问）；② `pm` 增同名两项（文档门禁自评、PRD / SPEC / 工单交叉拷问）；③ `anam` 增同名两项（调研方案自审、证据与文档交叉拷问），并同步到 `anatl`；④ §1.4 角色表补 `anam` 行（此前遗漏）。同步改动：`dmt-director` / `dmt-pm` / `dmt-am` / `dmt-atl`、`README.md`、机检 4e。
- **2026-10-24（用户裁定·第二十一次：编辑前查文件占用；评审门禁下沉到 pm/dm）**：① **新增 §1.5 文件占用** —— 任何角色编辑任何文件前必须 `scripts/file-claim.sh check/claim`，`rc=3` 即停手，改完 `release`；占用记录落项目根 `locks/`（不入库），TTL 30 分钟、过期可抢占但要留痕；模型参考 Orca（先看 worktree 活跃会话），Orca runtime 可连通时加跑 `orca worktree ps`。② **文档门禁归 pm**：PRD / SPEC / 工单由 pm 起草并由 **pm 评审**（验收标准逐条可测、`spec-seq` 对齐、切片可独立验证、Files 不重叠、依赖无环），通过后自行改状态行；director 不逐条评审文档，只在口径冲突时裁决。③ **代码门禁归 dm**：ticket 代码干完后由 **devm 评审**（逐条对照 SPEC 判据、核 diff 与证据、合并、写「实施状态」），PASS 即代码通过；director **抽查后发布**（`git push`），不替代 devm 评审。④ 机检新增 4f（文件占用）、4g（评审门禁）断言，判据十项 → 十二项。同步改动：六个技能、`README.md`、新增 `scripts/file-claim.sh`。
- **2026-10-24（用户裁定·第二十次：mattpocock 技能改为强制使用）**：① §1.4 由「依赖的 harness 技能」改为「**强制使用**」，新增**角色 × 强制技能**表：`director` [`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)+[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)、`pm` [`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)+[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)+[`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)、`devm` [`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)+[`/diagnosing-bugs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/diagnosing-bugs/SKILL.md)、`devtl` [`/tdd`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md)+[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)+[`/diagnosing-bugs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/diagnosing-bugs/SKILL.md)、`anatl` [`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md)+[`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)，工程师类由派发 prompt 强制写入。② **不得静默跳过**：技能不可用先装，仍不可用须在产物与回报标注 `[SKILL_UNAVAILABLE]` 并回报 director；调用要留痕（用了哪个技能、产出在哪）。③ 六个技能各新增「强制技能（mattpocock，必须使用）」一节；`README.md` 增「角色 × 强制技能」「角色 × 交付物」两表。④ 机检新增 4e 断言（契约含「强制使用」、五个角色技能各含自己的强制技能名），判据九项 → 十项。
- **2026-10-24（用户裁定·第十九次：工单改由 pm 拆，devm 只接单与评审整合）**：① **pm 的交付物扩为四类** —— PRD、SPEC（[`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)）、**开发工单（[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)）**、人类架构与人类计划；工单按 tracer-bullet 纵向切片、编号按依赖序、`spec-seq` 与 SPEC 严格对齐，落 `docs/dev/tickets/`。② **`docs/dev/tickets/` 负责人改为 pm**（票面内容、编号、判据、Files 边界）；**devm 只在票面末尾追加「实施状态」一节**，不改判据、编号与 Files 边界，缺项回报 director 转 pm 补。③ **devm 职责改为接单与整合** —— 读 pm 的票面（director 已 PASS）→ 按依赖排期 → 按排队数自派 `dev-e` 或开队长 pane → 评审并整合开发部门交付物；**不拆票、不改判据**，[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md) 不再是 devm 的技能。④ 新增 §4.3 工单模板；§5.3 门禁行由「PRD 与 SPEC」改为「PRD / SPEC / 工单」。同步改动：`dmt-pm`、`dmt-dm`、`dmt-director`、`dmt-dtl`（票面改由 pm 落笔）、`README.md`、机检脚本（新增 pm 工单断言）。
- **2026-10-24（用户裁定·第十八次：装机与推送收归 director，并加推送节奏）**：① **装机只由 director** —— 原「只到经理级（`director`／`pm`／`devm`／`anam`）」收紧为**只许 `director` 执行**（`adb install`／`uninstall`／覆写设备文件／`dump_prefs`／`force-stop` 等设备写操作）；pm／devm／anam／队长／工程师一律禁装禁写，需要装机时回报 director、不转授权。② **`git push` 只由 director** —— 原「只有 devm 能 push」作废，devm／队长／工程师一律不得 push。③ **推送节奏**：director **至少每完成一个 ticket 推送一次**到 GitLab（`10.223.36.12:808`），推送信息含 `{spec-seq}-ticket-{slug}` 与一句话结果；**至少每小时**巡检 `git status --porcelain`，有新建或修改文件即按显式路径提交并推送（不必等 ticket 收口）。④ 门禁表 `ticket 代码` 行改为「PASS 后由 director 自己提交并 push」；§5.1 新增第 5 条推送节奏、原第 5 条合并冲突顺延为第 6 条。同步改动：`dmt-director`（新增「装机与推送」节）、`dmt-dm`（删 push 步骤、改「不 push」）、`README.md`、机检脚本（八项 → 九项，新增 4d 断言）。
- **2026-10-24（用户裁定·第十七次：新增产品部经理 pm，director 改为纯团队领导）**：① **新增第五个部门经理** —— 产品部经理 `pm`（技能 `dmt-pm`，运行 id `pm`，pane label `pm`），**承接原属 director 的全部产品经理职责与技能**：PRD、SPEC（含逐条可测验收标准）、人类架构、人类计划，以及 [`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)、[`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md) 等产品技能；`pm` 无队长层，直接派生 `pm-e` 产品工程师子代理。② **director 不再落笔 PRD / SPEC / 人类文档**，只保留团队领导职责：接需求与验收口径、分派、评审（产品口径 + 转 devm 评审）、裁决、**组织维护**。③ **pm 由 director 在 director 自己的 tab 内右侧 split 创建**（herdr 0.9.5 无 `pane create`，建 pane 的等价动作就是 `pane split`）；director 启动**先改 tab label 为 `director`、再改 pane label 为 `director`**，随后建 `pm`，再建 `devm` / `anam` 两个 tab。④ **`devm` / `anam` 的 tab 与 pane label 由 director 独占创建与维护**（巡检、改名、重建、重装技能命令），下级不得自行新建或改名。⑤ **门铃通道**：对端 harness ∈ `codebuddy` / `pi-coding-agent` / `codex` / `opencode2` / `opencode` 时优先 `herdr agent prompt`；返回非 `agent_prompted` 或对端是其它 harness 时回退 `herdr pane send-text` + `herdr pane send-keys <pane> enter`。⑥ **经理层路径判据**：`devm` / `anam` 排队任务 **≤2 ⇒ 自己派生工程师子代理**（不开 pane）；**>2 ⇒ 开队长 pane**（**优先 cbc harness**：`codebuddy --permission-mode auto` + `/dmt-dtl` 或 `/dmt-atl`）。⑦ **director 与 pm 的无依赖工作同样用子代理并行**（cbc 用 Agent / team，pi 用 dynamic workflow），子代理只做取证与预检，结论本人落笔。⑧ 运行 id（pane label / tab label / 收件箱目录）**保持 `director` / `pm` / `devm` / `anam` / `devtl{n}` / `anatl{n}`，不加前缀**（用户 2026-10-24 裁定）。同步改动：六个技能、`README.md`、机检脚本（七项 → 八项）。

- **2026-10-24（用户裁定·第十七次附：§5.4④ 改合取判据）**：快照归属由「在 `new.list` 内」改为**两条合取**（① 在本窗 `new.list`；② `build_sha256` 与同窗其余一致）。依据＝anam 014（004 窗 9 条 `new.list` 里混进 1 份 `a676c083` 旧构建快照：frames=172／window_ms=30106／早 33.8 s，已剔除，证据目录 14 件，manifest sha `0404d916…`）。另记读数特征：本窗 8 份 `detect_ms_median` 20 秒内由 85.42 单调爬到 98.46（+15%）⇒ **单点快照之间不可互换**，A/B 须同帧号段或同窗同位置比较。
- **2026-10-24（用户裁定·第十六次：§5.4 增快照归属纪律）**：§5.4 新增第 4 条**快照必须在本窗 `new.list` 内**（不在 ⇒ 跨轮残留，禁用于任何对账）；原第 4 条装机权限顺延为第 5 条。依据＝anam 013 号件（004 原件误用跨轮残留快照 `67528008`，绝对值 99.6／107.51 → **86／93 ms**、fps 0.76 → **1.79**；f=92.7% 与结论不变）。
- **2026-10-24（用户裁定·第十五次：§5.4 增装机权限 ＋ 身份门与 push 口径）**：① §5.4 新增第 4 条**装机权限只到经理级**（`director`／`devm`／`anam`；队长与工程师禁装禁写设备；装机后必报 `sha256`＋`lastUpdateTime`＋`pidof` 空）。② **身份门角色集补 dmt 五角色**（`director`／`devm`／`anam`／`devtl`／`anatl`），由 T4 落地（票面 T4-e），落地前 director 暂用 `p00292(pm)` 提交。③ **push 口径**：常规仍由 devm 执行；**用户直接指令下 director 可代推**，须在回报中注明（2026-10-24 首次代推：GitLab＋GitHub）。
- **2026-10-24（用户裁定·第十四次：新增调研证据目录）**：`docs/analyst/evidence/{research-seq}-{slug}/` 登记为 anam 的**一手证据**落点（采样产物／原始日志／manifest），与报告同号，必须带 `manifest.txt`（文件名＋大小＋sha256＋采样命令）。理由＝`docs/research/evidence/` 已随用户清理移除，若不设新落点，调研读数将不可复现。
- **2026-10-24（用户裁定·第十三次：新增 §5.4 读数纪律）**：① dump 开关随窗登记，**dump-on 窗的 fps／耗时对比一律作废**（实测 sha256 占全进程 CPU 13.3%、detect_fps 0.76 vs 生产 3.86）；② 跨构建绝对值禁比、比值须挂横幅；③ force-stop 后须 pidof 为空才算停，队长回报不可直接采信。依据＝anam 004 号件（f 补测＋两条方法论警告）。
- **2026-10-24（用户裁定·第十二次：门铃通道统一 ＋ 队长 pane 竖排）**：① 门铃一律用 `herdr agent prompt <pane> '<短句>'`（自带 Enter 提交，返回 `"type":"agent_prompted"` 即送达）；**codebuddy 面板同样适用** —— 2026-10-24 实测：返回 `agent_prompted`、输入框保持空、agent 立刻进 processing；`send-text + send-keys enter` **降级为回退通道**。② 队长 pane 布局：**第 1 个开在经理 pane 右侧；第 2 个起开在「上一个队长 pane」的下方**（右侧一列竖排，不横排）；容量条目随之改为「高度均分、经理宽度不变，建议 ≤3 个队长」。同步改动：`dmt-am` / `dmt-dm` / `dmt-dtl` / `dmt-atl` 四份技能。
- **2026-10-24（用户裁定·第十一次：经理层启动自动化）**：团队启动顺序改为 **director 全自动拉起经理层** —— 建 `devm` / `anam` tab、root pane 打同名 label 后，**代启动** `codebuddy --permission-mode auto`（就绪判据 `auto mode on`），再在各 pane 输入 `/dmt-dm`、`/dmt-am` 装载角色技能；**不再请用户手动在经理 tab 里启动 harness**。用户原话写的是 `codebuddy --permission auto`，实测 CLI 参数为 `--permission-mode <mode>`（choices 含 `auto`，见 `codebuddy --help`），按实测参数执行。同步改动：`dmt-director/SKILL.md`（建 tab 段落补三步启动动作）。
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
