import SwiftUI

#if DEBUG
@MainActor
extension AppCompositionRoot {
    static func demo() -> AppCompositionRoot {
        AppCompositionRoot(dependencies: .demo())
    }

    @ViewBuilder
    func makeRootView(launchConfiguration: AppLaunchConfiguration) -> some View {
        switch launchConfiguration {
        case .standard:
            makeContentView()
        case .screenshot(let screen):
            makeScreenshotView(screen: screen)
        }
    }

    private func makeDemoContentView() -> ContentView {
        ContentView(
            dashboardViewModel: AppDemoData.makeDashboardViewModel(),
            symptomEntryViewModel: AppDemoData.makeSymptomEntryViewModel()
        )
    }

    @ViewBuilder
    private func makeScreenshotView(screen: AppScreenshotScreen) -> some View {
        switch screen {
        case .dashboard:
            makeDemoContentView()
        case .entry:
            SymptomEntryView(viewModel: AppDemoData.makeSymptomEntryViewModel())
        }
    }
}

extension AppDependencies {
    static func demo() -> AppDependencies {
        AppDependencies(
            pollenRepository: DemoPollenRepository(forecasts: AppDemoData.pollenForecasts),
            symptomEntryRepository: DemoSymptomEntryRepository(entries: AppDemoData.symptomEntries),
            locationProvider: FixedLocationCoordinateProvider(coordinate: AppDemoData.coordinate),
            defaultCoordinate: AppDemoData.coordinate
        )
    }
}
#endif
