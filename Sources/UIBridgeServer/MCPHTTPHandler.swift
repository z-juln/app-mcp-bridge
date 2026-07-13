import Foundation
import MCP
import UIBridgeMCP
import UIBridgeMacCore

final class MCPHTTPHandler: @unchecked Sendable {
    private let runtime: AutomationRuntime

    private init(runtime: AutomationRuntime) {
        self.runtime = runtime
    }

    static func make(runtime: AutomationRuntime) async throws -> MCPHTTPHandler {
        MCPHTTPHandler(runtime: runtime)
    }

    func handle(_ request: HTTPRequest) async -> HTTPResponse {
        // A stateless HTTP request must not reuse Server initialization state.
        // Build a short-lived protocol server for every request while sharing
        // the long-lived desktop automation runtime across all clients.
        let transport = StatelessHTTPServerTransport()
        let server = await MCPBridge.makeServer(runtime: runtime)
        do {
            try await server.start(transport: transport)
        } catch {
            return HTTPResponse(status: 500, body: Data("{\"error\":\"mcp_start_failed\"}".utf8))
        }
        let mcpRequest = MCP.HTTPRequest(
            method: request.method,
            headers: request.headers,
            body: request.body,
            path: request.path
        )
        let response = await transport.handleRequest(mcpRequest)
        await server.stop()
        if case .stream = response {
            return HTTPResponse(status: 501, body: Data("{\"error\":\"streaming_not_available\"}".utf8))
        }
        return HTTPResponse(
            status: response.statusCode,
            body: response.bodyData ?? Data(),
            contentType: response.headers["Content-Type"] ?? "application/json; charset=utf-8",
            additionalHeaders: response.headers
        )
    }
}
