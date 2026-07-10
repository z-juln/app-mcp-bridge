# 实现 macOS 通用 UI Bridge 第一轮 - 发现记录

## 已确认事实

1. Codex Computer Use 本机插件为专有实现，不能复制 Skill 获得其底层能力。
2. macOS 公开能力足以构建通用底座：AXUIElement、ScreenCaptureKit、CGEvent。
3. 企业微信实测表明，完整读取虚拟列表关系比截图坐标更关键。
4. 普通微信和企业微信暴露结构差异巨大，核心必须按能力探测而非应用类型判断。
5. 官方 MCP Swift SDK支持 stdio 和 Streamable HTTP，可保持单语言实现。

## 技术决策

| 决策 | 选择 | 原因 | 状态 |
| --- | --- | --- | --- |
| 平台 | macOS 14.4+ | 第一轮单平台，减少兼容成本 | accepted |
| 实现 | Swift 6 无界面 App Bundle | 稳定系统权限身份和原生能力 | accepted |
| 服务 | 回环 HTTP + MCP | 同时覆盖 WorkBuddy 与 Cursor | accepted |
| 核心 | 通用能力探测 | 禁止应用专属固定流程 | accepted |
| 协作 | 串行小提交 + Harness 任务包 | 用户可随时换 Agent 接力 | accepted |

## 待验证

- Swift SDK 与当前 Xcode/macOS 工具链版本。
- ScreenCaptureKit 单窗口截图在后台与跨 Space 的实际行为。
- WorkBuddy 当前版本支持 MCP 还是仅支持 HTTP/Skill 命令。

## 环境发现

- Swift 6.3.3 编译器可用。
- 当前 active developer directory 是 CommandLineTools，不是完整 Xcode。
- `XCTest` 和独立 `Testing` 模块不可直接使用；引入 swift-testing 后链接仍缺少
  `_TestingInterop`。为保持接力环境可运行，基础测试暂用项目内可执行自检。
