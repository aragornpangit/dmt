# dmt

dmt 团队的角色技能仓：**团队定义与七个角色技能的唯一维护地**。层级：`director`（总监兼产品部经理）→ 部门经理（`devm` / `anam`）→ 工程师（`dev-e` / `ana-e` / `pde{n}` / `reviewer{n}`）。
**产品部并入总监**：director 写 PRD / SPEC / 工单时召唤 `pde{n}` 落笔（人类文档亲自落笔），自派 `pde{n}` / `reviewer{n}` 子代理（`dmt-pde` / `dmt-reviewer` 技能，不占 tab 不占 pane），不设产品经理；`devm` pane 在 director tab 内右侧，`anam` 独立 tab。
**经理直接派工程师**：`devm` / `anam` 一律直接派 `dev-e` / `ana-e` 子代理（无依赖任务开满并行、开满到 harness 并发上限）；建 worktree、实施层初检与一手出处复核由经理收口，**不设队长层**。

> **作用域（Scope，必读）**：本仓全部纪律 —— 角色权限、**写操作归属（硬件设备写操作 / `git push` / merge）**、门禁、pane 生命周期、收件箱规范 —— **只作用于 dmt 工作流所管理的「目标项目」**（用 `init-project.sh <项目根>` 初始化的那个 project root）。
> **维护 `dmt` / `dmt-en` 等技能仓自身时不适用**：维护者（人或其他 agent）可直接 `git add` / `git commit` / `git push`，**无需 director 授权，也不需 devm 代推**。

| 角色 | 技能名 | 运行 id（pane label） | 直属上级 | 直属下级 | 职责摘要 |
|---|---|---|---|---|---|
| 总监兼产品部经理 | `dmt-director` | `director` | 用户 | `devm`、`anam`（+ 自派 `pde{n}` / `reviewer{n}` 副轨） | 唯一入口；接需求与验收口径、召唤 `pde{n}` 落笔 PRD / SPEC / 工单（director 定稿）、落笔人类文档并出文档门禁结论、分派、裁决、维护 pane/tab；抽查放行（merge / push 归 devm；**硬件设备写操作 devm 与 director 均可**；**代码验收主轨由 devm 派 `reviewer{n}`**，**director 自派 `reviewer{n}` 副轨做抽查与高风险复验**）；**不替代** devm 的代码评审 |
| 产品工程师（子代理） | `dmt-pde` | `pde{n}` | `director` | — | **落笔 PRD / SPEC / 工单**、产品事实取证、用户故事与边界枚举、验收标准核对；**不占 tab 不占 pane**，director 自派、一单元一实例 |
| 开发经理 | `dmt-dm` | `devm` | `director` | `dev-e` / `reviewer{n}`（子代理） | 依用户要求与 tickets 计划直接干活（知会 director 即可）、排期派活、建 worktree、派 `dev-e` 实施、收 diff 做实施层初检、**代码门禁**（ticket 代码评审责任人）、**派 `reviewer{n}` 独立验收**（独立于实施者、以证据为准）、整合交付物、**merge / push（代码库归 devm 管理，收到 `reviewer{n}` 通过后即合并 / 推送）**；**硬件设备写操作（devm 与 director 均可）**；**不拆票** |
| 分析经理 | `dmt-am` | `anam` | `director` | `ana-e`（子代理） | 依用户要求与 tickets 计划直接干活（知会 director 即可）；拆子问题、派 `ana-e` 并行取证、复核一手出处、收口调研报告 |
| 开发工程师（子代理） | `dmt-de` | `dev-e` | `devm` | — | 一票一 worktree、TDD 实施（`/tdd` `/implement`）、提交前自审（`/code-review`）、worktree 内提交（不 push） |
| 分析工程师（子代理） | `dmt-ae` | `ana-e` | `anam` | — | 一手取证（`/research`）、竞品逆向（`/rea`）、证据分级、交叉拷问（`/grilling` 系） |
| 审核工程师（子代理） | `dmt-reviewer` | `reviewer{n}` | **双轨**：主轨 `devm` / 副轨 `director` | — | **主轨**由 devm 按票数派做**代码审核**（逐条验收 ticket 代码、独立于 `dev-e`）；**副轨**由 director 自派做**抽查 / 高风险复验**（每批至少抽 1 票、高风险票 100%，实例独立于主轨）；`/code-review` 写进派发 prompt；以证据为准、不改代码、不 push |

