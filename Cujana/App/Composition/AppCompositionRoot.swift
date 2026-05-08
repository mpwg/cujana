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
            telemetryService: telemetryService
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
            loadPollenUseCase: LoadPollenForecastUseCase(repository: dependencies.pollenRepository),
            locationProvider: dependencies.locationProvider
        )
    }

    private func makeLoadAllergyOverviewUseCase() -> LoadAllergyOverviewUseCase {
        LoadAllergyOverviewUseCase(
            pollenRepository: dependencies.pollenRepository,
            symptomEntryRepository: dependencies.symptomEntryRepository
        )
    }

    private func makeSaveAllergySymptomEntryUseCase() -> SaveAllergySymptomEntryUseCase {
        SaveAllergySymptomEntryUseCase(repository: dependencies.symptomEntryRepository)
    }
}
