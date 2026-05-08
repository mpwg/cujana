import SwiftUI

#if DEBUG
@MainActor
extension AppCompositionRoot {
    static func demo() -> AppCompositionRoot {
        AppCompositionRoot(dependencies: .demo())
    }

    @ViewBuilder
    func makeRootView(
        launchConfiguration: AppLaunchConfiguration,
        telemetryService: AppTelemetryService
    ) -> some View {
        switch launchConfiguration {
        case .standard:
            makeContentView(telemetryService: telemetryService)
        case .screenshot(let screen):
            makeScreenshotView(screen: screen, telemetryService: telemetryService)
        }
    }

    private func makeDemoContentView(telemetryService: AppTelemetryService) -> ContentView {
        ContentView(
            dashboardViewModel: AppDemoData.makeDashboardViewModel(),
            entryListViewModel: AppDemoData.makeEntryListViewModel(),
            symptomEntryViewModel: AppDemoData.makeSymptomEntryViewModel(),
            telemetryService: telemetryService
        )
    }

    @ViewBuilder
    private func makeScreenshotView(
        screen: AppScreenshotScreen,
        telemetryService: AppTelemetryService
    ) -> some View {
        switch screen {
        case .dashboard:
            makeDemoContentView(telemetryService: telemetryService)
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
            locationProvider: FixedLocationCoordinateProvider(coordinate: AppDemoData.coordinate)
        )
    }
}
#endif
