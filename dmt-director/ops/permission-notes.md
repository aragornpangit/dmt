# 权限档位与 auto 复核：事故实证与逃生舱（`OPS.md` §1 按需引用）

## 档位复验（第六十三次）

`agent_status` 就绪 ≠ 自动档。2026-11-03 bcr-nh 实测三个常驻 pane 全落 `default` 档，当日 33 次工具栏 `ASK`；表象却是「脚本超时 / 命令失败」（另一 pane 标题写着 `file-claim.sh 审批超时`），而脚本本体 57ms 正常 —— **根因在权限层，现象在命令层**。

- **判据读 argv，不读屏幕**：`dmt_pane_auto_mode <pane>` 逐 token 判（`--permission-mode auto` / `--dangerously-skip-permissions` / `--yolo` / `--approve` / `--auto` / `-a never` / `--ask-for-approval never`）；**子串匹配会把 `--autocompact auto` 误判**，故逐 token。rc=0 自动 / 1 非自动 / 2 拿不到 argv。
- **接线**：`setup-team.sh` / `spawn-helper.sh` 在「就绪 + 输技能」后调 `verify_auto_mode`；rc=1 打 `WARN` + 打印 argv，rc=2 只 `INFO`。
- **修正**：非自动档 ⇒ `setup-team.sh --force-start`（或重开 pane）。

## auto 复核（`autoModeClassifier`）已知坑与现行配置

auto 模式下每个**需审批**的工具调用过一次自动复核（prompt 为整段会话上下文，默认 **90s 硬上限**）；企业网关抖动 / 限流时以 `no verdict ... failure=timeout` 收场、命令被判失败，表象像「脚本坏了」（2026-11-03 实测一次 `file-claim.sh check`，脚本本体 57ms 正常）。

现行加固四条（第六十 / 六十一次）：① `lib-dmt.sh` 的 `dmt_harness_cmd()` 为 codebuddy 前置 `CODEBUDDY_AUTO_REVIEW_TIMEOUT_MS=300000`（用户级 `~/.codebuddy/settings.json` 的 `env` 块同键兜底，覆盖手动启动会话）；② 复核器优先走本地模型（端点见 `.env` 的 `DMT_LOCAL_MODEL_HOST` / `DMT_LOCAL_MODEL_PORT`，模型 id `DMT_AUTO_REVIEW_LOCAL_MODEL`）；③ **健康门 `auto-review-model.sh`**（随 harness 启动自动跑）：探活本地端点，可达 ⇒ 钉本地、不可达 ⇒ 摘钉回退 cbc 内置链路 —— **钉了模型就禁用内置 fallback，故这道门不能省**；`DMT_AUTO_REVIEW_GATE=off` 整门关闭；④ 用户级 `permissions.allow` 覆盖 `dmt-director/scripts/` 下全部脚本（规则只认 `Bash(<前缀>:*)`；**含 `*` 通配的规则在 auto 模式下被判危险而整条忽略**；含重定向的命令不套规则）。

**健康门只在启动时跑**：端点会话中途挂掉，现役会话需重开 pane。
