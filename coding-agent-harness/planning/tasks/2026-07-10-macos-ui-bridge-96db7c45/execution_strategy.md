# 执行策略

## 协作决定

- 主执行者：当前 Agent coordinator。
- reviewer：自审；Harness 默认只读 reviewer 可用，但当前不启用以节省额度。
- worker subagent：未授权且当前不需要。
- 模式：same checkout、串行小提交、commit-backed handoff。
- 证据深度：核心单测 L1；HTTP/MCP 集成 L2；真实应用冒烟 L2/L3。

## 接力规则

任何 Agent 接手时必须：

1. 运行 `git status --short` 和 `git log --oneline -8`。
2. 阅读 `brief.md`、`task_plan.md`、`progress.md`、`findings.md`。
3. 若工作区有未提交内容，先判断归属并验证，不能覆盖。
4. 从 `progress.md` 最后的“下一步”选择一个提交切片。
5. 停止前更新进度并提交；无法提交则记录具体原因、Owner 和恢复命令。

## 证据计划

| 层级 | 检查 | 记录 |
| --- | --- | --- |
| L0 | Harness check、格式和静态检查 | `progress.md` |
| L1 | `swift build`、`swift test` | `progress.md` |
| L2 | HTTP/MCP 端到端与测试 App | `artifacts/INDEX.md` |
| L3 | TextEdit/Finder/企业微信/Electron 真实冒烟 | `artifacts/INDEX.md`、`review.md` |

## 暂停条件

- 必须购买服务、申请外部凭据或改变用户已确认的范围。
- macOS 权限无法由当前环境取得，且所有只读/模拟测试已完成。
- 架构实测证明 AXUIElement 路线不能达到第一轮核心目标。
- 工作区出现来源不明且与当前切片冲突的改动。
- 配额不足以完成下一可提交切片；此时先提交当前状态并写交接。
