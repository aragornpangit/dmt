### 1.2 运行环境与 pane 生命周期

**操作细节见 [`dmt-director/ops/runtime.md`](../ops/runtime.md)** —— pane/tab 形态、启动、权限和 helper 生命周期。

**harness 兼容**：

| harness | 技能发现目录（实测；`<项目>/` 项目级、`~/` 用户级） | 代启动命令 | 技能调用行 |
|---|---|---|---|
| `claude` | 项目级 `.claude/skills/`；用户级 `~/.claude/skills/` | `claude --permission-mode auto` | `/dmt-dm` |
| `codebuddy` | 项目级 `.codebuddy/skills/`；用户级 `~/.codebuddy/skills/` | `codebuddy --permission-mode auto` | `/dmt-dm` |
| `codex` | 项目级 `.agents/skills/`、`.codex/skills/`；用户级 `~/.agents/skills/`、`~/.codex/skills/` | `codex -a never '<角色技能 prompt>'` | `/dmt-dm`；插件技能 `mattpocock-skills:<name>` |
| `opencode` | 项目级 `.agents/skills/`、`.claude/skills/`、`.opencode/skills/`（**复数**）；用户级 `~/.agents/skills/`、`~/.claude/skills/` | `opencode --auto` | `/dmt-dm` |
| `pi` | 项目级 `.agents/skills/`、`.pi/skills/`；用户级 `~/.agents/skills/`、`~/.pi/agent/skills/`（**不是 `~/.pi/skills/`**） | `pi --approve` | **`/skill:dmt-dm`** |

**约束**：

1. 技能调用统一经 `lib-dmt.sh: dmt_skill_cmd`；pi 用 `/skill:<name>`，其余用 `/<name>`。Codex 插件技能另经 `dmt_skill_ref` 生成限定名。
2. `install-skills.sh` 默认装 `.agents/skills/`、`.claude/skills/`、`.codebuddy/skills/` 三处；只装一处会漏 harness。
3. Codex 首次进入项目需人工确认 trust；其技能与 helper 任务必须随首轮 prompt 下发。pi 启动必须带 `--approve`。
4. 启动后必须用 `dmt_pane_auto_mode` 读 argv 复验自动档；角色技能是否正确加载，用该角色实际产物与回执核验。非自动档用 `setup-team.sh --force-start` 重开。事故细节见 [`dmt-director/ops/permission-notes.md`](../ops/permission-notes.md)。
5. Codex 的 agent name 不是角色身份；门铃只按 pane label 解析目标，并向 pane 发送 `agent prompt` 或 pane 输入。

**技能加载（按 harness 分文件）**：「技能发现目录 / 启动与权限 / 技能调用行 / 技能如何到达模型 / 子代理承载”的说明在 [`../harness/README.md`](../harness/README.md) —— **共性** [`../harness/COMMON.md`](../harness/COMMON.md) ＋ **每 harness 一份差异**（[`pi.md`](../harness/pi.md) / [`codebuddy.md`](../harness/codebuddy.md) / [`claude.md`](../harness/claude.md) / [`codex.md`](../harness/codex.md) / [`opencode.md`](../harness/opencode.md)）。

七份角色 `SKILL.md` 的「## 0. 按 harness 加载」是**唯一入口**：先 `bash dmt-director/scripts/harness-detect.sh` 判定本会话 harness（判不出给 `unknown` 且 rc=1，**不得默认**），再读共性 ＋ 本 harness 差异。
