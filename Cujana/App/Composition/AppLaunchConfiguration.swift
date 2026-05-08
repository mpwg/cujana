import Foundation

enum AppLaunchConfiguration {
    case standard
    case screenshot(AppScreenshotScreen)

    static func current(arguments: [String] = ProcessInfo.processInfo.arguments) -> AppLaunchConfiguration {
        guard arguments.contains("-FASTLANE_SNAPSHOT") || arguments.contains("-cujana_screenshot_screen") else {
            return .standard
        }

        return .screenshot(AppScreenshotScreen(arguments: arguments) ?? .dashboard)
    }
}

enum AppScreenshotScreen: String, CaseIterable {
    case dashboard
    case entry

    init?(arguments: [String]) {
        guard let index = arguments.firstIndex(of: "-cujana_screenshot_screen"),
              arguments.indices.contains(arguments.index(after: index)) else {
            return nil
        }

        self.init(rawValue: arguments[arguments.index(after: index)])
    }
}
