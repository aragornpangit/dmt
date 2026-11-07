# 结构检查

单一入口：

```bash
bash dmt-director/scripts/check-dmt.sh <项目根>
bash dmt-director/scripts/check-dmt.sh --verbose <项目根>  # 显示每个 OK 项
```

维护本仓时：

```bash
DMT_SKILLS_DIR="$PWD" bash dmt-director/scripts/check-dmt.sh "$PWD"
```

检查内容由 `dmt_contract.yaml` 与 `harness_matrix.yaml` 驱动，包括 frontmatter、版本、声明文件、脚本、技能预算、harness 键集合和严格相对链接。通用项目不强制 DMT 专属目录；显式声明的目录或适配器才检查。

默认只输出失败与最终摘要，避免把机检结果大量注入模型上下文。相对链接必须从源文件目录解析，不通过删除 `../` 或猜测其他根目录兜底。

修改公开技能、脚本接口、契约、平台矩阵或文档链接后运行检查。内容是否正确由评审和测试验证，不用固定中文句子代替行为断言。
