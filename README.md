# dmt

dmt 团队的角色技能仓：**团队定义与八个角色技能的唯一维护地**。

- **层级**：`director`（总监兼产品部经理）→ `devm` → `devl{n}` → `dev-e`；`director` → `anam` → `ana-e`；`pde{n}` 直属 director；`reviewer{n}` 双轨（主轨归 `devl{n}`、副轨归 `director`）。
- **产品部并入总监**：不设产品经理。PRD / SPEC 由 `pde{n}` 落笔、director 定稿；工单由 `devm` 落笔、director 定稿；人类文档 director 亲自写。
- **用户入口**：`director` 是默认入口；用户可直连 `devm` / `anam`，经理开工即知会 director。
- **写权**：merge / push 只归 `devm`；`devl{n}` / `dev-e` 只在 worktree 内 commit；硬件设备写操作 `devm` 与 `director` 均可（同一设备单写者）。

> **作用域**：全部纪律（权限、写操作归属、门禁、pane 生命周期、收件箱）**只作用于 dmt 管理的「目标项目」**（`init-project.sh <项目根>` 初始化的 root）。**维护 `dmt` / `dmt-en` 技能仓自身时不适用**：维护者可直接 `git add` / `commit` / `push`，无需 director 授权或 devm 代推。

**团队契约＝ [`dmt-director/team.md`](dmt-director/team.md)**（组织 / 通信 / 命名 / 目录 / 纪律的唯一权威）。其余按需读：

| 要什么 | 去哪 |
|---|---|
| 产物与目录职责 | [`team/05-dirs.md`](dmt-director/team/05-dirs.md) |
| 命名规则 | [`team/04-naming.md`](dmt-director/team/04-naming.md) |
| 工作流 | [`team/06-workflow.md`](dmt-director/team/06-workflow.md) |
| 纪律（Git / 并行 / 门禁） | [`team/07-discipline.md`](dmt-director/team/07-discipline.md) |
| 通信与强制技能 | [`ops/comms.md`](dmt-director/ops/comms.md) · [`team/03-comms.md`](dmt-director/team/03-comms.md) §1.4 |
| pane 生命周期 / helper | [`ops/runtime.md`](dmt-director/ops/runtime.md) · [`ops/helper.md`](dmt-director/ops/helper.md) |
| harness 机器事实 / 加载规则 | [`harness_matrix.yaml`](dmt-director/harness_matrix.yaml) · [`harness/README.md`](dmt-director/harness/README.md) |

```
dmt/
├── dmt-director/   # SKILL.md + team.md（契约）+ OPS.md + ops/ + harness/ + scripts/ + CHANGELOG（全量 100 条）
├── dmt-dm/ dmt-devl/ dmt-am/                # pane 角色技能
├── dmt-pde/ dmt-de/ dmt-ae/ dmt-reviewer/   # 子代理技能
├── scripts/        # 仓级辅助脚本（不随安装分发）
└── logs/           # 事故复盘档
```

## 安装到一个项目

仓内目录名即技能名，**装到技能目录时同名复制**；运行 id（`devm` 等）只是 pane label 与收件箱名。

```bash
bash dmt-director/scripts/install-skills.sh <项目根>              # 软链（推荐，跟随本仓更新）
bash dmt-director/scripts/install-skills.sh <项目根> --copy       # 复制（不跟随本仓）
bash dmt-director/scripts/install-skills.sh <项目根> --harness claude,codebuddy  # 收窄落点
```

脚本做四件事：① 按 harness 建技能落点并软链或复制八个技能目录（默认 `all` ⇒ `.agents/skills/` + `.claude/skills/` + `.codebuddy/skills/`）；② 把 `dmt-director/`（含 `scripts/`）链到项目根；③ 把 `team.md`、`OPS.md`、`ops/` 软链到 `docs/`；④ 调 `init-project.sh` 建目录、写 `.gitignore`、跑机检。

各 harness 只认自己的目录：`codex` / `opencode` / `pi` 读 `.agents/skills/`（pi 需 `--approve`），`claude` 读 `.claude/skills/`，`codebuddy` 读 `.codebuddy/skills/`。只装一处会静默漏装。

