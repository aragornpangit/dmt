# dmt 团队操作手册（OPS）

> 本文是 [`team.md`](team.md)（团队契约 · 规范层）的**操作层配套**：pane 生命周期、收件箱协议、文件占用。
> 二者**共同构成 dmt 的团队定义**；**规范以 `team.md` 为准**，操作细节以本文为准。
> 装到目标项目时与 `team.md` 一并落到 `docs/`（`install-skills.sh` 软链）。

## 1. 运行环境与 pane 生命周期

**身份＝pane label，不是位置、不是 tab。** 每个常驻角色占一个 **pane**（`pde{n}` / `dev-e` / `ana-e` 是子代理、不占 pane），pane label 与角色/实例名同名（`director` / `devm` / `anam`；helper 为 `{角色}-helper`），在同一 workspace 内**唯一**。

- **tab 只是视觉分组**：**`anam` 占一个 tab**（tab label 与本人 pane label 同名）；**`devm` 不占 tab**，它的 pane 开在 **`director` 的 tab 内、director pane 右侧**（左 director、右 devm）。
- **识别伙伴一律按 pane label**（`herdr pane list` 过滤 `label`），**不按 tab 内位置、不按 pane id 记忆**：pane id 随重启变化，pane 顺序与 pane id 都会变，**只有 label 稳定**。
- **工程师仍是子代理**：`pde{n}` / `dev-e` / `ana-e` 不占 pane、不装技能（技能随派发 prompt 下发）、不走跨 pane 通信。
- **团队启动（director 全自动、幂等）**：用户备好 `director` tab 并启动 harness；director 先给自己正名（**tab label → pane label，顺序不可颠倒**），再在右侧 split 出 `devm`、另建 `anam` tab，两个 pane 由 director **代启动** harness（默认 `codebuddy --permission-mode auto`；`--harness pi|opencode|codex|claude` 或 `$DMT_HARNESS` 切换、`$DMT_HARNESS_CMD` 覆盖，白名单在 `lib-dmt.sh`），就绪判据＝`herdr pane get <pane>` 的 `agent_status` 非 `unknown`，随后输**技能命令**装载角色（claude / codebuddy / codex / opencode 用 `/dmt-dm`、`/dmt-am`；**pi 用 `/skill:dmt-dm`** —— 由 `dmt_skill_cmd` 按 harness 生成，写错前缀会静默变成普通提问）。**命令一律走 `bash dmt-director/scripts/setup-team.sh`，不手敲**。产品工作不需要 pane（director 自派 `pde{n}`，prompt 里下发 `/dmt-pde`）。
- **director 独占创建与维护**：`devm` / `anam` 的 pane、tab 与 label 只由 director 建、只由 director 改；开工前巡检两个 label，缺失/漂移就 `pane rename` 或重建 pane 并重走「代启动 + 输技能命令」。下级**不得**自行新建或改名自己的 pane/tab。
- **director 的 tab 内常驻 director 与 devm 两个 pane** ⇒ **禁止 `herdr tab close`**：关 tab 会连带杀掉 devm 与 director 自己；只许关 pane，且 director 不关 devm（devm 常驻）。
- **helper tab / helper pane（纯分身分流）**：**触发三条同时成立才开**（① 本体忙不过来；② 在途子代理已饱和、收不过来回报；③ 仍有待办）。**形态**：helper tab（label 固定 `helper`，**全队共享一个**，无则 `herdr tab create`）+ 其下 `{角色}-helper` pane（**每角色至多一个**），由 `spawn-helper.sh` 建、代启动、输同角色技能。**语义＝本体纯分身**：任务**随 spawn 一次性下发**，此后**不接受任何输入框内容**；成果**单向汇报给主体**（写 `inbox/<本体>/`，方向 `{角色}-helper2{角色}`）—— helper **没有自己的 inbox**、**不走门铃互通**。**生命周期归创建者**（建立 / 改名自愈 / 完成即回收 `close-helper.sh`；**helper tab 保留复用，禁 `herdr tab close`**）。**独占动作不移交**：装机只归 `director` 本体、merge / push 只归 `devm` 本体。helper 是 **pane 角色（非子代理）**。

```bash
# 按 pane label 解析（label 文字为准，不抄历史 pane id）
HERDR_ENV=1 herdr pane list --workspace "$HERDR_WORKSPACE_ID" \
  | jq -r --arg l "<角色名>" '.result.panes[] | select(.label==$l) | .pane_id'
```

若目标 label 不存在：**停下问用户**，不要猜测 pane id、不要对不存在的会话反复重试。
**迁移兜底**（仅当 label 缺失）：存在同名 tab 且该 tab 只有一个 pane 时，用该 pane；否则仍须停下问用户。**`devm` 例外**：它与 `director` 同 tab，该 tab 恒不止一个 pane，**不得**用 tab 兜底，必须按 label 或请用户重建。

