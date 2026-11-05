# harness × dmt 配合实测汇总（2026-11-05 · pi / claude 双侧）

> **范围**：dmt 七角色技能在 **pi（pi-coding-agent）** 与 **Claude Code** 两个 harness 上的「技能发现 → 装载 → 强制技能调用 → 子代理承载」全链路实测，以及实测暴露缺陷的汇总与处置。
> **来源**：pi 侧为本仓工作区实测（workspace4 / `w5`）；claude 侧引自另一位 agent 的报告（完整版 `/tmp/pi-summary.txt`，摘要版 `/tmp/pi-msg.txt`）。文中**引述**与**本侧实测**已分别标注。
> **配套变更**：`CHANGELOG.md` 第七十九～八十一次条目（`5.18.0` → `5.18.2`）。

## 一、结论

| harness | 结论 | 依据 |
|---|---|---|
| **pi** | 可用：技能可发现（`/skill:` 与 read 文件两路）、七角色可装载、子代理可承载（`delegate`） | 本侧实测（下文 §3.1） |
| **Claude Code** | 可用：技能可发现、可斜杠调起、子代理可继承技能；「写文档 / 写代码 / 派子代理取证」三模式均有实证 | 引述 §3.2 |

**共同缺口（双侧同源）**：mattpocock 部分技能正文要求 `Call the Skill tool …`（转发式），而 **pi 无 Skill 工具**、claude 侧需按 harness 语义核对 ⇒ 已在 `harness/pi.md` §5.1 立降级规则。

## 二、环境与测试方法

### 2.1 pi 侧（本侧实测）

- workspace `w5`（label `workspace4`）、tab `dmt-pi`、三 pane：`director-pi` / `devm-pi` / `anam-pi`，cwd `/tmp/dmt-pi-lab`。
- 启动：`pi --approve`（项目级 `.agents/skills/` 属 trust-requiring）→ 就绪后注入 `/skill:dmt-director` / `/skill:dmt-dm` / `/skill:dmt-am`。
- 项目侧：`install-skills.sh /tmp/dmt-pi-lab --harness pi`（七技能软链进 `.agents/skills/`），机检 `ALL_PASS`。

### 2.2 claude 侧（引述报告）

- 三 pane 以 `claude --dangerously-skip-permissions --settings tianyi.json` 启动，`dmt_pane_auto_mode` 三个均 rc=0（yolo 档被 dmt 判据正确识别）。
- `/dmt-director` `/dmt-dm` `/dmt-am` 装载成功；子代理 `Skill(dmt-de)` 成功；`claude -p '/dmt-ae'` 正确返回技能名 + 版本。

## 三、实测结果

### 3.1 pi 侧（本侧实测）

| # | 测试 | 结果 |
|---|---|---|
| 1 | 三角色技能装载 | ✅ 三个 pane 均按角色技能行动（devm 做「身份自证 / 认知刷新 / 回报 / 门铃」四步；director 认领 inbox；anam 走调研→独立复核→落盘） |
| 2 | mattpocock 技能调用 | ✅ `grilling`（director）、`code-review`（devm）、`research`（anam）均被实际使用；模型自述「pi 无 Skill 工具（见 `harness/pi.md` §4），已实读 `~/.pi/agent/git/github.com/mattpocock/skills/skills/productivity/grilling/SKILL.md`」 |
| 3 | 子代理启动 | ✅ `pde1` / `dev-e` / `ana-e` 三个子代理均由 `delegate` 承载派出并回收；**子代理留痕含 `harness/COMMON.md` ＋ `harness/pi.md`** ⇒ 「按 harness 加载」机制端到端生效 |
| 4 | 定向技能可用性（`to-spec` / `to-tickets` / `grill-with-docs` / `tdd` / `implement` / `research`） | ✅ **7/7 技能文件读取通路打通**（pane 角色与子代理均可）；寻径链＝`dmt-<角色>/SKILL.md` → `team/03-comms.md` §1.4 → `harness/pi.md` §5 |
| 5 | 产物落地 | ✅ `docs/analyst/001-research-greet-py-261105-1622--v1.md`；`inbox/director/.doing/001-devm2director-…md`（发信→认领三态跑通） |

**pi 侧缺口（已处置）**：`grill-with-docs` 正文**只有一句** `Call the Skill tool twice, for "grilling" and "domain-modeling"` ⇒ pi 上必须降级为 `read` 两份子技能；同族受影响：`grill-me`、`implement`、`tdd`。

