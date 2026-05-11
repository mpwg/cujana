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
        let locationProvider = FixedLocationCoordinateProvider(coordinate: AppDemoData.coordinate)

        return AppDependencies(
            pollenRepository: DemoPollenRepository(forecasts: AppDemoData.pollenForecasts),
            weatherRepository: DemoWeatherRepository(forecasts: AppDemoData.weatherForecasts),
            environmentalDataRepository: DemoEnvironmentalDataRepository(),
            symptomEntryRepository: DemoSymptomEntryRepository(entries: AppDemoData.symptomEntries),
            locationProvider: locationProvider,
            backgroundLocationAuthorizer: locationProvider
        )
    }
}

private actor DemoEnvironmentalDataRepository: EnvironmentalDataRepository {
    func latestPollenEntry(for coordinate: LocationCoordinate) async throws -> PollenDataEntry? {
        nil
    }

    func latestWeatherEntry(for coordinate: LocationCoordinate) async throws -> WeatherDataEntry? {
        nil
    }

    func savePollenEntries(_ entries: [PollenDataEntry]) async throws {}

    func saveWeatherEntries(_ entries: [WeatherDataEntry]) async throws {}
}
#endif