**身份自愈**（每个角色启动后第一件事）：`herdr pane get "$HERDR_PANE_ID"` 读到的 label 与角色名不符（含为空）时，立即 `herdr pane rename "$HERDR_PANE_ID" <角色名>`。`devm` **不得**用 `herdr tab list` 认自己 —— 它的 tab label 是上级 `director` 的（devm 的 pane 在 director tab 内）。

**创建 pane 一律用脚本（不手敲）**：`setup-team.sh`（给自己正名 + 建 `devm`/`anam` + 代启动 + 输技能，幂等）、`spawn-helper.sh <角色> "<任务>"`（helper tab 下开 `{角色}-helper` 并**一次性下发**任务）、`close-helper.sh <角色>`（本体收口后关 helper pane；helper tab 保留复用）。脚本内部用 `herdr pane split/rename/send-text/send-keys`，自带 label 幂等检查与就绪轮询（`pane get` 的 `agent_status`，不是 `wait-output`）；`--dry-run` 只打印命令，`--no-start` 只建 pane 不启动。**布局只能在 split 时定对**（同 tab 内 `pane move` 返回 `changed:false`）。

**让 helper pane 进入角色**：由 `spawn-helper.sh` 一并完成（代启动 → 等 `agent_status` 非 `unknown` → 输同角色技能命令 → **任务随 spawn 一次性下发**），并用 `pane read` 核验输入框已清空。此后**不再**向 helper 的输入框投递任何内容。

**权限模式（仅用户手动启动的会话）**：harness 启动后、**发第一条消息前**按 `shift+Tab` 切到 `auto mode`，并确认面板底部出现 `auto mode on` —— **顺序不可颠倒**（会话一旦开始权限模式即锁定：`Mode cannot be changed after the conversation starts`，事后只能 `/clear` 重开，会丢掉在跑的子代理与上下文）。`setup-team.sh` / `spawn-helper.sh` **代启动的 pane 不走这条流程**（启动命令已带 `--permission-mode auto`，再按 `shift+Tab` 反而会切走）。

**档位复验（第六十三次，硬规则）**：代启动之后**必须回读 argv 复验档位**，`agent_status` 就绪 ≠ 自动档。`setup-team.sh` / `spawn-helper.sh` 已在「就绪 + 输技能」后自动调 `dmt_pane_auto_mode`（`lib-dmt.sh`），非自动档打 `WARN` 并打印 argv。**为什么非做不可**：2026-11-03 bcr-nh 的三个常驻 pane 全在 default 档，当日 33 次工具栏 `ASK`，而现象是「`file-claim.sh` 审批超时 / 命令失败」—— 脚本 57ms 正常，错在权限层。**巡检既有 pane**：`dmt_pane_auto_mode <pane_id>`（rc=0 自动 / 1 非自动 / 2 拿不到 argv），非自动档用 `setup-team.sh --force-start` 重开；判据读 argv、不读屏幕上的 `auto mode on`（那行只在首屏出现，随后被输出顶走）。

**auto 模式复核（`autoModeClassifier`）的已知坑与现行配置**：auto 模式下每个**需审批**的工具调用都要过一次自动复核（prompt 为整段会话上下文，默认 **90s 硬上限**）；企业网关抖动 / 限流时会以 `no verdict ... failure=timeout` 收场、命令被判失败，而表象像「脚本坏了」（2026-11-03 实测一次 `file-claim.sh check` 即如此，脚本本体 57ms 正常）。现行加固四条（2026-11-03 · 第六十/六十一次）：① `lib-dmt.sh` 的 `dmt_harness_cmd()` 为 codebuddy 前置 `CODEBUDDY_AUTO_REVIEW_TIMEOUT_MS=300000`，用户级 `~/.codebuddy/settings.json` 的 `env` 块同键兜底（覆盖手动启动的会话）；② 复核器优先走本地模型（`custom-local:Qwen3.8-27b`，本地 sglang `http://10.223.32.29:30000`），避开企业网关限流；③ **健康门 `auto-review-model.sh`**（随 harness 启动自动跑）：探活该端点，可达 ⇒ 钉本地、不可达 ⇒ 摘钉回退 cbc 内置链路（网关模型）—— **这道门不能省**，因为钉了模型就禁用 cbc 内置 fallback；`DMT_AUTO_REVIEW_GATE=off` 可整门关闭（纯走网关，保留人工选择）；④ 用户级 `permissions.allow` 覆盖 `dmt-director/scripts/` 下全部契约脚本（相对前缀 ＋ 三个绝对安装位置；命中即直接放行、不进复核）。**规则只认 `Bash(<前缀>:*)`**（去掉 `:*` 后按「首词相等／全等／前缀+空格」匹配）；**带 `*` 通配的规则在 auto 模式下会被判危险而整条忽略**，含重定向的命令不套规则。**健康门只在启动时跑**：端点会话中途挂掉，现役会话需重开 pane。

