import Foundation

public enum BridgeErrorCode: String, Codable, CaseIterable, Sendable {
    case permissionMissing = "permission_missing"
    case appNotFound = "app_not_found"
    case windowAmbiguous = "window_ambiguous"
    case snapshotStale = "snapshot_stale"
    case elementNotFound = "element_not_found"
    case partialTree = "partial_tree"
    case backgroundDropped = "background_dropped"
    case foregroundRequired = "foreground_required"
    case confirmationRequired = "confirmation_required"
    case verificationAmbiguous = "verification_ambiguous"
    case rateLimited = "rate_limited"
    case unsupported
    case invalidRequest = "invalid_request"
    case internalFailure = "internal_failure"
}

public struct BridgeError: Error, Codable, Hashable, Sendable {
    public let code: BridgeErrorCode
    public let message: String
    public let retryable: Bool
    public let suggestedAction: String?

    public init(
        code: BridgeErrorCode,
        message: String,
        retryable: Bool = false,
        suggestedAction: String? = nil
    ) {
        self.code = code
        self.message = message
        self.retryable = retryable
        self.suggestedAction = suggestedAction
    }
}
