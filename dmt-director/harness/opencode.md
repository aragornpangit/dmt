# harness 差异：opencode

> 共性见 [`COMMON.md`](COMMON.md)；机器可读事实单一来源 [`../harness_matrix.yaml`](../../dmt-director/harness_matrix.yaml)。

## 1. 技能发现目录

| 级别 | 目录 |
|---|---|
| 项目级 | `.agents/skills/`、`.claude/skills/`、`.opencode/skills/`（**复数**） |
| 用户级 | `~/.agents/skills/`、`~/.claude/skills/` |

- **单数 `.opencode/skill/` 在项目级不生效**（实测；本机旧安装目录里两份并存，易误判）。
- 读 `.claude/skills/` ⇒ 与 claude 共用一份落点。

## 2. 启动与权限

`opencode --auto`；自动档判据 argv 含 `--auto`（另有 `--dangerously-skip-permissions`）。

## 3. 技能调用行

`/<技能名>`。

**2026-11-05 实测补充（重要）**：

- **斜杠命令清单不完整**：`/to-spec`、`/to-tickets` 实测**未进** opencode 的斜杠清单，敲了不生效；但 **`skill` 工具能按 id 加载**（`implement` / `tdd` / `code-review` / `research` 实测均成功，含带 `disable-model-invocation: true` 者）。
- ⇒ **优先用 `skill` 工具**（id 即技能名）；工具也不可用时按 §4 直读 `SKILL.md`。director 实测就是走了这条回退：报「`/to-spec`、`/to-tickets` 未进本项目 opencode 技能清单」，改为直读 `~/.agents/skills/mattpocock-skills/skills/engineering/<name>/SKILL.md`。
- **门铃（`herdr agent prompt`）可用**：实测 `send-msg.sh` 发 `director` 成功（无 WARN，收件方认领并收口）。但**首次启动后的最初几十秒**输入可能未就绪 ⇒ 首次注入技能后需复核 pane 输出是否真的开始工作（必要时补 `send-keys enter`）。

## 4. 技能如何到达模型

- 技能进清单、可斜杠调用；不能调起时改读技能文件路径。
- 子代理：按 harness 自身的并行子代理机制承载（模板见 [`../team/07b-dispatch.md`](../team/07b-dispatch.md)）。

## 5. 强制技能

`/<name>`。

## 6. 特有约束

- **并发上限**：上游 opencode 2.2.5 **未提供并发入口**，矩阵显式记为 `null`（不是漏填）⇒ 派发前按任务规模自判，不设硬上限。
- `cbc-herdr` **不需要**（herdr 原生识别 opencode）。