### 3.2 claude 侧（引述报告，未在本侧复跑）

| # | 测试 | 结果 |
|---|---|---|
| 1 | director `/to-spec` → `/to-tickets` | 会话核到两次真实 Skill 调用；SPEC 205 行（7 个标准章节齐全）＋ 3 张 tracer-bullet 工单，阻塞边 `01→None / 02→01 / 03→02` 正确成链 |
| 2 | devm `/implement` | 调用链 `implement → tdd → code-review`，`code-review` 又自派 2 个并行只读子代理（Standards 轴 / Spec 轴）；产出 `mathx.py` + `test_mathx.py`，`pytest` 11 passed；红阶段真红（`ModuleNotFoundError`） |
| 3 | anam 派子代理 `/research` | 一条消息双发 2 个 Agent，子代理各调 `research`（其一另加 `grilling` 自审），主代理再调 `research` 收口；产出 `a.md` 18.4K / `b.md` 19.5K / `summary.md` 12.3K |
| 3b | 质量对照（故意写错常量） | 提示里把 CameraX 常量写成 `OUTPUT_IMAGE_FORMAT_YUV_420_888 = 0x23`（混用命名空间）；子代理**未顺着说**，指出错误并把 CameraX 常量 `=1` 与平台值 `ImageFormat.YUV_420_888 = 0x23` 分开列，还拉 `androidx-main@e6e39ba6` ＋ `camera-core-1.4.2-sources.jar` 双源交叉验证 |

## 四、缺陷清单与处置（合并两侧）

| # | 缺陷 | 来源 | 本轮处置 |
|---|---|---|---|
| 1 | `check-dmt.sh` 的 `REPO` 不解析软链（P0）：项目里 `dmt-director` 是软链 ⇒ REPO 算成项目根 ⇒ 六技能「文件不存在」、A7 雪崩（报告实测：仓内 0 FAIL / 项目根相对路径 305 FAIL / 绝对真路径 9 FAIL） | claude | ✅ **修**：20 个脚本统一 `cd -P … && pwd -P`（`check-dmt.sh` / `lib-dmt.sh` / `bump-version.sh` 等）。本侧复测：lab **软链调用**由「`SKIP 维护仓自身` ＋ `maintenance_only` 假红」→ **`ALL_PASS`** |
| 2 | pane label `<角色>-pi` 与契约「label == 角色名」冲突 ⇒ `dmt_pane_by_label director` 返回空、门铃失效（anam-pi 按纪律停手上报） | pi | ✅ **修**：`dmt_pane_by_label` 增**唯一前缀回退**（精确优先；`<角色>-*` 命中多个 ⇒ 给空不猜）；`send-msg.sh` 复用该函数并接受 `<角色>-<后缀>` 的收发名 |
| 3 | `docs/handoff/` 契约 §3 列了但 `init-project.sh` 未建 | pi | ✅ **修**：`init-project.sh` 建 `docs/handoff/` |
| 4 | `.gitignore` 未覆盖 `__pycache__`（子代理探针残留 `.pyc`） | pi | ✅ **修**：`init-project.sh` 与仓 `.gitignore` 同时加 `__pycache__/`、`*.pyc` |
| 5 | A7 断链检查未排除代码块（P2）：4 条红全是 markdown 行内代码伪链接（`x[i]`、`+out1`、`[a-z0-9_]+`） | claude | ✅ **修**：A7 提取链接前先剥围栏代码块与行内代码 |
| 6 | claude 侧「无 auto 复核加固」＋ `harness/claude.md` §2 写「同 codebuddy」但不成立（P2） | claude | ✅ **修**：`harness/claude.md` §2 更正 —— claude **无本地复核器**；`auto` 档依赖远程 classifier 会限流（报告实测 122 次 Bash 中 9 次被 rate-limited 拒掉，Zod 现象＝命令失败、错因在权限层）；给出 `--dangerously-skip-permissions` 选项；并登记「用户级 `permissions.defaultMode` 会让 argv 不带档位 ⇒ `dmt_pane_auto_mode` 误报」这一已知面 |
| 7 | `harness_matrix.yaml` 的 claude `max_subagents_env` 为 `null`（P3），而 claude 二进制含 `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` / `CLAUDE_CODE_MAX_SUBAGENTS_PER_SESSION` | claude | ✅ **修**：填 `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` |
| 8 | 子代理不守产物边界（P3）：测试目录堆 26 个 `.java` 抓取件 ＋ `aar`/`IPC.cpp`/`analyze.html` | claude | ✅ **修**：`harness/COMMON.md` §7「产物边界」（只落 prompt 指定路径） |
| 9 | pane 装载技能后**自动开工**（P3）：devm 真建 detached worktree，发现越界后自行 `git worktree remove --force` 撤销 | claude | ✅ **修**：`harness/COMMON.md` §7「加载 ≠ 开工」（停在就绪报到，等派单） |
| 10 | 误建多层嵌套目录 `dmt-director/team/dmt-director/ops/file-claim.md` | claude | ✅ **清**：已 `rm -rf dmt-director/team/dmt-director/` |
| 11 | 转发式技能依赖 Skill 工具（pi） | pi | ✅ **修**：`harness/pi.md` §5.1 ＋ `team/03-comms.md` §1.4 已知缺口 |
| 12 | 「打 readlink 修复后 A7 另报 6 条断链（文件实际存在）」 | claude | ✅ **复测未见**：当前维护仓与 lab 机检均 `ALL_PASS`（A7 已含第八十次的解析修正 ＋ 本次的代码块剥离） |
| 13 | 用户级 `~/.claude/skills/dmt-*` 与项目级重复安装（P3） | claude | ⚠️ **文档提示**（`harness/claude.md` §6），未强制清理 |
| 14 | `dmt-ae` 依赖 `/rea`，本机无 rea 技能（仅 REA MCP `rea-agents@6.4.0`，技能内有 `npx` 回退） | claude | ⚠️ pi 侧已在 `harness/pi.md` §5 说明（REA＝MCP 工具非技能）；claude 侧走 MCP / `npx` 回退 |
| 15 | docs 安装面缺件（P1）：目标项目 `docs/team.md` 被删、`docs/ops/`、`docs/team/` 不存在（旧版 `install-skills.sh` 所装） | claude | ⚠️ **需在目标项目重跑** `install-skills.sh`（脚本侧本轮再补 `docs/harness` 铺设；`install-skills.sh` 已会铺 `team.md`/`ops/`/`team/`/`harness/`） |

