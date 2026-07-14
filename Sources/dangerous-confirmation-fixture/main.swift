import Foundation
import UIBridgeMacCore

@main
enum DangerousConfirmationFixture {
    static func main() async {
        let arguments = Array(CommandLine.arguments.dropFirst())
        let timeout = arguments.first.flatMap(TimeInterval.init) ?? 2
        let category = arguments.indices.contains(1)
            ? DangerousActionCategory(rawValue: arguments[1]) ?? .other
            : .purchase
        let approved = await DangerousActionConfirmationCenter.requestApproval(
            category: category,
            appName: "隔离危险操作验收",
            action: "等待确认的隔离\(category.displayName)操作",
            target: "不会改变真实数据的测试目标",
            impact: "仅验证确认流程，不会产生真实影响",
            timeout: timeout
        )
        print(approved ? "unexpectedly-approved" : "denied-by-timeout")
    }
}
