# Regression SSoT

| Gate | Surface | Command / Evidence | Required |
| --- | --- | --- | --- |
| harness | 任务与交接完整性 | `npx --yes coding-agent-harness check --profile target-project .` | every commit slice |
| build | Swift 编译 | `swift build` | code slices |
| unit | 模型、树、坐标、策略 | `swift run protocol-self-test`；完整 Xcode 后扩展标准测试 | code slices |
| dangerous-confirmation | 删除、购买、权限变更二次确认 | `swift run safety-self-test` + 隔离夹具安装版拒绝/超时/单次允许回归 | safety and release slices |
| http-smoke | 回环端口与核心调用 | integration script | server slice onward |
| mcp-smoke | 工具列表与动作映射 | MCP client fixture | MCP slice onward |
| skill | 格式、触发和安全路由 | skill validator + scenario tests | skill slice onward |
| native-app | TextEdit/Finder | live smoke evidence | release candidate |
| complex-app | 企业微信/Electron | live smoke evidence | release candidate |

完成不能只依赖 build；所有触达 surface 的 gate 必须有证据或明确 blocker。