**角色 × 强制技能**（mattpocock，必须使用）及逐条用途见 `dmt-director/team.md` §1.4（含可点击链接）。

技能名与 [`mattpocock/skills`](https://github.com/mattpocock/skills) 上游**逐字一致**，链接指向 `raw.githubusercontent.com` 源文件；`/rea` 属 REA、不在该仓内，保持原名。

另：三个 pane 常驻角色（`director` / `devm` / `anam`）都加载 **`cbc-herdr`**（CodeBuddy 在 herdr 的状态上报）；工程师子代理不占 pane，不需要。

| 角色 | 交付物（落盘位置） |
|---|---|
| `director` | `docs/team.md`；`docs/pd/prd/` PRD、`docs/pd/spec/` SPEC、`docs/dev/tickets/` 工单、`docs/human/human-arch/`、`docs/human/human-plan/`（PRD / SPEC / 工单由 `pde{n}` 落笔、director 定稿；取证类 pde 只交证据不落盘）；按需 `docs/handoff/`（director / devm）；抽查 / 复验结论（收件箱）；**硬件设备写操作（与 devm 均可）** |
| `devm` | 票面末尾「实施状态」；合并后的主干代码；`feat/{ticket-id}` 分支提交（worktree）；实施层初检结论；`reviewer{n}` 的逐条验收结论；**merge 与 push**；**硬件设备写操作（devm 与 director 均可）**；GitLab 推送（每 ticket 一推 ＋ 每小时巡检） |
| `anam` | `docs/analyst/` 调研报告 ＋ `docs/analyst/evidence/` 一手证据；取证回报与一手出处复核 |
| `pde{n}` | `docs/pd/prd/`、`docs/pd/spec/`、`docs/dev/tickets/` 落笔（director 定稿） |
| `reviewer{n}` | 逐条验收结论（主轨回报 `devm`、副轨回报 `director`；**不落盘、不进收件箱**，副轨抽查结论可落 `docs/handoff/`） |
| `dev-e` / `ana-e` | worktree 代码提交 / 核对材料（经派生者收口，不写收件箱） |

**三层命名**：技能名带 `dmt-` 前缀（`dmt-director` / `dmt-dm` / `dmt-am` / `dmt-pde` / `dmt-de` / `dmt-ae` / `dmt-reviewer`），用于技能注册表、安装目录与斜杠命令；运行 id 不带前缀（`director` / `devm` / `anam` / `pde{n}` / `dev-e` / `ana-e` / `reviewer{n}`，helper 为 `{角色}-helper`），用于 pane label、收件箱目录与方向码；正文与日志用称呼（总监／开发经理／分析经理）。**三层不混写。**

**单线指挥**：每个角色只与直属上下级通信；director 不越级指挥工程师，经理之间不横向直连，跨部门一律经 director 转派。**工程师永远是子代理**（不占 pane、不走跨 pane 通信）：一律由经理直接开（`devm` 开 `dev-e`、`anam` 开 `ana-e`，无依赖任务开满并行、开满到 harness 并发上限）—— 经理与工程师之间没有 pane 级通道，只有父子代理关系；`pde{n}` 由 `director` 直接开。
**helper（`{角色}-helper`，本体的纯分身，每角色至多一个）**：`director-helper` / `devm-helper` / `anam-helper` 是本体的**纯分身**——任务随 spawn **一次性下发**，此后**不接受任何输入框内容**；工作成果由 `helper-report.sh` **单向写回主体**（`inbox/<本体>/`，无门铃）；helper **没有自己的 inbox**（不收件）。**唯一开法判据（可观测）**：本 pane `agent_status == working` 且有待办超过 10 分钟未处理。**生命周期由创建者（本体角色）维护**：用 `bash dmt-director/scripts/spawn-helper.sh <director|devm|anam>` 建立（幂等，支持 `--dry-run` / `--no-start`；helper tab label 固定 `helper`（全队共享一个），pane label 固定 `{角色}-helper`，代启动 harness 并装载**同角色技能**）、label 漂移自愈改名、任务完成用 `bash dmt-director/scripts/close-helper.sh <director|devm|anam>` 回收（支持 `--force` / `--dry-run`；**helper tab 保留复用，不随 pane 关闭**）。**独占动作不移交**：硬件设备写操作（`devm` / `director` 本体）与 merge / push（`devm` 本体）均不移交 helper。

成员运行在 Herdr（终端多智能体复用器）中，**按 pane label 识别伙伴**（label 与角色名同名、全 workspace 唯一；不看 tab 内位置，pane id 每次发送前重查）。
**角色间通信 = 收件箱文件 + herdr 门铃**：正文写进收件方 `inbox/<收件角色>/{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`（项目根，不在 `docs/` 下），herdr 只发一句「你有新消息 …」；收件方读后**不回执**：先 `msg-take.sh` 移到 `inbox/<自己>/.doing/`（认领），办完 `msg-done.sh` 删除（详见 `OPS.md` §2）。
工作流一句话：anam 做调研（director 评审）→ director 定验收口径并召唤 `pde{n}` 落笔 PRD、SPEC 与工单（文档门禁自评）→ devm 接单排期，**devm / anam 直接派工程师子代理（无依赖任务开满并行、开满到 harness 并发上限）、实施层初检与出处复核由经理收口** → devm 完成票并代码门禁评审 → **devm 按票数派 reviewer1…reviewer{n}**（技能 `dmt-reviewer`；独立于实施该票的 dev-e、以证据为准）对照同 spec-seq 的 SPEC+ticket 逐条验收 → **通过后 devm 直接 merge/push**（reviewer{n} 为子代理、不占 pane 不装技能，`/review`（= `/code-review`）写进派发 prompt；merge 与 push 只归 devm：至少每完成一个 ticket 推送一次、至少每小时巡检未推送变更，代码库归 devm 管理），不通过打回 **dev-e** 返工、不得先 merge/push；**director 保留抽查与高风险票复验**。merge / push **只归 `devm`**；**硬件设备写操作 `devm` 与 `director` 均可**。devm / anam 可**依用户要求与 tickets 计划直接干活**，知会 director 即可；director **默认放行，只有觉得不合适才出面制止**（畅通无阻）。

**团队契约（组织、通信、文件命名、目录职责与纪律的唯一权威）＝ [`dmt-director/team.md`](dmt-director/team.md)。**

```
dmt/                                    # 一个角色一个文件夹
├── README.md                           # 项目总说明（本文件）
├── dmt-director/                       # 总监（技能 dmt-director）
│   ├── SKILL.md
│   ├── team.md                         # 团队契约（规范层，唯一权威）
│   ├── OPS.md                          # 操作手册（pane 生命周期 / 收件箱协议 / 文件占用）
│   ├── CHANGELOG.md                    # 变更历史明细（§8 外移，78 条；更早季度归档在 changelog/）
│   ├── harness_matrix.yaml             # harness 兼容矩阵（落点 / 前缀 / 启动命令 / 并发上限；单一来源）
│   ├── dmt_contract.yaml               # 结构契约（技能清单 / 版本源 / 目录 / 脚本；单一来源）
│   ├── hooks/pre-commit                # git hook：防内网地址 / 凭证 / .env 入库
│   ├── README.md                       # 脚本清单（正文见根 README.md）
│   └── scripts/                        # 机检（散文 + 结构）/ 文件占用 / 初始化 / 一键拉起 / 建团队 / 建 helper / helper 回报 / 关 helper / 发消息 / 认领 / 收口 / 推送 / 安装 / 装 hooks / 版本同步 / CHANGELOG 归档 / 复核器健康门 / harness 矩阵读取（+ lib-dmt.sh 公共库）
├── dmt-pde/SKILL.md                    # 产品工程师（pde{n} 子代理技能，不占 pane）
├── dmt-de/SKILL.md                     # 开发工程师（dev-e 子代理技能，不占 pane）
├── dmt-ae/SKILL.md                     # 分析工程师（ana-e 子代理技能，不占 pane）
├── dmt-reviewer/SKILL.md                    # 审核工程师（reviewer{n} 子代理技能，不占 pane）
├── dmt-dm/SKILL.md                     # 开发经理
├── dmt-am/SKILL.md                     # 分析经理
└── logs/                              # 事故复盘档（如 2026-10-27-serial-queue-incident.md）
```

## 安装到一个项目

仓内目录名即技能名（`dmt-director` / `dmt-dm` / `dmt-am` / `dmt-pde` / `dmt-de` / `dmt-ae` / `dmt-reviewer`），**装到技能目录时同名复制**。运行 id（`devm` 等）只是 pane label 与收件箱名，不随技能名变化。

```bash
# 软链安装（推荐，跟随本仓更新）；默认 --harness all ⇒ 铺 .agents/skills + .claude/skills + .codebuddy/skills
bash dmt-director/scripts/install-skills.sh <项目根>

# 复制安装（目标项目不跟随本仓）
bash dmt-director/scripts/install-skills.sh <项目根> --copy

# 只装指定 harness 的落点（收窄；默认 all）
bash dmt-director/scripts/install-skills.sh <项目根> --harness claude,codebuddy
```

脚本做四件事：① **按 harness 建技能落点**并软链或复制七个技能目录（默认 `--harness all` ⇒ `.agents/skills/` ＋ `.claude/skills/` ＋ `.codebuddy/skills/` 三处，覆盖五个 harness）；② 把整个 `dmt-director/`（含 `scripts/`）链接或复制到项目根 —— **脚本路径一律写 `dmt-director/scripts/…`**，旧的 `<项目根>/scripts/` 已废弃；③ 把 `team.md` 与 `OPS.md` **软链**到 `docs/`（机检读它；`--copy` 模式改为复制）；④ 调用 `init-project.sh` 建目录、写 `.gitignore` 并跑机检。

> **为什么要三个落点（2026-11-04 逐 harness 探针实测）**：各 harness **只认自己的技能目录**，没有「一处通用」—— `codex` / `opencode` / `pi` 读 `.agents/skills/`（`pi` 的项目级目录需 `--approve`），`claude` **只读** `.claude/skills/`，`codebuddy` **只读** `.codebuddy/skills/`。所以 `install-skills.sh` 默认铺满三处；只装一处会在 claude / codebuddy 上静默装不上。详见 `dmt-director/team.md` §1.2。

软链整个角色目录时，`dmt-director/` 里的契约、说明与机检脚本一并可见，不影响技能加载。
装到其他 harness 的用户级技能目录时，规则同样是**目录名即技能名**。

**五个 harness 的技能发现目录（2026-11-04 逐 harness 探针实测）**：`.agents/skills/` **不是**五者交集 —— 实测只有 `codex` / `opencode` / `pi` 读它，`claude` 与 `codebuddy` **只认各自私有目录**（项目级 `.claude/skills/` / `.codebuddy/skills/`，用户级 `~/.claude/skills/` / `~/.codebuddy/skills/`）。因此 `install-skills.sh` 的 `<target>/.agents/skills/` 落点只覆盖三者（`pi` 还需 `--approve`）；**装到 claude / codebuddy 时必须另软链其私有目录**。另一个易错点：`pi` 的用户级私有目录是 `~/.pi/agent/skills/`（**不是 `~/.pi/skills/`**），`opencode` 的项目级目录是 `.opencode/skills/`（**复数**）。**斜杠写法也不同**：claude / codebuddy / codex / opencode 用 `/dmt-dm`，**pi 用 `/skill:dmt-dm`** —— 启动脚本经 `lib-dmt.sh` 的 `dmt_skill_cmd` 自动生成，不要手敲。完整表（含项目级 / 用户级）见 `dmt-director/team.md` §1.2「harness 兼容」。

## 机检

```bash
bash dmt-director/scripts/check-dmt-doc-paths.sh <项目根目录>   # 散文 / 落盘纪律机检
bash dmt-director/scripts/check-dmt-structure.sh <项目根目录>    # 结构化机检（YAML 单一来源）
# 技能未装在 <项目根>/.agents/skills 时，用 DMT_SKILLS_DIR 覆盖
```

**结构化机检**（`check-dmt-structure.sh`）校验**可机读的结构事实**，事实定义在 `dmt-director/dmt_contract.yaml`（技能清单 / 版本源 / 产物目录 / 组织 / 脚本清单 / 已废止脚本）与 `dmt-director/harness_matrix.yaml`（五 harness 矩阵）——改一处即改全部，不再散落中文 grep。**散文机检**（`check-dmt-doc-paths.sh`）保留「纪律是否被登记」的软断言。

判据 **十八项**（机检共 27 组断言）。**逐项说明与判据维护在 `dmt-director/team.md` §7（单一来源）**，本文件不复制、避免两处漂移。改动路径规范、pane 生命周期、并行口径、角色层级、写权限、强制技能、文件占用、评审门禁、通用技能、技能链接、收件箱三态、派发 prompt 文件写入纪律、pi agent 名承载或脚本接口后必须重跑。

## 内网端点配置（`.env`）

内网地址（GitLab、本地复核器端点等）**不写进仓库正文**，统一用变量名引用、值放在 `.env`：

```bash
cp .env.example .env && ${EDITOR:-vi} .env   # 填入本机实际地址
```

| 变量 | 用途 |
|---|---|
| `DMT_GITLAB_SERVER` / `DMT_GITLAB_PORT` / `DMT_GITLAB_REPO` | 内网 GitLab（devm 的 `publish.sh` 推送目标） |
| `DMT_LOCAL_MODEL_HOST` / `DMT_LOCAL_MODEL_PORT` | 本地复核器（`autoModeClassifier`）端点 host / port（拼成 `http://<host>:<port>/v1/models`） |
| `DMT_AUTO_REVIEW_LOCAL_MODEL` | 本地复核器模型 id |

- `.env` 由 `dmt-director/scripts/lib-dmt.sh` 的 `dmt_load_env` 读取（查找顺序：`$DMT_ENV_FILE` → `<项目根>/.env` → 技能仓根 `.env`）；**已导出的环境变量优先**，`.env` 不覆盖。可用 `DMT_ENV_FILE=<路径>` 指定其它文件。
- `.env` **不入库**（见 `.gitignore`），模板是 `.env.example`；`DMT_AUTO_REVIEW_URL` 可直接给整条端点 URL，覆盖 host / port 拼装。

## 维护

- **单一来源**：团队口径只在 `dmt-director/team.md`（规范）/ `OPS.md`（操作）；harness 差异只在 `harness_matrix.yaml`；结构事实只在 `dmt_contract.yaml`。七份技能只写「本角色怎么干」，共性一律写指针（`check-dmt-structure.sh` §6 断言）。
- **版本同步**：版本号权威在 `dmt_contract.yaml`；`bash dmt-director/scripts/bump-version.sh <X.Y.Z>` 一条命令刷进 team.md 与七份 SKILL.md，`--check` 复核同号。
- **防泄漏门禁**：`bash dmt-director/scripts/install-git-hooks.sh` 启用受版本控制的 `pre-commit`（拦截 `.env`、内网地址、密钥形态）；`launch.sh` 默认安装。误报用 `git commit --no-verify` 绕过。
- **变更记录**：`CHANGELOG.md` 只留当前季度条目；`bash dmt-director/scripts/archive-changelog.sh` 把更早季度整条原样归档到 `dmt-director/changelog/<YYYYQn>.md`。

- 本仓是 dmt 的**唯一维护地**。技能落点（`.agents/skills/`、`.claude/skills/`、`.codebuddy/skills/` 下的 `<角色>/`，由 `install-skills.sh` 按 `--harness` 铺设）与 **`docs/team.md` / `docs/OPS.md` 均以软链安装**（默认 `link` 模式）⇒ 随本仓更新、改完即生效，**无需重跑安装**。仅 `--copy` 安装的项目不跟随本仓，正本 `team.md` 变更后需重跑 `bash dmt-director/scripts/install-skills.sh <项目根> --copy`。
- 技能内的契约引用不依赖相对路径（写作「`dmt-director/team.md`（本仓；装到项目后为 `docs/team.md`）」），因此软链安装不会断链。
- **`dmt-en`（早期英文镜像仓）已停更**（末版 `5.7.1 · 2026-10-27`）：自 2026-11-04 起**以本仓（`dmt`）为准**，不再双仓并行维护；需要英文版时按本仓当期内容另行翻译，**不要把 `dmt-en` 当权威**。
- 脚本接口变更（参数、输出、退出码）视为契约变更，必须同步七个技能与机检 4m。
- 依赖 harness 侧技能：`herdr`（pane 控制与 label 识别）、`cbc-herdr`（CodeBuddy 状态上报）、`pi-subagents`（仅 pi harness；cbc 用 Agent/team 子代理），以及 mattpocock 的 [`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)、[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)、[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)、[`/tdd`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md)、[`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md) 等（安装与回退见 `team.md` §1.4）。
