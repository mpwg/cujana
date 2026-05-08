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
