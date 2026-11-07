# pane 运行与生命周期

**身份＝pane label，不是位置、不是 tab。** 常驻角色各占一个 pane（`director` / `devm` / `anam` / `devl{n}`）；`{角色}-helper` 按需；`pde{n}` / `dev-e` / `ana-e` / `reviewer{n}` 是子代理，不占 pane。

## 布局

- `director` tab：左侧 `director`，右侧 `anam`。
- `dmt-dev` tab：左侧 `devm` 占 40%，右侧竖排 `devl1…devl{n}` 占 60%（`n ≥ DEVL_MIN=2`；`DEVM_WIDTH_RATIO=0.4`）。
- label 与角色名同名且全 workspace 唯一；按 `herdr pane list` 的 `label` 识别伙伴，不按 tab 位置、不记 pane id。label 缺失 ⇒ 停下问用户。
- `devm` 不得用 tab label 认自己（其 tab label 是 `dmt-dev`）。
- **禁止 `herdr tab close`**：会连带同 tab 的其它 pane。只关 pane；空 tab 且非 `director` / `dmt-dev` / `helper` 才可关。
- **devm pane 恢复**：丢失 / label 漂移由 director 按 pane id 改名自愈或重建；重建期间 merge / push 暂停，不转授权。

## 启动

用户备好 `director` tab 并启动 harness 后（Codex 加 `--harness codex`）：

```bash
bash dmt-director/scripts/setup-team.sh --harness codex
```

脚本幂等：director 正名 → 建 `dmt-dev` tab 并把 `devm` 迁入左侧 → `anam` 移到 director tab 右侧 → 代启动 harness → 输技能命令。`devl` pane 由 `devm` 启动后调 `devl-pane.sh ensure-min` 建立，`setup-team.sh` 不预建。技能名 / 落点变更后跑 `--reload`，Codex 则重开 pane。

就绪判据＝`herdr pane get <pane>` 的 `agent_status` 非 `unknown`。启动后必须用 `dmt_pane_auto_mode` 回读 argv 复验自动档；技能是否加载用该角色实际产物与回执核验。见 `WARN` 用 `--force-start` 重开。事故与逃生舱见 [`permission-notes.md`](permission-notes.md)。

## devl pane 生命周期（devm 负责）

| 阶段 | 触发 | 动作 | 判据 |
|---|---|---|---|
| 补位 | `n < DEVL_MIN` | `devl-pane.sh ensure-min` | 至少 2 个 `devl` pane |
| 扩容 | 待派票 > 空闲 devl，且 `n < floor(tab_height / MIN_DEVL_ROWS)` | `devl-pane.sh add` | label 连续、`agent_status` 非 `unknown` |
| 回收 | `n > DEVL_MIN` 且无在办票、工作区干净、空闲 ≥ 10 min | `devl-pane.sh remove <index>` | 双钥匙：队长自报收口 + `git status` 干净、无 running `dev-e` |
| 拒绝回收 | `n = DEVL_MIN` | 保留 | 不得降到 1 |
| 恢复 | pane 丢失 / label 漂移 | 按 pane id 改名自愈，或从待办重建 | label 与 pane id 一致 |
| 重排 | 列内行高不齐（`remove` 的重排没跑到） | `devl-pane.sh rebalance` | 各 `devl` 行数相等且 ≥ `MIN_DEVL_ROWS` |

**实现要点**：`HERDR_TAB_ID` 是 pane 创建时注入的，`pane move` 后不更新 ⇒ 用 `herdr pane get "$HERDR_PANE_ID" | jq -r '.result.pane.tab_id'` 现查。`pane split` 只切最底层 pane、不重排祖先比例，直接连加会让第 3 个队长只剩 8 行；`add` / `remove` 后由 `rebalance_devl_column` 从最底层往上逐层 `pane resize` 到 `1/(n-i)`（`remove` 后 `sleep 1` 等 layout 树收敛）。

## 手动会话权限

仅用户手动启动的会话：发第一条消息前按 `shift+Tab` 切 `auto mode`；会话开始后权限模式锁定。代启动的 pane 不走此流程。

## Codex 差异

见 [`../harness/codex.md`](../harness/codex.md)。

## helper 生命周期

见 [`helper.md`](helper.md)；`dmt-devl` 不设 helper。