#### helper 实例的回收（任务完成即收）

只有 helper 是**按需实例**；`director` / `devm` / `anam` 本体 pane **常驻**。

- **责任人**：创建者本人（谁开谁关，用 `close-helper.sh`）；他人不得代关。
- **时机**：任务一收口**立即关 pane**，不留到下一批（同批内可复用）。
- **关闭前置（顺序固定）**：① 成果（逐条判据读数 / 一手出处）已并入票面或报告；② 名下 worktree 已 `git worktree remove`；③ `inbox/<本体>/` 中该 helper 方向消息已全部收口（`close-helper.sh` 自动判，不满足拒关，`--force` 可强关）。
- **禁止 `herdr tab close`**（helper tab 全队共享、保留复用，**只许关 pane**）。
- **禁止先关后收**：关 pane 会终止会话、**context 不可恢复**；关闭必须在成果入账与 worktree 回收**之后**，并向用户一句话报告。

## 2. 通信方式（收件箱文件 + herdr 门铃）

**正文一律走文件，herdr 只发门铃一句。** 派单、回报、评审结论、裁决请求、缺陷退回，全部先落成收件方收件箱里的一份文件，再用 herdr 敲一句「你有新消息 <文件名>」。**消息里不贴长正文、不贴日志、不贴 diff。**

**允许的直接通信只有上下级这一条线**（其余一律经上级转派）；helper 例外：只有 **helper → 本体** 的单向汇报（不走门铃、无回程）：

| 发送方 | 收件方 | 方向码 |
|---|---|---|
| `director` | `devm` / `anam` | `director2devm` / `director2anam` |
| `devm` / `anam` | `director` | `devm2director` / `anam2director` |
| `devm-helper` / `anam-helper` / `director-helper` | 本体（`devm` / `anam` / `director`） | `{角色}-helper2{角色}`（**单向汇报，无门铃、无回程**；helper 无自己的 inbox） |

**第一步 定位伙伴**（每次重跑，禁止复用上一次的 pane id）：`herdr pane list` 按 **pane label** 取**当前** pane id（label 与角色名同名、全 workspace 唯一）。label 不在列表里 ⇒ **停下问用户**，不猜 pane id、不按 tab 内位置兜底。

**第二步 写收件箱文件**

- 路径：**项目根目录**下的 `inbox/<收件角色>/{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`（`<收件角色>` ∈ `director` / `devm` / `anam`；**不在 `docs/` 下**；目录不存在先 `mkdir -p`）
- `{seq}`：自累计流水号，001 起（与 SPEC 的 `spec-seq` 无关）。**取号 = max(`inbox/<收件角色>/**` 含 `.doing/` 的最大号, `.seq` 高水位) + 1**；`.seq` 存**无前导零**十进制整数（防 bash 八进制误读），由 `send-msg.sh` 维护，**不要手改**
- **两个运行时子项**：`inbox/<收件角色>/.doing/`（已认领、在做）与 `inbox/<收件角色>/.seq`（序号高水位）；都在 `inbox/*/` 的 gitignore 覆盖内，不是交付物
- `{方向}`：见上表；跨部门事项由 director 转派，不出现 `devm2anam` 之类
- `{slug}`：英文小写短横线，不超过 5 个词
- `{YYMMDDHHMM}`：落盘时刻，两位年 + 月 + 日 + 时 + 分，无分隔符（例 `2610201430`）
- 正文**自包含**：一句话摘要 / 权威文档路径 / 请求动作 / 期望产物 / 回报要求

**用脚本**：`bash dmt-director/scripts/send-msg.sh <收件角色> <自己> <slug> <正文文件>` —— 自动算 `{seq}`、时刻与方向码，写文件后按 label 发门铃（`agent prompt` 返回非 `agent_prompted` 时回退 `send-text` + `send-keys`；label 不存在时只写文件并告警）。

**第三步 发门铃**（按**对端 harness** 选通道，消息只发一句：文件名 + 目录）

