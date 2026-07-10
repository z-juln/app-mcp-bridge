// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "macos-ui-bridge",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "UIBridgeProtocol", targets: ["UIBridgeProtocol"]),
        .executable(name: "macos-ui-bridge", targets: ["macos-ui-bridge"]),
    ],
    targets: [
        .target(name: "UIBridgeProtocol"),
        .executableTarget(
            name: "macos-ui-bridge",
            dependencies: ["UIBridgeProtocol"]
        ),
        .executableTarget(
            name: "protocol-self-test",
            dependencies: ["UIBridgeProtocol"]
        ),
    ]
)