**Codex 备选启动**：`bash dmt-director/scripts/setup-team.sh --harness codex` —— 技能随首轮 prompt 下发，首次 trust 后重跑 `--force-start`；见 [`harness/codex.md`](dmt-director/harness/codex.md)。

## 机检

```bash
bash dmt-director/scripts/check-dmt.sh <项目根目录>   # 单一入口：结构断言 + 内容断言
# 技能未装在 <项目根>/.agents/skills 时用 DMT_SKILLS_DIR 覆盖；维护本仓自身：
DMT_SKILLS_DIR="$PWD" bash dmt-director/scripts/check-dmt.sh "$PWD"
```

事实都来自单一来源：`dmt_contract.yaml`（技能 / 版本源 / 目录 / 脚本 / 技能预算）、`dmt_assertions.yaml`（内容断言表）与 `harness_matrix.yaml`（五 harness 矩阵）——加改断言只改 YAML。逐项判据见 [`team/09-check.md`](dmt-director/team/09-check.md)。

## 内网端点配置（`.env`）

内网地址不写进仓库正文，用变量名引用、值放 `.env`（`cp .env.example .env`）。

| 变量 | 用途 |
|---|---|
| `DMT_GITLAB_SERVER` / `DMT_GITLAB_PORT` / `DMT_GITLAB_REPO` | 内网 GitLab（`publish.sh` 推送目标） |
| `DMT_LOCAL_MODEL_HOST` / `DMT_LOCAL_MODEL_PORT` | 本地复核器端点（拼 `http://<host>:<port>/v1/models`） |
| `DMT_AUTO_REVIEW_LOCAL_MODEL` | 本地复核器模型 id |

`dmt_load_env` 按 `$DMT_ENV_FILE` → `<项目根>/.env` → 技能仓根 `.env` 查找，**已导出的环境变量优先**；`.env` 不入库。`DMT_AUTO_REVIEW_URL` 可整条覆盖。

## 维护

- **单一来源**：团队常量只在 `team.md`；操作细节按 `OPS.md` 路由到 `ops/`；harness 机器事实只在 `harness_matrix.yaml`、加载说明只在 `harness/`；结构事实只在 `dmt_contract.yaml`、内容断言只在 `dmt_assertions.yaml`。八份技能只写「本角色怎么干」。
- **版本同步**：权威在 `dmt_contract.yaml`；`bash dmt-director/scripts/bump-version.sh <X.Y.Z>` 刷进 `team.md` 与八份 `SKILL.md`，`--check` 复核同号。
- **防泄漏门禁**：`bash dmt-director/scripts/install-git-hooks.sh` 启用 `pre-commit`（拦 `.env`、内网地址、密钥形态）；误报用 `git commit --no-verify`。
- **变更记录**：`CHANGELOG.md` 只留当前季度；`archive-changelog.sh` 把更早季度归档到 `dmt-director/changelog/<YYYYQn>.md`。
- **安装即生效**：技能落点与 `docs/team.md` / `docs/OPS.md` / `docs/ops/` 默认软链 ⇒ 改完即生效，无需重装；仅 `--copy` 不跟随。
- **`dmt-en` 落后本仓整批**（5.18.9）：缺 `dmt-devl`、四层组织、`devl-pane.sh`，`send-msg.sh` 白名单无 `devl{n}`。中文仓 `dmt` 是权威源，两仓不一致时按本仓整批重新同步，不要单点补。
- 脚本接口变更（参数 / 输出 / 退出码）视为契约变更，须同步八个技能与机检 4m。
- 依赖的 harness 侧技能：`herdr`、`cbc-herdr`（仅 cbc）、`pi-subagents`（仅 pi），以及 mattpocock 的 `/to-spec` `/to-tickets` `/code-review` `/tdd` `/research` 等（清单与安装见 `team/03-comms.md` §1.4）。

## 许可证

[MIT](LICENSE) © 2026 aragornpangit
