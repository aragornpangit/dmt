# dispatch-ledger.sh 变更通知（2026-10-27）

**一句话**：`scripts/dispatch-ledger.sh` 已改为 max-subagents「台账内核」的**薄壳**；原实现在 `scripts/dispatch-ledger.sh.orig-20261027`（一份 `cp` 即可回滚）。

## 为什么改

原脚本有 7 处判据缺陷（2026-10-27 实测取证），且与 max-subagents 的 gate 判据分叉（两套账对不上）。同一判据出现两份实现必然再次分叉（`lib-dmt.sh` 注释里已有此教训）。故改为：**判据只有一份实现**（`max-subagents/ledger.py`），dmt 侧只保留领域约定。

## 对外契约不变（hook 配置无需改动）

- 子命令全集不变：`plan / inc / excuse / done / check / report / status / ledger-path / inject / nudge`
- 调用形式不变：`bash scripts/dispatch-ledger.sh <cmd> <role> [args...]`（`inc`/`check`/`nudge` 从 stdin 读 hook payload）
- 角色解析与治理白名单不变（`dmt_role`；只治理 director/devm/anam/*-helper；`DMT_DISPATCH_ALL=1` 绕过）
- 账本路径不变：`$(dmt_root)/locks/dispatch-<ROLE>.tsv`（旧账本文件可直接继续用，含老 `HHMMSS` 时间列）
- `excuse` 理由码不变：`dep|files|build|order|device|rea`
- 输出格式保留：`report` 的「并发账：…[CAP=cap]」、`nudge` 的 `hookSpecificOutput.additionalContext`、`inject` 原文案
- `check` 语义保留：有未派单元且在途 0 → `rc=2` 阻断收工；`stop_hook_active=true` → `rc=0`；超 24h 旧账不阻断

## 修掉的 7 处缺陷

| # | 原缺陷（实测） | 现状 |
|---|---|---|
| 1 | `report` 报数虚高（真值 pending=1 报成「未派 2」，把 excused 算进未派） | pending 只数 planned |
| 2 | `plan a b a` 造出幽灵单元，在途归零后**永久无法收口** | 重复单元 `rc=2` 且不写账 |
| 3 | 残留锁（进程被 kill）→ `status` 耗时 11s、`rc=4`，**角色永久瘫痪** | 锁写 pid+ts，死 pid/超 10s 自动接管；等待上限 3s，超时 fail-open |
| 4 | 行内时间只有 `HHMMSS`（无法跨天）；过期判据用文件 mtime | 行内时间改 ISO；过期按行内时间（`MAX_SUBAGENTS_LEDGER_TTL_HOURS=24`） |
| 5 | 子代理内部的派发会**销掉父账** | 命中 subagent 上下文时不写账 |
| 6 | 工具白名单与 gate 分叉（`subagent` 一边认一边不认） | 统一走 max-subagents `policy.SPAWN_RE` |
| 7 | 一次 workflow 派 n 个子代理只销 1 行账 | 按 `tool_input` 推断派发数，一次销 n 行（上限 64） |

## 依赖与失败姿态

- 依赖 `max-subagents` 仓库（绝对路径常量，见脚本头部注释）。
- **fail-open**：内核不可用或返回意外码时，`check` 强制 `rc=0`（绝不卡住 agent），其它命令 stderr 报错后 `rc=0`。

## 自测与回滚

```bash
bash scripts/test-dispatch-ledger.sh     # 10 条自测（含锁接管 / 子代理不销账 / 旧账本可读 / 非治理角色静默）
cp scripts/dispatch-ledger.sh.orig-20261027 scripts/dispatch-ledger.sh   # 一键回滚
```

## 参考

- 台账范式与完整 CLI：`/home/panxiaoyong/pxy/projects26h2/max-subagents/docs/ledger.md`
- 设计与 7 缺陷取证：`/home/panxiaoyong/pxy/projects26h2/max-subagents/docs/ledger-design.md`
