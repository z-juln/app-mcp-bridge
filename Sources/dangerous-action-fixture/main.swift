import AppKit

@main
@MainActor
enum DangerousActionFixture {
    private static let delegate = FixtureDelegate()

    static func main() {
        let application = NSApplication.shared
        application.setActivationPolicy(.accessory)
        application.delegate = delegate
        application.run()
    }
}

@MainActor
private final class FixtureDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?
    private let statusLabel = NSTextField(labelWithString: "未执行")

    func applicationDidFinishLaunching(_ notification: Notification) {
        let title = NSTextField(labelWithString: "隔离危险操作验收")
        title.font = .boldSystemFont(ofSize: 20)

        statusLabel.font = .systemFont(ofSize: 16)
        statusLabel.setAccessibilityLabel("操作状态")

        let button = NSButton(title: "执行隔离危险操作", target: self, action: #selector(performIsolatedAction))
        button.bezelStyle = .rounded

        let stack = NSStackView(views: [title, statusLabel, button])
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 220),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "危险操作验收夹具"
        window.contentView?.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: window.contentView!.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: window.contentView!.centerYAnchor),
        ])
        window.center()
        window.orderFrontRegardless()
        self.window = window
    }

    @objc private func performIsolatedAction() {
        statusLabel.stringValue = "已执行一次"
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
