# 评审基线（本地、离线、可审计）

`dmt-reviewer` 的规范基线以**本目录的本地副本**为准，评审时不再联网检索规范。原因：同一个
commit 在不同时间检索会得到不同结论（网络抖动、搜索排名漂移、把博客当标准），而验收结论必须
可复现。需要刷新时跑维护仓的 `scripts/fetch-style-baselines.sh`。

## 用法顺序

1. 先读 [`CHECKLIST.md`](CHECKLIST.md) —— 每语言「可机械判定的规则 → 对应工具」，几分钟扫完。
2. 工具不覆盖或结论有争议时，再读对应语言全文。
3. 项目自带规范 / lint 配置**优先于**本目录；冲突以项目为准，偏差写进评审结论。

## 基线清单

| 语言 | 文件 | 上游来源 | 许可证 | 获取日期 |
|---|---|---|---|---|
| Python | [`python.md`](python.md) | PEP 8 – Style Guide for Python Code（peps.python.org/pep-0008） | Public domain（PSF） | 2026-11-16 |
| Java | [`java.md`](java.md) | Google Java Style Guide（google/styleguide） | CC BY 3.0 Unported（Google LLC） | 2026-11-16 |
| JavaScript | [`javascript.md`](javascript.md) | Airbnb JavaScript Style Guide | MIT（Airbnb） | 2026-11-16 |
| TypeScript | [`typescript.md`](typescript.md) | Google TypeScript Style Guide（google/styleguide） | CC BY 3.0 Unported（Google LLC） | 2026-11-16 |
| C++ | [`cpp.md`](cpp.md) | Google C++ Style Guide（google/styleguide） | CC BY 3.0 Unported（Google LLC） | 2026-11-16 |

每个文件头部都写明来源 URL、获取日期与许可证；正文为上游原文的本地副本，只去除了 HTML 包装与
非 http(s) 链接（避免仓库内断链），**条文未改动**。上游更新后重新抓取即可。

## 选型说明

- **Python**：PEP 8 是官方风格定义；实际执行以项目 `ruff` / `mypy` 配置为准。
- **Java**：Google Java Style 是公开、可机检（checkstyle）的事实标准；若项目用 Alibaba P3C 或
  公司规范，以项目为准。
- **JavaScript**：Airbnb 是采用最广、且有官方 `eslint-config-airbnb` 的一份；Google JS Style
  可作替代基线，切换时同步改本表与 `CHECKLIST.md`。
- **TypeScript**：Google TS Style 是公开的官方风格指南（社区版，去除了 Google 内部章节）。
- **C++**：Google C++ Style 是公开事实标准；C++ Core Guidelines 覆盖面更广但不适合作为逐条
  评审基线，需要时单独取证。

## 语言不在清单内时

标 `[BASELINE_MISSING]`，按项目自带规范与 lint 配置执行，并在结论里写明局限；不凭记忆或联网
片段充当基线。新增语言时同时补 `CHECKLIST.md` 与维护仓的抓取脚本。

## 刷新

```bash
bash scripts/fetch-style-baselines.sh          # 维护仓执行，重新抓取五份
bash scripts/fetch-style-baselines.sh --check  # 只校验来源行与体积
```

抓取后跑 `bash dmt-dir/scripts/check-dmt.sh <项目根>`，A6h 会校验五份基线齐备且带来源信息。
