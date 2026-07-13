import Foundation
import MCP
import UIBridgeMCP
import UIBridgeMacCore

final class MCPHTTPHandler: @unchecked Sendable {
    private let transport: StatelessHTTPServerTransport

    private init(transport: StatelessHTTPServerTransport) {
        self.transport = transport
    }

    static func make(runtime: AutomationRuntime) async throws -> MCPHTTPHandler {
        let transport = StatelessHTTPServerTransport()
        let server = await MCPBridge.makeServer(runtime: runtime)
        try await server.start(transport: transport)
        return MCPHTTPHandler(transport: transport)
    }

    func handle(_ request: HTTPRequest) async -> HTTPResponse {
        let mcpRequest = MCP.HTTPRequest(
            method: request.method,
            headers: request.headers,
            body: request.body,
            path: request.path
        )
        let response = await transport.handleRequest(mcpRequest)
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
