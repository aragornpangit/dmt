# dmt

dmt 团队的角色技能仓：**团队定义与六个角色技能的唯一维护地**。层级：`director`（总监兼产品部经理）→ 部门经理（`devm` / `anam`）→ 队长（`devtl{n}` / `anatl{n}`）→ 工程师（`dev-e` / `ana-e` / `pde{n}`）。
**产品部并入总监**：director 写 PRD / SPEC / 工单时召唤 `pde{n}` 落笔（人类文档亲自落笔），自派 `pde{n}` / `reviewer{n}` 子代理（`dmt-pde` 技能，不占 tab 不占 pane），不设产品经理与产品队长；`devm` pane 在 director tab 内右侧，`anam` 独立 tab。
**队长层是按需的，且有数值判据**：经理**排队任务未超阈值时自己派生工程师子代理**（`devm` ≤8、`anam` ≤8）；**待办任务超过 8 个**才用 `bash dmt-director/scripts/spawn-leader.sh` 在**自己的 tab 内**开队长 pane（脚本内部 `herdr pane split` / `pane rename`，带 `min(8, cap)` 并发实例数闸门；pane label 固定为 `devtl{n}` / `anatl{n}`，**优先 cbc harness** 并输入 `/dmt-dtl` / `/dmt-atl`），队长接单后再开工程师子代理；**队长 pane 生命周期归经理**（经理建 pane、维护 label），**tl 完成任务即由经理用 `bash dmt-director/scripts/close-leader.sh` 关闭**（收件箱安检）。

| 角色 | 技能名 | 运行 id（pane label） | 直属上级 | 直属下级 | 职责摘要 |
|---|---|---|---|---|---|
| 总监兼产品部经理 | `dmt-director` | `director` | 用户 | `devm`、`anam`（+ 自派 `pde{n}`） | 唯一入口；接需求与验收口径、召唤 `pde{n}` 落笔 PRD / SPEC / 工单（director 定稿）、落笔人类文档并出文档门禁结论、分派、裁决、维护 pane/tab；抽查放行（merge / push 归 devm，不代推）与装机；**不替代** devm 的代码评审 |
| 产品工程师（子代理） | `dmt-pde` | `pde{n}` | `director` | — | **落笔 PRD / SPEC / 工单**、产品事实取证、用户故事与边界枚举、验收标准核对；**不占 tab 不占 pane**，director 自派、一单元一实例 |
| 开发经理 | `dmt-dm` | `devm` | `director` | `dev-e`（≤8 自派）或 `devtl{n}`（>8） | 依用户要求与 tickets 计划直接干活（知会 director 即可）、排期派活、**代码门禁**（ticket 代码评审责任人）、整合交付物、**merge 与 push（代码库归 devm 管理）**；**不拆票** |
| 分析经理 | `dmt-am` | `anam` | `director` | `ana-e`（≤8 自派）或 `anatl{n}`（>8） | 依用户要求与 tickets 计划直接干活（知会 director 即可）；按排队数自派子代理或开队长 pane；复核出处、收口调研报告 |
| 开发队长 | `dmt-dtl` | `devtl1`、`devtl2` …（在 devm 的 tab 内） | `devm` | `dev-e`（子代理） | 由经理按需生成；建 worktree、并发派开发工程师、收 diff 做初检、回报 devm |
| 分析队长 | `dmt-atl` | `anatl1`、`anatl2` …（在 anam 的 tab 内） | `anam` | `ana-e`（子代理） | 由经理按需生成；拆子问题、派分析工程师并行取证、复核出处、回报 anam |

| 角色 | 强制技能（mattpocock，必须使用） |
|---|---|
| 总监 `director` | [`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)（问穿验收口径）、[`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md)（方案自审）、[`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md)（契约/文档交叉拷问）、[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)（抽查）、[`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)（SPEC 落笔）、[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)（工单拆解） |
| 产品工程师 `pde{n}` | [`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)（口径核对）、[`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md)（事实取证）、[`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)、[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)（SPEC / 工单拆解与核对，**与 director 匹配同一套**），**写进派发 prompt** |
| 开发经理 `devm` | [`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)（评审整合前）、[`/diagnosing-bugs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/diagnosing-bugs/SKILL.md)（缺陷分诊） |
| 开发队长 `devtl` | [`/tdd`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md)、[`/implement`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/implement/SKILL.md)、[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)、[`/diagnosing-bugs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/diagnosing-bugs/SKILL.md) |
| 分析经理 `anam` | [`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md)、[`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)、[`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md)、[`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md) |
| 分析队长 `anatl` | [`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md)、[`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)、[`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md)、[`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md) |
| 工程师 `dev-e` / `ana-e` | 由派发 prompt 强制写入（见 `team.md` §1.4） |

