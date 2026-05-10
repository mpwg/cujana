import Foundation

#if DEBUG
enum AppLaunchConfiguration: Equatable {
    case standard
    case screenshot(AppScreenshotScreen)

    static func current(arguments: [String] = ProcessInfo.processInfo.arguments) -> AppLaunchConfiguration {
        guard let screenshotScreen = AppScreenshotScreen(arguments: arguments) else {
            return .standard
        }

        return .screenshot(screenshotScreen)
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
#endif
