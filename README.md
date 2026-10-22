# dmt

dmt 团队的角色技能仓：**团队定义与五个角色技能的唯一维护地**。四层层级：`director` → 部门经理（`dev-m` / `ana-m`）→ 组长（`dev-tl{n}` / `ana-tl{n}`）→ 工程师（`dev-e` / `ana-e`）。

| 角色 | 技能 | tab label | 直属上级 | 直属下级 | 职责摘要 |
|---|---|---|---|---|---|
| 总监（团队领导兼产品经理） | `director` | `director` | 用户 | `dev-m`、`ana-m` | 接需求、输出验收标准、落笔 PRD 与 SPEC、评审调研报告与 ticket 代码、跨部门裁决 |
| 开发部经理 | `dev-m` | `dev-m` | `director` | `dev-tl{n}` | 由 SPEC 拆 ticket、按需生成并收回开发组长、验收整合、director 通过后才 push |
| 分析部经理 | `ana-m` | `ana-m` | `director` | `ana-tl{n}` | 接调研诉求、按需生成并收回分析组长、收口调研报告 |
| 开发组长 | `dev-tl`（实例 `dev-tl{n}`） | `dev-tl1`、`dev-tl2` … | `dev-m` | `dev-e`（子代理） | 建 worktree、并发派开发工程师、收 diff 做初检、回报 dev-m |
| 分析组长 | `ana-tl`（实例 `ana-tl{n}`） | `ana-tl1`、`ana-tl2` … | `ana-m` | `ana-e`（子代理） | 拆子问题、派分析工程师并行取证、复核出处、回报 ana-m |

**单线指挥**：每个角色只与直属上下级通信；director 不越级指挥组长与工程师，经理不直接给工程师派活，组长之间、经理之间不横向直连，跨部门一律经 director 转派。
组长**按需生成、用完即关**：dev-m 用 `herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label dev-tl{n}` 建开发组长，ana-m 用同样的命令建 `ana-tl{n}`；本批收口且确认无下一批可派后，由**创建者本人**用 `herdr tab close <tab_id>` 关闭（`tab_id` 按 `herdr tab list` 的 label 解析）。**关闭前置三件事**（回报已入账、worktree 已 `git worktree remove`、收件箱无该组长未读）顺序固定、缺一不可；**禁止先关后收**（关 tab 即终止该 agent 会话、context 不可恢复）；**批内可复用、批间不保留**；非创建者不得代关。细则见 `team.md` §1.2。

成员运行在 Herdr（终端多智能体复用器）中，**按 tab label 识别伙伴**，pane id 每次发送前重查。
**角色间通信 = 收件箱文件 + herdr 门铃**：正文写进收件方 `inbox/<收件角色>/{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`（项目根，不在 `docs/` 下），herdr 只发一句「你有新消息 …」；收件方读后**不回执**、读入 context window 并删掉文件（详见 `team.md` §1.3）。
工作流一句话：ana-m 派分析组长调研（director 评审）→ director 出 PRD 与 SPEC（dev-m 评审）→ dev-m 拆 ticket 并生成开发组长 → 组长派 dev-e 实施并初检 → dev-m 验收整合 → director 评审通过 → dev-m `git push`。

**团队契约（组织、通信、文件命名、目录职责与纪律的唯一权威）＝ [`team.md`](team.md)。**

```
dmt/                              # 一个角色一个文件夹
├── README.md                                 # 项目总说明（本文件）
├── director/                                 # 总监兼产品经理（技能 director）
│   ├── SKILL.md
│   ├── team.md                         # 团队契约（唯一权威）
│   ├── README.md                       # 指针：根目录 README.md
│   └── scripts/check-dmt-doc-paths.sh  # 产物落盘路径机检
├── dev-m/SKILL.md                      # 开发部经理（dev-m）
├── ana-m/SKILL.md                      # 分析部经理（ana-m）
├── dev-tl/SKILL.md                     # 开发组长（dev-tl{n}）
└── ana-tl/SKILL.md                     # 分析组长（ana-tl{n}）
```

## 安装到一个项目

仓内目录名即技能名（`director` / `dev-m` / `ana-m` / `dev-tl` / `ana-tl`），**装到技能目录时同名复制**。

```bash
mkdir -p <项目>/.agents/skills/{director,dev-m,ana-m,dev-tl,ana-tl} <项目>/scripts \
         <项目>/docs/{pd/{prd,spec},dev/tickets,analyst,human/{human-arch,human-plan}} \
         <项目>/inbox/{director,dev-m,ana-m}
cp director/SKILL.md  <项目>/.agents/skills/director/
cp dev-m/SKILL.md  <项目>/.agents/skills/dev-m/
cp ana-m/SKILL.md  <项目>/.agents/skills/ana-m/
cp dev-tl/SKILL.md <项目>/.agents/skills/dev-tl/
cp ana-tl/SKILL.md <项目>/.agents/skills/ana-tl/
cp director/team.md <项目>/docs/team.md
cp director/scripts/check-dmt-doc-paths.sh <项目>/scripts/
printf 'inbox/*/\n' >> <项目>/.gitignore        # 收件箱是运行时通道，不入库
```

想跟随本仓更新就改用**相对软链**（推荐；以与本仓同级的项目为例）：

```bash
ln -s ../../../dmt/director <项目>/.agents/skills/director
ln -s ../../../dmt/dev-m <项目>/.agents/skills/dev-m     # ana-m / dev-tl / ana-tl 同理
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

判据六项：六个产物目录 + 根目录 `inbox/` 存在（**缺则由 director 初始化时补齐**，见 `team.md` §3.1）、五个角色技能各自指向自己的唯一目录、**组长实例关闭动作已登记**（契约与 `dev-m` / `ana-m` 技能含 `herdr tab close`）、**组长层并行判据已登记**（`dev-tl` / `ana-tl` 含「必须并行」、契约含「≥2 ⇒ 必须并发派发」）、本契约登记齐全、负样本能被正确拒绝（**只查 §3 落盘登记表**，§8 历史留痕不算登记）。**改路径规范、tab 生命周期或并行口径后必须重跑。**

## 维护

- 本仓是 dmt 的**唯一维护地**，使用方不保留副本；软链后技能与契约随本仓更新，改完即生效（无需重装）。
- 技能内的契约引用不依赖相对路径（写作「`director/team.md`（本仓；装到项目后为 `docs/team.md`）」），因此软链安装不会断链。
- 依赖 harness 侧技能：`herdr`（通信与 tab 生成）、`pi-subagents`（subagents 与 dynamic workflow），以及 mattpocock 的 `/to-spec`、`/to-tickets`、`/code-review`、`/tdd`、`/research` 等（安装与回退见 `team.md` §1.4）。
