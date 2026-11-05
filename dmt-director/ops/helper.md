# helper 分身

helper 是常驻 pane 角色的临时纯分身，每角色至多一个，不占新角色、不建独立频道。

## 开法

唯一判据：本体 pane `agent_status == working` 且待办超过 10 分钟未处理。

```bash
bash dmt-director/scripts/spawn-helper.sh <director|devm|anam> "<任务>"
```

脚本创建或复用共享 `helper` tab，并 split 出 `{角色}-helper`。任务随 spawn 一次性下发；此后不接受任何输入框内容。

## 语义

- 技能同本体。
- 无自己的 inbox，不收件，不走门铃。
- 成果用 `helper-report.sh <本体> <正文文件>` 单向写回 `inbox/<本体>/`。
- 独占动作不移交：硬件设备写操作归 `devm` / `director` 本体；merge / push 归 `devm` 本体。

## 回收

任务收口后立即关 pane：

```bash
bash dmt-director/scripts/close-helper.sh <director|devm|anam>
```

关闭前置：成果已入账；名下 worktree 已移除；本体收件箱中该 helper 方向消息已收口。helper tab 保留复用，禁止关 tab。
