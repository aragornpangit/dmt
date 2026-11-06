# §5.2 附：派发 prompt 模板与 pi 承载（低频细节；`team/07-discipline.md` §5.2 按需引用）

## 子代理派发骨架（照填，不要现编）

`你是 <角色> 的子代理。技能：<对应的 dmt-<角色> 技能名>（cbc 直接斜杠调用；**opencode 用 `@<技能名>`**；codex 用同名技能或 '<技能目录>/dmt-<角色>/SKILL.md'；pi 读 '<技能目录>/dmt-<角色>/SKILL.md' 并按其中强制技能节执行）。单元：<一句话>。输入：<路径>。边界：<Files>。产物：<路径与格式>。判据：<可测>。回报：<格式>。超时：<timeoutMs>。构建补件：<**凡票涉 gradle／clean build ⇒ 必写此字段**：本 worktree 需补 `local.properties`(sdk.dir) ＋ `app/src/main/jni/` 两个 vendored 目录软链（`opencv-mobile-4.13.0-android`／`ncnn-20260526-android-vulkan` → 主仓同路径；均 gitignored、非交付物）＋ 设 `ANDROID_HOME=<sdk 路径>；缺之则 configureCMake 报 `Could not find OpenCV`／`SDK location not found`>。**素材补件**：<**凡门依赖“外部采集素材”（如 `test/` 下的设备样张/JSON）⇒ 必写**：素材根路径、**覆盖口变量名**（如 `MATERIALS_ROOT`／`DEVICE_RESULTS`）、缺失时的行为（必须 **fail-loud** 并打印**实际取用的素材根绝对路径** ＋ 指向补件动作）>。资源纪律：**禁 `pkill <pattern>`／`pkill -f`／`killall`**（只允许按自己 pidfile 的确切 PID 清理）＋ **同一门／同一 worktree 不得并发跑**（跑重门前先 `ps` 查，等或换）。收口：**合流前必须在「缺本票本地产物的树」上跑一次门**（同一主仓 **detached worktree**；**禁** `archive`／`clone --shared` —— 会缺 refs 造成假红）；证据需给该次读数。文件写入纪律：用各 harness 的结构化编辑工具写入（codex 用 `apply_patch`）；Edit 的 oldString 必须唯一。`

`<角色>` ∈ `dev-e` / `ana-e` / `pde{n}`，对应技能 `dmt-de` / `dmt-ae` / `dmt-pde`。`reviewer{n}` 变体见下。`devl{n}` 是 pane 角色，不走本骨架，见下一节。

## devm → devl 派单（收件箱 + 门铃，不是子代理 prompt）

正文必带：`批次` / `票号列表` / `票面路径` / `SPEC 路径（spec-seq）` / `worktree 根`（`<项目根>/.worktrees/`）/ `判据` / `可并行的票` / `回报格式`（交付包字段）/ `timeoutMs` / `纪律`。

纪律固定写死：**不 push、不 merge、不跨队长通信；汇总自派 subagents 后上报 devm；reviewer 必须按 `spec-seq` 独立实例。**

## devl → dev-e 派发

用上面的子代理骨架，`<角色>` 填 `dev-e`，`<对应的 dmt-<角色> 技能名>` 填 `dmt-de`；额外写明 `worktree：<本票 worktree 绝对路径；由 devl 预建>` 与 `单写者：本 worktree 只有你能提交`。

## reviewer{n} 变体（验收专用；`/code-review` 为模板常量，不得替换或省略）

`你是 devl{n} 的 reviewer{n} 子代理。技能：dmt-reviewer（cbc 直接斜杠调用；codex 用 dmt-reviewer；pi 读 '<技能目录>/dmt-reviewer/SKILL.md'）。必须调用 <强制技能名：codex 为 mattpocock-skills:code-review，其余为 /code-review> 逐条验收。独立性：不得与实施该票的 dev-e 同实例，不采信 devl / dev-e 的结论，只认 ticket + SPEC + diff + 证据；无证据的「通过」视为不通过。票：<ticket 路径>。SPEC：<对应 spec-seq 路径>。输入：<diff、证据、测试输出路径>。判据：照 ticket 验收标准逐条核，逐条挂证据路径。回报：逐条通过/不通过 + 结论 + 证据路径（结论随 devl 交付包上报 devm，并抄送 director 供抽查）。超时：<timeoutMs>。`

## Codex harness 承载

Codex 角色的技能来自项目 `.agents/skills/`（以及 `.codex/skills/`），mattpocock 插件技能按 `mattpocock-skills:<name>` 引用。子代理派发模板如下：

`你是 <派生者> 的 <角色> 子代理。先完整读取并执行技能 <技能路径>，再读取其强制技能：<限定名或路径>。单元：<一句话>。输入：<绝对路径>。上下文路径：<只给需要的外部文件>。边界：<Files>。worktree：<本票 worktree 绝对路径；由 devl 预建>。产物：<路径与格式>。判据：<可测>。回报：<格式>。超时：<timeoutMs>。完成后只回报证据，不自行 merge / push。`

Codex 首选 `spawn_agent`；派生后并行使用 `wait_agent` 收结果。新单元另起 `spawn_agent`；同一单元只做纠正 / 收窄时才沿用。子代理必须显式给角色技能和输入路径，不信口称“已加载”。Codex 在 herdr 角色 pane 中没有 `spawn_agent` 接口时，不通过 shell 嵌套 `codex exec` 伪造团队，只在本 pane 完成本角色工作并记 `[SUBAGENT_UNAVAILABLE]`。

## pi harness 承载（`delegate`）

`dev-e` / `ana-e` / `pde{n}` / `reviewer{n}` 是**角色语义名**，不是 pi-subagents 的 agent 注册名。pi workflow `runs.run/all` 的 `agent` 字段**必须填内置承载 agent `delegate`**（无预设行为、继承父模型）；按角色名直派必报 `Unknown agent`（实例：2026-10-31 `agent:'ana-e'` 三发三败，改 `delegate` 即成）。prompt 里写「你是 <派生者> 的 <角色> 子代理」定角色，`agent` 只管承载。

`devl{n}` 是 **pane 角色**，不是 pi delegate：它由 `devm` 用 `devl-pane.sh` 起 pane，自己 `pi --approve` 并加载 `/skill:dmt-devl`。

pi 下 `delegate` **无技能清单、无 Skill 工具** ⇒ 必须在 prompt 给技能文件路径：`read <技能目录>/dmt-<角色>/SKILL.md`，并依次 `read <技能目录>/<name>/SKILL.md` 读强制技能。cbc 不受此约束（teammate `Agent` 带 name 即角色名，且继承技能清单、可直接斜杠调用）。
