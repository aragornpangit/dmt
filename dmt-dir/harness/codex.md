# harness 差异：codex

共性见 [`COMMON.md`](COMMON.md)，机器事实见 [`../harness_matrix.yaml`](../harness_matrix.yaml)。

- 项目技能目录可用 `.agents/skills/`、`.codex/skills/`；避免同一技能重复登记。
- 角色技能使用 `/<技能名>`；其他技能的限定名由其实际安装方式决定。
- 支持首轮 prompt 的平台可在启动时传入角色技能与任务。
- 子代理优先使用原生 `spawn_agent` / `wait_agent`；不可用时报告能力缺口，不用嵌套进程伪造团队。

## 沙箱与 herdr

受限 workspace 沙箱可能无法访问 herdr unix socket，导致门铃、寻址或文件占用不可用。默认启动不因此放开文件系统和网络权限。

需要跨沙箱访问时，先说明限制，由用户选择受控环境或显式授权。`danger-full-access` 只能在用户明确接受风险后作为一次性配置，例如通过 `DMT_HARNESS_CMD` 覆盖启动命令，不能作为通用默认或机检合格条件。

首次 trust、权限模式和会话环境按当前版本实际行为核验；失败时保留消息并报告，不重复投递。
