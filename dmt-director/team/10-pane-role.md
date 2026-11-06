# §10 pane 角色公共动作（`director` / `devm` / `anam` / `devl{n}` 四份 pane 技能共用；个性差异在各技能一行里给）

> 四份 pane 技能（`dmt-director` / `dmt-dm` / `dmt-am` / `dmt-devl`）的**身份与 pane、通信、helper、文件占用**四条同构，只差角色名 / 方向码 / 上下级；本文件写共性，各技能只写「本角色差异」一行。

## 身份与 pane（细节见 [`dmt-director/ops/runtime.md`](../ops/runtime.md)）

- **身份＝pane label**：角色名＝自己的 pane label，全 workspace 唯一；**不按 tab 位置识别、不记 pane id**（重启即变）。启动自检：`herdr pane get "$HERDR_PANE_ID"` 的 label 不符 ⇒ `pane rename` 自愈。
- **不自建 tab / pane**（唯一例外：全队共享 `helper` tab 不存在时建）；`director` 除外（它建 `devm` / `anam` pane，见其技能）；**`devm` 例外**：可在自己的 `dmt-dev` tab 内创建、改名、关闭 `devl{n}` pane，**不得建 tab，不得动其他 tab 的 pane**。
- **`dmt-devl` 不设 helper**：队长直接派子代理，不建 `devl-helper` pane。
- **技能调用行按 harness 生成**（`team.md` §1.2）：claude / codebuddy / codex / opencode 为 `/<技能名>`，**pi 为 `/skill:<技能名>`**；一律经 `lib-dmt.sh` 的 `dmt_skill_cmd`，**不要手敲前缀**（写错在前述 harness 上静默失效）。

## 通信 / helper / 占用

分别见 [`dmt-director/ops/comms.md`](../ops/comms.md)、[`dmt-director/ops/helper.md`](../ops/helper.md)、[`dmt-director/ops/file-claim.md`](../ops/file-claim.md)。本页不再复述操作步骤。

## 结尾收工

**完成即报**：本批收口（或阻塞 / 超时 / 需裁决）**立即**向直属上级回报（收件箱正文 + 门铃），不静默挂着。**回报必带**：目标 / 结论一句话、产物路径、证据来源、未决项。
