# harness 差异：hermes

共性见 [`COMMON.md`](COMMON.md)，机器事实见 [`../harness_matrix.yaml`](../harness_matrix.yaml)。

## 技能与权限

- 用户级技能目录为 `~/.hermes/skills/`；项目级可用 `.hermes/skills/` 与 `.agents/skills/`，但只在 `skills.trusted_project_dirs` 内加载。首次使用项目技能先 `hermes skills trust`（或把项目根写入该配置）。
- **用户级铺法（全局可用，免逐项目 trust）**：把已有的 `~/.agents/skills/dmt-*` 软链进 `~/.hermes/skills/`：
  ```bash
  for d in ~/.agents/skills/dmt-*; do ln -sfn "$d" ~/.hermes/skills/"$(basename "$d")"; done
  ```
  验证：任意目录执行 `hermes skills list | grep dmt-` 应看到 7 个（`Source=local`）。软链指向 `~/.agents/skills` 的整目录软链，最终解析到技能仓，改仓即生效，不必重装。项目级落点仍按 `install-skills.sh` 铺设，两者不冲突（同名时项目级优先）。
- **第三方技能同样要铺到 `~/.hermes/skills`**：`~/.hermes/skills` 就是矩阵里 hermes 的 `skills.dir_user`，所以 `bash scripts/install-third-party-skills.sh` 会自动覆盖它（10 个技能，幂等；`--check` 校验可读性与 explicit-only 解锁）。漏铺的后果是 `dmt-de` 在 hermes 里拿不到 `tdd` / `implement` / `code-review`，只能标 `[SKILL_UNAVAILABLE]` 降级。
- 技能调用为 `/<技能名>`；`hermes skills list` 查看已安装技能，`hermes chat -s <技能名>` 可在启动时预加载。
- 启动命令 `hermes chat --yolo` 是 yolo（免逐次审批）档，与其余 harness 一致；需要收窄时用 `DMT_HARNESS_CMD` 显式覆盖并说明原因。`--yolo` 不替代 `hermes skills trust`：项目技能仍需先信任才加载。
- 项目技能被信任后，`.agents/skills` 与 codex/opencode/pi 共用，不需要重复铺设。
- **技能落点必须是整目录软链，不能是「真实目录 + 指向目录外的软链」**：hermes 对每个项目 `SKILL.md` 的父目录跑 `skills_guard` 扫描，目录内任何指向目录外的软链都判 `symlink_escape`（critical/traversal），整个技能被隔离 —— 不进技能索引、不进斜杠命令。症状是启动横幅仍报「N project skill(s)」但 `/<技能>` 补全少一个。`install-skills.sh` 已按此铺设（link 模式整目录软链；copy 模式按 `CORE_ITEMS` 复制实体文件）。
- 扫描结论按内容摘要缓存在 `~/.hermes/cache/project_skill_scans`（跨项目共享，与路径无关）。同一内容即使换了目录布局也会复用旧结论，排查时先删该缓存再复测。

## 子代理

- 原生子代理工具为 `delegate_task`（`goal` / `context` / `tasks`），并发上限读 `delegation.max_concurrent_children`（默认 10）。
- `delegate_task` 没有技能参数；派发时在 `context` 中给出角色 `SKILL.md` 绝对路径，由子代理 `read`，与 `subagent_skill: read` 一致。
- 子代理只向派发者回报；不可用时报告能力缺口，不用嵌套进程伪造团队。

## 门铃与首轮 prompt

- 首轮 prompt 可用 `hermes chat -q '<text>'` 注入；dmt pane 启动不假定首轮 prompt，按 `first_prompt: false` 先启动、就绪后再发 `/dmt-*` 技能命令。
- herdr 门铃优先走 `herdr agent prompt`；herdr 不认识该 agent 时退回 `pane send-text` + `pane send-keys enter`，发送后按 [`../team/03-comms.md`](../team/03-comms.md) 的三步复核。
