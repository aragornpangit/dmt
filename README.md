# dmt

dmt 团队的角色技能仓：**团队定义与六个角色技能的唯一维护地**。层级：`director` → 部门经理（`pm` / `devm` / `anam`）→ 队长（`devtl{n}` / `anatl{n}`，仅开发与分析两部有）→ 工程师（`dev-e` / `ana-e` / `pm-e`）。
**产品部只有三层**：`pm` 直接派生 `pm-e` 子代理，不设队长。
**队长层是按需的，且有数值判据**：经理**排队任务未超阈值时自己派生工程师子代理**（`devm` ≤4、`anam` ≤4）；**超过阈值时**用 `herdr pane split` 在**自己的 tab 内**开队长 pane（pane label 固定为 `devtl{n}` / `anatl{n}`，**优先 cbc harness** 并输入 `/dmt-dtl` / `/dmt-atl`），队长接单后再开工程师子代理；队长 pane 用完即关。

| 角色 | 技能名 | 运行 id（pane label） | 直属上级 | 直属下级 | 职责摘要 |
|---|---|---|---|---|---|
| 总监（团队领导） | `dmt-director` | `director` | 用户 | `pm`、`devm`、`anam` | 唯一入口；接需求与验收口径、分派、裁决、创建并维护经理层 pane/tab；抽查后发布（`git push`）与装机；**不替代** pm 的文档评审与 devm 的代码评审 |
| 产品部经理 | `dmt-pm` | `pm` | `director` | `pm-e`（子代理） | 落笔 PRD、SPEC（[`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)）、开发工单（[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)）、人类架构与人类计划；**文档门禁**（文档评审责任人）；用子代理并行做产品取证与核对 |
| 开发经理 | `dmt-dm` | `devm` | `director` | `dev-e`（≤4 自派）或 `devtl{n}`（>4） | 接单（pm 的 ticket）、排期派活、**代码门禁**（ticket 代码评审责任人）、整合交付物；**不拆票、不 push** |
| 分析经理 | `dmt-am` | `anam` | `director` | `ana-e`（≤4 自派）或 `anatl{n}`（>4） | 接调研诉求；按排队数自派子代理或开队长 pane；复核出处、收口调研报告 |
| 开发队长 | `dmt-dtl` | `devtl1`、`devtl2` …（在 devm 的 tab 内） | `devm` | `dev-e`（子代理） | 由经理按需生成；建 worktree、并发派开发工程师、收 diff 做初检、回报 devm |
| 分析队长 | `dmt-atl` | `anatl1`、`anatl2` …（在 anam 的 tab 内） | `anam` | `ana-e`（子代理） | 由经理按需生成；拆子问题、派分析工程师并行取证、复核出处、回报 anam |

| 角色 | 强制技能（mattpocock，必须使用） |
|---|---|
| 总监 `director` | [`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)（问穿验收口径）、[`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md)（方案自审）、[`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md)（契约/文档交叉拷问）、[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)（抽查） |
| 产品部经理 `pm` | [`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)（SPEC）、[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)（工单）、[`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)（需求澄清）、[`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md)、[`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md) |
| 开发经理 `devm` | [`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)（评审整合前）、[`/diagnosing-bugs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/diagnosing-bugs/SKILL.md)（缺陷分诊） |
| 开发队长 `devtl` | [`/tdd`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md)、[`/implement`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/implement/SKILL.md)、[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)、[`/diagnosing-bugs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/diagnosing-bugs/SKILL.md) |
| 分析经理 `anam` | [`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md)、[`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)、[`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md)、[`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md) |
| 分析队长 `anatl` | [`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md)、[`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)、[`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md)、[`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md) |
| 工程师 `pm-e` / `dev-e` / `ana-e` | 由派发 prompt 强制写入（见 `team.md` §1.4） |

技能名与 [`mattpocock/skills`](https://github.com/mattpocock/skills) 上游**逐字一致**，链接指向 `raw.githubusercontent.com` 源文件；`/rea` 属 REA、不在该仓内，保持原名。

另：六个 pane 常驻角色（`director` / `pm` / `devm` / `anam` / `devtl` / `anatl`）都加载 **`cbc-herdr`**（CodeBuddy 在 herdr 的状态上报）；工程师子代理不占 pane，不需要。

| 角色 | 交付物（落盘位置） |
|---|---|
| `director` | `docs/team.md`；按需 `docs/handoff/`；评审结论（收件箱）；GitLab 推送（每 ticket 一推 ＋ 每小时巡检）；装机 |
| `pm` | `docs/pd/prd/` PRD、`docs/pd/spec/` SPEC、`docs/dev/tickets/` 工单、`docs/human/human-arch/`、`docs/human/human-plan/` |
| `devm` | 票面末尾「实施状态」；合并后的主干代码；验收证据（收件箱回报） |
| `devtl` | 实施层初检回报（`inbox/devm/`）；`feat/{ticket-id}` 分支提交 |
| `anam` | `docs/analyst/` 调研报告 ＋ `docs/analyst/evidence/` 一手证据 |
| `anatl` | 取证回报与一手出处（`inbox/anam/`） |
| `dev-e` / `ana-e` / `pm-e` | worktree 代码提交 / 取证材料 / 核对材料（经派生者收口） |

**三层命名**：技能名带 `dmt-` 前缀（`dmt-director` / `dmt-pm` / `dmt-dm` / `dmt-am` / `dmt-dtl` / `dmt-atl`），用于技能注册表、安装目录与斜杠命令；运行 id 不带前缀（`director` / `pm` / `devm` / `anam` / `devtl{n}` / `anatl{n}` / `dev-e` / `ana-e` / `pm-e`），用于 pane label、收件箱目录与方向码；正文与日志用称呼（总监／开发经理／分析经理／开发队长{n}／分析队长{n}）。**三层不混写。**

**单线指挥**：每个角色只与直属上下级通信；director 不越级指挥队长与工程师，队长之间、经理之间不横向直连，跨部门一律经 director 转派。**工程师永远是子代理**（不占 pane、不走跨 pane 通信）：未超阈值时由经理开、超过时由队长开（`devm` 4 / `anam` 2） —— 经理与工程师之间没有 pane 级通道，只有父子代理关系；`pm-e` 由 `pm` 直接开。
队长**按需生成、用完即关**：经理**只在排队任务超过阈值时（`devm` >4、`anam` >4）**用 `herdr pane split "$HERDR_PANE_ID" --direction right --cwd "$PWD" --no-focus` 在**自己的 tab 内**开队长 pane，再 `herdr pane rename <pane> devtl{n}`（anam 同理建 `anatl{n}`），并代启动 harness（`codebuddy --permission-mode auto`）后输入 `/dmt-dtl` / `/dmt-atl` 装载队长技能；本批收口且确认无下一批可派后，由**创建者本人**用 `herdr pane close <pane>` 关闭（`pane` 按 `herdr pane list` 的 **pane label** 解析）。**关闭前置三件事**（回报已入账、worktree 已 `git worktree remove`、收件箱无该队长未读）顺序固定、缺一不可；**禁止先关后收**（关 pane 即终止该 agent 会话、context 不可恢复）；**禁止 `herdr tab close`**（队长与经理同 tab，关 tab 会连带杀掉经理）；**批内可复用、批间不保留**；非创建者不得代关。细则见 `team.md` §1.2。

成员运行在 Herdr（终端多智能体复用器）中，**按 pane label 识别伙伴**（label 与角色名同名、全 workspace 唯一；不看 tab 内位置，pane id 每次发送前重查）。
**角色间通信 = 收件箱文件 + herdr 门铃**：正文写进收件方 `inbox/<收件角色>/{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`（项目根，不在 `docs/` 下），herdr 只发一句「你有新消息 …」；收件方读后**不回执**：先 `msg-take.sh` 移到 `inbox/<自己>/.doing/`（认领），办完 `msg-done.sh` 删除（详见 `team.md` §1.3）。
工作流一句话：director 定验收口径 → anam 做调研（director 评审）+ pm 落笔 PRD、SPEC 与工单并做文档门禁自评（director 只确认需求口径）→ devm 接单排期，按排队数自派 dev-e 或开队长 pane → 队长开 dev-e 实施并初检 → devm 评审（代码门禁）整合 → director 抽查后 `git push`（至少每 ticket 一推、每小时巡检未推送变更）。装机（`adb install` 等）与 `git push` **只由 director 执行**。

**团队契约（组织、通信、文件命名、目录职责与纪律的唯一权威）＝ [`dmt-director/team.md`](dmt-director/team.md)。**

```
dmt/                              # 一个角色一个文件夹
├── README.md                                 # 项目总说明（本文件）
├── dmt-director/                                 # 总监（技能 director）
│   ├── SKILL.md
│   ├── team.md                         # 团队契约（唯一权威）
│   ├── README.md                       # 指针：根目录 README.md
│   └── scripts/                        # 机检 / 文件占用 / 初始化 / 建团队 / 开队长 / 关队长 / 发消息 / 推送 / 安装
├── dmt-pm/SKILL.md                      # 产品部经理（pm）
├── dmt-dm/SKILL.md                      # 开发经理
├── dmt-am/SKILL.md                      # 分析经理
├── dmt-dtl/SKILL.md                     # 开发队长（devtl{n}）
└── dmt-atl/SKILL.md                     # 分析队长（anatl{n}）
```

## 安装到一个项目

仓内目录名即技能名（`dmt-director` / `dmt-pm` / `dmt-dm` / `dmt-am` / `dmt-dtl` / `dmt-atl`），**装到技能目录时同名复制**。运行 id（`devm` 等）只是 pane label 与收件箱名，不随技能名变化。

```bash
# 软链安装（推荐，跟随本仓更新）
bash dmt-director/scripts/install-skills.sh <项目根>

# 复制安装（目标项目不跟随本仓）
bash dmt-director/scripts/install-skills.sh <项目根> --copy
```

脚本做五件事：建 `.agents/skills/` 与 `scripts/`；软链或复制六个技能目录；把 `team.md` 复制到 `docs/team.md`；把 `scripts/*.sh` 复制到项目 `scripts/`；调用 `init-project.sh` 建目录、写 `.gitignore` 并跑机检。

软链整个角色目录时，`dmt-director/` 里的契约、说明与机检脚本一并可见，不影响技能加载。
装到其他 harness（codebuddy / codex / opencode 等）的用户级技能目录时，规则同样是**目录名即技能名**。

## 机检

```bash
bash dmt-director/scripts/check-dmt-doc-paths.sh <项目根目录>   # 省略参数则检查当前目录
# 技能未装在 <项目根>/.agents/skills 时，用 DMT_SKILLS_DIR 覆盖（默认值见脚本第 9 行）
```

判据**十六项**：① 六个产物目录 + 根目录 `inbox/` 存在（**缺则由 director 初始化时补齐**，见 `team.md` §3.1）；② 六个技能（`dmt-director` / `dmt-pm` / `dmt-dm` / `dmt-am` / `dmt-dtl` / `dmt-atl`）各自指向自己的唯一目录（PRD / SPEC / 工单 / 人类文档归 `dmt-pm`）；③ **队长实例关闭动作已登记**（契约与 `dmt-dm` / `dmt-am` 技能含 `close-leader.sh`、契约含「只许关 pane」）；④ **身份识别已登记**（契约与六个技能含 `pane label`）；⑤ **队长层并行判据已登记**（`dmt-dtl` / `dmt-atl` 含「必须并行」、契约含「≥2 ⇒ 必须并发派发」）；⑥ **经理层路径判据与饱和派发已登记**（`dmt-dm` 含「≤4」「>4」、`dmt-am` 含「≤4」「>4」、契约含「≤4 ⇒ 自己派生 `dev-e`」与「≤4 ⇒ 自己派生 `ana-e`」，以及「并发数 = 单元数」；`dmt-dm` / `dmt-am` 含「开满」与 `teammate`）；⑦ **装机与推送归属已登记**（契约含「只由 director」、`dmt-director` 含 `git push`、`dmt-dm` 含「不得 push」、契约含「每小时」）；⑧ **mattpocock 强制技能已逐角色登记**（契约含「强制使用」与角色表，六个技能各含自己的强制技能名）；⑨ **文件占用已登记**（契约含「文件占用」与 `file-claim`，六个角色技能各含 `file-claim`，脚本存在）；⑩ **评审门禁归属已登记**（契约与 `dmt-pm` 含「文档门禁」、契约与 `dmt-dm` 含「代码门禁」、`dmt-director` 含「不替代」）；⑪ **cbc-herdr 通用技能已登记**（六个 pane 角色技能各含 `cbc-herdr`）；⑫ **技能链接与上游一致**（契约与六个技能都含 `raw.githubusercontent.com`）；⑬ **确定性动作已脚本化**（十一个脚本存在且可执行）；⑭ **收件箱三态已登记**（契约含 `.doing/` 与 `.seq`、六个技能各含 `msg-take.sh`）；⑮ 本契约登记齐全；⑯ 负样本能被正确拒绝（**只查 §3 落盘登记表**，§8 历史留痕不算登记）。**改路径规范、pane 生命周期、并行口径、角色层级、写权限、强制技能、文件占用、评审门禁、通用技能、技能链接、收件箱三态或脚本接口后必须重跑。**

## 维护

- 本仓是 dmt 的**唯一维护地**，使用方不保留副本；软链后技能与契约随本仓更新，改完即生效（无需重装）。
- 技能内的契约引用不依赖相对路径（写作「`dmt-director/team.md`（本仓；装到项目后为 `docs/team.md`）」），因此软链安装不会断链。
- 脚本接口变更（参数、输出、退出码）视为契约变更，必须同步六个技能与机检 4j。
- 依赖 harness 侧技能：`herdr`（pane 控制与 label 识别）、`cbc-herdr`（CodeBuddy 状态上报）、`pi-subagents`（仅 pi harness；cbc 用 Agent/team 子代理），以及 mattpocock 的 [`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)、[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)、[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)、[`/tdd`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md)、[`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md) 等（安装与回退见 `team.md` §1.4）。
