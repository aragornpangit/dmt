# pane 运行与生命周期

**身份＝pane label，不是位置、不是 tab。** 常驻角色各占一个 pane（`director` / `devm` / `anam`）；`{角色}-helper` 是按需 pane；`pde{n}` / `dev-e` / `ana-e` / `reviewer{n}` 是子代理，不占 pane。

## 布局

- `devm` 在 `director` tab 内、director pane 右侧；`anam` 独立 tab；label 与角色名同名且全 workspace 唯一。
- 按 `herdr pane list` 的 `label` 识别伙伴；不按 tab 位置、不记 pane id。label 缺失 ⇒ 停下问用户。
- `devm` 不得用 tab label 认自己（其 tab label 是 `director`）。
- **禁止 `herdr tab close`**：director tab 会连带 devm，helper tab 需保留复用；只关 pane。

## 启动

用户备好 `director` tab 并启动 harness 后（Codex 作为备选时加 `--harness codex`）：

```bash
bash dmt-director/scripts/setup-team.sh --harness codex
```

脚本幂等完成：director 正名 → split `devm` → 建 `anam` tab → 代启动 harness → 输技能命令。Codex 的技能随首轮 prompt 一次下发；启动时出现 trust 界面就先人工确认，再重跑 `setup-team.sh --harness codex --force-start`。技能名 / 落点变更后跑 `setup-team.sh --reload`，Codex 则重开 pane。

就绪判据＝`herdr pane get <pane>` 的 `agent_status` 非 `unknown`。启动后必须用 `dmt_pane_auto_mode` 回读 argv 复验自动档；角色技能是否正确加载则用该角色实际产物和技能回执核验。见 `WARN` 用 `setup-team.sh --force-start` 重开。事故与逃生舱见 [`permission-notes.md`](permission-notes.md)。

## 手动会话权限

仅用户手动启动的会话：发第一条消息前按 `shift+Tab` 切 `auto mode`。会话开始后权限模式锁定；代启动的 pane 不走此流程。

## Codex 差异

- Codex 从 `.agents/skills/` 和 `.codex/skills/` 发现项目技能；DMT 角色技能是裸名 `dmt-dm`，mattpocock 插件技能按限定名 `mattpocock-skills:<name>` 引用。
- pane 角色只认 `label`。发送门铃时先用 label 解析 pane id，再向 pane 发 `agent prompt`；Codex 的 agent name 可独立漂移，不能充当角色身份。
- Codex 启动中先出 trust / startup 界面时，`agent_status` 可能仍是 `unknown` 或 `blocked`。等待人工确认，再重跑阶段；不要把技能文本粘贴进确认界面。
- Codex 的原生子代理接口按当前用户配置出现，可能缺席。缺少 `spawn_agent` 时，DMT 在该 herdr 会话只做本 pane 的角色工作，不伪造嵌套 pane、也不通过 `codex exec` 自建代理。
- mattpocock 的 Codex 插件是安装来源；若同时有 `~/.codex/skills` 兼容副本，启动前按同一版本二选一，避免同名技能重复登记。

## helper 生命周期

helper 的开法、语义和回收统一见 [`helper.md`](helper.md)。
