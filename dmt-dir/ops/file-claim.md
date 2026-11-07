# 可选：多写者文件占用

只有多个角色必须共享同一文件且无法拆分时才启用；单写者工作区不需要锁仪式。

```bash
bash dmt-dir/scripts/file-claim.sh check|claim|release <path> <owner>
bash dmt-dir/scripts/file-claim.sh list
```

- 锁记录位于主工作区 `locks/`，可用 `DMT_LOCKS_DIR` 覆盖；owner 应唯一标识持有实例。
- `rc=3` 表示被他人占用，应等待、换路径或回报派发者，不能删除他人的活跃锁。
- 锁有效期由 `DMT_CLAIM_TTL`（秒）配置；长任务按该策略续期。
- 接管过期锁需记录原持有者；确认对方仍在写时不能仅因过期就抢占。
- `inbox/` 与 `locks/` 自身不登记，正式产物仍须遵守单写者边界。
