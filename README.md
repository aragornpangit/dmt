# dmt

dmt 团队的角色技能仓：**团队定义与五个角色技能的唯一维护地**。四层层级：`director` → 部门经理（`devm` / `anam`）→ 队长（`devtl{n}` / `anatl{n}`）→ 工程师（`dev-e` / `ana-e`）。
**队长层是按需的**：经理需要并行铺开时，用 `herdr pane split` 在**自己的 tab 内**开队长 pane（pane label 固定为 `devtl{n}`），队长接单后再开工程师子代理；队长 pane 用完即关。

| 角色 | 技能 | pane label | 直属上级 | 直属下级 | 职责摘要 |
|---|---|---|---|---|---|
| 总监（团队领导兼产品经理） | `director` | `director` | 用户 | `devm`、`anam` | 接需求、输出验收标准、落笔 PRD 与 SPEC、评审调研报告与 ticket 代码、跨部门裁决 |
| 开发经理 | `devm` | `devm` | `director` | `devtl{n}`（pane，按需生成） | 由 SPEC 拆 ticket；按需开队长 pane；验收整合、director 通过后才 push |
| 分析经理 | `anam` | `anam` | `director` | `anatl{n}`（pane，按需生成） | 接调研诉求；按需开队长 pane；复核出处、收口调研报告 |
| 开发队长 | `devtl`（实例 `devtl{n}`） | `devtl1`、`devtl2` …（在 devm 的 tab 内） | `devm` | `dev-e`（子代理） | 由经理按需生成；建 worktree、并发派开发工程师、收 diff 做初检、回报 devm |
| 分析队长 | `anatl`（实例 `anatl{n}`） | `anatl1`、`anatl2` …（在 anam 的 tab 内） | `anam` | `ana-e`（子代理） | 由经理按需生成；拆子问题、派分析工程师并行取证、复核出处、回报 anam |

**称呼**：正文、汇报、日志用「总监／开发经理／分析经理／开发队长{n}／分析队长{n}」；pane label、收件箱目录、方向码与命令用 id（`director` / `devm` / `anam` / `devtl{n}` / `anatl{n}` / `dev-e` / `ana-e`），两者不混写。

**单线指挥**：每个角色只与直属上下级通信；director 不越级指挥队长与工程师，队长之间、经理之间不横向直连，跨部门一律经 director 转派。**工程师永远是子代理**（不占 pane、不走跨 pane 通信）：由队长开 —— 经理与工程师之间没有 pane 级通道，只有父子代理关系。
队长**按需生成、用完即关**：经理用 `herdr pane split "$HERDR_PANE_ID" --direction right --cwd "$PWD" --no-focus` 在**自己的 tab 内**开队长 pane，再 `herdr pane rename <pane> devtl{n}`（anam 同理建 `anatl{n}`），并代启动 harness（`codebuddy --permission-mode auto`）；本批收口且确认无下一批可派后，由**创建者本人**用 `herdr pane close <pane>` 关闭（`pane` 按 `herdr pane list` 的 **pane label** 解析）。**关闭前置三件事**（回报已入账、worktree 已 `git worktree remove`、收件箱无该队长未读）顺序固定、缺一不可；**禁止先关后收**（关 pane 即终止该 agent 会话、context 不可恢复）；**禁止 `herdr tab close`**（队长与经理同 tab，关 tab 会连带杀掉经理）；**批内可复用、批间不保留**；非创建者不得代关。细则见 `team.md` §1.2。

成员运行在 Herdr（终端多智能体复用器）中，**按 pane label 识别伙伴**（label 与角色名同名、全 workspace 唯一；不看 tab 内位置，pane id 每次发送前重查）。
**角色间通信 = 收件箱文件 + herdr 门铃**：正文写进收件方 `inbox/<收件角色>/{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`（项目根，不在 `docs/` 下），herdr 只发一句「你有新消息 …」；收件方读后**不回执**、读入 context window 并删掉文件（详见 `team.md` §1.3）。
工作流一句话：anam 开队长 pane 做调研（director 评审）→ director 出 PRD 与 SPEC（devm 评审）→ devm 拆 ticket 并开队长 pane → 队长开 dev-e 实施并初检 → devm 验收整合 → director 评审通过 → devm `git push`。

