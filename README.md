# dmt

dmt 团队的角色技能仓：**团队定义与八个角色技能的唯一维护地**。层级：`director`（总监兼产品部经理）→ `devm`（开发经理）→ `devl{n}`（开发队长）→ `dev-e`；`director` → `anam` → `ana-e`；`pde{n}` 直属 director。
**产品部并入总监**：director 写 PRD / SPEC 时召唤 `pde{n}` 落笔（人类文档亲自落笔），自派 `pde{n}` / `reviewer{n}` 副轨子代理（`dmt-pde` / `dmt-reviewer` 技能，不占 tab 不占 pane），不设产品经理；工单由 `devm` 落笔、director 定稿。
**开发部四层**：`devm` 派 `devl{n}`，`devl{n}` 派 `dev-e`；队长按 `spec-seq` 派 `reviewer{n}` 独立评审，汇总后上报 `devm`；`devm` 只做疑问裁决、merge、push 与汇报。队长 pane 在 `dmt-dev` tab 右侧竖排，**至少 2 个**（`DEVL_MIN=2`，可增）；`anam` 在 director tab 右侧。

> **作用域（Scope，必读）**：本仓全部纪律 —— 角色权限、**写操作归属（硬件设备写操作 / `git push` / merge）**、门禁、pane 生命周期、收件箱规范 —— **只作用于 dmt 工作流所管理的「目标项目」**（用 `init-project.sh <项目根>` 初始化的那个 project root）。
> **维护 `dmt` / `dmt-en` 等技能仓自身时不适用**：维护者（人或其他 agent）可直接 `git add` / `git commit` / `git push`，**无需 director 授权，也不需 devm 代推**。

| 角色 | 技能名 | 运行 id（pane label） | 直属上级 | 直属下级 | 职责摘要 |
|---|---|---|---|---|---|
| 总监兼产品部经理 | `dmt-director` | `director` | 用户 | `devm`、`anam`（+ 自派 `pde{n}` / `reviewer{n}` 副轨） | 唯一入口；接需求与验收口径、召唤 `pde{n}` 落笔 PRD / SPEC（director 定稿）、工单由 devm 落笔并定稿、落笔人类文档并出文档门禁结论、分派、裁决、维护 pane/tab；抽查放行（merge / push 归 devm；**硬件设备写操作 devm 与 director 均可**；**代码验收主轨由 devl 派 `reviewer{n}`**，**director 自派 `reviewer{n}` 副轨做抽查与高风险复验**）；**不替代** devl 的代码评审 |
| 产品工程师（子代理） | `dmt-pde` | `pde{n}` | `director` | — | **落笔 PRD / SPEC**、产品事实取证、用户故事与边界枚举、验收标准核对；**不占 tab 不占 pane**，director 自派、一单元一实例；`to-tickets` 已移交 devm |
| 开发经理 | `dmt-dm` | `devm` | `director` | `devl{n}`（pane） | 落笔 `to-tickets`、按依赖排期派单给 `devl{n}`、**管理 `devl` pane 生命周期**（`DEVL_MIN=2`、按票扩容、回收、崩溃重建）、**裁决队长疑问**、**merge / push**、向 director 汇报；**不做代码评审、不派 `reviewer{n}`、不直接派 `dev-e`** |
| 开发队长 | `dmt-devl` | `devl{n}` | `devm` | `dev-e` / `reviewer{n}`（子代理） | 接票、建 worktree（`.worktrees/{ticket-id}`）、派 `dev-e` 实施、**按 `spec-seq` 派 `reviewer{n}` 独立评审**、**汇总自派 subagents 的结果**、PASS 后上报 devm；**不 push、不 merge、不跨队长通信** |
| 分析经理 | `dmt-am` | `anam` | `director` | `ana-e`（子代理） | 依用户要求与 tickets 计划直接干活（知会 director 即可）；拆子问题、派 `ana-e` 并行取证、复核一手出处、收口调研报告 |
| 开发工程师（子代理） | `dmt-de` | `dev-e` | `devl{n}` | — | 一票一 worktree、TDD 实施（`/tdd` `/implement`）、提交前自审（`/code-review`）、worktree 内提交（不 push） |
| 分析工程师（子代理） | `dmt-ae` | `ana-e` | `anam` | — | 一手取证（`/research`）、竞品逆向（`/rea`）、证据分级、交叉拷问（`/grilling` 系） |
| 审核工程师（子代理） | `dmt-reviewer` | `reviewer{n}` | **双轨**：主轨 `devl{n}` / 副轨 `director` | — | **主轨**由 devl 按票派做**代码审核**（逐条验收 ticket 代码、独立于 `dev-e`）；**副轨**由 director 自派做**抽查 / 高风险复验**（每批至少抽 1 票、高风险票 100%，实例独立于主轨）；`/code-review` 写进派发 prompt；以证据为准、不改代码、不 push |

