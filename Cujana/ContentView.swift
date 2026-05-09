import SwiftUI

struct ContentView: View {
    @Bindable private var telemetryService: AppTelemetryService
    @State private var dashboardViewModel: AllergyDashboardViewModel
    @State private var entryListViewModel: EntryListViewModel
    @State private var symptomEntryViewModel: SymptomEntryViewModel
    @State private var selectedTab: AppTab = .home
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
        TabView(selection: $selectedTab) {
            AllergyDashboardView(
                viewModel: dashboardViewModel,
                onStartSymptomEntry: {
                    isShowingSymptomEntry = true
                }
            )
            .tabItem {
                Label(AppTab.home.title, systemImage: AppTab.home.systemImageName)
            }
            .tag(AppTab.home)

            EntryListView(viewModel: entryListViewModel)
                .tabItem {
                    Label(AppTab.entries.title, systemImage: AppTab.entries.systemImageName)
                }
                .tag(AppTab.entries)

            SettingsView(telemetryService: telemetryService)
                .tabItem {
                    Label(AppTab.settings.title, systemImage: AppTab.settings.systemImageName)
                }
                .tag(AppTab.settings)
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

private enum AppTab: CaseIterable, Identifiable {
    case home
    case entries
    case settings

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .home:
            "Home"
        case .entries:
            "Einträge"
        case .settings:
            "Einstellungen"
        }
    }

    var systemImageName: String {
        switch self {
        case .home:
            "leaf"
        case .entries:
            "list.bullet.rectangle"
        case .settings:
            "gearshape"
        }
    }
}