**团队契约（组织、通信、文件命名、目录职责与纪律的唯一权威）＝ [`team.md`](team.md)。**

```
dmt/                              # 一个角色一个文件夹
├── README.md                                 # 项目总说明（本文件）
├── director/                                 # 总监兼产品经理（技能 director）
│   ├── SKILL.md
│   ├── team.md                         # 团队契约（唯一权威）
│   ├── README.md                       # 指针：根目录 README.md
│   └── scripts/check-dmt-doc-paths.sh  # 产物落盘路径机检
├── devm/SKILL.md                      # 开发经理
├── anam/SKILL.md                      # 分析经理
├── devtl/SKILL.md                     # 开发队长（devtl{n}）
└── anatl/SKILL.md                     # 分析队长（anatl{n}）
```

## 安装到一个项目

仓内目录名即技能名（`director` / `devm` / `anam` / `devtl` / `anatl`），**装到技能目录时同名复制**。

```bash
mkdir -p <项目>/.agents/skills/{director,devm,anam,devtl,anatl} <项目>/scripts \
         <项目>/docs/{pd/{prd,spec},dev/tickets,analyst,human/{human-arch,human-plan}} \
         <项目>/inbox/{director,devm,anam}
cp director/SKILL.md  <项目>/.agents/skills/director/
cp devm/SKILL.md  <项目>/.agents/skills/devm/
cp anam/SKILL.md  <项目>/.agents/skills/anam/
cp devtl/SKILL.md <项目>/.agents/skills/devtl/
cp anatl/SKILL.md <项目>/.agents/skills/anatl/
cp director/team.md <项目>/docs/team.md
cp director/scripts/check-dmt-doc-paths.sh <项目>/scripts/
printf 'inbox/*/\n' >> <项目>/.gitignore        # 收件箱是运行时通道，不入库
```

想跟随本仓更新就改用**相对软链**（推荐；以与本仓同级的项目为例）：

```bash
ln -s ../../../dmt/director <项目>/.agents/skills/director
ln -s ../../../dmt/devm <项目>/.agents/skills/devm     # anam / devtl / anatl 同理
ln -s ../../dmt/director/team.md <项目>/docs/team.md
ln -s ../../dmt/director/scripts/check-dmt-doc-paths.sh <项目>/scripts/check-dmt-doc-paths.sh
```

软链整个角色目录时，`director/` 里的契约、说明与机检脚本一并可见，不影响技能加载。
装到其他 harness（codebuddy / codex / opencode 等）的用户级技能目录时，规则同样是**目录名即技能名**。

## 机检

```bash
bash director/scripts/check-dmt-doc-paths.sh <项目根目录>   # 省略参数则检查当前目录
# 技能未装在 <项目根>/.agents/skills 时，用 DMT_SKILLS_DIR 覆盖（默认值见脚本第 9 行）
```

判据六项：六个产物目录 + 根目录 `inbox/` 存在（**缺则由 director 初始化时补齐**，见 `team.md` §3.1）、五个角色技能各自指向自己的唯一目录、**队长实例关闭动作已登记**（契约与 `devm` / `anam` 技能含 `herdr pane close`、契约含「禁止 `herdr tab close`」）、**身份识别已登记**（契约与五个技能含 `pane label`）、**队长层并行判据已登记**（`devtl` / `anatl` 含「必须并行」、契约含「≥2 ⇒ 必须并发派发」）、本契约登记齐全、负样本能被正确拒绝（**只查 §3 落盘登记表**，§8 历史留痕不算登记）。**改路径规范、pane 生命周期或并行口径后必须重跑。**

## 维护

- 本仓是 dmt 的**唯一维护地**，使用方不保留副本；软链后技能与契约随本仓更新，改完即生效（无需重装）。
- 技能内的契约引用不依赖相对路径（写作「`director/team.md`（本仓；装到项目后为 `docs/team.md`）」），因此软链安装不会断链。
- 依赖 harness 侧技能：`herdr`（pane 控制与 label 识别）、`pi-subagents`（subagents 与 dynamic workflow），以及 mattpocock 的 `/to-spec`、`/to-tickets`、`/code-review`、`/tdd`、`/research` 等（安装与回退见 `team.md` §1.4）。
