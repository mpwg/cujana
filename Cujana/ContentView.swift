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
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .home:
                    AllergyDashboardView(
                        viewModel: dashboardViewModel,
                        onStartSymptomEntry: {
                            isShowingSymptomEntry = true
                        }
                    )
                case .entries:
                    EntryListView(viewModel: entryListViewModel)
                case .settings:
                    SettingsView(telemetryService: telemetryService)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)

            FloatingTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, SpacingToken.xl)
                .padding(.top, SpacingToken.sm)
                .padding(.bottom, SpacingToken.lg)
        }
        .background(ColorToken.backgroundPrimary)
        .animation(.easeInOut(duration: 0.18), value: selectedTab)
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
            "Ich"
        }
    }

    var systemImageName: String {
        switch self {
        case .home:
            "leaf"
        case .entries:
            "list.bullet.rectangle"
        case .settings:
            "person"
        }
    }
}

private struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: SpacingToken.sm) {
            ForEach(AppTab.allCases) { tab in
                FloatingTabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    selectedTab = tab
                }
            }
        }
        .padding(.horizontal, SpacingToken.sm)
        .padding(.vertical, SpacingToken.xs)
        .background(ColorToken.cardBackground.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusXLarge, style: .continuous))
        .softShadow(ShadowToken.floating)
        .accessibilityElement(children: .contain)
    }
}

private struct FloatingTabBarItem: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: tab.systemImageName)
                    .font(.system(.body, design: .rounded).weight(.light))

                Text(tab.title)
                    .font(TypographyToken.caption.weight(isSelected ? .semibold : .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .foregroundStyle(isSelected ? ColorToken.accentPrimary : ColorToken.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background {
                if isSelected {
                    OrganicTabSelection()
                        .fill(ColorToken.accentSoft)
                        .scaleEffect(x: 0.92, y: 0.78)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct OrganicTabSelection: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control1: CGPoint(x: rect.maxX * 0.78, y: rect.minY),
            control2: CGPoint(x: rect.maxX, y: rect.maxY * 0.28)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX, y: rect.maxY * 0.8),
            control2: CGPoint(x: rect.maxX * 0.7, y: rect.maxY)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.midY),
            control1: CGPoint(x: rect.maxX * 0.24, y: rect.maxY),
            control2: CGPoint(x: rect.minX, y: rect.maxY * 0.76)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.minX, y: rect.maxY * 0.24),
            control2: CGPoint(x: rect.maxX * 0.24, y: rect.minY)
        )
        path.closeSubpath()
        return path
    }
}
