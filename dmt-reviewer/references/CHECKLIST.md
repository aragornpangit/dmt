# 评审快速清单（按主语言取对应段）

每行格式：**规则 → 可执行判据**。能用工具判定的以工具退出码为准；工具不覆盖的才人工看。
项目自带规范与 lint 配置优先于本清单，冲突以项目为准并把偏差写进结论。

## Python（PEP 8；执行以 ruff / mypy 配置为准）

- 4 空格缩进、不用 tab；续行对齐或悬挂缩进 → `ruff` W191 / E101
- 行宽按 PEP 8 79 或项目配置 → `ruff` E501
- import 分组与排序 → `ruff` I001（isort）
- 命名：模块/函数 `snake_case`，类 `PascalCase`，常量 `UPPER_CASE` → `ruff` N801-N806（pep8-naming）
- `is None` / `is True`，不用 `==` → `ruff` E711 / E712
- 无未使用 import / 变量 → `ruff` F401 / F841
- 不用裸 `except:` → `ruff` E722
- 禁用可变默认参数 → `ruff` B006（bugbear）
- 类型注解可验证 → `mypy` / `pyright`

## Java（Google Java Style；执行以 checkstyle 配置为准）

- 缩进 2 空格（Google）、行宽 100 → `checkstyle` Indentation / LineLength
- 大括号 K&R 位置 → `checkstyle` LeftCurly / RightCurly
- 不用通配 import、无未使用 import → `checkstyle` AvoidStarImport / UnusedImports
- 命名 `UpperCamel` 类 / `lowerCamel` 方法 / `CONSTANT_CASE` 常量 → `checkstyle` TypeName / MethodName / ConstantName
- 公开 API 有 Javadoc（按项目要求） → `checkstyle` JavadocMethod
- 编译告警与静态缺陷 → `javac -Xlint:all` / `spotbugs`

## JavaScript（Airbnb；执行以 eslint 配置为准）

- 2 空格缩进、单引号、分号必写 → `eslint` indent / quotes / semi
- 只用 `const` / `let`，禁 `var` → `eslint` no-var / prefer-const
- 严格相等 → `eslint` eqeqeq
- 无未使用变量 → `eslint` no-unused-vars
- 对象浅拷贝用展开 → `eslint` prefer-object-spread
- 数组回调显式 return → `eslint` array-callback-return / arrow-body-style
- 命令 → `npx eslint .`

## TypeScript（Google TS Style；执行以 tsc + typescript-eslint 为准）

- 不用 `any`（项目显式允许处除外） → `@typescript-eslint/no-explicit-any`
- 公开 API 有显式返回类型 → `explicit-module-boundary-types`
- 禁用 `// @ts-ignore`；抑制必须用 `@ts-expect-error` 且写原因 → `ban-ts-comment`
- 命名：类型 `UpperCamel`，变量/函数 `lowerCamel`，常量 `CONSTANT_CASE`
- 命令 → `npx tsc --noEmit`，再 `npx eslint .`

## C++（Google C++ Style；执行以 clang-format / clang-tidy 为准）

- 每行 80 列、缩进与括号风格按项目 `.clang-format` → `clang-format --dry-run --Werror`
- 命名：类型 `UpperCamel`，变量 `snake_case`，成员尾下划线（按项目）
- 头文件中禁用 `using namespace`
- 用 `nullptr`、能 `const` 就 `const`；`auto` 只用于类型显而易见处
- 编译告警 → `-Wall -Wextra`；静态检查 → `clang-tidy`

## 通用

- 先跑 `dmt-dir/scripts/review-gate.sh`，拿到逐段退出码；它判 FAIL 的段不再人工复核。
- 静态门（类型检查 / lint）任一 FAIL ⇒ 直接判 FAIL 退回，不进入功能验收。
- 不为了过门改 lint / 类型检查配置，不加 `# type: ignore` / `eslint-disable` / `@ts-ignore`。
- 规范基线版本见 [`README.md`](README.md)；基线缺失标 `[BASELINE_MISSING]`，不联网猜。
- 联网只用于确认工具用法或上游版本，须记 URL + 访问日期，且不得作为实现证据。
