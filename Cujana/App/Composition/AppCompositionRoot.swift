import SwiftUI

@MainActor
struct AppCompositionRoot {
    private let dependencies: AppDependencies
    private let symptomEntryChangeStore: SymptomEntryChangeStore

    init(
        dependencies: AppDependencies,
        symptomEntryChangeStore: SymptomEntryChangeStore = SymptomEntryChangeStore()
    ) {
        self.dependencies = dependencies
        self.symptomEntryChangeStore = symptomEntryChangeStore
    }

    static func production() throws -> AppCompositionRoot {
        AppCompositionRoot(dependencies: try .production())
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
        SymptomEntryViewModel(
            saveUseCase: makeSaveAllergySymptomEntryUseCase(),
            entryChangePublisher: symptomEntryChangeStore
        )
    }

    private func makeEntryListViewModel() -> EntryListViewModel {
        EntryListViewModel(
            loadEntriesUseCase: LoadAllergySymptomEntriesUseCase(repository: dependencies.symptomEntryRepository),
            saveEntryUseCase: makeSaveAllergySymptomEntryUseCase(),
            deleteEntryUseCase: DeleteAllergySymptomEntryUseCase(repository: dependencies.symptomEntryRepository),
            loadPollenUseCase: LoadPollenForecastUseCase(repository: dependencies.pollenRepository),
            entryChangeObserver: symptomEntryChangeStore,
            entryChangePublisher: symptomEntryChangeStore,
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
