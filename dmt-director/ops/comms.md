# 收件箱通信

**正文走文件，herdr 只发门铃一句。** 派单、回报、评审结论、裁决请求、缺陷退回都先落盘，再发「你有新消息 <文件名>」。

## 允许方向

| 发送方 | 收件方 | 方向码 |
|---|---|---|
| `director` | `devm` / `anam` | `director2devm` / `director2anam` |
| `devm` / `anam` | `director` | `devm2director` / `anam2director` |
| `devm` | `devl{n}` | `devm2devl{n}` |
| `devl{n}` | `devm` | `devl{n}2devm` |
| `{角色}-helper` | 本体 | `{角色}-helper2{角色}`（单向，无门铃，无回程） |

跨部门经 director 转派；队长之间禁止直连，跨队经 `devm`。`dmt-devl` 不设 helper，helper 无自己的 inbox。

**本表由 `send-msg.sh` 强制**：方向不在表内一律 `exit 2`（`bad direction: <from> -> <to>`），不落盘、不按门铃。非法方向含队长互连、越级（`director→devl{n}`、`devl{n}→director`）、跨部门（`devm↔anam`、`devl{n}→anam`）与同角色自投。改表必须同步改 `dir_ok()`（唯一实现），机检 A6b 有 16 条方向自测守回退。

## 写消息

路径：项目根 `inbox/<收件角色>/{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`。

- `{seq}` 由 `.seq` 高水位维护，无前导零；取号 = max(inbox 与 `.doing/` 最大号, `.seq`) + 1。
- `{slug}` 英文小写短横线，最多 5 词。
- 正文自包含：摘要、权威路径、请求动作、期望产物、回报要求。

```bash
bash dmt-director/scripts/send-msg.sh <收件角色> <自己> <slug> <正文文件>
```

## 门铃

1. `herdr pane list --workspace <id>` 按 `label == <收件角色>` 解析 pane id；不缓存 id，也不把 herdr agent name 当角色名。
2. 发 `herdr agent prompt <pane-id> '你有新消息 <文件名>，在 inbox/<角色>/'`；返回 `agent_prompted` 即送达。
3. 不接受目标或返回 `agent_not_ready` / `agent_blocked` 时，先只读 `pane get` / `agent read` 判断是否 trust / 审批界面。普通输入态可回退 `pane send-text` + `send-keys enter`，再用 `pane read` 核验；阻塞态保留消息文件并请用户处理。

匹配键是 pane label，不是 agent name：Codex 的 agent 名可独立漂移。发送前先读目标 pane；对方有未提交输入时等待或请用户转达。

## 三态

1. 认领：`msg-take.sh <角色> <文件>`，从 inbox 移入 `.doing/`。
2. 处理：读 `.doing/` 文件；不回执。
3. 收口：`msg-done.sh <角色> <文件>`，从 `.doing/` 删除。

重启后根目录 `*.md` 是未读，`.doing/` 是续做清单；`.doing/` 超 24h 未收口要上报直属上级。超过 10 分钟的操作，开工前和收工后各扫一次收件箱。

## 完成即报

`devl{n}` 本批收口或遇阻塞 / 超时 / 需裁决立即回报 `devm`；`devm` / `anam` 向 director 回报；director 对用户同理。收件方不回执，发送方不确定时问用户，不重复投递。
