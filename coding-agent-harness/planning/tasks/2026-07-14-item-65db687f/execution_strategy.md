# 执行策略

## Subagent Authorization

任务开始时先读这一段，并向用户说明当前授权状态。这里是授权记录，不是执行沙箱。

| Role | Status | Permission | Authorized By | Authorized At | Scope | Worktree / Branch | Reuse |
| --- | --- | --- | --- | --- | --- | --- | --- |
| reviewer subagent | allowed by default | read-only | harness task policy | task creation | current task review | n/a | allowed within this task |
| worker subagent | not authorized | none | task contract | task creation | n/a | n/a | no |

## Subagent Delegation Decision

任务开始时，coordinator 必须根据用户目标主动做这个判断，即使用户完全没有提到 subagent。
不要假设用户知道 subagent 或 worker 是什么。如果分工有帮助，用白话说明收益，并向用户申请一次授权。
可以直接对用户说 subagent 或 worker subagent；关键规则是 agent 不能等用户主动提出 subagent。
如果任务已经明显拆成互不重叠的独立切片，implementation 前就应判断为 `ask-user`。如果还不知道精确文件路径，先确认路径，然后立刻申请独立执行助手授权。

| Question | Decision | Reason | Next Action |
| --- | --- | --- | --- |
| Should a reviewer subagent be used? | no | 本轮开发文件强关联，先由 coordinator 完成真实运行与自审。 | 收口时执行对抗性自审。 |
| Would a worker subagent materially help? | no | 状态、截图、界面和安全链路相互依赖，并行写入会增加冲突；用户要求连续小提交即可接力。 | coordinator 单线程分片。 |

## User Authorization Decision

如果上方 worker 决策是 `ask-user`，implementation 必须暂停，直到这里记录用户答案。
已解决状态只能是 `authorized`、`denied` 或 `not-needed`。选择 `ask-user` 后不得继续保持 `pending`。

| Gate | State | Decided By | Decided At | Scope | Worktree / Branch | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| worker subagent | not-needed | coordinator | 2026-07-14 | 不适用 | 当前仓库 / master | 文件高度相关，不拆 worker。 |

## 决策表

| 决策 | 选择 | 说明 |
| --- | --- | --- |
| 主执行者 | coordinator | coordinator 负责编排顺序、冲突判断和最终收口。 |
| Subagent 模式 | none | 单协调者分片实现。 |
| 审查模型 | adversarial review | 涉及持续截图和危险操作门禁，必须检查隐私、性能和绕过路径。 |
| Worktree 策略 | same checkout | 无并行 worker。 |
| 冲突控制 | coordinator owns shared files | subagent 不得直接编辑 coordinator 管理的全局表或共享文件，除非获得明确锁。 |
| 证据深度 | L3 | 安装版原生 UI 与危险动作需要真实运行证据。 |

## 子代理 / Worker 合同

如使用 subagent 或 worker，在这里写清楚输入包、写入范围、handoff 格式和最终集成 owner。

| 角色 | 输入包 | 写入范围 | 交接要求 | 负责人 |
| --- | --- | --- | --- | --- |
| n/a | C-001 | n/a | n/a | coordinator |

## 证据计划

| 证据层级 | 计划命令或检查 | 记录位置 | 完成条件 |
| --- | --- | --- | --- |
| L0 | Swift 编译与敏感数据/旧名称检查 | `progress.md` | 无编译错误和敏感内容落盘 |
| L1 | 状态、历史、确认门禁自检 | `progress.md` | 拒绝、超时和允许分支均通过 |
| L2 | 安装版真实窗口、截图和导航冒烟 | `artifacts/INDEX.md` | 七页可打开，活动画面真实更新 |
| L3 | Cursor/WorkBuddy 真实操作与危险动作阻断 | `review.md` 与 walkthrough | 操作映射可见，未经 App 二次确认不执行 |

## 暂停 / 升级条件

- 所需工作超出已批准写入范围。
- 共享表需要更新，但没有 coordinator lock。
- 实际风险高于原计划，证据深度需要升级。
- reviewer 发现会改变范围或方案的 P0/P1/P2 问题。
- 环境无法提供关键证据，继续执行会变成猜测。
