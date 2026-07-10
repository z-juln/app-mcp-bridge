import Foundation

public enum DeliveryPreference: String, Codable, Sendable {
    case background
    case foreground
}

public enum ActionKind: String, Codable, Sendable {
    case press
    case select
    case setValue = "set_value"
    case typeText = "type_text"
    case pressKey = "press_key"
    case scroll
    case showMenu = "show_menu"
    case coordinateClick = "coordinate_click"
}

public enum ActionTarget: Codable, Hashable, Sendable {
    case element(handle: String)
    case coordinate(point: UIBPoint)
}

public struct VerificationExpectation: Codable, Hashable, Sendable {
    public enum Kind: String, Codable, Sendable {
        case elementPresent = "element_present"
        case elementAbsent = "element_absent"
        case elementValueContains = "element_value_contains"
        case windowTitleContains = "window_title_contains"
        case screenshotChanged = "screenshot_changed"
    }

    public let kind: Kind
    public let value: String?

    public init(kind: Kind, value: String? = nil) {
        self.kind = kind
        self.value = value
    }
}

public struct ActionRequest: Codable, Hashable, Sendable {
    public let snapshotID: String
    public let target: ActionTarget
    public let action: ActionKind
    public let delivery: DeliveryPreference
    public let text: String?
    public let key: String?
    public let verification: VerificationExpectation?

    public init(
        snapshotID: String,
        target: ActionTarget,
        action: ActionKind,
        delivery: DeliveryPreference = .background,
        text: String? = nil,
        key: String? = nil,
        verification: VerificationExpectation? = nil
    ) {
        self.snapshotID = snapshotID
        self.target = target
        self.action = action
        self.delivery = delivery
        self.text = text
        self.key = key
        self.verification = verification
    }
}

public enum ActionStatus: String, Codable, Sendable {
    case confirmed
    case notObserved = "not_observed"
    case ambiguous
    case failed
    case confirmationRequired = "confirmation_required"
    case foregroundRequired = "foreground_required"
}

public struct ActionEvidence: Codable, Hashable, Sendable {
    public let condition: String
    public let observed: String?

    public init(condition: String, observed: String? = nil) {
        self.condition = condition
        self.observed = observed
    }
}

public struct ActionResult: Codable, Hashable, Sendable, Identifiable {
    public var id: String { actionID }
    public let actionID: String
    public let status: ActionStatus
    public let deliveryUsed: String
    public let focusChanged: Bool
    public let newSnapshotID: String?
    public let evidence: ActionEvidence?

    public init(
        actionID: String,
        status: ActionStatus,
        deliveryUsed: String,
        focusChanged: Bool,
        newSnapshotID: String? = nil,
        evidence: ActionEvidence? = nil
    ) {
        self.actionID = actionID
        self.status = status
        self.deliveryUsed = deliveryUsed
        self.focusChanged = focusChanged
        self.newSnapshotID = newSnapshotID
        self.evidence = evidence
    }
}
