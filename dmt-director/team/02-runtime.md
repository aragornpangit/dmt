### 1.2 运行环境与 pane 生命周期

**操作细节见 [`dmt-director/OPS.md`](dmt-director/OPS.md) §1** —— pane/tab 形态、身份＝`pane label`、启动顺序、helper 生命周期（含 helper tab 的锚点 pane `helper-anchor`）、首条消息前的权限模式。

**harness 兼容（五个；2026-11-04 第六十五次逐 harness 探针实测复核）**：

| harness | 技能发现目录（实测；`<项目>/` 项目级、`~/` 用户级） | 代启动命令 | 技能调用行 |
|---|---|---|---|
| `claude` | 项目级 `.claude/skills/`；用户级 `~/.claude/skills/` | `claude --permission-mode auto` | `/dmt-dm` |
| `codebuddy` | 项目级 `.codebuddy/skills/`；用户级 `~/.codebuddy/skills/` | `codebuddy --permission-mode auto` | `/dmt-dm` |
| `codex` | 项目级 `.agents/skills/`、`.codex/skills/`；用户级 `~/.agents/skills/`、`~/.codex/skills/` | `codex -a never` | `/dmt-dm` |
| `opencode` | 项目级 `.agents/skills/`、`.claude/skills/`、`.opencode/skills/`（**复数**）；用户级 `~/.agents/skills/`、`~/.claude/skills/` | `opencode --auto` | `/dmt-dm` |
| `pi` | 项目级 `.agents/skills/`、`.pi/skills/`；用户级 `~/.agents/skills/`、`~/.pi/agent/skills/`（**不是 `~/.pi/skills/`**） | `pi --approve` | **`/skill:dmt-dm`** |

**四条实测约束**（写进契约以免回退）：
1. **斜杠前缀按 harness 分流**：pi 的技能命令是 `/skill:<name>`，其余四个是 `/<name>`。写死 `/<name>` 在 pi 上**静默降级为普通提问**（不报错、不装载）。统一由 `lib-dmt.sh` 的 `dmt_skill_cmd` 生成，`setup-team.sh` / `spawn-helper.sh` 一律经它取命令，**不得在脚本或文档里写死某一种前缀**。
2. **`.agents/skills/` 不是五个 harness 的交集**（2026-11-04 实测更正第六十二次的结论）：只有 `codex` / `opencode` / `pi` 读它（项目级与用户级同理），**`claude` 与 `codebuddy` 都不读**——它们各自只认私有目录（`.claude/skills/` / `.codebuddy/skills/`）。`install-skills.sh` **默认 `--harness all`（`<target>/.agents/skills/` ＋ `.claude/skills/` ＋ `.codebuddy/skills/` 三处）**因此覆盖五个 harness；只装 `.agents/skills/` 一处会在 claude / codebuddy 上静默装不上（`--harness claude,codex,…` 可收窄）。**pi 的项目级 `.agents/skills` 属 trust-requiring**，启动不带 `--approve` 就看不到（实测：不带时只见用户级技能）—— 这也是 `dmt_harness_cmd` 给 pi 固定带该参数的原因。
3. **codex 首次进入项目目录需人工确认 trust（一次性）**；`-a never` 只免逐条审批，不免这一步。pane 卡在 trust 提示时由 director 手工确认后重跑 `setup-team.sh`。

**4. 权限档位必须复验，不能只看「有没有 agent 在跑」**（2026-11-03 第六十三次，事故实证）：`agent_status` 非 `unknown` 只证明 pane 里有 agent，**不证明它在自动批准档**。2026-11-03 bcr-nh 实测三个常驻 pane（`director` / `devm` / `anam`）**全部落在 default 档**，当日日志 33 次工具栏 `ASK`；表象却是「脚本超时 / 命令失败」（另一 pane 标题直接写着 `file-claim.sh 审批超时`），而脚本本体 57ms 正常返回 —— 根因在权限层，现象在命令层，极易误判成脚本坏了。
   - **判据读 argv，不读屏幕**：屏幕上的 `auto mode on` 只在手动会话首屏出现，之后被输出顶走；argv 是恒定事实。`lib-dmt.sh: dmt_pane_auto_mode <pane>` 逐 token 判（`--permission-mode auto` / `--dangerously-skip-permissions` / `--yolo` / `--approve` / `--auto` / `-a never` / `--ask-for-approval never`），**用子串匹配会把 `--autocompact auto` 误判成自动档**，故必须逐 token。
   - **接线**：`setup-team.sh` / `spawn-helper.sh` 在「就绪 + 输技能」之后调 `verify_auto_mode`；rc=1 打 `WARN` 并指出 argv，rc=2（拿不到 argv）只打 `INFO`、不当违规。
   - **既有 pane 也适用**：巡检发现非自动档 ⇒ 用 `setup-team.sh --force-start`（或重开 pane）修正；**不要**只在文档里写「应该用 auto」而不复验。
