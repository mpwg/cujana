import SwiftUI

struct ContentView: View {
    @Bindable private var telemetryService: AppTelemetryService
    @State private var dashboardViewModel: AllergyDashboardViewModel
    @State private var symptomEntryViewModel: SymptomEntryViewModel
    @State private var isShowingSymptomEntry = false

    init(
        dashboardViewModel: AllergyDashboardViewModel,
        symptomEntryViewModel: SymptomEntryViewModel,
        telemetryService: AppTelemetryService
    ) {
        self.dashboardViewModel = dashboardViewModel
        self.symptomEntryViewModel = symptomEntryViewModel
        self.telemetryService = telemetryService
    }

    var body: some View {
        TabView {
            AllergyDashboardView(
                viewModel: dashboardViewModel,
                onStartSymptomEntry: {
                    isShowingSymptomEntry = true
                }
            )
            .tabItem {
                Label("Cujana", systemImage: "leaf")
            }

            SettingsView(telemetryService: telemetryService)
                .tabItem {
                    Label("Einstellungen", systemImage: "gearshape")
                }
        }
        .tint(ColorToken.brandPrimary)
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