**角色 × 强制技能**（mattpocock，必须使用）及逐条用途见 `dmt-director/team.md` §1.4（含可点击链接）。

技能名与 [`mattpocock/skills`](https://github.com/mattpocock/skills) 上游**逐字一致**，链接指向 `raw.githubusercontent.com` 源文件；`/rea` 属 REA、不在该仓内，保持原名。

另：四个 pane 常驻角色（`director` / `devm` / `anam` / `devl{n}`）都加载 **`cbc-herdr`**（CodeBuddy 在 herdr 的状态上报）；工程师子代理不占 pane，不需要。**`dmt-devl` 不设 helper**。

| 角色 | 交付物（落盘位置） |
|---|---|
| `director` | `docs/team.md`；`docs/pd/prd/` PRD、`docs/pd/spec/` SPEC、`docs/dev/tickets/` 工单定稿、`docs/human/human-arch/`、`docs/human/human-plan/`（PRD / SPEC 由 `pde{n}` 落笔、工单由 `devm` 落笔，director 定稿；取证类 pde 只交证据不落盘）；按需 `docs/handoff/`（director / devm）；抽查 / 复验结论（收件箱）；**硬件设备写操作（与 devm 均可）** |
| `devm` | `docs/dev/tickets/` 工单落笔；合并后的主干代码；`devl{n}` 交付包汇总；**merge 与 push**；**硬件设备写操作（devm 与 director 均可）**；GitLab 推送（每 ticket 一推 ＋ 每小时巡检）；`devl` pane 生命周期记录 |
| `devl{n}` | `.worktrees/{ticket-id}` 内的 commit；`reviewer{n}` 的逐条验收结论；交付包（票号 / `spec-seq` / commit / 测试结果 / 证据路径）；不 push、不 merge |
| `anam` | `docs/analyst/` 调研报告 ＋ `docs/analyst/evidence/` 一手证据；取证回报与一手出处复核 |
| `pde{n}` | `docs/pd/prd/`、`docs/pd/spec/` 落笔（director 定稿） |
| `reviewer{n}` | 逐条验收结论（主轨回报 `devl{n}`、副轨回报 `director`；**不落盘、不进收件箱**，副轨抽查结论可落 `docs/handoff/`） |
| `dev-e` / `ana-e` | worktree 代码提交 / 核对材料（经派生者收口，不写收件箱） |

**三层命名**：技能名带 `dmt-` 前缀（`dmt-director` / `dmt-dm` / `dmt-devl` / `dmt-am` / `dmt-pde` / `dmt-de` / `dmt-ae` / `dmt-reviewer`），用于技能注册表、安装目录与斜杠命令；运行 id 不带前缀（`director` / `devm` / `devl{n}` / `anam` / `pde{n}` / `dev-e` / `ana-e` / `reviewer{n}`，helper 为 `{角色}-helper`），用于 pane label、收件箱目录与方向码；正文与日志用称呼（总监／开发经理／开发队长／分析经理）。**三层不混写。**

**单线指挥**：`director` → `devm` → `devl{n}` → `dev-e`；`director` → `anam` → `ana-e`；`pde{n}` 直属 director。director 不越级指挥 `devl{n}` / 工程师；**队长之间不得通信**；`devm` 与 `anam` 不直连；跨部门一律经 director 转派。**工程师与 reviewer 永远是子代理**（不占 pane、不走跨 pane 通信）：`devl{n}` 开 `dev-e` / `reviewer{n}`，`anam` 开 `ana-e`，`pde{n}` 由 `director` 直接开；无依赖任务开满并行、开满到 harness 并发上限。
**helper（`{角色}-helper`，本体的纯分身，每个 pane 角色至多一个；`dmt-devl` 不设 helper）**：`director-helper` / `devm-helper` / `anam-helper` 是本体的**纯分身**——任务随 spawn **一次性下发**，此后**不接受任何输入框内容**；工作成果由 `helper-report.sh` **单向写回主体**（`inbox/<本体>/`，无门铃）；helper **没有自己的 inbox**（不收件）。**唯一开法判据（可观测）**：本 pane `agent_status == working` 且有待办超过 10 分钟未处理。**生命周期由创建者（本体角色）维护**：用 `bash dmt-director/scripts/spawn-helper.sh <director|devm|anam>` 建立（幂等，支持 `--dry-run` / `--no-start`；helper tab label 固定 `helper`（全队共享一个），pane label 固定 `{角色}-helper`，代启动 harness 并装载**同角色技能**）、label 漂移自愈改名、任务完成用 `bash dmt-director/scripts/close-helper.sh <director|devm|anam>` 回收（支持 `--force` / `--dry-run`；**helper tab 保留复用，不随 pane 关闭**）。**独占动作不移交**：硬件设备写操作（`devm` / `director` 本体）与 merge / push（`devm` 本体）均不移交 helper。

成员运行在 Herdr（终端多智能体复用器）中，**按 pane label 识别伙伴**（label 与角色名同名、全 workspace 唯一；不看 tab 内位置，pane id 每次发送前重查）。
**角色间通信 = 收件箱文件 + herdr 门铃**：正文写进收件方 `inbox/<收件角色>/{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`（项目根，不在 `docs/` 下），herdr 只发一句「你有新消息 …」；收件方读后**不回执**：先 `msg-take.sh` 移到 `inbox/<自己>/.doing/`（认领），办完 `msg-done.sh` 删除（详见 `dmt-director/ops/comms.md`）。
工作流一句话：anam 做调研（director 评审）→ director 定验收口径并召唤 `pde{n}` 落笔 PRD、SPEC（文档门禁自评）→ devm 落笔工单并派给 `devl{n}` → devl 建 worktree、派 `dev-e` 实施、按 `spec-seq` 派 `reviewer{n}` 独立验收、汇总后上报 devm → devm 做合并前机检并 **merge / push**（至少每完成一个 ticket 推送一次、至少每小时巡检）→ director 抽查与高风险票复验。merge / push **只归 `devm`**；队长不 push、不 merge；**硬件设备写操作 `devm` 与 `director` 均可**。devm / anam 可**依用户要求与 tickets 计划直接干活**，知会 director 即可；director **默认放行，只有觉得不合适才出面制止**（畅通无阻）。

**团队契约（组织、通信、文件命名、目录职责与纪律的唯一权威）＝ [`dmt-director/team.md`](dmt-director/team.md)。**

```
dmt/                                    # 一个角色一个文件夹
├── README.md                           # 项目总说明（本文件）
├── dmt-director/                       # 总监（技能 dmt-director）
│   ├── SKILL.md
│   ├── team.md                         # 团队契约（规范层，唯一权威）
│   ├── OPS.md                          # 操作手册兼容入口（按任务路由到 ops/）
│   ├── ops/*.md                        # 操作手册（runtime / comms / file-claim / helper / permission-notes）
│   ├── harness/                        # 按 harness 加载（COMMON.md ＋ pi/codebuddy/claude/codex/opencode 各一份差异）
│   ├── CHANGELOG.md                    # 变更历史明细（全量 91 条；更早季度归档在 changelog/）
│   ├── harness_matrix.yaml             # harness 兼容矩阵（落点 / 前缀 / 启动命令 / 并发上限；单一来源）
│   ├── dmt_contract.yaml               # 结构契约（技能清单 / 版本源 / 目录 / 脚本；单一来源）
│   ├── hooks/pre-commit                # git hook：防内网地址 / 凭证 / .env 入库
│   ├── README.md                       # 脚本清单（正文见根 README.md）
│   └── scripts/                        # 机检（散文 + 结构）/ 文件占用 / 初始化 / 一键拉起 / 建团队 / 队长 pane 生命周期 / 建 helper / helper 回报 / 关 helper / 发消息 / 认领 / 收口 / 推送 / 安装 / 装 hooks / 版本同步 / CHANGELOG 归档 / 复核器健康门 / harness 矩阵读取 / harness 判定（+ lib-dmt.sh 公共库）
├── dmt-pde/SKILL.md                    # 产品工程师（pde{n} 子代理技能，不占 pane）
├── dmt-de/SKILL.md                     # 开发工程师（dev-e 子代理技能，不占 pane）
├── dmt-ae/SKILL.md                     # 分析工程师（ana-e 子代理技能，不占 pane）
├── dmt-reviewer/SKILL.md                    # 审核工程师（reviewer{n} 子代理技能，不占 pane）
├── dmt-dm/SKILL.md                     # 开发经理
├── dmt-devl/SKILL.md                   # 开发队长（devl{n} pane 技能）
├── dmt-am/SKILL.md                     # 分析经理
├── scripts/                           # 仓级辅助脚本（不随安装分发）：
│   └── sync-mattpocock-codex-compat.sh # 把 to-spec / to-tickets / implement 的兼容副本装进 $CODEX_HOME/skills
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

脚本做四件事：① **按 harness 建技能落点**并软链或复制八个技能目录（默认 `--harness all` ⇒ `.agents/skills/` ＋ `.claude/skills/` ＋ `.codebuddy/skills/` 三处，覆盖五个 harness）；② 把整个 `dmt-director/`（含 `scripts/`）链接或复制到项目根；③ 把 `team.md`、`OPS.md` 与 `ops/` **软链**到 `docs/`（`--copy` 模式改为复制）；④ 调用 `init-project.sh` 建目录、写 `.gitignore` 并跑机检。

> **为什么要三个落点（2026-11-04 逐 harness 探针实测）**：各 harness **只认自己的技能目录**，没有「一处通用」—— `codex` / `opencode` / `pi` 读 `.agents/skills/`（`pi` 的项目级目录需 `--approve`），`claude` **只读** `.claude/skills/`，`codebuddy` **只读** `.codebuddy/skills/`。所以 `install-skills.sh` 默认铺满三处；只装一处会在 claude / codebuddy 上静默装不上。详见 `dmt-director/team.md` §1.2。

软链整个角色目录时，`dmt-director/` 里的契约、说明与机检脚本一并可见，不影响技能加载。
装到其他 harness 的用户级技能目录时，规则同样是**目录名即技能名**。

**五个 harness 的技能发现目录（2026-11-04 逐 harness 探针实测）**：`.agents/skills/` **不是**五者交集 —— 实测只有 `codex` / `opencode` / `pi` 读它，`claude` 与 `codebuddy` **只认各自私有目录**（项目级 `.claude/skills/` / `.codebuddy/skills/`，用户级 `~/.claude/skills/` / `~/.codebuddy/skills/`）。因此 `install-skills.sh` 的 `<target>/.agents/skills/` 落点只覆盖三者（`pi` 还需 `--approve`）；**装到 claude / codebuddy 时必须另软链其私有目录**。另一个易错点：`pi` 的用户级私有目录是 `~/.pi/agent/skills/`（**不是 `~/.pi/skills/`**），`opencode` 的项目级目录是 `.opencode/skills/`（**复数**）。**斜杠写法也不同**：claude / codebuddy / codex / opencode 用 `/dmt-dm`，**pi 用 `/skill:dmt-dm`** —— 启动脚本经 `lib-dmt.sh` 的 `dmt_skill_cmd` 自动生成，不要手敲。完整表（含项目级 / 用户级）见 `dmt-director/team.md` §1.2「harness 兼容」。

**Codex 备选启动**：

```bash
bash dmt-director/scripts/setup-team.sh --harness codex
```

Codex 的角色技能与 helper 任务随首轮 prompt 一次下发；mattpocock 插件技能用 `mattpocock-skills:<name>`。首次 trust 人工确认后，再跑 `setup-team.sh --harness codex --force-start`。Codex 在 herdr pane 中没有 `spawn_agent` 时只做本 pane 角色工作；不会伪造嵌套 pane 或 `codex exec` 子代理。详见 `dmt-director/ops/runtime.md`「Codex 差异」。

## 机检

```bash
bash dmt-director/scripts/check-dmt.sh <项目根目录>   # 单一入口：结构断言 + 内容断言
# 技能未装在 <项目根>/.agents/skills 时，用 DMT_SKILLS_DIR 覆盖
# 维护 dmt 仓自身（技能正本在仓根，不在 .agents/skills）：
DMT_SKILLS_DIR="$PWD" bash dmt-director/scripts/check-dmt.sh "$PWD"
```

**A 结构断言 + B 内容断言**，事实都来自单一来源：`dmt-director/dmt_contract.yaml`（技能清单 / 版本源 / 目录 / 组织 / 脚本 / 操作手册 / 技能预算 / **content_assertions**）与 `dmt-director/harness_matrix.yaml`（五 harness 矩阵）——加 / 改断言只改 YAML，不再散落中文 grep。**逐项说明与判据维护在 `dmt-director/team/09-check.md`（单一来源）**。

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

- **单一来源**：团队常量只在 `dmt-director/team.md`；操作细节按 `dmt-director/OPS.md` 路由到 `ops/`；harness 的**机器事实**只在 `harness_matrix.yaml`、**技能加载说明**只在 `dmt-director/harness/`（一份共性 ＋ 每 harness 一份差异）；结构事实只在 `dmt_contract.yaml`。八份技能只写「本角色怎么干」，harness 差异一律写指针。
- **版本同步**：版本号权威在 `dmt_contract.yaml`；`bash dmt-director/scripts/bump-version.sh <X.Y.Z>` 一条命令刷进 team.md 与八份 SKILL.md，`--check` 复核同号。
- **防泄漏门禁**：`bash dmt-director/scripts/install-git-hooks.sh` 启用受版本控制的 `pre-commit`（拦截 `.env`、内网地址、密钥形态）；`launch.sh` 默认安装。误报用 `git commit --no-verify` 绕过。
- **变更记录**：`CHANGELOG.md` 只留当前季度条目；`bash dmt-director/scripts/archive-changelog.sh` 把更早季度整条原样归档到 `dmt-director/changelog/<YYYYQn>.md`。

- 本仓是 dmt 的**唯一维护地**。技能落点（`.agents/skills/`、`.claude/skills/`、`.codebuddy/skills/` 下的 `<角色>/`，由 `install-skills.sh` 按 `--harness` 铺设）与 **`docs/team.md` / `docs/OPS.md` / `docs/ops/` 均以软链安装**（默认 `link` 模式）⇒ 随本仓更新、改完即生效，**无需重跑安装**。仅 `--copy` 安装的项目不跟随本仓。
- 技能内的契约引用不依赖相对路径（写作「`dmt-director/team.md`（本仓；装到项目后为 `docs/team.md`）」），因此软链安装不会断链。
- **`dmt-en`（英文镜像仓）与 `dmt` 同步维护**（当前 `5.18.8`，待同步 `5.19.0`，八技能 ＋ `harness/` 层）：中文仓 `dmt` 是**权威源**，两仓不一致时以 `dmt` 为准并按本仓当期内容重新同步；**不要把 `dmt-en` 当权威**。
- 脚本接口变更（参数、输出、退出码）视为契约变更，必须同步八个技能与机检 4m。
- 依赖 harness 侧技能：`herdr`（pane 控制与 label 识别）、`cbc-herdr`（仅 CodeBuddy 状态上报）、`pi-subagents`（仅 pi harness；Codex 用原生 `spawn_agent`/`wait_agent`，cbc 用 Agent/team 子代理），以及 mattpocock 的 [`/to-spec`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md)、[`/to-tickets`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md)、[`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)、[`/tdd`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md)、[`/research`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/research/SKILL.md) 等（安装与回退见 `team.md` §1.4）。
