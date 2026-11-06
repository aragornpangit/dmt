# 各 harness 改善清单（BACKLOG）

> **English summary**：see repo-local `logs/2026-11-06-harness-test-report.en.md`.
> 来源：五 harness 端到端实测（仓内 `logs/2026-11-06-harness-test-report.md`）。
> 状态：`DONE` = 已改进融进仓；`WATCH` = 环境侧/上游侧问题，仓内只能兜底并留痕；`OPEN` = 待办。
> **纪律**：每项必须写「判据」（怎么验证改好了），不接受「改完就算」。

## pi

| # | 项 | 判据 | 状态 |
|---|---|---|---|
| P1 | 子代理无技能清单（`delegate` `inheritSkills: false`） | 自定义 agent `inheritSkills: false + skills:[…]` 的子代理 `<available_skills>` **只含列出的技能，且实际注入必须与声明逐条相等**（`disable-model-invocation: true` 会被静默过滤 ⇒ 该类技能不写进 `skills:`，改由 prompt 给路径） | **DONE**（`harness/pi-agents/`；2026-11-06 实测：`dmt-dev-e` 4 项、`dmt-pde` 3 项、`dmt-ana-e` 3 项，与整形后的声明一致；机检 A6c 静态守护） |
| P2 | 无 Skill 工具（转发式技能静默失效） | `harness/pi.md` §5.1 列出 `grill-with-docs`/`grill-me`/`implement`/`tdd` 的降级读法 | **DONE** |
| P3 | 并发上限未声明（矩阵 `null`） | `harness_matrix.yaml` 的 `pi.max_subagents_conc` 有值，与 pi-subagents 默认一致（`maxTasks=8` / `concurrency=4`） | **DONE**（填 8 ＋ 配置键说明） |
| P4 | 同名技能重复注册（`tdd`/`code-review` 各两份） | `harness/pi.md` §4.4 写明成因与规避（用 `skills:` 点名；只保留一份） | **DONE** |
| P5 | 启动初期输入未就绪（`/skill:` 早于 TUI 就绪） | 装载后必须用 `dmt_confirm_role_ready` 复核「角色名 ＋ 一次性凭据」出现在 pane 输出 | **DONE**（`harness/pi.md` §7 + `lib-dmt.sh` 已有该函数） |

## codebuddy (cbc)

| # | 项 | 判据 | 状态 |
|---|---|---|---|
| C1 | `-y` 与 `--permission-mode auto` 混用风险（前者 HIGH/CRITICAL 仍问） | `harness/codebuddy.md` §2 写明两种档位差异与判据 | **DONE** |
| C2 | 子代理权限继承未显式指定 | 矩阵 codebuddy `start_cmd` 带 `--subagent-permission-mode bypassPermissions`，子代理不再回 default 档 | **DONE** |
| C3 | auto 档复核器限流把「命令失败」伪装成脚本故障 | `ops/permission-notes.md` 已载 300s 预算 + 健康门 + allow 规则；`harness/codebuddy.md` 指向它 | **DONE**（既有） |
| C4 | `cbc-herdr` 缺登记时 `agent_status` 恒 `unknown` | 三个 pane 角色启动后 `agent_status != unknown`；缺则按 `harness/codebuddy.md` §6 补登记 | **DONE**（既有文档） |

## claude

| # | 项 | 判据 | 状态 |
|---|---|---|---|
| L1 | `auto` 档远程 classifier 限流（122 次 Bash 中 9 次被拒） | `harness/claude.md` §2 写明：无本地复核器、可改 yolo 档 | **DONE** |
| L2 | `permissions.defaultMode=auto` 时 argv 不带档位 ⇒ `dmt_pane_auto_mode` 误报 | `harness/claude.md` §2 登记为「已知误报面 + 人工确认」 | **DONE** |
| L3 | 用户级与项目级重复安装（旧副本会被非 dmt 项目命中） | `harness/claude.md` §6 写明建议（只留项目级或软链到仓）；机检不强制 | **DONE**（文档级） |
| L4 | 并发上限的 env 名 | 矩阵 `claude.max_subagents_env = CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` | **DONE** |

## codex

