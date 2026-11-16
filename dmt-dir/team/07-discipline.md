# 工程纪律

## Git 与工作区

开发线按**两级分权 ＋ 独立评审 gate**（默认拓扑见 [`01-org.md`](01-org.md)）；一个实施单元一个隔离 worktree（独立 index）+ 独立分支，并行单元不共用同一 index。

1. `dmt-de`（工程师）：按 tdd → implement → code-review 在自己 worktree 的功能分支上实施、测试、自审并 commit，只列自己获授权的路径；不 merge、不 push、不改共享分支。功能分支上的 commit 不进主干，是后续评审的不可变对象。
2. `dmt-dm`（经理）：收到 SPEC / 需求 / bug 先评估，用 `to-tickets` 拆成 ticket 并派 `dmt-de`；`dmt-de` 完工后另派**未参与该 ticket 实现**、加载 `dmt-reviewer` 技能的临时子代理，按 ticket 为单位基于功能分支的 commit 逐条独立评审（评审者 ≠ 实现者）；评审通过且证据齐备后，按项目 Git 策略和授权执行 merge、push、发布或回滚。不直接实施、不代工程师 commit、不代替独立评审。

`git add` 只写本 worktree 的 index，不跨 worktree 交接；分支是仓库共享 ref，worktree 只签出其中一条 —— 交接靠功能分支上的 commit，不靠暂存区。提交前检查工作区状态，不用宽泛暂存覆盖他人改动。冲突需逐文件理解两侧改动，不能只因一侧更新就整份覆盖。清理工作区、分支或进程前确认所有权和未完成工作，不使用模糊匹配杀死进程。

## 并行与派发

1. 无依赖的工作单元一律并行派发：优先用 workflow（动态编排）或一次性开满当前环境可用的多个 subagents；只有真依赖、共享文件 / 构建目标 / 设备或顺序验收才串行，并在回报里写明理由。
2. 先分析依赖；共享文件、构建目标、设备和有顺序要求的验收需要协调或串行。
3. 派发写清输入、边界、产物、判据、回报和必要的时间预算；新工作单元使用新上下文。
4. 谁派发谁汇总；子代理只向派发者回报，不越级传递未经核验的结论。
5. 需要等待时使用平台原生通知或等待原语，避免无意义轮询。
6. 开发线内部（`dmt-dm` ↔ `dmt-de` 及其 `dmt-reviewer` 子代理）的派单、工作安排、进度与结果回报由开发线自行闭环，不需 `dmt-dir` 确认；只有需求 / SPEC 或验收口径变化、以及跨域冲突才上交（见 [`01-org.md`](01-org.md)）。

## 派生资源的生命周期

总监（`dmt-dir`）与经理（`dmt-dm` / `dmt-am`）可以按需通过 herdr / Orca 派生新的 pane、terminal 或进程；**派生即产生回收责任**，不允许留孤儿。

1. **谁派生谁回收**：创建者负责收尾，不把回收推给下一个会话、别的角色或用户。派生时就在自己的任务清单里记一条回收项。
2. **三种收尾都要回收**：正常完成、失败中止、主动放弃 —— 任一情况下都要关掉自己派生的 pane / terminal / 进程。
3. **回收前先确认无未收口工作**：没有未读回报、没有跑到一半的构建或测试；helper pane 用 `close-helper.sh`（内含收件箱安检），不要裸 `pane close` 绕过检查。
4. **精确关闭，不批量误杀**：按 pane id / terminal handle 关闭；不用标题、模糊匹配或 `pkill` 扫一片进程。不确定归属时先 `list` 再关。
5. **平台工具**：herdr 用 `herdr pane close <id>`（helper 走 `close-helper.sh`）；Orca 用 `orca-reap.sh`（按 `.dmt/orca-terminals.tsv` 台账回收）或 `orca terminal close --terminal <handle>`。Orca 派生优先用 `orca-launch.sh`，它按矩阵 `start_cmd` 起 harness 并自动登记台账。
6. **长期角色 pane 不在回收范围**：`dmt-dir` / `dmt-dm` / `dmt-am` 自己的常驻 pane 是部署设施，由用户或 `setup-team.sh` 管理，不因单个任务结束而关闭。
7. **句柄只向下持有，不向上转交**：pane id / terminal handle 归派生者的直接上级，`dmt-dm` 手里的 `dmt-de` 句柄不得上报给 `dmt-dir`，`dmt-dir` 也不得索取。越级拿到句柄等于开了一条绕过汇报线的观测通道（能直接读下级屏幕），与「角色间互连、越级一律禁止」冲突。上级核验走产物：commit SHA、`git show --stat`、测试输出、报告路径。

## 评审与证据

1. 实现与独立评审分离；评审只依据 ticket 票面判据、变更和可复现证据。
2. 每条判据都有 PASS / FAIL 与证据；无证据、证据过期或范围不符不能判 PASS。
3. **评审顺序固定**：先按项目主语言联网核对编码规范（官方或事实标准，记来源与访问日期），再依次跑类型检查、lint，最后做功能检查；静态门不过直接 FAIL 退回，不进入功能验收。
4. **证据先于结论**：宣称完成、修复或通过前先跑可复现验证，不拿推断当证据（superpowers `verification-before-completion` 判据）。
5. 验收范围以票面判据为准，不额外设置抽检环节。
6. 需求、调研和代码的批准人按项目授权确定，格式检查不能替代实质验收。
7. 性能或实验结论注明环境、窗口、构建和对照条件；不同条件的数据不直接比较。
8. 共享设备或外部系统写操作由获授权者执行，并记录版本、结果和必要的清理状态。

## 与 superpowers 方法论的同构判据（dmt 自带）

下列判据与 superpowers 核心原则同构，已内建在本纪律里，**不依赖任何外部 plugin**；仅 claudecode 装了 superpowers 时才按 [`../ops/optional-skills.md`](../ops/optional-skills.md) 追加点名对应技能。

- **先找根因再改**（`systematic-debugging`）：bug / 回归先定位根因，不做症状修补。
- **先探测已有隔离**（`using-git-worktrees`）：进入工作区先看现成隔离，不与 harness 既有机制对抗。
- **独立上下文精确派发**（`dispatching-parallel-agents`）：子代理只收本单元必需的指令与上下文，不继承派发会话历史。
- 上述三条与「并行与派发」第 1 条、本节第 3 条共同构成 dmt 的方法论底座；外部技能只是该底座在某 harness 上的可选实现，缺席时用本节判据继续工作。
