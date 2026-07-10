import Foundation
import UIBridgeProtocol

@main
enum UIBridgeCommand {
    static func main() {
        let arguments = Array(CommandLine.arguments.dropFirst())
        let command = arguments.first ?? "help"

        switch command {
        case "version":
            print("macos-ui-bridge 0.1.0-dev")
        case "status":
            print("not running")
        default:
            print("macos-ui-bridge <version|status>")
        }
    }
}
