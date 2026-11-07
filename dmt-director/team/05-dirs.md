## 3. 目录职责

**落盘唯一位置**：

| 唯一目录 | 负责人 | 产物 | 对齐 |
|---|---|---|---|
| `docs/pd/prd/` | `pde{n}` 落笔 / director 定稿 | PRD | `{prd-seq}` 独立编号 |
| `docs/pd/spec/` | `pde{n}` 落笔 / director 定稿 | SPEC（含验收标准） | 与 ticket 共用 `spec-seq` |
| `docs/dev/tickets/` | `devm` 落笔 / director 定稿；`devl{n}` 追加「实施状态」 | 开发工单 | 与 SPEC 共用 `spec-seq` |
| `docs/analyst/` | anam | 调研与竞品逆向报告 | — |
| `docs/analyst/evidence/{research-seq}-{slug}/` | anam | 一手证据（采样产物 / 原始日志 / manifest） | 与报告同号；须带 `manifest.txt`（文件名＋大小＋sha256＋采样命令） |
| `docs/human/human-arch/`、`docs/human/human-plan/` | director | 人类架构 / 计划文档 | — |
| `docs/handoff/` | director / devm | 交接说明 `{director,devm}-{slug}-{YYMMDD-HHMM}-v{N}.md`；抽查 / 复验结论亦可写此处 | 仅用户要求或留痕时写 |
| `inbox/<收件角色>/` | 发送方写、收件方读后删 | 角色间消息（运行时通道，不入库，在项目根不在 `docs/`） | 方向见 [`ops/comms.md`](../ops/comms.md) |
| `dmt-director/team.md`（正本，安装后入口 `docs/team.md`） | director | 团队契约 | 软链跟随正本（`--copy` 除外） |

1. 上述是**唯一允许位置**：不得写到 `docs/pd/`（除 `prd/`、`spec/`）、`docs/dev/`（除 `tickets/`）、`docs/human/`（除 `human-arch/`、`human-plan/`）、`docs/test/` 或其它任何位置；不得自建新文档目录。
2. 各部门产物目录互不越界：只读引用可以，移动 / 改名不可以。
3. **工程师与 `reviewer{n}` 不写 `docs/`**：回报走子代理返回值，证据由上级并入票面 / 报告。
4. 旧目录只保留历史，不再接收新产物。
5. **目录初始化归 director**：接手项目先检查再补齐（§3.1），产物目录不由 anam / devm 自建。
6. 机检不校验单个文件路径，新产物靠本表与评审把关。

### 3.1 初始化（director 负责，幂等）

```bash
bash dmt-director/scripts/init-project.sh <项目根>   # 省略参数＝当前目录
```

脚本做三件事：建六个产物目录 + 五个收件箱（`director` / `devm` / `anam` / `devl1` / `devl2`）+ `locks/`；把 `inbox/*/`、`locks/`、`.codebuddy/` 写进 `.gitignore`（已存在则跳过）；跑机检到 `ALL_PASS`。

- **完成判据**：机检 `ALL_PASS`。缺目录时脚本报 `FAIL 目录缺失`，补齐后重跑。
- **只建目录、不建产物**：空目录不预置占位文件。
- `locks/` 是运行时通道，见 [`ops/file-claim.md`](../ops/file-claim.md)，不入库。
- **anam / devm 不自建产物目录**：缺目录回报 director（收件箱可按需 `mkdir -p` 兜底）。
- 契约文件与技能安装不在本步骤内（见 `README.md`）。
