# harness 差异：opencode

> 共性见 [`COMMON.md`](COMMON.md)；机器可读事实单一来源 [`../harness_matrix.yaml`](../harness_matrix.yaml)。

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

## 4. 技能如何到达模型

- 技能进清单、可斜杠调用；不能调起时改读技能文件路径。
- 子代理：按 harness 自身的并行子代理机制承载（模板见 [`../team/07b-dispatch.md`](../team/07b-dispatch.md)）。

## 5. 强制技能

`/<name>`。

## 6. 特有约束

- **并发上限未声明**（矩阵 `null`）⇒ 派发前自行按任务规模自判。
- `cbc-herdr` **不需要**（herdr 原生识别 opencode）。