## 五、其他观察（引自 claude 侧报告）

- **档位复验的口径缺口**：w2 的 anam pane 权限实为 auto（来自用户级 `~/.claude/settings.json` 的 `permissions.defaultMode`），但 argv 不带档位参数 ⇒ `dmt_pane_auto_mode` 只读 argv，故记「非自动档」。已在 `harness/claude.md` §2 登记为已知误报面。
- **rtk 钩子**会改写 `git`/`ls`/`grep` 等命令，并把 `pytest` 输出折叠成一行 ⇒ 影响「原样证据」；脚本调用（`bash dmt-director/...`）不被改写。
- **两套团队同仓并行**：测试期间 w2 的 codebuddy 团队与本侧 pi 团队同时写仓库（新增 `u-f32`~`u-f37`、改 `docs/analyst/INDEX.md`）⇒ 有写入冲突风险，跨 harness 并行应显式约定文件面。

## 六、可复现命令

```bash
# 维护仓机检（应 ALL_PASS）
DMT_SKILLS_DIR="$PWD" bash dmt-director/scripts/check-dmt.sh "$PWD"

# 目标项目机检（软链安装；修复前会误判为「维护仓自身」）
DMT_SKILLS_DIR=<项目>/.agents/skills bash <项目>/dmt-director/scripts/check-dmt.sh <项目>

# harness 判定（技能加载第 0 步）
bash dmt-director/scripts/harness-detect.sh --explain
```

---

# 追加：claude 与 cbc 同构端到端实测（2026-11-05，本侧复跑）

> 本节为**本侧亲自执行**（非引述）：两个 workspace、各三 pane、yolo 档、`herdr agent prompt` 下发指令。
> 测试项目：`/tmp/dmt-claude-lab`（`--harness claude`）、`/tmp/dmt-cbc-lab`（`--harness codebuddy`），均 `install-skills.sh` 安装、机检 `ALL_PASS`。

## 1. 环境与方法

| 项 | claude 侧 | cbc 侧 |
|---|---|---|
| workspace | `w6`（label `claude-lab`） | `w7`（label `cbc-lab`） |
| pane | `director` / `devm` / `anam`（**用契约名**，同时验证 label 精确寻址） | 同左 |
| 启动 | `claude --dangerously-skip-permissions` | `codebuddy -y` |
| 权限 | `bypass permissions on` | `bypass permissions on` |
| 技能注入 | `herdr agent prompt <pane> /dmt-director` 等 | 同左 |
| 首启提示 | 需过一次 "trust this folder"（↓ + Enter） | 无 |

