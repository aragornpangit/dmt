## 5. 纪律

### 5.1 Git

1. **禁止 `git add -A` / `git add .`**，提交一律显式列文件路径（优先 `git commit -m "..." -- <path>`，绕过索引），且 `add` 与 `commit` 之间不插入其它动作（避免索引被并发写者扫入）。
2. **代码库归 devm 管理：merge 与 push 只归 devm**（**作用域＝目标项目**：本条的 push / merge 归属只约束 dmt 工作流所管理的项目仓库；**维护 `dmt` / `dmt-en` 等技能仓自身时不受此限**，见文件头「作用域（Scope）」）：`git push` 与合并主干（merge）**只有 `devm` 能执行**（**收到本部门 `reviewer{n}` 验收通过后**即可推送，不必再等 director 通知）；`director` 保留抽查权（抽查后仍由 devm 推送）；`anam` / 工程师**一律不得 push、不得 merge 主干**。工程师（`dev-e`）只在各自 worktree 内 `git add` + `git commit`，**不得 push**、**不得 merge 主干**。
3. 提交前先跑 [`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)；提交后 `git diff -- <显式路径>` 复核改动内容（`git commit -m … -- <路径>` 不经索引，故不查 `--cached`）。
4. **同一 worktree 单一写者（无豁免）**：一个 worktree 从开工到收工，**只有被派到该票的那一个 agent 可以提交**。任何人要提交自己的文档 / 记录，**不得**在工程师正在施工的 worktree 里做——走主工作树或另开 worktree。**并发提交不会报错，只会把别人的改动扫进自己的提交**，事后靠 `git show --stat` 才能发现，而那时已经进了历史。

   - **How to apply**：提交前先 `git status` 看有没有别人的未提交改动；有则改用 `git commit -- <自己的路径>` 且**不先 `add`**；发现同 worktree 已有他人改动，停下问 devm，不要自行判断「应该没事」。
5. **推送节奏（devm）**：① **至少每完成一个 ticket 推送一次**到 GitLab（地址取 `.env` 的 `DMT_GITLAB_SERVER` / `DMT_GITLAB_PORT`，模板见 `.env.example`），推送信息含 `{spec-seq}-ticket-{slug}` 与一句话结果（`publish.sh` 默认推 `gitlab origin` 双远端：GitLab 为主、GitHub 镜像；只推 GitLab 时用 `--remotes gitlab`）；② **至少每小时**巡检一次 `git status --porcelain`，有新建或修改文件就按显式路径提交并推送（不必等 ticket 收口）。巡检与推送结果在下一次回报里一句话说明（推了什么、跳过什么、为什么）。
   - 命令：`bash dmt-director/scripts/publish.sh -m '<message>' -- <显式路径...>`；`--auto` 由 `git status --porcelain` 枚举改动路径（仍是显式路径，不使用 `git add -A`），`--no-push` 只提交。
6. **合并冲突时「取 main」（`checkout --ours`）只在 main 是分支的严格超集时成立。** 判断办法不是看谁改得多，是**逐项比对「两侧各有哪些行是对方没有的」**；只要有一项只有分支有，就必须手工合成。

   - **How to apply**：合并前跑一次两侧差异清单（`git diff --stat main...branch` 逐文件看，或直接 `git merge-tree` 预判）；合成后**与分支版本再 diff 一次**，确认差异只剩「main 独有的行」与「人工合成的那几行」，其余逐字节相同。

### 5.2 并行子代理

1. 派发前先做**依赖分析**：只有无依赖任务适合并行；共享文件、共享构建目标、有顺序验收关系的任务**必须串行**。
2. **经理层路径（硬约束）**：`devm` / `anam` **一律直接派工程师子代理** —— `devm` 派 `dev-e`（一票一 worktree）、`anam` 派 `ana-e`，**不开任何中间层 pane**（队长层已取消）。工程师子代理随任务收口回收。
3. **无依赖任务一律开满 subagents 并行（`director` / `devm` / `anam`；2026-11-04 用户裁定，推翻「按需、可少派」）**：任务间**无依赖**（不同文件面 / 共享输入 / 共享构建目标 / 顺序验收以外）⇒ **必须开满并行、到 harness 并发上限**（`harness_matrix.yaml` 的 `max_subagents_conc`，经 `dmt_concurrency_cap` 读：codebuddy 8/env、claude 10、codex 8），**不得自行留一手串行**。串行**仅限**真依赖（共享文件 / 构建目标 / 顺序验收 / 同一设备 / 同一 REA 会话）与第 7 条 worktree 单写者，**且须写明理由**。任务收口后子代理随收口回收。
   - **手段**：cbc 用 **teammate 方式**（`Agent` 带 `name`）；pi 用 dynamic workflow `runs.all`（`agent` 字段填 `delegate`）；其它 harness 用多个并行子代理。**派发 prompt 模板 + pi `delegate` 承载详情见 [`team/07b-dispatch.md`](07b-dispatch.md)**。
   - **废止项**（不回潮）：2026-11-02 的「按需、可少派、任务小就自做」作废；开工先落账、每波按上限拆波、并发位计数、回报首行交账及其理由白名单等饱和机制脚本仍保持删除、不得恢复。
4. **产品工作（director 自派 `pde{n}`）**：产品线无 pane、无队长层，**无依赖产品单元一律开满 `pde{n}` 并行**（一单元一 `pde{n}`，全部无依赖单元同时派出，派发手段同第 3 条）；`director` 的评审前预检同理。
5. 每份派发 prompt 必须显式写清：输入（产物路径）、边界、期望产物、回报要求、`timeoutMs`（长链路不短于 45 min）、**文件写入纪律**（改 bash 用单引号 heredoc / Write/Edit；禁把脚本正文放进 JS 模板字符串；Edit 的 `oldString` 必须唯一）。**骨架与 reviewer 变体照 [`team/07b-dispatch.md`](07b-dispatch.md) 填空，不要现编。**
6. 子代理一律后台/异步派发，**派完立即结束本轮**，由完成通知唤醒再验收；不做轮询。
7. 开发工程师**每人一个 git worktree**，只在 worktree 内编辑与提交；主工作树只读。
8. 所有子代理结果由**派生他的那一级**复核证据后，才能写入权威文档或进入下一步；经理不直接采信工程师的原始回报。
9. **一子代理一单元队列（2026-10-27 事故后立规，复盘见 `logs/2026-10-27-serial-queue-incident.md`）**：
    - **在途子代理只收同一单元的纠正 / 收窄**；**新单元一律另派子代理**（另开 worktree），**不得**用 `SendMessage` 追加成队列。
    - **追加前先做「文件面矩阵」**：逐条写 `单元 | 触达文件 | 与在途单元是否重叠`。重叠才可排队（须列出具体重叠文件路径）；不重叠 ⇒ **立即另派**。
    - **队列消息会过期**：依赖上级裁定的追加，要么写明「以最新裁定为准」，要么等裁定落地再派；否则子代理会按已作废的规格做完一轮。
    - **判据（越界即另派）**：同一子代理收到第二个新单元的指派（界面读数 `N queued ≥ 2`）即违规。
    - **复用 vs 新派的唯一判据**：问「这条要求会不会改变他正在做的事的**验收面**？」不会 ⇒ 复用（缺陷修正 / 收窄）；会 ⇒ 新派（哪怕同票同主题）。

### 5.3 评审门禁

| 门禁 | 提交方 | 评审方 | 通过条件 |
|---|---|---|---|
| 调研报告 | anam | director | director 认可结论与证据来源；**anam 落盘** `docs/analyst/` |
| PRD / SPEC / 工单 | `pde{n}`（落笔，director 召唤） | **director（文档门禁自评）**，用户可抽查 | 验收标准逐条可测、`spec-seq` 对齐、切片可独立验证、Files 不重叠、依赖无环；通过后状态行改 `状态：已通过` |
| 实施初检 | devm（自做，或自派子代理初检后本人复核） | devm | 票面判据逐条有读数、门红已分类、Files 边界未越界 |
| helper 回收 | `director` / `devm` / `anam`（创建者＝本体） | 创建者本人自检 | 成果已入账、worktree 已 `git worktree remove`、本体收件箱该 helper 方向无未收口；关闭后 `herdr pane list` 无 `{角色}-helper` label |
| 人类架构 / 人类计划 | director | **director（文档门禁自评）** + 用户 | 结构与真实代码一致、不混写未来态，落盘 `docs/human/human-arch/`、`docs/human/human-plan/` |
| ticket 代码 | 开发部门（devm 直接派 `dev-e`） | **devm（代码门禁）** | 逐条对照 SPEC 判据通过、diff 与证据核对无误；PASS 后写「实施状态」，**merge 待本部门 `reviewer{n}` 验收通过** |
| 代码验收（spec-seq 对齐） | `dev-e`（实施）/ `devm`（提交） | **`devm` 派 `reviewer{n}`（独立实例；结论抄送 director）** | 与同 spec-seq 的 SPEC 验收标准、ticket 判据逐条对齐（diff 与证据无误）；通过后由 **devm merge / push**；逐条结论与证据随 devm 回报抄送 director |
| 代码验收抽查 / 高风险复验 | devm（验收结论与证据） | **director**（**每批至少抽 1 票**；**高风险票 —— 设备 / SHA / 门禁 / 破坏性变更类 —— 100% 复验**）—— director **自派 `reviewer{n}` 副轨**执行抽查 / 复验（与 devm 主轨 `reviewer{n}` 实例独立） | 抽查 / 复验结论与证据**留痕**（`docs/handoff/` 或回报）；发现验收不实 ⇒ 打回 devm 重验 |
| 跨部门分歧 | devm / anam | director | director 裁决并回结论 |

### 5.4 读数纪律（性能窗）

1. **观测窗口必须显式定义，且「诊断开关」随窗登记**：任何性能 / 耗时对比都必须写明**观测窗口与运行时长** —— **瞬时或窗口化的指标不得当健康证据**（「窗口内 0 条」不等于「没问题」；典型写法：**运行 ≥ 5 min 后复测**）。凡有诊断 / dump / 采样类开关（默认 off），**开窗前必须先核其状态值**（如 `diagnostics_state`）**并把该值写进口径行**；**开窗读数一律不得与关窗读数对比、不得进任何结论**。（示例实证：某目标项目该开关开时每帧另算 raw sha256，占全进程 CPU 约 13%、detect 线程约 95% ⇒ 测得 fps 约为生产档的一半；**具体标识与数值以目标项目为准**。）
2. **跨构建绝对值禁比**：不同产物（so / APK / 固件 / 镜像）的毫秒数**不可互比**（设备现装、语料、仓内产物三者不同源）；**比值可跨构建比，但须挂横幅说明**（如「本窗与上窗非同一构建」）。
3. **「停」要复验**：下发停止指令后，必须核**目标进程确已退出**（如 `pidof <pkg>` 为空）才算停；**下级回报的「已停」不可直接采信**。
4. **快照必须同时满足两条才算本窗**：① 在**本窗清单**（如 `new.list`）内；② **构建哈希**（如 `build_sha256`）与同窗其余快照**一致**。任一条不满足 ⇒ **跨轮残留**，禁用于任何对账（含各阶段耗时与 fps）。
5. **硬件设备写操作权限（`devm` 与 `director` 均可；2026-11-04 用户裁定：先移交 devm，随后放开 director）**：凡**对硬件设备产生副作用的写操作** —— 安装 / 卸载产物、刷写固件、覆写设备上的文件或配置、触发设备探针、强杀设备进程、修改设备运行时参数等 —— **只许 `devm` 或 `director` 执行**；`anam`／工程师／子代理**一律禁做**（需要时回报 `devm` 或 `director`，**不转授权**给工程师）。**同一设备同一时刻只允许一个写者**：动手前先确认无人正在使用该设备。**工具链与设备文件以目标项目实际为准**（不限于安卓：`adb`／`fastboot`／串口／网口／JTAG 等命令行工具与设备专用文件均属此列）。设备操作后必报**可核验证据**：写入产物的哈希（如 `sha256`）＋ 设备侧版本 / 更新时间 ＋ 目标进程确已退出（如 `pidof` 为空）—— 具体字段按项目设备而定。
