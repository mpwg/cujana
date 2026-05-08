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

    func makeContentView() -> ContentView {
        ContentView(
            dashboardViewModel: makeAllergyDashboardViewModel(),
            symptomEntryViewModel: makeSymptomEntryViewModel()
        )
    }

    private func makeAllergyDashboardViewModel() -> AllergyDashboardViewModel {
        AllergyDashboardViewModel(
            loadUseCase: makeLoadAllergyOverviewUseCase(),
            locationProvider: dependencies.locationProvider,
            coordinate: dependencies.defaultCoordinate
        )
    }

    private func makeSymptomEntryViewModel() -> SymptomEntryViewModel {
        SymptomEntryViewModel(saveUseCase: makeSaveAllergySymptomEntryUseCase())
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
