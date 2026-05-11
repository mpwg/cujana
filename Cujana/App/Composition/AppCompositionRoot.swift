import SwiftUI

@MainActor
struct AppCompositionRoot {
    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    static func production() -> AppCompositionRoot {
        AppCompositionRoot(dependencies: .production())
    }

    func makeContentView(telemetryService: AppTelemetryService) -> ContentView {
        ContentView(
            dashboardViewModel: makeAllergyDashboardViewModel(),
            entryListViewModel: makeEntryListViewModel(),
            symptomEntryViewModel: makeSymptomEntryViewModel(),
            backgroundLocationAuthorizer: dependencies.backgroundLocationAuthorizer,
            telemetryService: telemetryService
        )
    }

    func makeEnvironmentalDataRefreshCoordinator() -> EnvironmentalDataRefreshCoordinator {
        EnvironmentalDataRefreshCoordinator(
            refreshUseCase: makeRefreshEnvironmentalDataUseCase(),
            locationProvider: dependencies.locationProvider,
            backgroundLocationAuthorizer: dependencies.backgroundLocationAuthorizer
        )
    }

    private func makeAllergyDashboardViewModel() -> AllergyDashboardViewModel {
        AllergyDashboardViewModel(
            loadUseCase: makeLoadAllergyOverviewUseCase(),
            locationProvider: dependencies.locationProvider
        )
    }

    private func makeSymptomEntryViewModel() -> SymptomEntryViewModel {
        SymptomEntryViewModel(saveUseCase: makeSaveAllergySymptomEntryUseCase())
    }

    private func makeEntryListViewModel() -> EntryListViewModel {
        EntryListViewModel(
            loadEntriesUseCase: LoadAllergySymptomEntriesUseCase(repository: dependencies.symptomEntryRepository),
            saveEntryUseCase: makeSaveAllergySymptomEntryUseCase(),
            deleteEntryUseCase: DeleteAllergySymptomEntryUseCase(repository: dependencies.symptomEntryRepository),
            loadPollenUseCase: LoadPollenForecastUseCase(repository: dependencies.pollenRepository),
            locationProvider: dependencies.locationProvider
        )
    }

    private func makeLoadAllergyOverviewUseCase() -> LoadAllergyOverviewUseCase {
        LoadAllergyOverviewUseCase(
            pollenRepository: dependencies.pollenRepository,
            weatherRepository: dependencies.weatherRepository,
            symptomEntryRepository: dependencies.symptomEntryRepository
        )
    }

    private func makeSaveAllergySymptomEntryUseCase() -> SaveAllergySymptomEntryUseCase {
        SaveAllergySymptomEntryUseCase(repository: dependencies.symptomEntryRepository)
    }

    private func makeRefreshEnvironmentalDataUseCase() -> RefreshEnvironmentalDataUseCase {
        RefreshEnvironmentalDataUseCase(
            pollenRepository: dependencies.pollenRepository,
            weatherRepository: dependencies.weatherRepository,
            environmentalDataRepository: dependencies.environmentalDataRepository
        )
    }
}
