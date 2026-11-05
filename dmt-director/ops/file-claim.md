# 文件占用

任何角色编辑（写入 / 追加 / 删除）任何文件前，必须先检查占用；到手才能改，改完立即释放。

```bash
bash dmt-director/scripts/file-claim.sh check|claim|release <path> <owner>
bash dmt-director/scripts/file-claim.sh list
```

- 记录落主工作树根 `locks/`；worktree 里也写回主树。`<owner>` 用「角色:实例」，如 `devm-helper`。
- `rc=3` ⇒ 停手：等释放、换文件或回报上级；不得绕过、不得删别人的锁。
- TTL 30 分钟。过期锁可接管，但回报要写明「接管过期锁 `<path>`（原持有者 `<owner>`）」；长任务收工前重新 `claim` 续期。
- `inbox/` 与 `locks/` 自身不登记；worktree 不豁免。
