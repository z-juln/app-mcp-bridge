import ApplicationServices
import CoreGraphics
import Foundation

public struct PermissionStatus: Codable, Hashable, Sendable {
    public let accessibilityTrusted: Bool
    public let screenCaptureAllowed: Bool?

    public init(accessibilityTrusted: Bool, screenCaptureAllowed: Bool? = nil) {
        self.accessibilityTrusted = accessibilityTrusted
        self.screenCaptureAllowed = screenCaptureAllowed
    }
}

public enum PermissionInspector {
    public static func current() -> PermissionStatus {
        PermissionStatus(
            accessibilityTrusted: AXIsProcessTrusted(),
            screenCaptureAllowed: CGPreflightScreenCaptureAccess()
        )
    }
}

public enum PermissionRestartPolicy {
    public static func newlyGranted(from previous: PermissionStatus, to current: PermissionStatus) -> [String] {
        var result: [String] = []
        if !previous.accessibilityTrusted && current.accessibilityTrusted {
            result.append("辅助功能")
        }
        if previous.screenCaptureAllowed == false && current.screenCaptureAllowed == true {
            result.append("屏幕录制")
        }
        return result
    }
}
