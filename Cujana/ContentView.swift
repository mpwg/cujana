import SwiftUI

struct ContentView: View {
    @Bindable private var telemetryService: AppTelemetryService
    @State private var dashboardViewModel: AllergyDashboardViewModel
    @State private var entryListViewModel: EntryListViewModel
    @State private var symptomEntryViewModel: SymptomEntryViewModel
    @State private var isShowingSymptomEntry = false

    init(
        dashboardViewModel: AllergyDashboardViewModel,
        entryListViewModel: EntryListViewModel,
        symptomEntryViewModel: SymptomEntryViewModel,
        telemetryService: AppTelemetryService
    ) {
        self.dashboardViewModel = dashboardViewModel
        self.entryListViewModel = entryListViewModel
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
                Label("Home", systemImage: "leaf")
            }

            EntryListView(viewModel: entryListViewModel)
                .tabItem {
                    Label("Einträge", systemImage: "list.bullet.rectangle")
                }

            SettingsView(telemetryService: telemetryService)
                .tabItem {
                    Label("Einstellungen", systemImage: "gearshape")
                }
        }
        .background(ColorToken.backgroundPrimary)
        .tint(ColorToken.accentPrimary)
        .sheet(
            isPresented: $isShowingSymptomEntry,
            onDismiss: {
                Task {
                    await dashboardViewModel.load()
                    await entryListViewModel.load()
                }
            },
            content: {
                SymptomEntryView(viewModel: symptomEntryViewModel)
            }
        )
    }
}
