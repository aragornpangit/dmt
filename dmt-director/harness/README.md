# 可选 harness 适配器

实际使用某个平台时读取 [`COMMON.md`](COMMON.md) 与对应一份差异文档：

- [`pi.md`](pi.md)
- [`codebuddy.md`](codebuddy.md)
- [`claude.md`](claude.md)
- [`codex.md`](codex.md)
- [`opencode.md`](opencode.md)

技能目录、调用前缀、启动命令和并发能力以 [`../harness_matrix.yaml`](../harness_matrix.yaml) 为唯一机器事实。pi 的命名子代理模板在 [`pi-agents/`](pi-agents/README.md)。

`BACKLOG.md` 与 `logs/` 是维护资料，不进入角色加载路径。单纯调用角色技能不检测 harness，也不读取本目录。
