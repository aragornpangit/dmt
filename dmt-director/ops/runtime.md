# pane 运行与生命周期

**身份＝pane label，不是位置、不是 tab。** 常驻角色各占一个 pane（`director` / `devm` / `anam` / `devl{n}`）；`{角色}-helper` 是按需 pane；`pde{n}` / `dev-e` / `ana-e` / `reviewer{n}` 是子代理，不占 pane。

## 布局

- `director` tab：左侧 `director`，右侧 `anam`。
- `dmt-dev` tab：左侧 `devm`，右侧竖排 `devl1…devl{n}`（`n ≥ DEVL_MIN=2`）。
- label 与角色名同名且全 workspace 唯一；按 `herdr pane list` 的 `label` 识别伙伴；不按 tab 位置、不记 pane id。label 缺失 ⇒ 停下问用户。
- `devm` 不得用 tab label 认自己（其 tab label 是 `dmt-dev`）。
- **禁止 `herdr tab close`**：`director` tab 会连带 `anam`，`dmt-dev` tab 会连带 `devm` / `devl{n}`；helper tab 需保留复用；只关 pane。空 tab 且非 `director` / `dmt-dev` / `helper` 才可关。

## 启动

用户备好 `director` tab 并启动 harness 后（Codex 作为备选时加 `--harness codex`）：

```bash
bash dmt-director/scripts/setup-team.sh --harness codex
```

脚本幂等完成：director 正名 → 建 `dmt-dev` tab 并把 `devm` 迁入左侧 → 把 `anam` 移到 director tab 右侧 → 代启动 harness → 输技能命令。`devl` pane 由 `devm` 启动后调 `devl-pane.sh ensure-min` 建立，`setup-team.sh` 不预建。Codex 的技能随首轮 prompt 一次下发；启动时出现 trust 界面就先人工确认，再重跑 `setup-team.sh --harness codex --force-start`。技能名 / 落点变更后跑 `setup-team.sh --reload`，Codex 则重开 pane。

就绪判据＝`herdr pane get <pane>` 的 `agent_status` 非 `unknown`。启动后必须用 `dmt_pane_auto_mode` 回读 argv 复验自动档；角色技能是否正确加载则用该角色实际产物和技能回执核验。见 `WARN` 用 `setup-team.sh --force-start` 重开。事故与逃生舱见 [`permission-notes.md`](permission-notes.md)。

## devl pane 生命周期（devm 负责）

| 阶段 | 触发 | 动作 | 判据 |
|---|---|---|---|
| 补位 | `n < DEVL_MIN` | `devl-pane.sh ensure-min` | 至少 2 个 `devl` pane |
| 扩容 | 待派票 > 空闲 devl 数，且 `n < floor(tab_height / MIN_DEVL_ROWS)` | `devl-pane.sh add` | 新 pane label 连续、`agent_status` 非 `unknown` |
| 回收 | `n > DEVL_MIN` 且无在办票、工作区干净、空闲 ≥ 10 min | `devl-pane.sh remove <index>` | 双钥匙：队长自报收口 + `git status` 干净、无 running `dev-e` |
| 拒绝回收 | `n = DEVL_MIN` | 保留 | 不得降到 1 |
| 恢复 | pane 丢失 / label 漂移 | 按 pane id 改名自愈，或从待办重建 | label 与 pane id 一致 |
| 重排 | 列内行高不齐（pane 被脚本外的方式关掉，`remove` 的重排没跑到） | `devl-pane.sh rebalance` | 各 `devl` 行数相等，且 ≥ `MIN_DEVL_ROWS` |

**实现要点**：`HERDR_TAB_ID` 是 pane 创建时注入的，`pane move` 后不更新；devm 必须用 `herdr pane get "$HERDR_PANE_ID" | jq -r '.result.pane.tab_id'` 现查当前 tab。分割比例：`pane split` 只切最底层 pane、**不重排祖先比例**，直接连加会让第 3 个队长只剩 8 行；`add` / `remove` 后由 `rebalance_devl_column` 从最底层 split 往上逐层 `pane resize` 到 `1/(n-i)` 才等高（`remove` 后需 `sleep 1` 等 layout 树收敛）。

## 手动会话权限

仅用户手动启动的会话：发第一条消息前按 `shift+Tab` 切 `auto mode`。会话开始后权限模式锁定；代启动的 pane 不走此流程。

## Codex 差异

- Codex 从 `.agents/skills/` 和 `.codex/skills/` 发现项目技能；DMT 角色技能是裸名 `dmt-dm`，mattpocock 插件技能按限定名 `mattpocock-skills:<name>` 引用。
- pane 角色只认 `label`。发送门铃时先用 label 解析 pane id，再向 pane 发 `agent prompt`；Codex 的 agent name 可独立漂移，不能充当角色身份。
- Codex 启动中先出 trust / startup 界面时，`agent_status` 可能仍是 `unknown` 或 `blocked`。等待人工确认，再重跑阶段；不要把技能文本粘贴进确认界面。
- Codex 的原生子代理接口按当前用户配置出现，可能缺席。缺少 `spawn_agent` 时，DMT 在该 herdr 会话只做本 pane 的角色工作，不伪造嵌套 pane、也不通过 `codex exec` 自建代理。
- mattpocock 的 Codex 插件是安装来源；若同时有 `~/.codex/skills` 兼容副本，启动前按同一版本二选一，避免同名技能重复登记。

## helper 生命周期

helper 的开法、语义和回收统一见 [`helper.md`](helper.md)。`dmt-devl` **不设 helper**。