| 对端 harness | 门铃 |
|---|---|
| **codebuddy / pi-coding-agent / codex / opencode2 / opencode** | 优先 `HERDR_ENV=1 herdr agent prompt <pane> '你有新消息 {文件名}，在 inbox/<收件角色>/'`（**一次调用自带 Enter 提交**，返回 `"type":"agent_prompted"` 即送达；**codebuddy 面板同样适用**，2026-10-24 实测） |
| 回退（**仅当**对端是其它 harness，或 `agent prompt` 返回非 `agent_prompted`） | `HERDR_ENV=1 herdr pane send-text <pane> '…'` 紧跟 `HERDR_ENV=1 herdr pane send-keys <pane> enter`，投后 `pane read` 核验输入框已清空 |

发送前**必须先读目标面板**（`herdr pane read`）；若对方输入区有用户未提交内容，不得注入，改为等待或请用户转达。

**第四步 收件方处理（认领 → 处理 → 收口，三态）**

1. **先认领**：收到门铃后立即 `bash dmt-director/scripts/msg-take.sh <自己> <文件名>`，把文件从 `inbox/<自己>/` 移入 `inbox/<自己>/.doing/`。**认领在前、读入在后**：`mv` 是原子动作，重扫不会重复处理；`.doing/` 就是重启后的待办清单。
2. **再读入**：读 `.doing/` 里的该文件，**读入自己的 context window** 处理；读后**不发送回执**（**不回** `{文件名} 已经收到`、不发任何确认消息）。
3. **办完收口**：`bash dmt-director/scripts/msg-done.sh <自己> <文件名>` 从 `.doing/` 删除。**收件箱根目录只允许存在未读消息，`.doing/` 只允许存在在做消息**。
4. **重启 / 上下文压缩后**：`ls inbox/<自己>/*.md` = 未读，`ls inbox/<自己>/.doing/` = 续做清单；**不得因为重启而丢单**——`.doing/` 里有文件就说明有活没干完。
5. **`.doing/` 超过 24h 未收口**：上报直属上级（可能卡住，也可能忘了收口），**不自动删**。
6. 需要回正文时，按同样规则反向写文件 + 门铃，不把长正文塞进门铃消息。
7. **任何超过 10 分钟的操作（合并 / 构建 / 真机长跑 / 批量验证），开工前扫一次收件箱，收工后再扫一次。** 长操作期间不回看收件箱，是**已知会漏消息**的行为，不是意外。

   - **How to apply**：把「扫收件箱」当成操作的**前后置动作**，不是独立任务；扫的时候看两处 `ls inbox/<自己>/ inbox/<自己>/.doing/`，有文件就当场认领处理，**不要攒着**。攒着的后果是：你基于过时的状态继续决策，而对方以为你已经知道了。

**完成即报（不傻等）**：`devm` / `anam` 本批工作一收口，或遇阻塞 / 超时 / 需要上级裁决，**立即**向直接上级发回报（收件箱正文 + 门铃），不等上级来问、不静默挂着；`director` 完成用户交办事项后同理主动向用户回报。收工前自查一句：「我有没有把结果告诉该告诉的人？」

**送达判定**：以 `herdr agent prompt` 返回 `"type":"agent_prompted"` 为「已送达」；走回退通道时以 `send-text + send-keys` 返回 exit 0 **且** `pane read` 见正文为「已送达」；**收件方不回执**，故不再以回执判定。发送方不确定是否已被读取时，**口头问用户**，不重复投递。

**不入库**：收件箱与 `locks/` 都是运行时通道，不是交付物；被服务项目的 `.gitignore` 必须含 `inbox/*/` 与 `locks/`。

## 3. 文件占用（编辑前必须检查）

**硬规则：任何角色编辑（写入 / 追加 / 删除）任何文件前，必须先 `check`；占用到手才能改；改完立刻 `release`。**

```bash
bash dmt-director/scripts/file-claim.sh check|claim|release <path> <owner>   # rc=0 可写；rc=3 他人占用
bash dmt-director/scripts/file-claim.sh list                                 # 看全部占用
```

- 记录落**主工作树**根 `locks/`（运行时通道、**不入库**、`.gitignore` 覆盖）；在 worktree 里跑也写回 `<main>/locks/`。`<owner>` 写「角色:实例」（如 `devm-helper`）。
- **rc=3 ⇒ 停手**：等对方释放 / 改做别的文件 / 回报上级协调；**不得绕过、不得删别人的锁**。
- **TTL 30 分钟**：过期锁视为可抢占，抢占须在回报写明「接管过期锁 `<path>`（原持有者 `<owner>`）」；超 30 分钟的任务收工前重新 `claim` 续期。
- **例外**：`inbox/` 消息与 `locks/` 自身**不登记**。**worktree 不是豁免** —— 一票一 worktree 只隔分支，同一 worktree 仍可能多写者（如交接前后），照样登记。
- 可选：`orca status` 可连通时编辑前跑 `orca worktree ps`，确认同 worktree 无活跃 agent（有则在回报注明）。

