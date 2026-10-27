# dmt

dmt 团队的角色技能仓：**团队定义与四个角色技能的唯一维护地**。层级：`director`（总监兼产品部经理）→ 部门经理（`devm` / `anam`）→ 工程师（`dev-e` / `ana-e` / `pde{n}`）。
**产品部并入总监**：director 写 PRD / SPEC / 工单时召唤 `pde{n}` 落笔（人类文档亲自落笔），自派 `pde{n}` / `reviewer{n}` 子代理（`dmt-pde` 技能，不占 tab 不占 pane），不设产品经理；`devm` pane 在 director tab 内右侧，`anam` 独立 tab。
**经理直接派工程师**：`devm` / `anam` 一律直接派 `dev-e` / `ana-e` 子代理（按需求开，上限 `min(8, cap)`）；建 worktree、实施层初检与一手出处复核由经理收口，**不设队长层**。

| 角色 | 技能名 | 运行 id（pane label） | 直属上级 | 直属下级 | 职责摘要 |
|---|---|---|---|---|---|
| 总监兼产品部经理 | `dmt-director` | `director` | 用户 | `devm`、`anam`（+ 自派 `pde{n}`） | 唯一入口；接需求与验收口径、召唤 `pde{n}` 落笔 PRD / SPEC / 工单（director 定稿）、落笔人类文档并出文档门禁结论、分派、裁决、维护 pane/tab；抽查放行（merge / push 归 devm，不代推）与装机；**不替代** devm 的代码评审 |
| 产品工程师（子代理） | `dmt-pde` | `pde{n}` | `director` | — | **落笔 PRD / SPEC / 工单**、产品事实取证、用户故事与边界枚举、验收标准核对；**不占 tab 不占 pane**，director 自派、一单元一实例 |
| 开发经理 | `dmt-dm` | `devm` | `director` | `dev-e`（子代理） | 依用户要求与 tickets 计划直接干活（知会 director 即可）、排期派活、建 worktree、派 `dev-e` 实施、收 diff 做实施层初检、**代码门禁**（ticket 代码评审责任人）、整合交付物、**merge 与 push（代码库归 devm 管理）**；**不拆票** |
| 分析经理 | `dmt-am` | `anam` | `director` | `ana-e`（子代理） | 依用户要求与 tickets 计划直接干活（知会 director 即可）；拆子问题、派 `ana-e` 并行取证、复核一手出处、收口调研报告 |

