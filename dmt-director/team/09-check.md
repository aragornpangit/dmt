## 7. 机检

**单一入口**（P5：结构 + 内容两组合并，一处运行）：

```bash
bash dmt-director/scripts/check-dmt.sh <项目根>
```

两组断言，事实都来自**单一来源**（P1：不再散落中文 grep）：

- **A. 结构断言** —— 读 `dmt-director/dmt_contract.yaml`（技能清单 / 版本源 / 产物目录 / 组织 / 脚本清单 / 已废止脚本）与 `dmt-director/harness_matrix.yaml`（五 harness 矩阵）。校验：A1 版本同号、A2 七技能就位、A3 产物 / 运行时目录、A4 脚本齐备 + 已废止脚本不回潮、A5 矩阵完整、A6 单一来源纪律（每份技能指针到 team.md）。
- **B. 内容断言** —— 读 `dmt_contract.yaml` 的 `content_assertions` 表（`组 → 文件 → require / forbid`）。加 / 改内容断言**只改 YAML**，不改脚本。

**改以下任一项后必须重跑**：路径规范、pane 生命周期、并行口径、角色层级、写权限、强制技能、文件占用、评审门禁、通用技能、技能链接、收件箱三态、派发 prompt 文件写入纪律、pi agent 名承载、脚本接口。

**维护**：新增 / 改名 / 退役技能、改组织、加脚本 → 改 `dmt_contract.yaml`（或 `harness_matrix.yaml`）；改某条纪律的落地位置 → 改对应 `team/*.md` 并同步 `content_assertions`。