技能名与 [`mattpocock/skills`](https://github.com/mattpocock/skills) 上游**逐字一致**，链接指向 `raw.githubusercontent.com` 源文件；`/rea` 属 REA、不在该仓内，保持原名。

另：五个 pane 常驻角色（`director` / `devm` / `anam` / `devtl` / `anatl`）都加载 **`cbc-herdr`**（CodeBuddy 在 herdr 的状态上报）；工程师子代理不占 pane，不需要。

| 角色 | 交付物（落盘位置） |
|---|---|
| `director` | `docs/team.md`；`docs/pd/prd/` PRD、`docs/pd/spec/` SPEC、`docs/dev/tickets/` 工单、`docs/human/human-arch/`、`docs/human/human-plan/`（`pde{n}` 只交证据不落盘）；按需 `docs/handoff/`（director / devm）；评审结论（收件箱）；装机 |
| `devm` | 票面末尾「实施状态」；合并后的主干代码；验收证据（收件箱回报）；**merge 与 push**；GitLab 推送（每 ticket 一推 ＋ 每小时巡检） |
| `devtl` | 实施层初检回报（`inbox/devm/`）；`feat/{ticket-id}` 分支提交 |
| `anam` | `docs/analyst/` 调研报告 ＋ `docs/analyst/evidence/` 一手证据 |
| `anatl` | 取证回报与一手出处（`inbox/anam/`） |
| `pde{n}` / `dev-e` / `ana-e` | 取证材料 / worktree 代码提交 / 核对材料（经派生者收口） |

**三层命名**：技能名带 `dmt-` 前缀（`dmt-director` / `dmt-pde` / `dmt-dm` / `dmt-am` / `dmt-dtl` / `dmt-atl`），用于技能注册表、安装目录与斜杠命令；运行 id 不带前缀（`director` / `devm` / `anam` / `devtl{n}` / `anatl{n}` / `pde{n}` / `dev-e` / `ana-e`），用于 pane label、收件箱目录与方向码；正文与日志用称呼（总监／开发经理／分析经理／开发队长{n}／分析队长{n}）。**三层不混写。**

**单线指挥**：每个角色只与直属上下级通信；director 不越级指挥队长与工程师，队长之间、经理之间不横向直连，跨部门一律经 director 转派。**工程师永远是子代理**（不占 pane、不走跨 pane 通信）：未超阈值时由经理开、超过时由队长开（`devm` 8 / `anam` 8） —— 经理与工程师之间没有 pane 级通道，只有父子代理关系；`pde{n}` 由 `director` 直接开。
队长**按需生成、任务完成即关（pane 生命周期归经理）**：经理**只在待办任务超过 8 个时（`devm` >8、`anam` >8）**用 `bash dmt-director/scripts/spawn-leader.sh` 在**自己的 tab 内**开队长 pane（脚本内部 `herdr pane split "$HERDR_PANE_ID" --direction right --cwd "$PWD" --no-focus` 建 pane、`herdr pane rename <pane> devtl{n}` 维护 pane-name（label）（anam 同理建 `anatl{n}`），并带 `min(8, cap)` 并发实例数闸门、达到上限拒开；**不得手敲 `herdr pane split` / `pane rename` 绕过闸门**），并代启动 harness（`codebuddy --permission-mode auto`）后输入 `/dmt-dtl` / `/dmt-atl` 装载队长技能；**tl 完成任务即由创建者本人（经理）**用 `bash dmt-director/scripts/close-leader.sh <devm|anam> <n>` 关闭（脚本内部按 `herdr pane list` 的 **pane label** 解析 `pane` 并 `herdr pane close`，带收件箱安检；**不得手敲 `herdr pane close` 绕过安检**）。**关闭前置三件事**缺一不可：① 回报已入账、② worktree 已 `git worktree remove` —— 两项由关闭者人工确认（脚本打印清单）；③ 收件箱无该队长未读 —— 脚本自动判（按 `{seq}-{队长}2{经理}-` 方向过滤，含 `.doing/`）；**禁止先关后收**（关 pane 即终止该 agent 会话、context 不可恢复）；**禁止 `herdr tab close`**（队长与经理同 tab，关 tab 会连带杀掉经理）；**批内可复用、批间不保留**；非创建者不得代关。细则见 `team.md` §1.2。

成员运行在 Herdr（终端多智能体复用器）中，**按 pane label 识别伙伴**（label 与角色名同名、全 workspace 唯一；不看 tab 内位置，pane id 每次发送前重查）。
**角色间通信 = 收件箱文件 + herdr 门铃**：正文写进收件方 `inbox/<收件角色>/{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`（项目根，不在 `docs/` 下），herdr 只发一句「你有新消息 …」；收件方读后**不回执**：先 `msg-take.sh` 移到 `inbox/<自己>/.doing/`（认领），办完 `msg-done.sh` 删除（详见 `team.md` §1.3）。
工作流一句话：anam 做调研（director 评审）→ director 定验收口径并召唤 `pde{n}` 落笔 PRD、SPEC 与工单（文档门禁自评）→ devm 接单排期，按排队数自派 dev-e 或开队长 pane → 队长开 dev-e 实施并初检 → devm 完成票并代码门禁评审 → director 按票数派 reviewer1…reviewer{n} 对照同 spec-seq 的 SPEC+ticket 逐条验收 → 通过通知 devm merge/push（reviewer{n} 为子代理、不占 pane 不装技能，`/code-review` 写进派发 prompt，按需求开、上限 `min(8, cap)`；merge 与 push 只归 devm：至少每完成一个 ticket 推送一次、至少每小时巡检未推送变更，代码库归 devm 管理），不通过打回 devm 返工、不得先 merge/push。装机（`adb install` 等）**只许 `director` 执行**。devm / anam 可**依用户要求与 tickets 计划直接干活**，知会 director 即可；director **默认放行，只有觉得不合适才出面制止**（畅通无阻）。

**团队契约（组织、通信、文件命名、目录职责与纪律的唯一权威）＝ [`dmt-director/team.md`](dmt-director/team.md)。**

```
dmt/                              # 一个角色一个文件夹
├── README.md                                 # 项目总说明（本文件）
├── dmt-director/                                 # 总监（技能 dmt-director）
│   ├── SKILL.md
│   ├── team.md                         # 团队契约（唯一权威）
│   ├── README.md                       # 仓库说明与安装（根 README.md）
│   └── scripts/                        # 机检 / 文件占用 / 初始化 / 建团队 / 开队长 / 关队长 / 发消息 / 认领 / 收口 / 派发账本 / hooks / CAP 探测 / 并行派发 / 推送 / 安装
├── dmt-pde/SKILL.md                      # 产品工程师（pde{n} 子代理技能，不占 pane）
├── dmt-dm/SKILL.md                      # 开发经理
├── dmt-am/SKILL.md                      # 分析经理
├── dmt-dtl/SKILL.md                     # 开发队长（devtl{n}）
└── dmt-atl/SKILL.md                     # 分析队长（anatl{n}）
```

## 安装到一个项目

仓内目录名即技能名（`dmt-director` / `dmt-pde` / `dmt-dm` / `dmt-am` / `dmt-dtl` / `dmt-atl`），**装到技能目录时同名复制**。运行 id（`devm` 等）只是 pane label 与收件箱名，不随技能名变化。

```bash
# 软链安装（推荐，跟随本仓更新）
bash dmt-director/scripts/install-skills.sh <项目根>

# 复制安装（目标项目不跟随本仓）
bash dmt-director/scripts/install-skills.sh <项目根> --copy
```

脚本做五件事：建 `.agents/skills/` 与 `<项目根>/dmt-director/`；软链或复制六个技能目录；把 `team.md` 复制到 `docs/team.md`；把整个 `dmt-director/`（含 `scripts/`）链接或复制到项目根 —— **脚本路径一律写 `dmt-director/scripts/…`**，旧的 `<项目根>/scripts/` 已废弃；调用 `init-project.sh` 建目录、写 `.gitignore` 并跑机检。

软链整个角色目录时，`dmt-director/` 里的契约、说明与机检脚本一并可见，不影响技能加载。
装到其他 harness（codebuddy / codex / opencode 等）的用户级技能目录时，规则同样是**目录名即技能名**。

## 机检

```bash
bash dmt-director/scripts/check-dmt-doc-paths.sh <项目根目录>   # 省略参数则检查当前目录
# 技能未装在 <项目根>/.agents/skills 时，用 DMT_SKILLS_DIR 覆盖（默认值见脚本第 9 行）
```

判据**十八项（另含 2b / 4c 两组专项，共 20 组断言）**：① 六个产物目录 + 根目录 `inbox/` 存在（**缺则由 director 初始化时补齐**，见 `team.md` §3.1）；② 六个技能（`dmt-director` / `dmt-pde` / `dmt-dm` / `dmt-am` / `dmt-dtl` / `dmt-atl`）各自指向自己的唯一目录（PRD / SPEC / 工单 / 人类文档归 `dmt-director`；`dmt-pde` 为 `pde{n}` 子代理技能）；③ **队长实例关闭动作已登记**（契约与 `dmt-dm` / `dmt-am` 技能含 `close-leader.sh`、契约含「只许关 pane」与「禁止先关后收」）；④ **身份识别已登记**（契约与六个技能含 `pane label`、契约含「不按 tab 内位置」）；⑤ **队长层并行判据已登记**（`dmt-dtl` / `dmt-atl` 含「必须并行」、契约含「≥2 ⇒ 必须并发派发」）；⑥ **经理层路径判据与按需派发已登记**（`dmt-dm` 含「≤8」「>8」、`dmt-am` 含「≤8」「>8」，契约含「≤8 ⇒ 自己派生 `dev-e`」与「≤8 ⇒ 自己派生 `ana-e`」，以及「min(8, cap)」（cap = harness 最大支持的 agent 数；有效 CAP = `min(8, cap)`、探测不到默认 8，N > CAP 分批推进；总监 / 经理 / 队长同一时刻在途实例一律 ≤ `min(8, cap)`）；`dmt-dm` / `dmt-am` 含「按需求开」与 `teammate`）；⑦ **装机与推送归属已登记**（装机：契约含「只许 `director` 执行」（反引号）；推送与合并：契约含「merge 与 push 只归 devm」、`dmt-dm` 含「push 与 merge 归 devm」、`dmt-director` 含「不代推」、负向断言「git push 后紧跟只由 director」不得出现、契约含「至少每完成一个 ticket 推送一次」与「至少每小时」）；⑧ **mattpocock 强制技能已逐角色登记**（契约含「强制使用」与角色表，六个技能各含自己的强制技能名）；⑨ **文件占用已登记**（契约含「文件占用」与 `file-claim`，六个角色技能各含 `file-claim`，脚本存在）；⑩ **评审门禁归属已登记**（契约与 `dmt-director` 含「文档门禁」、契约与 `dmt-dm` 含「代码门禁」、`dmt-director` 含「不替代」）；⑪ **cbc-herdr 通用技能已登记**（五个 pane 角色技能各含 `cbc-herdr`）；⑫ **技能链接与上游一致**（契约与六个技能都含 `raw.githubusercontent.com`）；⑬ **确定性动作已脚本化**（十七个脚本存在且可执行，含 `probe-cap.sh` / `fanout.sh` / `parallel-guard.sh`）；⑭ **收件箱三态已登记**（契约含 `.doing/` 与 `.seq`、五个 pane 角色技能各含 `msg-take.sh`）；⑮ **先派后干、并发账与完成即报已登记**（契约与五个派发技能 `dmt-director` / `dmt-dm` / `dmt-am` / `dmt-dtl` / `dmt-atl` 含「先派后干」「并发账」；契约与 `dmt-director` / `dmt-dm` / `dmt-am` / `dmt-dtl` / `dmt-atl` 含「完成即报」；契约含「派发合规」）；⑯ 本契约登记齐全；⑰ **契约头部带版本号与日期且与六个技能同号**（`team.md` 头部 `版本 X.Y.Z · YYYY-MM-DD`，六份 `SKILL.md` 的 `version:` 与之一致，脚本 4m）；⑱ 负样本能被正确拒绝（**只看契约的表格登记行**，§8 历史留痕不算登记）。**改路径规范、pane 生命周期、并行口径、角色层级、写权限、强制技能、文件占用、评审门禁、通用技能、技能链接、收件箱三态或脚本接口后必须重跑。**

## 维护

- 本仓是 dmt 的**唯一维护地**，使用方不保留副本；软链后技能与契约随本仓更新，改完即生效（无需重装）。
- 技能内的契约引用不依赖相对路径（写作「`dmt-director/team.md`（本仓；装到项目后为 `docs/team.md`）」），因此软链安装不会断链。
- 脚本接口变更（参数、输出、退出码）视为契约变更，必须同步六个技能与机检 4m。
- 依赖 harness 侧技能：`herdr`（pane 控制与 label 识别）、`cbc-herdr`（CodeBuddy 状态上报）、`pi-subagents`（仅 pi harness；cbc 用 Agent/team 子代理），以及 mattpocock 的 [`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)、[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)、[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)、[`/tdd`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md)、[`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md) 等（安装与回退见 `team.md` §1.4）。