## 2. 测试项与结果（两侧同构，全部通过）

| 项 | claude 侧实测 | cbc 侧实测 |
|---|---|---|
| T1 角色技能装载 | ✅ 三角色就绪自述 | ✅ 三角色就绪自述 |
| T2 `/to-spec`＋`/to-tickets`（director） | ✅ SPEC 46 行；工单 2 张，`02 blocked by 01` | ✅ SPEC 38 行；工单 2 张，依赖边正确 |
| T3 `/implement`→`/tdd`→`/code-review`（devm） | ✅ 三步均发生；`pytest` **1 passed**（复跑一致）；0 findings | ✅ 三步均发生（`implement` 带 `disable-model-invocation: true` 仍调起成功）；`pytest` **2 passed**（复跑一致） |
| T4 `/research`＋并行子代理（anam） | ✅ 2 个子代理；38 行落盘；**交叉校验出冲突点**（`greet(None) == greet('stranger')` 为 True 但身份不同） | ✅ 2 个子代理；27 行落盘；证据目录 `docs/analyst/evidence/{none,non-str}/` |
| T5 门铃（`send-msg.sh` label 精确匹配） | ✅ 无 WARN；director 收件→`.doing/`→收口删除 | ✅ 无 WARN；同链路通 |

**工具级硬证据**（session 文件解析，非模型自述）：

| 侧 | session | Skill 调用 | 子代理 |
|---|---|---|---|
| claude | director | `to-spec`×2、`to-tickets`×2 | — |
| claude | devm | `implement`×2、`tdd`×2、`code-review`×2 | — |
| claude | anam | `research`×2 | `Agent`×4（general-purpose） |
| cbc | director | `to-spec`、`to-tickets` | — |
| cbc | devm | `code-review`（＋`implement`/`tdd` 正文痕迹 40/42 处） | `Agent`×1 |
| cbc | anam | `research` | `Agent`×2 |

## 3. 与 pi 的关键差异（本次三 harness 对照）

| 维度 | pi | claude | cbc |
|---|---|---|---|
| Skill 工具 | **无**（只能 read 文件） | **有**（实测 `Skill` 直接调用） | **有**（实测 `Skill` 调用成功） |
| 子代理机制 | `delegate`（无技能继承） | `Agent`（general-purpose，可继承技能） | `Agent`（general-purpose，可继承技能） |
| 强制技能调用行 | `/skill:<name>` | `/<name>` | `/<name>` |
| `disable-model-invocation` 技能 | `/skill:` 可显式调起；模型只能 read | 可 `Skill` 直接调起 | 可 `Skill` 直接调起 |
| yolo/自动档 | `--approve` | `--dangerously-skip-permissions`（无 classifier 限流） | `-y`（HIGH/CRITICAL 仍问） |
| 首启额外步骤 | 项目级技能需 `--approve` | 需确认 trust folder | 无 |

⇒ **结论**：dmt 七角色在 claude / cbc 上属于「原生承载」（Skill 工具 + 子代理继承技能），pi 属「降级承载」（read 文件 + `delegate`）；三者均能完成「文档 / 代码 / 取证」三类工作。

## 4. 本次实测新发现

| # | 发现 | 级别 | 处置 |
|---|---|---|---|
| 1 | `harness/claude.md` 说「同 codebuddy」已被上一轮更正；本次确认 claude yolo 档**无 classifier 限流**（122 次 Bash 那次限流发生在 `auto` 档） | 观察 | 文档已含 |
| 2 | cbc `-y` 档仍有 HIGH/CRITICAL 询问（`--help` 明示），与 `--permission-mode auto` 不同 | 观察 | 已记 `harness/codebuddy.md` 待补 |
| 3 | 并发写干扰：同一 lab 内 devm 改 `src/mathx.py` 时 anam 正在取证同目录（anam 主动声明「mathx.py 变大非本次产物」）⇒ 单写者纪律有效 | 观察 | 无需变更 |
| 4 | 两侧 lab 用 `install-skills.sh --harness claude|codebuddy` 单落点安装，机检（软链调用）均 `ALL_PASS` ⇒ 第八十一次 P0 修复在真实单落点安装下成立 | 验证 | — |
