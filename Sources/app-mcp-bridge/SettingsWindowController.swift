import AppKit
import SwiftUI
import UIBridgeMacCore

@MainActor
final class BridgeSettingsModel: ObservableObject {
    @Published var selectedSection: SettingsSection = .overview {
        didSet { updateLiveRefresh() }
    }
    @Published var permissions = PermissionInspector.current()
    @Published var activeTargets: [ControlledTarget] = []
    @Published var lastRefreshed = Date()
    @Published var selectedTargetPID: Int32?
    @Published var livePreviews: [Int32: NSImage] = [:]
    @Published var previewErrors: [Int32: String] = [:]
    @Published var recentEvents: [AutomationActivityRecord] = []
    @Published var operationsStopped = false
    @Published var liveRefreshStatus = "等待活动"

    private var liveRefreshTask: Task<Void, Never>?
    private let token: String

    init(token: String) {
        self.token = token
    }

    let connectionURL = "http://127.0.0.1:8765/mcp"

    var serviceReady: Bool { true }

    func refresh(targets: [ControlledTarget]? = nil) {
        permissions = PermissionInspector.current()
        if let targets { activeTargets = targets }
        recentEvents = AutomationActivityCenter.recent()
        if selectedTargetPID == nil || !activeTargets.contains(where: { $0.pid == selectedTargetPID }) {
            selectedTargetPID = activeTargets.first?.pid
        }
        lastRefreshed = Date()
    }

    func setWindowVisible(_ visible: Bool) {
        windowVisible = visible
        updateLiveRefresh()
    }

    private var windowVisible = false
    private var livePageVisible = false

    func beginLivePreview() {
        livePageVisible = true
        updateLiveRefresh()
    }

    func endLivePreview() {
        livePageVisible = false
        updateLiveRefresh()
    }

    private func updateLiveRefresh() {
        liveRefreshTask?.cancel()
        liveRefreshTask = nil
        guard windowVisible, livePageVisible, selectedSection == .liveControl else { return }
        liveRefreshTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                self.refresh()
                self.liveRefreshStatus = "正在刷新 \(self.activeTargets.count) 个窗口"
                await self.captureVisibleTargets()
                try? await Task.sleep(for: .milliseconds(900))
            }
        }
    }

    private func captureVisibleTargets() async {
        let targets = Array(activeTargets.prefix(6))
        for target in targets where !Task.isCancelled {
            do {
                let windowID = target.windowID
                let capture = try await Task.detached {
                    try await WindowCapture.capture(windowID: windowID, handle: "live-\(target.pid)")
                }.value
                if let image = NSImage(data: capture.pngData) {
                    livePreviews[target.pid] = image
                    previewErrors[target.pid] = nil
                    liveRefreshStatus = "画面已更新"
                }
            } catch {
                previewErrors[target.pid] = error.localizedDescription
                liveRefreshStatus = "画面读取失败"
            }
        }
        let valid = Set(targets.map(\.pid))
        livePreviews = livePreviews.filter { valid.contains($0.key) }
        previewErrors = previewErrors.filter { valid.contains($0.key) }
    }

    func stopAllOperations() async {
        do {
            _ = try await LocalBridgeClient(token: token).call(tool: "emergency_stop", argumentsJSON: nil)
            operationsStopped = true
            activeTargets = []
            livePreviews = [:]
        } catch {
            // The diagnostics page will still expose a stopped or unreachable service.
        }
    }
}

enum SettingsSection: String, CaseIterable, Identifiable {
    case overview
    case liveControl
    case permissions
    case connections
    case appAccess
    case safety
    case diagnostics

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: "总览"
        case .liveControl: "实时操控"
        case .permissions: "系统权限"
        case .connections: "连接"
        case .appAccess: "应用访问"
        case .safety: "操作安全"
        case .diagnostics: "调试与诊断"
        }
    }

    var symbol: String {
        switch self {
        case .overview: "square.grid.2x2"
        case .liveControl: "rectangle.inset.filled.and.cursorarrow"
        case .permissions: "checkmark.shield"
        case .connections: "cable.connector"
        case .appAccess: "app.badge.checkmark"
        case .safety: "exclamationmark.shield"
        case .diagnostics: "waveform.path.ecg.rectangle"
        }
    }
}

@MainActor
final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    let model: BridgeSettingsModel

    init(model: BridgeSettingsModel) {
        self.model = model
        let content = SettingsRootView(model: model)
        let hosting = NSHostingController(rootView: content)
        let window = NSWindow(contentViewController: hosting)
        window.title = "App MCP Bridge"
        window.setContentSize(NSSize(width: 1_080, height: 720))
        window.minSize = NSSize(width: 900, height: 600)
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.center()
        window.isReleasedWhenClosed = false
        super.init(window: window)
        window.delegate = self
    }

    required init?(coder: NSCoder) { nil }

    func show(section: SettingsSection? = nil, targets: [ControlledTarget]) {
        if let section { model.selectedSection = section }
        model.refresh(targets: targets)
        showWindow(nil)
        window?.centerIfNeeded()
        NSApplication.shared.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
        model.setWindowVisible(true)
    }

    func windowWillClose(_ notification: Notification) {
        model.setWindowVisible(false)
    }
}

private extension NSWindow {
    func centerIfNeeded() {
        guard !isVisible else { return }
        center()
    }
}
