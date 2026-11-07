# 可选：helper 适配器

helper 是常驻 pane 角色的临时执行分身，不是必需角色。只有待办可独立拆分、额外容量有收益且本体仍在处理其他工作时才启用。

```bash
bash dmt-director/scripts/spawn-helper.sh <director|devm|anam> "<任务>"
```

- 任务随创建一次下发，写清输入、边界、产物和回报；是否复用 pane 由脚本决定。
- helper 使用与本体相应的角色能力，不建立独立上下级关系。
- 默认无独立收件箱，成果用 `helper-report.sh` 单向写回本体。
- 发布、共享设备和其他独占操作是否可移交由项目授权决定，默认留在本体。

完成后用 `close-helper.sh` 回收。关闭前确认成果已入账、工作区已清理、相关消息已收口；保留可复用 tab，不连带关闭其他 pane。
