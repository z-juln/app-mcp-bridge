import AppKit
import CoreGraphics
import Foundation
import UIBridgeProtocol

public enum ProcessEventExecutor {
    public static func execute(_ request: ActionRequest, snapshot: Snapshot, foregroundApproved: Bool) throws -> ActionResult {
        if request.delivery == .foreground && !foregroundApproved {
            return ActionResult(actionID: UUID().uuidString, status: .foregroundRequired, deliveryUsed: "none", focusChanged: false, evidence: ActionEvidence(condition: "explicit_foreground_consent_required"))
        }

        var focusChanged = false
        if request.delivery == .foreground {
            guard let app = NSRunningApplication(processIdentifier: snapshot.pid) else {
                throw BridgeError(code: .appNotFound, message: "The target application is no longer running.", retryable: true)
            }
            focusChanged = app.activate(options: [.activateAllWindows])
        }

        switch request.action {
        case .pressKey:
            guard let key = request.key, let code = keyCode(for: key) else {
                throw BridgeError(code: .invalidRequest, message: "A supported key name is required for press_key.")
            }
            try postKey(code, pid: snapshot.pid)
        case .scroll:
            let amount = Int32(request.text.flatMap(Int.init) ?? -3)
            guard let event = CGEvent(scrollWheelEvent2Source: nil, units: .line, wheelCount: 1, wheel1: amount, wheel2: 0, wheel3: 0) else {
                throw BridgeError(code: .internalFailure, message: "Could not create scroll event.")
            }
            event.postToPid(snapshot.pid)
        case .coordinateClick:
            guard case let .coordinate(point) = request.target,
                  point.x >= 0, point.y >= 0,
                  point.x <= snapshot.windowBounds.size.width,
                  point.y <= snapshot.windowBounds.size.height else {
                throw BridgeError(code: .invalidRequest, message: "Coordinate must be inside the current snapshot window.")
            }
            let global = CGPoint(x: snapshot.windowBounds.origin.x + point.x, y: snapshot.windowBounds.origin.y + point.y)
            guard let down = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: global, mouseButton: .left),
                  let up = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: global, mouseButton: .left) else {
                throw BridgeError(code: .internalFailure, message: "Could not create click event.")
            }
            down.postToPid(snapshot.pid)
            up.postToPid(snapshot.pid)
        default:
            throw BridgeError(code: .unsupported, message: "This action is not a process event action.")
        }

        return ActionResult(actionID: UUID().uuidString, status: .notObserved, deliveryUsed: request.delivery == .foreground ? "foreground_event" : "process_event", focusChanged: focusChanged, evidence: ActionEvidence(condition: "event_delivered_verification_pending"))
    }

    private static func postKey(_ code: CGKeyCode, pid: Int32) throws {
        guard let down = CGEvent(keyboardEventSource: nil, virtualKey: code, keyDown: true),
              let up = CGEvent(keyboardEventSource: nil, virtualKey: code, keyDown: false) else {
            throw BridgeError(code: .internalFailure, message: "Could not create keyboard event.")
        }
        down.postToPid(pid)
        up.postToPid(pid)
    }

    private static func keyCode(for name: String) -> CGKeyCode? {
        switch name.lowercased() {
        case "return", "enter": 36
        case "tab": 48
        case "space": 49
        case "delete", "backspace": 51
        case "escape", "esc": 53
        case "left": 123
        case "right": 124
        case "down": 125
        case "up": 126
        default: nil
        }
    }
}
