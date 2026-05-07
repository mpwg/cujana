import SwiftUI

struct ContentView: View {
    @State private var dashboardViewModel: AllergyDashboardViewModel
    @State private var symptomEntryViewModel: SymptomEntryViewModel
    @State private var isShowingSymptomEntry = false

    init(
        dashboardViewModel: AllergyDashboardViewModel,
        symptomEntryViewModel: SymptomEntryViewModel
    ) {
        self.dashboardViewModel = dashboardViewModel
        self.symptomEntryViewModel = symptomEntryViewModel
    }

    var body: some View {
        AllergyDashboardView(
            viewModel: dashboardViewModel,
            onStartSymptomEntry: {
                isShowingSymptomEntry = true
            }
        )
        .sheet(
            isPresented: $isShowingSymptomEntry,
            onDismiss: {
                Task {
                    await dashboardViewModel.load()
                }
            },
            content: {
                SymptomEntryView(viewModel: symptomEntryViewModel)
            }
        )
    }
}

#Preview {
    let repository = InMemorySymptomEntryRepository()
    let saveUseCase = SaveAllergySymptomEntryUseCase(repository: repository)
    let loadUseCase = LoadAllergyOverviewUseCase(
        pollenRepository: EmptyPollenRepository(),
        symptomEntryRepository: repository
    )

    ContentView(
        dashboardViewModel: AllergyDashboardViewModel(
            loadUseCase: loadUseCase,
            coordinate: .previewVienna
        ),
        symptomEntryViewModel: SymptomEntryViewModel(saveUseCase: saveUseCase)
    )
}

private extension LocationCoordinate {
    static var previewVienna: LocationCoordinate {
        guard let coordinate = try? LocationCoordinate(latitude: 48.2082, longitude: 16.3738) else {
            fatalError("Preview coordinate must be valid.")
        }

        return coordinate
    }
}

private struct EmptyPollenRepository: PollenRepository {
    func pollenForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [PollenForecast] {
        []
    }
}
