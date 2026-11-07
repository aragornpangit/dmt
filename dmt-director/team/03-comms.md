### 1.3 通信方式（收件箱文件 + herdr 门铃）

方向码、路径、门铃与三态见 [`ops/comms.md`](../ops/comms.md)。

### 1.4 依赖的 harness 技能（mattpocock，强制使用）

**强制口径**：下表技能必须调用，不得以「手写更快」「技能没装」为由跳过；不可用先按本节安装，仍不可用标 `[SKILL_UNAVAILABLE]` 并回报 director。调用要留痕（用了哪个、产出在哪）。

| 角色 | 强制技能 | 用在哪 |
|---|---|---|
| `director` | `/grilling` `/grill-me` `/grill-with-docs` `/code-review` `/to-spec` | 需求问穿、方案自审、文档交叉拷问、抽查复验（只复核证据）、SPEC 定稿 |
| `devm` | `/to-tickets` `/diagnosing-bugs` | 工单落笔、缺陷分诊；**不做代码评审** |
| `devl{n}` | `/code-review` `/grilling` | 票面歧义拷问、派 reviewer 前自检、汇总证据 |
| `anam` | `/research` `/grilling` `/grill-me` `/grill-with-docs` | 一手取证与证据分级、方案自审、交叉拷问 |
| `pde{n}` | `/grilling` `/research` `/to-spec` | 口径核对、事实取证、SPEC 落笔（`to-tickets` 归 devm） |
| `reviewer{n}` | `/code-review` | 逐条核判据、diff、证据（**写进派发 prompt**） |
| `dev-e` | `/tdd` `/implement` `/code-review` `/diagnosing-bugs` | TDD 实施、按 SPEC 落地、提交前自审、缺陷分诊 |
| `ana-e` | `/research` `/rea` `/grilling` `/grill-me` `/grill-with-docs` | 取证、竞品逆向（`/rea` 属 REA）、交叉拷问 |

**director 的 `/code-review` 只用于复核 reviewer 证据与高风险复验，不构成第二道主轨；主轨 PASS 只由 `devl{n}` 派的 `reviewer{n}` 给出。**

**角色技能映射**：`pde{n}`→`dmt-pde`、`dev-e`→`dmt-de`、`ana-e`→`dmt-ae`、`reviewer{n}`→`dmt-reviewer`、`devl{n}`→`dmt-devl`。派发者把技能名写进 prompt；加载方式按 harness 差异（cbc `/`、opencode `@`、pi `/skill:`、codex 插件前缀），见 [`../harness/README.md`](../harness/README.md) 与 [`07b-dispatch.md`](07b-dispatch.md)。

**技能源**：技能名与 [`mattpocock/skills`](https://github.com/mattpocock/skills) 上游目录名逐字一致；正文路径 `https://raw.githubusercontent.com/mattpocock/skills/main/skills/<engineering|productivity>/<name>/SKILL.md`（`/rea` 属 REA，不在该仓）。`/improve-codebase-architecture` 可选、非强制。

**安装**：`npx skills@latest add mattpocock/skills -a <agent>`；Codex 用 `codex plugin marketplace add mattpocock/skills` + `codex plugin add mattpocock-skills@mattpocock`。失败则克隆仓库，把技能目录放进 `~/.agents/skills/` 再软链；插件与兼容副本二选一，避免重复登记。

**cbc-herdr**（仅 CodeBuddy pane）：只用于状态上报，Codex 用 herdr 原生识别。`dmt-director` / `dmt-dm` / `dmt-am` / `dmt-devl` 的 cbc 必须登记，其它 harness 与子代理不登记。

**harness 差异**：机器事实见 [`../../dmt-director/harness_matrix.yaml`](../../dmt-director/harness_matrix.yaml)；加载规则见 [`../harness/README.md`](../harness/README.md)。

**已知缺口**：

- 上游无 `to-prd` ⇒ PRD 按 §4.1 模板由 pde 落笔。
- **转发式技能在 pi 上必须降级**：`grill-with-docs` / `grill-me` / `implement` / `tdd` 正文含 `Call the Skill tool with "<其它技能>"`，而 pi 无 Skill 工具 ⇒ 改为 `read <镜像根>/<其它技能>/SKILL.md`（不降级会静默失效；见 [`../harness/pi.md`](../harness/pi.md) §5.1）。

### 1.5 文件占用（编辑前必须检查）

见 [`ops/file-claim.md`](../ops/file-claim.md)。
