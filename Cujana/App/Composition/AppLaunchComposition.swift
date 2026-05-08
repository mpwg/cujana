import SwiftUI

#if DEBUG
@MainActor
struct AppLaunchComposition {
    private let compositionRoot: AppCompositionRoot
    private let launchConfiguration: AppLaunchConfiguration

    static func current() -> AppLaunchComposition {
        let launchConfiguration = AppLaunchConfiguration.current()
        let compositionRoot: AppCompositionRoot

        switch launchConfiguration {
        case .standard:
            compositionRoot = .production()
        case .screenshot:
            compositionRoot = .demo()
        }

        return AppLaunchComposition(
            compositionRoot: compositionRoot,
            launchConfiguration: launchConfiguration
        )
    }

    @ViewBuilder
    func makeRootView() -> some View {
        compositionRoot.makeRootView(launchConfiguration: launchConfiguration)
    }
}
#else
@MainActor
struct AppLaunchComposition {
    private let compositionRoot: AppCompositionRoot

    static func current() -> AppLaunchComposition {
        AppLaunchComposition(compositionRoot: .production())
    }

    @ViewBuilder
    func makeRootView() -> some View {
        compositionRoot.makeContentView()
    }
}
#endif
