# 五 harness × dmt 测试报告（2026-11-06）

> **范围**：dmt 七角色技能在 **pi / codebuddy(cbc) / claude / codex / opencode** 五个 harness 上的
> 「技能发现 → 装载 → 强制技能调用 → 子代理承载 → pane 通信（门铃）」全链路实测。
> **判据**：每项都要有**可复跑的证据**（脚本输出 / session 文件解析 / 产物路径），不接受模型自述。
> **English summary**：[`2026-11-06-harness-test-report.en.md`](2026-11-06-harness-test-report.en.md)（同一批结论的英文版，供 GitHub 读者）。
> **配套**：缺陷与改善见 [`../../dmt-director/harness/BACKLOG.md`](../../dmt-director/harness/BACKLOG.md)；
> 逐 harness 差异规则见 [`../../dmt-director/harness/`](../../dmt-director/harness/README.md)。

## 0. 测试方法（五者统一，便于横比）

| 项 | 做法 |
|---|---|
| 项目 | 每个 harness 一个 `/tmp/dmt-<harness>-lab`，`install-skills.sh --harness <h>` 安装，机检须 `ALL_PASS` |
| pane | **契约名** `director` / `devm` / `anam`（同时验证 `dmt_pane_by_label` 精确寻址） |
| 启动 | 各 harness 的 yolo/自动档（见下表） |
| 装载 | `herdr agent prompt <pane> /dmt-<角色>`（pi 为 `/skill:`） |
| 测试 | T1 装载 / T2 `to-spec`+`to-tickets` / T3 `implement`→`tdd`→`code-review` / T4 `research`+并行子代理 / T5 门铃 |
| 取证 | pane 屏幕 + 各 harness 的会话文件（`~/.claude/projects`、`~/.codebuddy/projects`、`~/.local/share/opencode/opencode.db`、`~/.codex/sessions`、`~/.pi/agent/sessions`） |
| 回收 | 测毕关 pane（workspace 随最后一个 pane 自动销毁） |

## 1. 总览

| | pi | cbc | claude | codex | opencode |
|---|---|---|---|---|---|
| 版本 | pi-coding-agent 1.5.0 | 2.180.0 | 2.1.318 | 0.166.0 | 2.2.5 |
| 启动档 | `--approve` | `-y` | `--dangerously-skip-permissions` | `-a never`（＋**必须** `--sandbox danger-full-access`） | `--auto` |
| T1 装载 | ✅ | ✅ | ✅ | ✅ | ✅ |
| T2 SPEC+工单 | ✅ | ✅ | ✅ | ✅ | ✅ |
| T3 实施链 | ✅ | ✅ | ✅ | ⚠️ | ✅ |
| T4 取证+子代理 | ✅ | ✅ | ✅ | ⚠️ | ✅ |
| T5 门铃 | ✅ | ✅ | ✅ | ⚠️→✅ | ✅ |
| Skill 工具 | ❌ | ✅ | ✅ | ❌ | ✅ |
| 子代理承载 | `delegate` ＋agent 白名单 | `Agent` | `Agent` | `spawn_agent`（**载荷丢失**） | `subagent` |

## 2. 逐 harness 明细

### 2.1 pi（降级承载，已用 agent 定义补齐）

- **现象**：无 Skill 工具；`delegate` 子代理 `inheritSkills: false`（实测 system prompt 无 `<available_skills>`），只能读 `SKILL.md`。
- **实测**：T1–T5 全通过（`pane` 侧 `/skill:dmt-*`；子代理侧按 prompt 给绝对路径读技能）。
- **关键实测（第八十二次）**：自定义 agent 三档粒度 —— `delegate` 无清单 / `inheritSkills:false + skills:[dmt-pde]` 只见 `dmt-pde` / `inheritSkills:true` 为全量。
- **落地**：`harness/pi-agents/` 四份 agent 定义（白名单）＋ `pi --skill <目录>` / `--approve` 两条装载通路。
- **遗留**：`tdd`/`code-review` 同名技能重复注册；矩阵并发上限为空。

### 2.2 codebuddy（cbc）

