# harness 差异：codex

共性见 [`COMMON.md`](COMMON.md)，机器事实见 [`../harness_matrix.yaml`](../harness_matrix.yaml)。

- 项目技能目录可用 `.agents/skills/`、`.codex/skills/`；避免同一技能重复登记。
- 启动档为 yolo：`codex --dangerously-bypass-approvals-and-sandbox`（启动屏显示 `Full Access · never`）。只免审批、仍保留沙箱时改用 `-a never`（显示 `Workspace · never`），此时跨沙箱访问 herdr socket 仍受限。
- 角色技能不提供 `/dmt-*` 补全：`/` 菜单只有 `/skills` 选择器，技能目录通过 prompt 注入模型（`codex debug prompt-input` 可核对），由模型按任务自行调用。
- 支持首轮 prompt 的平台可在启动时传入角色技能与任务。
- 子代理优先使用原生 `spawn_agent` / `wait_agent`；当前版本载荷不送达时见 [`BACKLOG.md`](BACKLOG.md) X3，报告能力缺口，不用嵌套进程伪造团队。

## 沙箱与 herdr

yolo 档（`--dangerously-bypass-approvals-and-sandbox`）连沙箱一并放行，herdr unix socket 可直连，门铃、寻址与文件占用正常 —— 这是 dmt 的默认启动档。

需要收窄时用 `-a never`（只免审批、保留 workspace 沙箱），此时跨沙箱访问 herdr 会失败。两档之间不要静默切换：按矩阵 `start_cmd` 启动，或显式用 `DMT_HARNESS_CMD` 覆盖并说明原因。

首次 trust、权限模式和会话环境按当前版本实际行为核验；失败时保留消息并报告，不重复投递。
