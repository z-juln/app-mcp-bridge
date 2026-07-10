import Foundation

public struct AppDescriptor: Codable, Hashable, Sendable, Identifiable {
    public var id: String { appID }
    public let appID: String
    public let pid: Int32
    public let name: String
    public let bundleURL: URL?
    public let isRunning: Bool
    public let isFrontmost: Bool

    public init(
        appID: String,
        pid: Int32,
        name: String,
        bundleURL: URL? = nil,
        isRunning: Bool,
        isFrontmost: Bool
    ) {
        self.appID = appID
        self.pid = pid
        self.name = name
        self.bundleURL = bundleURL
        self.isRunning = isRunning
        self.isFrontmost = isFrontmost
    }
}

public struct WindowDescriptor: Codable, Hashable, Sendable, Identifiable {
    public var id: UInt32 { windowID }
    public let windowID: UInt32
    public let pid: Int32
    public let title: String
    public let bounds: UIBRect
    public let isVisible: Bool
    public let isCapturable: Bool

    public init(
        windowID: UInt32,
        pid: Int32,
        title: String,
        bounds: UIBRect,
        isVisible: Bool,
        isCapturable: Bool
    ) {
        self.windowID = windowID
        self.pid = pid
        self.title = title
        self.bounds = bounds
        self.isVisible = isVisible
        self.isCapturable = isCapturable
    }
}

public enum TreeQuality: String, Codable, CaseIterable, Sendable {
    case complete
    case partial
    case shellOnly = "shell_only"
    case unavailable
}

public struct ElementState: Codable, Hashable, Sendable {
    public let isEnabled: Bool
    public let isSelected: Bool
    public let isFocused: Bool
    public let isSettable: Bool
    public let isExpanded: Bool?

    public init(
        isEnabled: Bool = true,
        isSelected: Bool = false,
        isFocused: Bool = false,
        isSettable: Bool = false,
        isExpanded: Bool? = nil
    ) {
        self.isEnabled = isEnabled
        self.isSelected = isSelected
        self.isFocused = isFocused
        self.isSettable = isSettable
        self.isExpanded = isExpanded
    }
}

public struct ElementDescriptor: Codable, Hashable, Sendable, Identifiable {
    public var id: String { handle }
    public let handle: String
    public let index: Int
    public let parentIndex: Int?
    public let role: String
    public let label: String?
    public let value: String?
    public let frameInWindow: UIBRect?
    public let screenshotFrame: UIBRect?
    public let state: ElementState
    public let actions: [String]

    public init(
        handle: String,
        index: Int,
        parentIndex: Int? = nil,
        role: String,
        label: String? = nil,
        value: String? = nil,
        frameInWindow: UIBRect? = nil,
        screenshotFrame: UIBRect? = nil,
        state: ElementState = ElementState(),
        actions: [String] = []
    ) {
        self.handle = handle
        self.index = index
        self.parentIndex = parentIndex
        self.role = role
        self.label = label
        self.value = value
        self.frameInWindow = frameInWindow
        self.screenshotFrame = screenshotFrame
        self.state = state
        self.actions = actions
    }
}

public struct ScreenshotDescriptor: Codable, Hashable, Sendable {
    public let handle: String
    public let width: Int
    public let height: Int
    public let mimeType: String

    public init(handle: String, width: Int, height: Int, mimeType: String = "image/png") {
        self.handle = handle
        self.width = width
        self.height = height
        self.mimeType = mimeType
    }
}

public struct Snapshot: Codable, Hashable, Sendable, Identifiable {
    public var id: String { snapshotID }
    public let snapshotID: String
    public let appID: String
    public let pid: Int32
    public let windowID: UInt32
    public let createdAt: Date
    public let expiresAt: Date
    public let treeQuality: TreeQuality
    public let windowBounds: UIBRect
    public let screenshot: ScreenshotDescriptor?
    public let elements: [ElementDescriptor]

    public init(
        snapshotID: String,
        appID: String,
        pid: Int32,
        windowID: UInt32,
        createdAt: Date,
        expiresAt: Date,
        treeQuality: TreeQuality,
        windowBounds: UIBRect,
        screenshot: ScreenshotDescriptor? = nil,
        elements: [ElementDescriptor]
    ) {
        self.snapshotID = snapshotID
        self.appID = appID
        self.pid = pid
        self.windowID = windowID
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.treeQuality = treeQuality
        self.windowBounds = windowBounds
        self.screenshot = screenshot
        self.elements = elements
    }
}