- **实测**：T1–T5 全通过；`implement` 虽带 `disable-model-invocation: true`，cbc 下 `Skill` 工具仍能调起；`pytest` 复跑一致。
- **注意**：`-y` 与 `--permission-mode auto` 是**两种自动档** —— 前者跳过复核器但 HIGH/CRITICAL 仍询问；后者每次工具调用过复核器（有 300s 预算 + 健康门配套）。
- **遗留**：子代理权限继承 —— `--subagent-permission-mode` 未用上（子代理可能回到 default 档）。

### 2.3 claude

- **实测**：T1–T5 全通过；`Skill` 工具调用 4~6 次/角色（`to-spec`/`to-tickets`/`implement`/`tdd`/`code-review`/`research`），`Agent` 子代理 4 个；`pytest` 11 passed（引述报告）与本次 1~2 passed 均一致。
- **注意**：`auto` 档依赖远程 classifier，实测 122 次 Bash 中 9 次被 rate-limited 直接拒（错因在权限层、现象像命令失败）；yolo 档无此问题。
- **遗留**：用户级 `~/.claude/skills/dmt-*` 与项目级重复安装（非 dmt 项目也会命中旧副本）。

### 2.4 codex（唯一需要改沙箱的 harness）

- **实测**：T1 ✅ / T2 ✅（SPEC 36 行 + 2 工单）/ T3 ⚠️（产物齐、`pytest` 2 passed，`code-review` 无结论）/ T4 ⚠️（落盘 41 行，子代理载荷丢失）/ T5 ❌→✅。
- **缺陷 1（沙箱）**：默认 `workspace-write` 下 `herdr pane list` → `PermissionDenied: Operation not permitted` ⇒ 门铃/身份/file-claim 全废。`--sandbox danger-full-access` 下门铃送达并被告认领收口。
- **缺陷 2（陈旧环境）**：codex 进程 `environ` 正确，但 `exec_command`（`bash -lc`）里 `HERDR_*` 指向已废弃 session（`w1`/`bcr-nihui`），前置 `env` 覆盖无效 ⇒ `lib-dmt.sh: dmt_herdr_env_fix` 兜底。
- **缺陷 3（子代理）**：`spawn_agent` 被真实调用（1/2/2 次）但载荷不送达；**Full Access 下复测同样失败**（子代理收到空任务、自行去读技能）⇒ codex 自身缺陷，定级 `[SUBAGENT_UNAVAILABLE]`。

### 2.5 opencode

- **实测**：T1–T5 全通过（`skill` 工具 1/4/2 次；`subagent` 2 个；`pytest` 2 passed）。
- **注意**：`/to-spec`、`/to-tickets` **不在斜杠命令清单**，但 `skill` 工具可按 id 加载（含 `disable-model-invocation` 者）⇒ 规则改为「skill 工具优先，不可用再直读文件」。
- **注意**：启动初期输入未就绪（首次 `agent prompt` 只填入不提交），需复核/补 `enter`。
- **遗留**：并发上限未声明。

## 3. 横向结论

1. **原生承载 vs 降级承载**：claude / cbc / opencode 有 Skill 工具，子代理能继承技能；pi / codex 没有 Skill 工具，pi 已用 agent 白名单补齐，codex 的子代理有自身缺陷。
2. **pane 通信是共同底线**：五个 harness 的 `herdr agent prompt` 都可用，但 codex 默认沙箱例外 —— 这是唯一必须改启动参数的 harness。
3. **技能"能装载"≠"能工作"**：转发式技能（`grill-with-docs` / `grill-me` / `implement` / `tdd`）依赖 Skill 工具，pi 上必须降级为读文件；这一点在四个 harness 上都被实测命中过。

## 4. 可复跑命令

```bash
# 安装 + 机检（示例：pi）
bash dmt-director/scripts/install-skills.sh /tmp/lab --harness pi
DMT_SKILLS_DIR=/tmp/lab/.agents/skills bash /tmp/lab/dmt-director/scripts/check-dmt.sh /tmp/lab

# harness 判定（技能第 0 步）
bash dmt-director/scripts/harness-detect.sh --explain

# 门铃（在目标 pane 所在 cwd 执行；codex 需 danger-full-access）
cd /tmp/lab && bash dmt-director/scripts/send-msg.sh director devm probe /tmp/body.md
```
