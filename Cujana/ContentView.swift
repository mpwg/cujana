import SwiftUI

struct ContentView: View {
    @Bindable private var telemetryService: AppTelemetryService
    @State private var dashboardViewModel: AllergyDashboardViewModel
    @State private var entryListViewModel: EntryListViewModel
    @State private var symptomEntryViewModel: SymptomEntryViewModel
    @State private var isShowingSymptomEntry = false
    private let backgroundLocationAuthorizer: (any BackgroundLocationAuthorizing)?

    init(
        dashboardViewModel: AllergyDashboardViewModel,
        entryListViewModel: EntryListViewModel,
        symptomEntryViewModel: SymptomEntryViewModel,
        backgroundLocationAuthorizer: (any BackgroundLocationAuthorizing)? = nil,
        telemetryService: AppTelemetryService
    ) {
        self.dashboardViewModel = dashboardViewModel
        self.entryListViewModel = entryListViewModel
        self.symptomEntryViewModel = symptomEntryViewModel
        self.backgroundLocationAuthorizer = backgroundLocationAuthorizer
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

            SettingsView(
                telemetryService: telemetryService,
                backgroundLocationAuthorizer: backgroundLocationAuthorizer
            )
                .tabItem {
                    Label("Einstellungen", systemImage: "gearshape")
                }
        }
        .background(ColorToken.backgroundPrimary)
        .tint(ColorToken.accentPrimary)
#if os(iOS)
        .toolbarBackground(ColorToken.cardBackground.opacity(TabBarToken.backgroundOpacity), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
#endif
        .sheet(
            isPresented: $isShowingSymptomEntry,
            onDismiss: {
                Task {
                    await dashboardViewModel.load()
                    await entryListViewModel.load()
                }
            },
            content: {
                SymptomEntryView(
                    viewModel: symptomEntryViewModel,
                    onSaved: { savedEntry in
                        entryListViewModel.upsertLocal(savedEntry)
                    }
                )
#if os(iOS)
                    .presentationCornerRadius(TabBarToken.sheetCornerRadius)
                    .presentationBackground(ColorToken.backgroundPrimary)
#endif
            }
        )
    }
}
