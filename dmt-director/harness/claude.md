# harness 差异：claude（Claude Code）

> 共性见 [`COMMON.md`](COMMON.md)；机器可读事实单一来源 [`../harness_matrix.yaml`](../../dmt-director/harness_matrix.yaml)。

## 1. 技能发现目录

| 级别 | 目录 |
|---|---|
| 项目级 | `.claude/skills/` |
| 用户级 | `~/.claude/skills/` |

**不读** `.agents/skills/`（2026-11-04 逐 harness 探针实测；项目级软链会被正确跟随，不必复制）。
注意 `opencode` **也读** `.claude/skills/` ⇒ 同一落点被两个 harness 共用。

## 2. 启动与权限

`claude --permission-mode auto`；自动档判据读 argv（`--permission-mode auto`；`--dangerously-skip-permissions` 亦被判据识别，见 `dmt_pane_auto_mode`）。

**两点与 codebuddy 不同**（2026-11-05 claude 侧实测更正）：

1. **没有本地复核器** —— codebuddy 那套（`auto-review-model.sh` 健康门 ＋ 300s 预算 ＋ `permissions.allow` 白名单）claude **不适用**（无 `autoModeClassifier` 端点概念）。
2. **`auto` 档依赖远程 classifier，会限流** —— 实测一轮 122 次 Bash 有 9 次被 `… temporarily unavailable (rate-limited)` 直接拒掉（表现为命令失败，错因在权限层）。若被此困扰：改用 `--dangerously-skip-permissions`（yolo 档，跳过 classifier；`dmt_pane_auto_mode` 仍判 rc=0），或接受偶发重试。
3. 另：若用户级 `~/.claude/settings.json` 设了 `permissions.defaultMode`，则 argv 可能**不带**档位参数，而权限实为 auto —— 此时 `dmt_pane_auto_mode` 读 argv 会给出 rc=2/1（拿不到或判非自动），属**已知误报面**，应人工确认后放行。

## 3. 技能调用行

`/<技能名>`，例如 `/dmt-dm`。

## 4. 技能如何到达模型

- 与 codebuddy 同路径：技能进清单、可斜杠调用；`/<name>` 无法调起时改读技能文件路径。
- 子代理：按 harness 自身的子代理机制承载，派发模板见 [`../team/07b-dispatch.md`](../team/07b-dispatch.md)。

## 5. 强制技能

`/<name>`（如 `/code-review`）。

## 6. 特有约束

- 并发上限 10；环境变量 `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`（另含 `CLAUDE_CODE_MAX_SUBAGENTS_PER_SESSION`）—— 实测 claude 二进制含这两个键，已填入矩阵 `max_subagents_env`。
- `cbc-herdr` **不需要**（herdr 原生识别 claude）。
- **用户级与项目级重复安装**：用户级 `~/.claude/skills/dmt-*` 与项目级 `.claude/skills/dmt-*` 同时存在时，非 dmt 项目也会命中用户级副本（版本可能落后）⇒ 建议只保留项目级，或确保用户级为软链到仓。
