# dmt 变更语义摘要（自动生成，勿手改）

> 由 `digest-changelog.sh` 从 [`CHANGELOG.md`](CHANGELOG.md) 及其归档（`changelog/`）生成；每条约一行语义摘要，全文以 CHANGELOG.md + 归档为准。共 80 条。

| 日期 | 条目 | 版本 | 要点 |
|---|---|---|---|
| 2026-11-04 | 用户要求·第七十七次：再瘦身 —— pane 技能公共块抽分节 / 07 附节外移 / OPS 事故复盘外移，版本 `5.16.15` | 5.16.15 | 用户认可「agent 读取文件的再瘦身」评估并执行 P1–P3 |
| 2026-11-04 | 用户要求·第七十六次：质量瘦身 —— P1 机检迁 YAML / P2 文档压缩 / P3 CHANGELOG 归档 / P4 技能去重 / P5 合并机检，版本 `5.16.14` | 5.16.14 | 用户采纳 AI 工程评估的 5 项优化并逐条落地 |
| 2026-11-04 | 用户要求·第七十五次：工程化加固 —— harness 矩阵单一来源 / helper 补全 / 结构化机检 / 版本自动化 / 防泄漏 hooks / reviewer 双轨，版本 `5.16.13` | 5.16.13 | 用户接受一批 AI 工程建议并逐条落地（A1–3 / B4–6 / C7–9） |
| 2026-11-04 | 用户要求·第七十四次：无依赖任务一律开满 subagents 并行 —— 推翻 2026-11-02「按需、不强制派满」口径，版本 `5.16.12` | 5.16.12 | 用户裁定「无依赖关系的票与待办，开满 subagents 并行处理」，并明确该口径适用于总监（director）与经理（devm / anam）、机检脚本跟随调 |
| 2026-11-04 | 用户要求·第七十三次：硬件设备写操作放开 director —— devm 与 director 均可，版本 `5.16.11` | 5.16.11 | 用户裁定「也允许 director 操作硬件设备」⇒ 撤销第六十八次「只归 devm」的独占，改为 devm 与 director 均可执行硬件设备写操作（an |
| 2026-11-04 | 用户要求·第七十二次：读数纪律通用化 ＋ 重载提示 ＋ `dmt-en` 停更标注，版本 `5.16.10` | 5.16.10 | 用户采纳第七十一次盘点出的三项待办 |
| 2026-11-04 | 用户要求·第七十一次：`install-skills.sh` 清理改名遗留 —— 旧技能名 `dmt-rve` 残留 15 处，版本 `5.16.9` | 5.16.9 | 第六十九次把技能 dmt-rve 改名为 dmt-reviewer 后，install-skills.sh 只安装当前 SKILLS 列表里的技能名、不删除旧名 |
| 2026-11-04 | 用户要求·第七十次：代码验收独立性四条硬约束 —— 结论平行可见 ＋ 抽查下限 / 高风险复验 / 留痕，版本 `5.16.8` | 5.16.8 | 第六十九次把 reviewer{n} 移入 devm 后，"独立验收"被降级为「部门内审 ＋ 产品抽查」 |
| 2026-11-04 | 用户要求·第六十九次：`reviewer{n}` 归 devm ＋ 改名 `dmt-reviewer` ＋ 设备操作抽象为「硬件设备写操作」，版本 `5.16.7` | 5.16.7 | 用户两项要求 —— ①「把代码评审工程师归到 devm 的团队中」（采纳"三条硬约束"方案） |
| 2026-11-04 | 用户要求·第六十八次：设备操作（装机）从 director 移交 devm，版本 `5.16.6` | 5.16.6 | 用户裁定「对于安卓设备的操作，合并代码，推送代码都由 devm 完成，不要由 director 去做」 |
| 2026-11-04 | 用户要求·第六十七次：四个子代理角色技能化 —— `dmt-de` / `dmt-ae` / `dmt-rve` ＋ 命名统一，版本 `5.16.5` | 5.16.5 | 用户裁定「dmt-pde（产品总监的产品工程师）、dmt-de（开发经理的开发工程师）、dmt-ae（分析调研经理的分析工程师）、dmt-rve（产品总监的审核 |
| 2026-11-04 | 用户要求·第六十六次：`install-skills.sh` 多落点铺设 ＋ claude 侧 strace 硬证据复核，版本 `5.16.4` | 5.16.4 | 第六十五次实测确认「.agents/skills/ 只被 codex / opencode / pi 读，claude 与 codebuddy 只认各自私有目录 |
| 2026-11-04 | 用户要求·第六十五次：全仓一致性修复 ＋ 五 harness 技能发现目录实测更正，版本 `5.16.3` | 5.16.3 | 用户要求「检查 dmt 内容不一致并解决、以实测为准」 |
| 2026-11-03 | 用户要求·第六十四次：`auto-review-model.sh` 的 `--quiet` 语义修正 —— 有变化时必须出一行，版本 `5.16.2` | 5.16.2 | 第六十一次把健康门脚本的 --quiet 写进文档（「只在有变化时输出一行」），但实现里唯一的输出函数 say() 被 [ "$QUIET" = 1 ] ||  |
| 2026-11-03 | 用户要求·第六十三次：权限档位复验 —— pane 落在 default 档时启动即告警，版本 `5.16.1` | 5.16.1 | 用户两度贴出 bcr-nh 里 cbc 的失败卡片（TaskUpdate / Grep 的 Invalid input、window_end_request 的 |
| 2026-11-03 | 用户要求·第六十二次：五 harness 兼容适配 —— claude / codebuddy / codex / opencode / pi，版本 `5.16.0` | 5.16.0 | 用户要求「把这个 skill 与 codebuddy / pi / opencode / claudecode / codex 适配并测试，要求 skill 与 |
| 2026-11-03 | 用户要求·第六十一次：复核器模型健康门 —— 本地端点不可达时回退 cbc 内置链路，版本 `5.15.0` | 5.15.0 | 第六十次把复核器钉到本地模型（custom-local:Qwen3.8-27b）以避开企业网关限流，但钉模型会禁用 cbc 内置 fallback —— 二进制 |
| 2026-11-03 | 用户要求·第六十次：cbc auto 模式复核超时加固 —— 抬预算 / 复核模型换本地 / 脚本 allow 规则，版本 `5.14.0` | 5.14.0 | 机队 pane 一律以 codebuddy --permission-mode auto 启动，而 auto 模式下每个需审批的工具调用都要过一次自动复核（ag |
| 2026-11-02 | 用户裁定·第五十九次：取消 max-subagents 机制与饱和派发强制，改「按需派发」，版本 `5.13.0` | 5.13.0 | 用户要求「取消对 max-subagents 的使用，不要强制 agent 派满 sub-agents」 |
| 2026-11-02 | 用户要求·第五十八次：`dispatch-ledger.sh` 撤销外部内核依赖、恢复自实现，未升号 | — | 用户要求 dmt 技能取消引用外部「台账内核」 |
| 2026-10-31 | 用户要求·第五十六次：pi harness agent 名承载纪律，版本升 `5.12.0` | — | anam 派 u-f1/u-f2/u-f3 三单元时 runs.run 的 agent 字段填了角色名 ana-e，三发三败（Unknown agent: an |
| 2026-10-31 | 用户要求·第五十五次：spawn-helper / setup-team 的 harness 参数化 ＋ helper tab 首 pane 修正 | — | ① harness 参数化 —— spawn-helper.sh / setup-team.sh 新增 --harness <name>（亦可 $DMT_HAR |
| 2026-10-27 | 用户要求·第五十四次：停用三条 guard hook，改语义约束 | — | install-hooks.sh 只再装三条 hook（PostToolUse×2 / Stop），注释停用 PreToolUse self-work-guar |
| 2026-10-27 | 用户要求·第五十三次：派发 prompt 加「文件写入纪律」，版本升 `5.10.0` | — | 第五十二次落地时子代理连撞两类工具层报错，据此把「子代理怎么写文件」立成纪律随每份派发 prompt 下发 |
| 2026-10-27 | 方案 B·第五十二次：self-work-guard 子代理豁免判据收敛至内核 is-subagent，版本同号 `5.9.0` | — | self-work-guard.sh 的子代理豁免判据从内联 jq 收敛为单一来源——经 dispatch-ledger.sh is-subagent 查询外部 |
| 2026-10-27 | 用户裁定·第五十一次：队列纪律机制落地 `append` 过账 ＋ 巡检扩项，版本 `5.9.0` | 5.9.0 | 对第五十次事故的 P1–P5 预防方案做落地裁定 —— P1（queue-guard hook 拦截 SendMessage）不做：判据「消息是不是新单元」无法 |
| 2026-10-27 | 用户要求·第五十次：一子代理一单元队列 ＋ 事故复盘，版本 `5.8.0` | 5.8.0 | 用户当场指出 —— 081 返工期间 devm 把 5 条可独立并行的追加要求逐条 SendMessage 投进同一个忙碌子代理（界面读数 41m 08s ·  |
| 2026-10-27 | 用户要求·第四十九次附：补「作用域（Scope）」声明，版本 `5.7.1` | 5.7.1 | 用户指出 —— 「push 归 director / devm」这类归属纪律在文档里未写作用域，导致其他 agent 维护 dmt 技能仓自身时误以为也要遵守（ |
| 2026-10-27 | 用户要求·第四十九次：审计遗留项收口 ＋ 公共库，版本 `5.7.0` | 5.7.0 | ① lib-dmt.sh 公共库（脚本 18→19）—— 工作树根 dmt_root / 角色解析 dmt_role / pane 查询 dmt_pane_by |
| 2026-10-27 | 用户要求·第四十八次：四路审计修复 ＋ reviewer 登记 `/review`，版本 `5.6.0` | 5.6.0 | ① reviewer{n} 进登记表 —— §1.1 直属下级与命名表补 reviewer{n}，§1.4 强制技能表补 reviewer{n} 行：/revi |
| 2026-10-27 | 实测修正·第四十七次：launch.sh 建团队 pane 的 cwd | — | 新环境一键拉起实测发现缺陷 —— launch.sh 在 dmt-director/scripts/ 内调用 setup-team.sh，而 pane 的 -- |
| 2026-10-27 | 用户裁定·第四十六次：取消队长层 ＋ helper 纯分身语义，版本 `5.5.0` | 5.5.0 | ① 取消队长角色 —— devtl{n} / anatl{n} 整个删除，职能与技能重新分配：管理职能（建 worktree、派工程师、收 diff 做实施层初 |
| 2026-10-26 | 用户裁定·第四十五次：helper tab/pane 分流机制 | — | ① 触发 —— {总监|经理}忙不过来、子代理在途达 min(8, cap) 上限、仍有待办 ⇒ 检查 helper tab（label helper，无则建） |
| 2026-10-26 | 用户要求·第四十四次：新增 launch.sh 一键拉起 | — | 新增 dmt-director/scripts/launch.sh —— director 一键拉起 dmt 团队（①install-skills → ②ini |
| 2026-10-26 | 用户裁定·第四十三次：PRD / SPEC / tickets 归 pde{n} 落笔，director 定稿 | — | ① 落笔归属 —— director 需写 PRD / SPEC / tickets 时召唤 pde{n} 子代理落笔（一单元一 pde、按需求开，上限 min |
| 2026-10-26 | 用户裁定·第四十二次：CAP 定稿按需求开 + reviewer 验收门禁 + 四路审计修复 | — | ① CAP 口径定稿 —— n = min{8, cap} 上限、按需求开，废止「开满/少开即违规」 |
| 2026-10-26 | 用户裁定·第四十一次：pde 技能改名 dmt-pde 并匹配 to-spec / to-tickets | — | ① 技能目录 dmt-pm → dmt-pde（git mv 保留历史），frontmatter name 与全仓引用（契约、README、dmt-direct |
| 2026-10-26 | 用户裁定·第四十次：并发上限 min(8, cap)，总监 / 经理 / 队长全员一致 | — | ① 并发上限 —— 任何派发角色（director / devm / anam / devtl{n} / anatl{n}）同一时刻在途的下级实例（子代理或队长 |
| 2026-10-26 | 用户裁定·第三十九次：队长阈值 8 + pane 生命周期归经理 + 代码库归 devm | — | ① 队长阈值 ≤4 → ≤8 —— 经理排队任务 ≤8 自派工程师子代理，待办超过 8 个才派 devtl{n} / anatl{n}（组织表、单线指挥、§4  |
| 2026-10-26 | 用户裁定·第三十八次：饱和派发升级为硬性要求，hook 扩到队长 | — | ① 硬性要求 —— 无依赖任务一律开满 min(N, CAP)，适用于 director / devm / anam / devtl{n} / anatl{n} |
| 2026-10-26 | 全面审计修复，非用户裁定·第三十七次 | — | ① README —— 阈值残留（anam 队长开关 2→4）、⑬ 脚本数（十六→十七）、⑦ 引述与机检断言字面对齐、⑱ 负样本口径对齐、交付物表 direct |
| 2026-10-26 | 用户裁定·第三十六次：pm 并入 director + devm pane 并入 director tab + pde 子代理 + 并行强化机制 | — | ① 组织改造 —— 取消产品经理 pane，director 兼任产品部经理（亲自落笔 PRD / SPEC / 工单 / 人类文档并出文档门禁结论，可自派 p |
| 2026-10-26 | 用户裁定·第三十五次：CAP 探测开满 + 完成即报 | — | ① 并发口径升级 —— 饱和从「并发数 = 单元数」改为：先探测当前 harness 最大子代理并行数（CAP，探测不到默认 8），每波并发 min(N, CA |
| 2026-10-24 | 实测修正·第三十四次：序号撞号 / 启动不幂等 / 契约版本可查 | 4.1.0 | ① send-msg.sh 八进制撞号 —— 文件名带前导零（077）或旧 .seq 里写着 077 时，bash 算术按八进制解析（077 = 63），序号被 |
| 2026-10-24 | 实测修正·第三十三次：hook 真实链路验证通过 | — | 在真实 codebuddy 会话（-p 模式、DMT_ROLE=devm）里跑通全链路，并修掉五处会导致「装了不生效」的问题：① matcher 改为通配 ，由 |
| 2026-10-24 | 用户裁定·第三十二次：派发合规进评审门禁 | — | ① §5.3 门禁表新增「派发合规（并发账）」一行 —— 提交方 pm / devm / anam，评审方 director，在既有评审点内看，不另设事前审批 |
| 2026-10-24 | 用户裁定·第三十一次：给总监与三个经理装上 hook | — | ① install-hooks.sh 增加 --user 模式，装到 ~/.codebuddy/settings.json（自动备份 settings.json |
| 2026-10-24 | 用户裁定·第三十次：先派后干 ＋ 并发账 ＋ 可选 hook 硬约束 | — | 观察到经理层倾向「自己一个人慢慢干」，把并行从口号变成可机器校验的规则 |
| 2026-10-24 | 用户裁定·第二十九次：收件箱三态 ＋ `.seq` 高水位 | — | 收件箱消息不再「读毕即删」 |
| 2026-10-24 | 用户裁定·第二十八次：经理层饱和派发，`devm` / `anam` 严责 | — | 无依赖任务必须开满子代理 —— 无依赖单元数 N ⇒ 同一回复内派出 N 个子代理，并发数 = 单元数 |
| 2026-10-24 | 用户裁定·第二十七次：anam 阈值与 devm 统一为 4 | — | 分析经理 anam 开队长 pane 的门槛由「排队子问题 >2」改为「>4」，≤4 时自己派生 ana-e 子代理 —— 与 devm 的 4 个阈值对齐，两 |
| 2026-10-24 | 用户裁定·第二十六次：确定性动作脚本化 | — | 把「结果确定」的指令从散文改成脚本，正文只留判据与例外 |
| 2026-10-24 | 全面审计修复，非用户裁定 | — | 逐文件核对后修复以下过期／矛盾／无效内容：① pm 与 director 同 tab ⇒ 迁移兜底与「不得用 tab list 认自己」补 pm 例外，避免按  |
| 2026-10-24 | 用户裁定·第二十五次：技能名与上游对齐并加 raw 链接 | — | ① 团队使用的 11 个 mattpocock 技能名与 [mattpocock/skills](https://github.com/mattpocock/s |
| 2026-10-24 | 用户裁定·第二十四次：ana-e 加 `/rea`；devtl 加 [`/implement`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/implement/SKILL.md)；devm 阈值放宽到 4 | — | ① ana-e 的强制技能增加 /rea（竞品逆向必须走 REA），由 anatl 写进派发 prompt |
| 2026-10-24 | 用户裁定·第二十三次：全员加载 `cbc-herdr` | — | ① 六个 pane 常驻角色（director / pm / devm / anam / devtl / anatl）的技能清单统一登记 cbc-herdr（C |
| 2026-10-24 | 用户裁定·第二十二次：director / pm / anam 增配 [`/grill-me`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md) 与 [`/grill-with-docs`](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md) | — | ① director 增 [/grill-me](https://raw.githubusercontent.com/mattpocock/skills/mai |
| 2026-10-24 | 用户裁定·第二十一次：编辑前查文件占用；评审门禁下沉到 pm/dm | — | ① 新增 §1.5 文件占用 —— 任何角色编辑任何文件前必须 scripts/file-claim.sh check/claim，rc=3 即停手，改完 re |
| 2026-10-24 | 用户裁定·第二十次：mattpocock 技能改为强制使用 | — | ① §1.4 由「依赖的 harness 技能」改为「强制使用」，新增角色 × 强制技能表：director [/grilling](https://raw.g |
| 2026-10-24 | 用户裁定·第十九次：工单改由 pm 拆，devm 只接单与评审整合 | — | ① pm 的交付物扩为四类 —— PRD、SPEC（[/to-spec](https://raw.githubusercontent.com/mattpococ |
| 2026-10-24 | 用户裁定·第十八次：装机与推送收归 director，并加推送节奏 | — | ① 装机只由 director —— 原「只到经理级（director／pm／devm／anam）」收紧为只许 director 执行（adb install／ |
| 2026-10-24 | 用户裁定·第十八次附：§5.1 增「APK 不入仓」 | — | .apk 一律不提交，只留 tools/apk-manifest.tsv（路径＋大小＋sha256＋构建 sha） |
| 2026-10-24 | 用户裁定·第十七次：新增产品部经理 pm，director 改为纯团队领导 | — | ① 新增产品部经理 —— pm（第三个部门经理 |
| 2026-10-24 | 用户裁定·第十七次附：§5.4④ 改合取判据 | — | 快照归属由「在 new.list 内」改为两条合取（① 在本窗 new.list |
| 2026-10-24 | 用户裁定·第十六次：§5.4 增快照归属纪律 | — | §5.4 新增第 4 条快照必须在本窗 new.list 内（不在 ⇒ 跨轮残留，禁用于任何对账） |
| 2026-10-24 | 用户裁定·第十五次：§5.4 增装机权限 ＋ 身份门与 push 口径 | — | ① §5.4 新增第 4 条装机权限只到经理级（director／devm／anam |
| 2026-10-24 | 用户裁定·第十四次：新增调研证据目录 | — | docs/analyst/evidence/{research-seq}-{slug}/ 登记为 anam 的一手证据落点（采样产物／原始日志／manifest |
| 2026-10-24 | 用户裁定·第十三次：新增 §5.4 读数纪律 | — | ① dump 开关随窗登记，dump-on 窗的 fps／耗时对比一律作废（实测 sha256 占全进程 CPU 13.3%、detect_fps 0.76 v |
| 2026-10-24 | 用户裁定·第十二次：门铃通道统一 ＋ 队长 pane 竖排 | — | ① 门铃一律用 herdr agent prompt <pane> '<短句>'（自带 Enter 提交，返回 "type":"agent_prompted"  |
| 2026-10-24 | 用户裁定·第十一次：经理层启动自动化 | — | 团队启动顺序改为 director 全自动拉起经理层 —— 建 devm / anam tab、root pane 打同名 label 后，代启动 codebu |
| 2026-10-24 | 用户裁定·第十次：身份改 pane label ＋ 队长 pane 进经理 tab | — | ① 回退此前的「自营 / 分包」双路径 —— 经理层只保留在本 tab 内开队长 pane一条路（队长再开工程师子代理），工程师永远只是队长的子代理，经理不直接 |
| 2026-10-22 | 用户裁定·组织调整 | — | 项目定名 dmt，组织固定为四层层级 director → 部门经理 → 队长 → 工程师 —— ① 顶层 director（总监，兼产品经理），直属下级只有  |
| 2026-10-21 | 用户裁定 | — | ① PRD 类别复活，落盘路径由 docs/prd/ 改为 docs/pd/prd/（docs/prd/ 作废） |
| 2026-10-21 | 用户裁定·第二次 | — | 目录结构重排 —— ① 收件箱移到项目根 inbox/<director|devm|anam>/，不再进 docs/（.gitignore 用 inbox//） |
| 2026-10-21 | 用户裁定·第三次 | — | 序号按产物类别拆分 —— PRD {prd-seq}、调研报告 {research-seq}、人类架构 {human-arch-seq}、人类计划 {human |
| 2026-10-21 | 用户裁定·第四次 | — | 目录由 director 初始化时检查并补齐（新增 §3.1，幂等命令 + 完成判据 ALL_PASS） |
| 2026-10-22 | 用户裁定·第五次 | — | 目录重命名 —— ① 调研报告目录 docs/research/ 改为 docs/analyst/（仍属 anam） |
| 2026-10-22 | 用户裁定·第六次 | — | 收件箱协议简化 —— 收件方收到门铃提醒后读入 context window、不发送回执、读毕即删 |
| 2026-10-22 | 用户裁定·第八次 | — | 队长层并行口径统一并加可测判据 |
| 2026-10-22 | 机检修正，非用户裁定 | — | 修正 §7 负样本断言的自相矛盾 —— 原脚本用 grep 'docs/not-a-dmt-output-dir/' "$CONTRACT" 判「坏路径是否被误 |
