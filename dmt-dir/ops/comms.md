# 可选：DMT 收件箱通信

启用文件收件箱时，正文写文件，herdr 只发送简短门铃。普通子代理使用原生返回通道，不必建立收件箱。

## 完整团队模式的允许方向

| 发送方 | 收件方 |
|---|---|
| `dmt-dir` | `dmt-am` |
| `dmt-dm` / `dmt-am` | `dmt-dir` |
| `dmt-dm` | `dmt-dl{n}` |
| `dmt-dl{n}` | `dmt-dm` |
| `{角色}-helper` | 本体（单向，无门铃） |

`dmt-dir` 只安排 `dmt-pde` 定稿 SPEC，不向 `dmt-dm` 派单；`dmt-dm` 依 SPEC 产物自行用 `to-tickets` 拆单向 `dmt-dl{n}` 派单（见 [`../team/01-org.md`](../team/01-org.md)），故 `dmt-dir → dmt-dm` 不在允许方向内。

`send-msg.sh` 是该可选拓扑的方向白名单实现；非法方向返回 2 且不写消息。独立角色或裁剪后的拓扑由项目消息机制定义，不套用此表。

## 写消息

路径为 `inbox/<收件角色>/{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`。

- `{seq}` 至少三位零填充，超过 999 后继续自然增长；`.seq` 保存无前导零的十进制高水位。
- 取号为现有消息、`.doing/` 和 `.seq` 的最大值加一，序列不得重用。
- slug 简明可读；正文包含摘要、相关路径、请求动作、产物和回报要求。

```bash
bash dmt-dir/scripts/send-msg.sh <收件角色> <自己> <slug> <正文文件>
```

门铃按当前 pane label 解析目标，不长期缓存 pane id。目标阻塞时保留消息并请用户处理，不重复投递。

## 三态与回报

1. `msg-take.sh` 将未读消息移入 `.doing/`。
2. 从 `.doing/` 读取并处理。
3. `msg-done.sh` 在收口后删除处理中消息。

超时、 stale 消息和巡检频率由项目约定。完成或阻塞时沿派发关系回报，包含结论、产物、证据和未决项。