| # | 项 | 判据 | 状态 |
|---|---|---|---|
| X1 | 默认沙箱拒连 herdr socket ⇒ 门铃/身份/file-claim 全废 | 矩阵 `start_cmd = codex -a never --sandbox danger-full-access`；`cd <项目> && send-msg.sh …` 无 `WARN` | **DONE** |
| X2 | shell 复用陈旧常驻环境（`HERDR_*` 指向废弃 session） | 模拟陈旧环境（`HERDR_SESSION=bcr-nihui` 等）跑 `send-msg.sh`：`rc=0` 且无 `WARN` | **DONE**（`dmt_herdr_env_fix`） |
| X3 | `spawn_agent` 载荷不送达（Full Access 下复测同样失败） | codex 上游修复后才能改判；当前按 `[SUBAGENT_UNAVAILABLE]` 记录并由本 pane 代行 | **WATCH**（上游缺陷，附复测证据） |
| X4 | 技能注入依赖首轮 prompt（`first_prompt: true`） | `harness/codex.md` §4 写明「技能与任务随首轮下发；重载须重开 pane」 | **DONE** |
| X5 | 子代理若可用，需限制嵌套 | `harness/codex.md` §4 已有「无 spawn_agent 接口时不得用 shell 嵌套伪造团队」 | **DONE** |

## opencode

| # | 项 | 判据 | 状态 |
|---|---|---|---|
| O1 | 斜杠命令清单不全（`/to-spec`、`/to-tickets` 敲了不生效） | `harness/opencode.md` §3 改为「`skill` 工具优先（按 id 加载），不可用再直读文件」 | **DONE** |
| O2 | 启动初期输入未就绪（`agent prompt` 只填入不提交） | 文档写明「首次注入后复核 pane 输出，必要时补 `send-keys enter`」 | **DONE** |
| O3 | 并发上限未声明 | 矩阵 `opencode.max_subagents_conc` 注明「上游未提供入口，按任务规模自判」 | **DONE**（显式声明为不设，而非留空） |
| O4 | 技能发现目录易踩单复数（`.opencode/skills/` vs `skill/`） | `harness/opencode.md` §1 已写明单数不生效 | **DONE** |
| O5 | OpenCode v2 统一用 `@<skill-id>` 加载技能（2026-11-06 用户裁定） | 在 opencode 2.2.5 pane 中 `herdr agent prompt <pane> '@to-spec'` 能让技能正文进入上下文；同名文件存在时选中 skill 而非文件；`skill({id})` 仍可用 | **OPEN**（契约已改，2.2.5 复测待补） |

## 跨 harness

| # | 项 | 判据 | 状态 |
|---|---|---|---|
| A1 | 技能"能装载"≠"能工作"（转发式技能） | `harness/COMMON.md` §2 指向 §1.4；`pi.md` §5.1 给降级规则 | **DONE** |
| A2 | pane 通信是共同底线，但 codex 例外 | 矩阵已内建 codex 的 full-access；`harness/codex.md` §6.1 对照表 | **DONE** |
| A3 | 子代理边界（产物边界 / 加载≠开工） | `harness/COMMON.md` §7 | **DONE** |
| A4 | 机检须能抓住回退 | `check-dmt.sh` A6b：harness 文件齐备 + 与矩阵 key 一致 + 八技能含第 0 步 + 检测脚本五 harness 自测 + pi-agents 白名单形态 | **DONE** |
| A5 | `send-msg.sh` 只校验**角色合法**、不校验**方向合法** ⇒ `ops/comms.md` 的「允许方向」表是纯文档，脚本不拦 | `send-msg.sh <to> <from> … --dry-run`：`devl1→devl2`（队长互连）、`director→devl{n}`（越级）、`anam→devl{n}`（跨部门）、`devl{n}→anam` / `devl{n}→director`（越级上报）**全部 exit 2**；合法方向（`devm→devl{n}` / `devl{n}→devm` / `director↔devm` / `director↔anam` / `{角色}-helper→本体`）仍 rc=0 | **DONE**（`dir_ok()` 唯一实现 ＋ `--check-dir`；机检 A6b 16 条方向自测：8 合法 rc=0 / 8 非法 rc=2，全 OK） |
