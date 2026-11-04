# §5.2 附：派发 prompt 模板与 pi 承载（低频细节；`team/07-discipline.md` §5.2 按需引用）

## 派发 prompt 骨架（照填，不要现编）

`你是 <角色> 的子代理。技能：<对应的 dmt-<角色> 技能名>（cbc 直接斜杠调用；pi 读 '<技能目录>/dmt-<角色>/SKILL.md' 并按其中强制技能节执行）。单元：<一句话>。输入：<路径>。边界：<Files>。产物：<路径与格式>。判据：<可测>。回报：<格式>。超时：<timeoutMs>。文件写入纪律：改 bash 文件用单引号 heredoc 或 Write/Edit，禁止把脚本正文放进 JS 模板字符串；Edit 的 oldString 必须唯一。`

`<角色>` ∈ `pde{n}` / `dev-e` / `ana-e`，对应技能 `dmt-pde` / `dmt-de` / `dmt-ae`。`reviewer{n}` 变体见下。

## reviewer{n} 变体（验收专用；`/code-review` 为模板常量，不得替换或省略）

`你是 devm 的 reviewer{n} 子代理。技能：dmt-reviewer（cbc 直接斜杠调用；pi 读 '<技能目录>/dmt-reviewer/SKILL.md'）。必须调用 /code-review 技能逐条验收。独立性：不得与实施该票的 dev-e 同实例，不采信 devm / dev-e 的结论，只认 ticket + SPEC + diff + 证据；无证据的「通过」视为不通过。票：<ticket 路径>。SPEC：<对应 spec-seq 路径>。输入：<diff、证据、测试输出路径>。判据：照 ticket 验收标准逐条核，逐条挂证据路径。回报：逐条通过/不通过 + 结论 + 证据路径（结论将随 devm 回报抄送 director 供抽查）。超时：<timeoutMs>。`

## pi harness 承载（`delegate`）

`dev-e` / `ana-e` / `pde{n}` / `reviewer{n}` 是**角色语义名**，不是 pi-subagents 的 agent 注册名。pi workflow `runs.run/all` 的 `agent` 字段**必须填内置承载 agent `delegate`**（无预设行为、继承父模型）；按角色名直派必报 `Unknown agent`（实例：2026-10-31 `agent:'ana-e'` 三发三败，改 `delegate` 即成）。prompt 里写「你是 <派生者> 的 <角色> 子代理」定角色，`agent` 只管承载。

pi 下 `delegate` **无技能清单、无 Skill 工具** ⇒ 必须在 prompt 给技能文件路径：`read <技能目录>/dmt-<角色>/SKILL.md`，并依次 `read <技能目录>/<name>/SKILL.md` 读强制技能。cbc 不受此约束（teammate `Agent` 带 name 即角色名，且继承技能清单、可直接斜杠调用）。
