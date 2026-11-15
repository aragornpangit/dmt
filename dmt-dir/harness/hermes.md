# harness 差异：hermes

共性见 [`COMMON.md`](COMMON.md)，机器事实见 [`../harness_matrix.yaml`](../harness_matrix.yaml)。

## 技能与权限

- 用户级技能目录为 `~/.hermes/skills/`；项目级可用 `.hermes/skills/` 与 `.agents/skills/`，但只在 `skills.trusted_project_dirs` 内加载。首次使用项目技能先 `hermes skills trust`（或把项目根写入该配置）。
- 技能调用为 `/<技能名>`；`hermes skills list` 查看已安装技能，`hermes chat -s <技能名>` 可在启动时预加载。
- 启动命令 `hermes chat --yolo` 是自动批准档；需要更严格权限时用 `DMT_HARNESS_CMD` 覆盖，不把 `--yolo` 当团队通信的默认前提。
- 项目技能被信任后，`.agents/skills` 与 codex/opencode/pi 共用，不需要重复铺设。

## 子代理

- 原生子代理工具为 `delegate_task`（`goal` / `context` / `tasks`），并发上限读 `delegation.max_concurrent_children`（默认 10）。
- `delegate_task` 没有技能参数；派发时在 `context` 中给出角色 `SKILL.md` 绝对路径，由子代理 `read`，与 `subagent_skill: read` 一致。
- 子代理只向派发者回报；不可用时报告能力缺口，不用嵌套进程伪造团队。

## 门铃与首轮 prompt

- 首轮 prompt 可用 `hermes chat -q '<text>'` 注入；dmt pane 启动不假定首轮 prompt，按 `first_prompt: false` 先启动、就绪后再发 `/dmt-*` 技能命令。
- herdr 门铃优先走 `herdr agent prompt`；herdr 不认识该 agent 时退回 `pane send-text` + `pane send-keys enter`，发送后按 [`../team/03-comms.md`](../team/03-comms.md) 的三步复核。
