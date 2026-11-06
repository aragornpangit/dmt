## 7. 机检

**单一入口**（P5：结构 + 内容两组合并，一处运行）：

```bash
bash dmt-director/scripts/check-dmt.sh <项目根>
```

维护 dmt 仓自身时，技能正本位于仓根而非 `.agents/skills`：

```bash
DMT_SKILLS_DIR="$PWD" bash dmt-director/scripts/check-dmt.sh "$PWD"
```

两组断言，事实都来自**单一来源**（P1：不再散落中文 grep）：

- **A. 结构断言** —— 读 `dmt-director/dmt_contract.yaml`（技能清单 / 版本源 / 产物目录 / 组织 / 脚本清单 / 已废止脚本）与 `dmt-director/harness_matrix.yaml`（五 harness 矩阵）。校验：A1 版本同号、A2 七技能就位、A3 产物 / 运行时目录、A4 脚本齐备 + 已废止脚本不回潮、A5 矩阵完整、A6 单一来源纪律（每份技能指针到 team.md）、A6b 按 harness 加载（`harness/` 文件齐备 ＋ 与矩阵 key 一致 ＋ 七技能含第 0 步 ＋ `harness-detect.sh` 五 harness 自测与 unknown rc=1）、**A6c** pi agent 白名单可注入性（`skills:` 里出现带 `disable-model-invocation` 的技能即 FAIL）、**A6d** 仓级脚本登记（`repo_scripts` 与仓根 `scripts/` 双向一致）、**A7** 文档相对链接可达（严格按文件所在目录解析，不回退仓根）。
- **B. 内容断言** —— 读 `dmt_contract.yaml` 的 `content_assertions` 表（`组 → 文件 → require / forbid`）。优先用结构断言，只在无法结构化时才用短字符串。

**改以下任一项后必须重跑**：路径规范、pane 生命周期、并行口径、角色层级、写权限、强制技能、文件占用、评审门禁、通用技能、技能链接、收件箱三态、派发 prompt 文件写入纪律、pi agent 名承载、脚本接口、**harness 差异 / 技能加载入口（`harness/` ＋ `harness-detect.sh`）**。

**维护**：技能、组织、脚本改 `dmt_contract.yaml`；纪律改对应 `team/*.md`，只在必要时同步短断言。
