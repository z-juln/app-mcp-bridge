# Regression SSoT

| Gate | Surface | Command / Evidence | Required |
| --- | --- | --- | --- |
| harness | 任务与交接完整性 | `npx --yes coding-agent-harness check --profile target-project .` | every commit slice |
| build | Swift 编译 | `swift build` | code slices |
| unit | 模型、树、坐标、策略 | `swift test` | code slices |
| http-smoke | 回环端口与核心调用 | integration script | server slice onward |
| mcp-smoke | 工具列表与动作映射 | MCP client fixture | MCP slice onward |
| skill | 格式、触发和安全路由 | skill validator + scenario tests | skill slice onward |
| native-app | TextEdit/Finder | live smoke evidence | release candidate |
| complex-app | 企业微信/Electron | live smoke evidence | release candidate |

完成不能只依赖 build；所有触达 surface 的 gate 必须有证据或明确 blocker。
