import Foundation
import MCP
import UIBridgeMacCore

public enum MCPBridge {
    public static func runStdio() async throws {
        let server = Server(
            name: "macos-ui-bridge",
            version: "0.1.0",
            instructions: "Inspect and operate macOS applications through live system state.",
            capabilities: .init(tools: .init(listChanged: false))
        )

        await server.withMethodHandler(ListTools.self) { _ in
            .init(tools: [
                Tool(
                    name: "permissions_get",
                    description: "Read the current macOS permissions available to the bridge.",
                    inputSchema: .object(["type": .string("object")])
                ),
                Tool(
                    name: "apps_list",
                    description: "List currently running macOS applications.",
                    inputSchema: .object(["type": .string("object")])
                ),
                Tool(
                    name: "windows_list",
                    description: "List windows owned by one running application process.",
                    inputSchema: .object([
                        "type": .string("object"),
                        "properties": .object([
                            "pid": .object([
                                "type": .string("integer"),
                                "description": .string("Process identifier returned by apps_list"),
                            ])
                        ]),
                        "required": .array([.string("pid")]),
                    ])
                ),
            ])
        }

        await server.withMethodHandler(CallTool.self) { params in
            do {
                switch params.name {
                case "permissions_get":
                    let status = PermissionInspector.current()
                    await PermissionGuidance.presentIfNeeded(for: status)
                    return try success(status)
                case "apps_list":
                    return try success(AppDiscovery.listRunningApplications())
                case "windows_list":
                    guard let rawPID = params.arguments?["pid"]?.intValue,
                          let pid = Int32(exactly: rawPID) else {
                        return failure("pid must be a valid 32-bit process identifier")
                    }
                    return try success(WindowDiscovery.listWindows(pid: pid))
                default:
                    return failure("unknown tool: \(params.name)")
                }
            } catch {
                return failure("tool failed: \(error.localizedDescription)")
            }
        }

        let transport = StdioTransport()
        try await server.start(transport: transport)
        await server.waitUntilCompleted()
    }

    private static func success<T: Encodable>(_ value: T) throws -> CallTool.Result {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(value)
        let text = String(decoding: data, as: UTF8.self)
        return .init(content: [.text(text: text, annotations: nil, _meta: nil)], isError: false)
    }

    private static func failure(_ message: String) -> CallTool.Result {
        .init(content: [.text(text: message, annotations: nil, _meta: nil)], isError: true)
    }
}
