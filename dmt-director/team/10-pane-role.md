# §10 pane 角色公共动作（`director` / `devm` / `anam` 三份 pane 技能共用；个性差异在各技能一行里给）

> 三份 pane 技能（`dmt-director` / `dmt-dm` / `dmt-am`）的**身份与 pane、通信、helper、文件占用**四条完全同构，只差角色名 / 方向码 / 上下级；本文件写共性，各技能只写「本角色差异」一行。

## 身份与 pane（细节见 `OPS.md` §1）

- **身份＝pane label**：角色名＝自己的 pane label，全 workspace 唯一；**不按 tab 位置识别、不记 pane id**（重启即变）。启动自检：`herdr pane get "$HERDR_PANE_ID"` 的 label 不符 ⇒ `pane rename` 自愈。
- **不自建 tab / pane**（唯一例外：全队共享 `helper` tab 不存在时建）；`director` 除外（它建 `devm` / `anam` pane，见其技能）。
- **技能调用行按 harness 生成**（`team.md` §1.2）：claude / codebuddy / codex / opencode 为 `/<技能名>`，**pi 为 `/skill:<技能名>`**；一律经 `lib-dmt.sh` 的 `dmt_skill_cmd`，**不要手敲前缀**（写错在前述 harness 上静默失效）。

## 通信（全文见 `OPS.md` §2）

**正文写文件，herdr 只发门铃**：用 `bash dmt-director/scripts/send-msg.sh <收件角色> <自己> <slug> <正文文件>` 发；收件读 `inbox/<自己>/` → `msg-take.sh` 认领（移到 `.doing/`）→ 读入 → **不回执** → `msg-done.sh` 删除。**只与直属上下级通信**；跨部门经 `director` 转派。**按 pane label 定位伙伴**（不用 tab 位置、不记 pane id）；label 不符 ⇒ **停下问用户**，不猜 pane id。

## helper 分身（细节见 `OPS.md` §1）

**唯一开法判据**＝本体 pane `agent_status == working` 且有待办超过 10 分钟未处理；`bash dmt-director/scripts/spawn-helper.sh <角色> "<任务>"`（**一次性下发**）、`close-helper.sh` 回收。helper 是纯分身：**无自己的 inbox、不走门铃**，成果由 `helper-report.sh` 单向写回 `inbox/<本体>/`。**独占动作不移交 helper**（硬件设备写操作、merge / push 归本体）。

## 编辑前检查占用（硬规则；细则见 `OPS.md` §3）

编辑任何文件前先 `bash dmt-director/scripts/file-claim.sh check <path> <owner>`，占用到手才改，改完 `release`；`rc=3`（他人占用）⇒ 停手（等释放 / 换文件 / 回报上级），**不得绕过、不得删别人的锁**。TTL 30 分钟、worktree 不豁免。

## 结尾收工

**完成即报**：本批收口（或阻塞 / 超时 / 需裁决）**立即**向直属上级回报（收件箱正文 + 门铃），不静默挂着。**回报必带**：目标 / 结论一句话、产物路径、证据来源、未决项。