| 角色 | 强制技能（mattpocock，必须使用） |
|---|---|
| 总监 `director` | [`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)（问穿验收口径）、[`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md)（方案自审）、[`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md)（契约/文档交叉拷问）、[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)（抽查）、[`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)（SPEC 落笔）、[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)（工单拆解） |
| 产品工程师 `pde{n}` | [`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)（口径核对）、[`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md)（事实取证）、[`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)、[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)（SPEC / 工单拆解与核对，**与 director 匹配同一套**），**写进派发 prompt** |
| 开发经理 `devm` | [`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)（评审整合前）、[`/diagnosing-bugs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/diagnosing-bugs/SKILL.md)（缺陷分诊） |
| 分析经理 `anam` | [`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md)、[`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)、[`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md)、[`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md) |
| 工程师 `dev-e` / `ana-e` | `dev-e`：[`/tdd`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md)、[`/implement`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/implement/SKILL.md)、[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)、[`/diagnosing-bugs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/diagnosing-bugs/SKILL.md)；`ana-e`：[`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md)、`/rea`、[`/grilling`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md)、[`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md)、[`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md) —— 由派发 prompt 强制写入（见 `team.md` §1.4） |

技能名与 [`mattpocock/skills`](https://github.com/mattpocock/skills) 上游**逐字一致**，链接指向 `raw.githubusercontent.com` 源文件；`/rea` 属 REA、不在该仓内，保持原名。

另：三个 pane 常驻角色（`director` / `devm` / `anam`）都加载 **`cbc-herdr`**（CodeBuddy 在 herdr 的状态上报）；工程师子代理不占 pane，不需要。

| 角色 | 交付物（落盘位置） |
|---|---|
| `director` | `docs/team.md`；`docs/pd/prd/` PRD、`docs/pd/spec/` SPEC、`docs/dev/tickets/` 工单、`docs/human/human-arch/`、`docs/human/human-plan/`（`pde{n}` 只交证据不落盘）；按需 `docs/handoff/`（director / devm）；评审结论（收件箱）；装机 |
| `devm` | 票面末尾「实施状态」；合并后的主干代码；`feat/{ticket-id}` 分支提交（worktree）；实施层初检结论；验收证据（收件箱回报）；**merge 与 push**；GitLab 推送（每 ticket 一推 ＋ 每小时巡检） |
| `anam` | `docs/analyst/` 调研报告 ＋ `docs/analyst/evidence/` 一手证据；取证回报与一手出处复核 |
| `pde{n}` / `dev-e` / `ana-e` | 取证材料 / worktree 代码提交 / 核对材料（经派生者收口） |

**三层命名**：技能名带 `dmt-` 前缀（`dmt-director` / `dmt-pde` / `dmt-dm` / `dmt-am`），用于技能注册表、安装目录与斜杠命令；运行 id 不带前缀（`director` / `devm` / `anam` / `pde{n}` / `dev-e` / `ana-e`，helper 为 `{角色}-helper`），用于 pane label、收件箱目录与方向码；正文与日志用称呼（总监／开发经理／分析经理）。**三层不混写。**

**单线指挥**：每个角色只与直属上下级通信；director 不越级指挥工程师，经理之间不横向直连，跨部门一律经 director 转派。**工程师永远是子代理**（不占 pane、不走跨 pane 通信）：一律由经理直接开（`devm` 开 `dev-e`、`anam` 开 `ana-e`，按需求开、上限 `min(8, cap)`）—— 经理与工程师之间没有 pane 级通道，只有父子代理关系；`pde{n}` 由 `director` 直接开。
**helper（`{角色}-helper`，本体的纯分身，每角色至多一个）**：`director-helper` / `devm-helper` / `anam-helper` 是本体的**纯分身**——任务随 spawn **一次性下发**，此后**不接受任何输入框内容**；工作成果**单向汇报给主体**（`{角色}`）；helper **没有自己的 inbox**（不收件），**不走门铃互通**。**生命周期由创建者（本体角色）维护**：用 `bash dmt-director/scripts/spawn-helper.sh <director|devm|anam>` 建立（幂等，支持 `--dry-run` / `--no-start`；helper tab label 固定 `helper`（全队共享一个），pane label 固定 `{角色}-helper`，代启动 harness 并装载**同角色技能**）、label 漂移自愈改名、任务完成用 `bash dmt-director/scripts/close-helper.sh <director|devm|anam>` 回收（支持 `--force` / `--dry-run`；**helper tab 保留复用，不随 pane 关闭**）。**独占动作不移交**：装机只归 `director` 本体、merge / push 只归 `devm` 本体。

成员运行在 Herdr（终端多智能体复用器）中，**按 pane label 识别伙伴**（label 与角色名同名、全 workspace 唯一；不看 tab 内位置，pane id 每次发送前重查）。
**角色间通信 = 收件箱文件 + herdr 门铃**：正文写进收件方 `inbox/<收件角色>/{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`（项目根，不在 `docs/` 下），herdr 只发一句「你有新消息 …」；收件方读后**不回执**：先 `msg-take.sh` 移到 `inbox/<自己>/.doing/`（认领），办完 `msg-done.sh` 删除（详见 `team.md` §1.3）。
工作流一句话：anam 做调研（director 评审）→ director 定验收口径并召唤 `pde{n}` 落笔 PRD、SPEC 与工单（文档门禁自评）→ devm 接单排期，**devm / anam 直接派工程师子代理（按需求开，上限 `min(8, cap)`）、实施层初检与出处复核由经理收口** → devm 完成票并代码门禁评审 → director 按票数派 reviewer1…reviewer{n} 对照同 spec-seq 的 SPEC+ticket 逐条验收 → 通过通知 devm merge/push（reviewer{n} 为子代理、不占 pane 不装技能，`/code-review` 写进派发 prompt，按需求开、上限 `min(8, cap)`；merge 与 push 只归 devm：至少每完成一个 ticket 推送一次、至少每小时巡检未推送变更，代码库归 devm 管理），不通过打回 devm 返工、不得先 merge/push。装机（`adb install` 等）**只许 `director` 执行**。devm / anam 可**依用户要求与 tickets 计划直接干活**，知会 director 即可；director **默认放行，只有觉得不合适才出面制止**（畅通无阻）。

**团队契约（组织、通信、文件命名、目录职责与纪律的唯一权威）＝ [`dmt-director/team.md`](dmt-director/team.md)。**

```
dmt/                              # 一个角色一个文件夹
├── README.md                                 # 项目总说明（本文件）
├── dmt-director/                                 # 总监（技能 dmt-director）
│   ├── SKILL.md
│   ├── team.md                         # 团队契约（唯一权威）
│   ├── README.md                       # 仓库说明与安装（根 README.md）
│   └── scripts/                        # 机检 / 文件占用 / 初始化 / 建团队 / 建 helper / 关 helper / 发消息 / 认领 / 收口 / 派发账本 / hooks / CAP 探测 / 并行派发 / 推送 / 安装
├── dmt-pde/SKILL.md                      # 产品工程师（pde{n} 子代理技能，不占 pane）
├── dmt-dm/SKILL.md                      # 开发经理
└── dmt-am/SKILL.md                      # 分析经理
```

## 安装到一个项目

仓内目录名即技能名（`dmt-director` / `dmt-pde` / `dmt-dm` / `dmt-am`），**装到技能目录时同名复制**。运行 id（`devm` 等）只是 pane label 与收件箱名，不随技能名变化。

```bash
# 软链安装（推荐，跟随本仓更新）
bash dmt-director/scripts/install-skills.sh <项目根>

# 复制安装（目标项目不跟随本仓）
bash dmt-director/scripts/install-skills.sh <项目根> --copy
```

脚本做五件事：建 `.agents/skills/` 与 `<项目根>/dmt-director/`；软链或复制四个技能目录；把 `team.md` 复制到 `docs/team.md`；把整个 `dmt-director/`（含 `scripts/`）链接或复制到项目根 —— **脚本路径一律写 `dmt-director/scripts/…`**，旧的 `<项目根>/scripts/` 已废弃；调用 `init-project.sh` 建目录、写 `.gitignore` 并跑机检。

软链整个角色目录时，`dmt-director/` 里的契约、说明与机检脚本一并可见，不影响技能加载。
装到其他 harness（codebuddy / codex / opencode 等）的用户级技能目录时，规则同样是**目录名即技能名**。

## 机检

```bash
bash dmt-director/scripts/check-dmt-doc-paths.sh <项目根目录>   # 省略参数则检查当前目录
# 技能未装在 <项目根>/.agents/skills 时，用 DMT_SKILLS_DIR 覆盖（默认值见脚本第 9 行）
```

判据**十八项（另含 2b / 4c 两组专项，共 20 组断言）**：① 六个产物目录 + 根目录 `inbox/` 存在（**缺则由 director 初始化时补齐**，见 `team.md` §3.1）；② 四个技能（`dmt-director` / `dmt-pde` / `dmt-dm` / `dmt-am`）各自指向自己的唯一目录（PRD / SPEC / 工单 / 人类文档归 `dmt-director`；`dmt-pde` 为 `pde{n}` 子代理技能）；③ **helper 纯分身语义与回收动作已登记**（契约含「一次性下发」「不接受任何输入框内容」「单向汇报」「没有自己的 inbox」「禁止先关后收」「只许关 pane」；契约与 `dmt-director` / `dmt-dm` / `dmt-am` 含 `close-helper.sh`；`spawn-helper.sh` 含「一次性下发」）；④ **身份识别已登记**（契约与四个技能含 `pane label`、契约含「不按 tab 内位置」）；⑤ **经理层并行判据已登记**（`dmt-dm` / `dmt-am` 含「必须并行」、契约含「无依赖任务一律派子代理」与「min(N, CAP)」）；⑥ **经理直派与按需派发已登记**（契约含「min(8, cap)」（cap = harness 最大支持的 agent 数；有效 CAP = `min(8, cap)`、探测不到默认 8，N > CAP 分批推进；总监 / 经理同一时刻在途实例一律 ≤ `min(8, cap)`）；`dmt-dm` / `dmt-am` 含「按需求开」与 `teammate`）；⑦ **装机与推送归属已登记**（装机：契约含「只许 `director` 执行」（反引号）；推送与合并：契约含「merge 与 push 只归 devm」、`dmt-dm` 含「push 与 merge 归 devm」、`dmt-director` 含「不代推」、负向断言「git push 后紧跟只由 director」不得出现、契约含「至少每完成一个 ticket 推送一次」与「至少每小时」）；⑧ **mattpocock 强制技能已逐角色登记**（契约含「强制使用」与角色表；技能侧 `dmt-director` / `dmt-pde` / `dmt-dm` / `dmt-am` 各含自己的强制技能名（`dmt-dm` 含 `/code-review`、`dmt-am` 含 `/research` 等）；`dev-e` / `ana-e` 吸收的执行技能登记在**契约角色表 `dev-e` / `ana-e` 行**（契约含 `/tdd`、`/implement`、`/diagnosing-bugs`、`/rea`、`/grilling`、`/grill-me`、`/grill-with-docs`，4e 共 7 条契约断言））；⑨ **文件占用已登记**（契约含「文件占用」与 `file-claim`，四个技能各含 `file-claim`，脚本存在）；⑩ **评审门禁归属已登记**（契约与 `dmt-director` 含「文档门禁」、契约与 `dmt-dm` 含「代码门禁」、`dmt-director` 含「不替代」）；⑪ **cbc-herdr 通用技能已登记**（三个 pane 角色技能各含 `cbc-herdr`）；⑫ **技能链接与上游一致**（契约与四个技能都含 `raw.githubusercontent.com`）；⑬ **确定性动作已脚本化**（十八个脚本存在且可执行，含 `launch.sh` / `probe-cap.sh` / `fanout.sh` / `parallel-guard.sh` / `spawn-helper.sh` / `close-helper.sh`）；⑭ **收件箱三态已登记**（契约含 `.doing/` 与 `.seq`、三个 pane 角色技能各含 `msg-take.sh`）；⑮ **先派后干、并发账与完成即报已登记**（契约与三个派发技能 `dmt-director` / `dmt-dm` / `dmt-am` 含「先派后干」「并发账」；契约与 `dmt-director` / `dmt-dm` / `dmt-am` 含「完成即报」；契约含「派发合规」）；⑯ 本契约登记齐全；⑰ **契约头部带版本号与日期且与四个技能同号**（`team.md` 头部 `版本 X.Y.Z · YYYY-MM-DD`，四份 `SKILL.md` 的 `version:` 与之一致，脚本 4m）；⑱ 负样本能被正确拒绝（**只看契约的表格登记行**，§8 历史留痕不算登记）。**改路径规范、pane 生命周期、并行口径、角色层级、写权限、强制技能、文件占用、评审门禁、通用技能、技能链接、收件箱三态或脚本接口后必须重跑。**

## 维护

- 本仓是 dmt 的**唯一维护地**，使用方不保留副本；软链后技能与契约随本仓更新，改完即生效（无需重装）。
- 技能内的契约引用不依赖相对路径（写作「`dmt-director/team.md`（本仓；装到项目后为 `docs/team.md`）」），因此软链安装不会断链。
- 脚本接口变更（参数、输出、退出码）视为契约变更，必须同步四个技能与机检 4m。
- 依赖 harness 侧技能：`herdr`（pane 控制与 label 识别）、`cbc-herdr`（CodeBuddy 状态上报）、`pi-subagents`（仅 pi harness；cbc 用 Agent/team 子代理），以及 mattpocock 的 [`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)、[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)、[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)、[`/tdd`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md)、[`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md) 等（安装与回退见 `team.md` §1.4）。
