## 3. 目录职责

**落盘唯一位置（含负责人与对齐要求）**：

| 唯一目录 | 负责人 | 产物 | 对齐要求 |
|---|---|---|---|
| `docs/pd/prd/` | `pde{n}`（落笔）/ director（定稿） | 产品需求文档（PRD） | `{prd-seq}` 独立编号 |
| `docs/pd/spec/` | `pde{n}`（落笔）/ director（定稿） | 产品规格书（SPEC，含验收标准） | 与 ticket 共用 `spec-seq` |
| `docs/dev/tickets/` | `pde{n}`（落笔）/ director（票面编号与定稿）；devm 只在票面末尾追加「实施状态」一节 | 开发工单（ticket） | 与 SPEC 共用 `spec-seq` |
| `docs/analyst/` | anam | 市场调研与竞品逆向报告 | 无 |
| `docs/analyst/evidence/{research-seq}-{slug}/` | anam | 调研一手证据（采样产物／原始日志／manifest） | 与报告同号；须带 `manifest.txt`（文件名＋大小＋sha256＋采样命令） |
| `docs/human/human-arch/` | director | 人类架构文档 | 无 |
| `docs/human/human-plan/` | director | 人类计划文档 | 无 |
| `dmt-director/team.md`（正本；`install-skills.sh` 把 `team.md` 与 `OPS.md` 软链到 `docs/`，把 `ops/` 内的文件软链到 `docs/ops/`） | director | 团队契约（本文件；安装后入口为 `docs/team.md`） | 软链跟随正本（`--copy` 模式除外） |
| `docs/handoff/` | director / devm | 交接说明（`{director,devm}-{slug}-{YYMMDD-HHMM}-v{N}.md`；**抽查 / 复验结论亦可写此处**）；其余情形仅在用户要求时写 | 无 |
| `inbox/<收件角色>/` | 发送方写、收件方读后删 | 角色间消息（运行时通道，**不入库**，**在项目根目录、不在 `docs/` 下**） | 方向与 `{seq}` 见 [`dmt-director/ops/comms.md`](../ops/comms.md) |

1. 上述路径是**唯一允许位置**，不得写到 `docs/pd/`（除 `prd/`、`spec/`）、`docs/dev/`（除 `tickets/`）、`docs/human/`（除 `human-arch/`、`human-plan/`）、`docs/test/` 或其它任何位置；收件箱只在项目根 `inbox/` 下，不进 `docs/`；不得自建新的文档目录。
2. 各部门的产物目录**互不越界**：只读引用可以，移动/改名不可以。
3. **工程师与 `reviewer{n}` 不写 `docs/`**：回报走子代理返回值；证据由上级并入票面 / 报告。
4. 旧目录只保留历史，不再接收新产物；现行落盘口径见上表。
5. **目录初始化由 director 负责**：director 接手一个项目时先检查再补齐（见 §3.1），产物目录不由 anam / devm 自建。
6. 机检不校验单个文件路径；新产物靠本表和评审把关。

### 3.1 初始化（director 负责，幂等）

director 接手项目的**第一件事**：检查目录，缺什么建什么。可重复执行，已存在则不动：

```bash
bash dmt-director/scripts/init-project.sh <项目根>   # 省略参数＝当前目录
```

脚本做三件事：建六个产物目录 + 三个收件箱（`inbox/director/`、`inbox/devm/`、`inbox/anam/`）+ `locks/`；把 `inbox/*/`、`locks/`、`.codebuddy/` 写进 `.gitignore`（已存在则跳过）；跑机检直到 `ALL_PASS`。

- **完成判据**：机检输出 `ALL_PASS`。缺目录时脚本报 `FAIL 目录缺失`，director 补齐后重跑。
- **只建目录、不建产物**：空目录不预置占位文件，避免被误认为已有交付物。
- **`locks/` 是运行时通道**：文件占用登记见 [`dmt-director/ops/file-claim.md`](../ops/file-claim.md)，不入库。
- **anam / devm 不自建产物目录**：发现自己的目标目录缺失，回报 director（收件箱目录属运行时通道，可按需 `mkdir -p` 兜底）。
- 契约文件 `dmt-director/team.md` 与技能安装不在本步骤内（安装见 `README.md`）。
