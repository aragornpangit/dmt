## 5. 纪律

### 5.1 Git

1. **禁 `git add -A` / `git add .`**：提交一律显式列路径（`git commit -m "…" -- <path>`，绕过索引），`add` 与 `commit` 之间不插别的动作。
2. **merge 与 push 只归 devm**：收到 `reviewer{n}` PASS 证据即可推，不必等 director；devm pane 不可用时由 director 重建，期间暂停 merge / push，不转授权。director 保留抽查权；anam / 队长 / 工程师不得 push / merge 主干，只在各自 worktree 内 `add` + `commit`。
3. 提交前跑 [`/code-review`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md)；提交后 `git diff -- <显式路径>` 复核（不走索引，故不查 `--cached`）。
4. **同一 worktree 单一写者（无豁免）**：只有被派到该票的那一个 agent 可提交。要提交自己的文档就走主工作树或另开 worktree——并发提交不报错，只会把别人的改动扫进自己的提交。提交前 `git status` 看有无他人未提交改动；有则 `git commit -- <自己的路径>` 且不先 `add`；拿不准就停下问 devm。
5. **推送节奏（devm）**：① **至少每完成一个 ticket 推送一次**（地址取 `.env` 的 `DMT_GITLAB_SERVER` / `DMT_GITLAB_PORT`，模板 `.env.example`），消息含 `{spec-seq}-ticket-{slug}` 与一句话结果；`publish.sh` 默认推 `gitlab origin` 双远端，只推 GitLab 用 `--remotes gitlab`。② **至少每小时**巡检 `git status --porcelain`，有改动就按显式路径提交并推送；结果在下一次回报里一句话说明。命令：`bash dmt-director/scripts/publish.sh -m '<msg>' -- <显式路径…>`；`--auto` 枚举改动路径，`--no-push` 只提交。③ **分支待合流期间不得向 `master` 推任何提交**（含文档类）：master 一动就要 rebase，sha 全变，登记册与已跑读数全部过期 ⇒ 先合流，最后推 master 侧文档。
6. **合并冲突「取 main」只在 main 是分支严格超集时成立**：逐项比对两侧各自独有的行，只要有一项只有分支有，就必须手工合成。合并前 `git diff --stat main...branch` 逐文件看（或 `git merge-tree` 预判），合成后再与分支 diff 一次。
7. **合并后收尾（单主）**：devm merge / push 后通知 `devl{n}` 删 `.worktrees/{ticket-id}` 与本地 `feat/{ticket-id}`；票面终态（`已合并`）由 devm 更新；回滚由 devm 执行。

### 5.2 并行子代理

1. **依赖分析先行**：只有无依赖任务可并行；共享文件、共享构建目标、有顺序验收关系的必须串行。
2. **指挥路径（硬约束）**：devm 只派 `devl{n}`，`devl{n}` 只派 `dev-e` / `reviewer{n}`，anam 只派 `ana-e`；devm 不直接派 `dev-e`，队长之间不通信。队长 pane 是唯一中间层，生命周期归 devm（`DEVL_MIN=2`、`DEVL_MAX=0`、几何上限 `floor(tab_height/14)`）。
3. **无依赖任务一律开满 subagents 并行**，上限取 `harness_matrix.yaml` 的 `max_subagents_conc`（经 `dmt_concurrency_cap`），不得自行留一手；串行仅限真依赖与 worktree 单写者，且须写明理由。手段：cbc 用 teammate `Agent`（带 `name`）、pi 用 `runs.all`（`agent: delegate`）、codex 用 `spawn_agent` + `wait_agent`；承载细节见 [`07b-dispatch.md`](07b-dispatch.md)。
4. **产品线同规则**：director 自派 `pde{n}` 无 pane、无队长层，无依赖产品单元一律开满。
5. 派发 prompt 必写：输入、边界、产物、回报、`timeoutMs`（长链路 ≥ 45 min）、文件写入纪律（单引号 heredoc / Write/Edit；禁把脚本正文放进 JS 模板串；`oldString` 唯一）。骨架见 [`07b-dispatch.md`](07b-dispatch.md)。
6. **派完立即结束本轮**，由完成通知或 harness 等待原语唤醒再验收；codex 用 `wait_agent`，不用 shell 轮询。
7. 开发工程师一人一个 worktree，只在 worktree 内编辑与提交；主工作树只读。
8. **谁派生谁汇总**：devl 汇总 dev-e / reviewer 后报 devm；devm 汇总 devl 交付包后 merge / push 并汇报 director；anam 汇总 ana-e；director 汇总 pde / 副轨 reviewer。上级不采信子代理原文，无证据不上报。
9. **一子代理一单元**：在途子代理只收同一单元的纠正 / 收窄，新单元一律另派（另开 worktree），不得用 `SendMessage` 排队；判据——同一子代理收到第二个新单元（`N queued ≥ 2`）即违规。

### 5.3 评审门禁

| 门禁 | 提交方 | 评审方 | 通过条件 |
|---|---|---|---|
| 调研报告 | anam | director | 结论与证据来源获认可；**anam 落盘** `docs/analyst/` |
| PRD / SPEC / 工单 | `pde{n}` / `devm` | **director（文档门禁自评）**，用户可抽查 | 判据逐条可测、`spec-seq` 对齐、切片可独立验证、Files 不重叠、依赖无环；改 `状态：已通过` |
| 实施初检（triage，不产生 PASS） | `devl{n}` | `devl{n}` | 判据逐条有读数、门红已分类、Files 未越界；**PASS 只由 `reviewer{n}` 给出** |
| helper 回收 | 创建者＝本体 | 本人自检 | 成果入账、worktree 已 remove、该方向无未收口；`herdr pane list` 无 `{角色}-helper` |
| 人类架构 / 计划 | director | **director + 用户** | 结构与真实代码一致、不混写未来态；落 `docs/human/human-{arch,plan}/` |
| ticket 代码 | `devl{n}` 派 `dev-e` | **`devl{n}` 代码门禁：派 `reviewer{n}`（每票独立实例）** | 对照同 `spec-seq` 的 SPEC / ticket / diff 逐条 PASS + 证据；FAIL 打回 `dev-e`；PASS 后 devl 上报 devm，**devm merge / push**，结论由 devm 转呈 director |
| 代码验收抽查 / 高风险复验 | `devl{n}` / `devm` | **director**（**每批至少抽 1 票**；设备 / SHA / 门禁 / 破坏性变更类 **100% 复验**）自派 `reviewer{n}` 副轨 | 结论与证据留痕（`docs/handoff/` 或回报）；验收不实 ⇒ 打回 devl 重验，必要时 devm 回滚 |
| 跨部门分歧 | devm / anam | director | 裁决并回结论 |

### 5.4 读数纪律（性能窗）

1. **窗口 + 开关**：写明观测窗口与时长；瞬时 / 窗口化指标不算健康证据；开窗前核诊断 / dump / 采样开关状态并写进口径行，开窗与关窗读数不得互比。
2. **跨构建绝对值禁比**：不同产物（so / APK / 固件 / 镜像）的毫秒数不可互比；比值可比但须标注「非同一构建」。
3. **「停」要复验**：核目标进程确已退出（如 `pidof` 为空）才算停；下级回报的「已停」不采信。
4. **快照两条**：在本窗清单内 + 构建哈希与同窗其余快照一致；缺一即跨轮残留，禁用于对账。
5. **硬件设备写操作**：只许 `devm` 或 `director` 执行（同一设备同一时刻单写者），工程师 / 子代理禁做；事后必报产物哈希 + 设备侧版本 / 更新时间 + 目标进程已退出。
