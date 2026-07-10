# 本地开发

Context Doc Type: local-setup
Owner: project coordinator
Source Evidence: TARGET:docs/03-delivery-and-validation.md
Last Verified: 2026-07-10
Confidence: medium

## 要求

- macOS 14.4+。
- Xcode 与 Swift 6 工具链。
- Node/npm 仅用于 Coding Agent Harness。

## 稳定命令

```bash
swift build
swift test
npx --yes coding-agent-harness check --profile target-project .
npx --yes coding-agent-harness status --json .
```

服务与权限命令会在 CLI 骨架建立后补充。系统权限只授予构建出的稳定 App Bundle；
不要让不同临时二进制反复触发授权。
