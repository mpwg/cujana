import SwiftUI

#if DEBUG
@MainActor
struct AppLaunchComposition {
    private let compositionRoot: AppCompositionRoot
    private let launchConfiguration: AppLaunchConfiguration

    static func current() throws -> AppLaunchComposition {
        let launchConfiguration = AppLaunchConfiguration.current()
        let compositionRoot: AppCompositionRoot

        switch launchConfiguration {
        case .standard:
            compositionRoot = try .production()
        case .screenshot:
            compositionRoot = .demo()
        }

        return AppLaunchComposition(
            compositionRoot: compositionRoot,
            launchConfiguration: launchConfiguration
        )
    }

    @ViewBuilder
    func makeRootView(telemetryService: AppTelemetryService) -> some View {
        compositionRoot.makeRootView(
            launchConfiguration: launchConfiguration,
            telemetryService: telemetryService
        )
    }

    func makeEnvironmentalDataRefreshCoordinator() -> EnvironmentalDataRefreshCoordinator? {
        switch launchConfiguration {
        case .standard:
            compositionRoot.makeEnvironmentalDataRefreshCoordinator()
        case .screenshot:
            nil
        }
    }
}
#else
@MainActor
struct AppLaunchComposition {
    private let compositionRoot: AppCompositionRoot

    static func current() throws -> AppLaunchComposition {
        AppLaunchComposition(compositionRoot: try .production())
    }

    @ViewBuilder
    func makeRootView(telemetryService: AppTelemetryService) -> some View {
        compositionRoot.makeContentView(telemetryService: telemetryService)
    }

    func makeEnvironmentalDataRefreshCoordinator() -> EnvironmentalDataRefreshCoordinator? {
        compositionRoot.makeEnvironmentalDataRefreshCoordinator()
    }
}
#endif
