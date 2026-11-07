# §5.2 附：派发 prompt 模板（按需读；骨架照填，不要现编）

## 通用字段（子代理：`dev-e` / `ana-e` / `pde{n}`）

技能名按角色取 `dmt-de` / `dmt-ae` / `dmt-pde`；加载方式按 harness 差异（cbc `/`、opencode `@`、pi 读文件、codex 插件前缀）。

```
你是 <派生者> 的 <角色> 子代理。技能：<dmt-角色>（<加载方式>）。
单元：<一句话>。输入：<路径>。边界：<Files>。产物：<路径与格式>。
判据：<可测>。回报：<格式>。超时：<timeoutMs>。
```

条件字段：

- **构建补件**：票涉 gradle / clean build 时必写——SDK 路径、vendored 依赖软链、环境变量；均 gitignored、非交付物。
- **素材补件**：门依赖外部采集素材时必写——素材根、覆盖用变量名、缺失时 fail-loud 并打印实际取用的绝对路径。
- **资源纪律**：禁 `pkill <pattern>` / `pkill -f` / `killall`（只按自己 pidfile 的确切 PID 清理）；同一门 / 同一 worktree 不得并发跑（先 `ps` 查）。
- **收口**：合流前须在「缺本票本地产物的树」上跑一次门（同一主仓 detached worktree；禁 `archive` / `clone --shared`，会缺 refs 造成假红），证据给该次读数。
- **文件写入**：用各 harness 的结构化编辑工具（codex 用 `apply_patch`）；`oldString` 必须唯一。

## devm → devl 派单（收件箱 + 门铃，不是子代理 prompt）

正文必带：批次 / 票号列表 / 票面路径 / SPEC 路径（`spec-seq`）/ worktree 根 / 判据 / 可并行的票 / 回报格式 / `timeoutMs` / 纪律。

纪律写死：**不 push、不 merge、不跨队长通信；汇总自派 subagents 后上报 devm；reviewer 必须按 `spec-seq` 独立实例。**

## devl → dev-e

用通用骨架，额外写明 `worktree：<本票绝对路径，devl 预建>` 与 `单写者：本 worktree 只有你能提交`。

## reviewer{n} 变体（`/code-review` 为模板常量，不得替换或省略）

```
你是 devl{n} 的 reviewer{n} 子代理。技能：dmt-reviewer。必须调用 <code-review> 逐条验收。
独立性：不得与实施该票的 dev-e 同实例，不采信 devl / dev-e 结论，只认 ticket + SPEC + diff + 证据；无证据的「通过」视为不通过。
票：<路径>。SPEC：<spec-seq 路径>。输入：<diff / 证据 / 测试输出路径>。
判据：照 ticket 验收标准逐条核，逐条挂证据路径。回报：逐条通过与否 + 结论 + 证据路径。
超时：<timeoutMs>。
```

结论随 devl 交付包上报 devm，由 devm 转呈 director 供抽查。

## Codex harness 承载

技能来自项目 `.agents/skills/`（及 `.codex/skills/`），mattpocock 插件技能按 `mattpocock-skills:<name>` 引用。

```
你是 <派生者> 的 <角色> 子代理。先完整读取并执行技能 <技能路径>，再读其强制技能 <限定名或路径>。
单元 / 输入 / 上下文路径 / 边界 / worktree / 产物 / 判据 / 回报 / 超时 同上。
完成后只回报证据，不自行 merge / push。
```

首选 `spawn_agent` 派发、`wait_agent` 收结果；新单元另起，只有纠正 / 收窄才沿用。技能与输入路径必须显式给，不信口称「已加载」。没有 `spawn_agent` 接口时，只做本 pane 工作并记 `[SUBAGENT_UNAVAILABLE]`，不得用 shell 嵌套 `codex exec` 伪造团队。

## pi harness 承载

`agent` 字段必须填内置 `delegate`（填角色名报 `Unknown agent`）；prompt 里写「你是 <派生者> 的 <角色> 子代理」定角色。`delegate` 无技能清单、无 Skill 工具 ⇒ prompt 必须给技能文件路径。`devl{n}` 是 pane 角色，由 devm 用 `devl-pane.sh` 起，不走 delegate。细节见 [`../harness/pi.md`](../harness/pi.md)。
