import Testing
@testable import Cujana

@MainActor
struct AppLaunchConfigurationTests {
    @Test
    func standardDebugLaunchDoesNotUseScreenshotMode() {
        #expect(AppLaunchConfiguration.current(arguments: ["Cujana"]) == .standard)
    }

    @Test
    func fastlaneSnapshotWithoutScreenDoesNotUseScreenshotMode() {
        #expect(AppLaunchConfiguration.current(arguments: ["Cujana", "-FASTLANE_SNAPSHOT", "YES"]) == .standard)
    }

    @Test
    func explicitScreenshotScreenUsesScreenshotMode() {
        #expect(
            AppLaunchConfiguration.current(arguments: ["Cujana", "-cujana_screenshot_screen", "dashboard"])
                == .screenshot(.dashboard)
        )
    }
}
