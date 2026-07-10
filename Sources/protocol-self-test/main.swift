import Foundation
import UIBridgeProtocol

enum SelfTestFailure: Error, CustomStringConvertible {
    case expectation(String)

    var description: String {
        switch self {
        case let .expectation(message): message
        }
    }
}

func expect(_ condition: @autoclosure () -> Bool, _ message: String) throws {
    guard condition() else {
        throw SelfTestFailure.expectation(message)
    }
}

func testSnapshotRoundTrip() throws {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    let snapshot = Snapshot(
        snapshotID: "snap-1",
        appID: "com.example.Editor",
        pid: 42,
        windowID: 7,
        createdAt: now,
        expiresAt: now.addingTimeInterval(60),
        treeQuality: .complete,
        windowBounds: UIBRect(x: 10, y: 20, width: 800, height: 600),
        screenshot: ScreenshotDescriptor(handle: "shot-1", width: 1600, height: 1200),
        elements: [
            ElementDescriptor(
                handle: "snap-1:0:root",
                index: 0,
                role: "window",
                label: "Editor",
                frameInWindow: UIBRect(x: 0, y: 0, width: 800, height: 600),
                actions: ["raise"]
            )
        ]
    )

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    let data = try encoder.encode(snapshot)
    let decoded = try decoder.decode(Snapshot.self, from: data)
    try expect(decoded == snapshot, "Snapshot JSON round-trip changed data")
}

func testActionRoundTrip() throws {
    let request = ActionRequest(
        snapshotID: "snap-1",
        target: .coordinate(point: UIBPoint(x: 12, y: 34)),
        action: .coordinateClick,
        verification: VerificationExpectation(kind: .screenshotChanged)
    )

    let data = try JSONEncoder().encode(request)
    let decoded = try JSONDecoder().decode(ActionRequest.self, from: data)
    try expect(decoded == request, "Action JSON round-trip changed its target variant")
}

func testErrorCodesAreUnique() throws {
    let rawValues = BridgeErrorCode.allCases.map(\.rawValue)
    try expect(Set(rawValues).count == rawValues.count, "Bridge error codes are not unique")
}

do {
    try testSnapshotRoundTrip()
    try testActionRoundTrip()
    try testErrorCodesAreUnique()
    print("protocol-self-test: 3 checks passed")
} catch {
    fputs("protocol-self-test failed: \(error)\n", stderr)
    exit(1)
}
