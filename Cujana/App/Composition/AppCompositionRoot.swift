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

    func makeContentView() -> ContentView {
        ContentView(
            dashboardViewModel: makeAllergyDashboardViewModel(),
            symptomEntryViewModel: makeSymptomEntryViewModel()
        )
    }

    @ViewBuilder
    private func makeScreenshotView(screen: AppScreenshotScreen) -> some View {
        switch screen {
        case .dashboard:
            makeContentView()
        case .entry:
            SymptomEntryView(viewModel: makeSymptomEntryViewModel())
        }
    }

    private func makeAllergyDashboardViewModel() -> AllergyDashboardViewModel {
        if dependencies.usesDemoData {
            return AppDemoData.makeDashboardViewModel()
        }

        return AllergyDashboardViewModel(
            loadUseCase: makeLoadAllergyOverviewUseCase(),
            locationProvider: dependencies.locationProvider,
            coordinate: dependencies.defaultCoordinate
        )
    }

    private func makeSymptomEntryViewModel() -> SymptomEntryViewModel {
        if dependencies.usesDemoData {
            return AppDemoData.makeSymptomEntryViewModel()
        }

        return SymptomEntryViewModel(saveUseCase: makeSaveAllergySymptomEntryUseCase())
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
