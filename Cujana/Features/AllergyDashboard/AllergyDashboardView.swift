import SwiftUI

struct AllergyDashboardView: View {
    @Bindable var viewModel: AllergyDashboardViewModel
    let onStartSymptomEntry: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SpacingToken.section) {
                    content
                }
                .padding(.horizontal, SpacingToken.xl)
                .padding(.vertical, SpacingToken.xl)
            }
            .background(ColorToken.backgroundPrimary)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ColorToken.backgroundPrimary, for: .navigationBar)
#endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Cujana")
                        .font(TypographyToken.headline)
                        .foregroundStyle(ColorToken.textPrimary)
                }
            }
            .task {
                await viewModel.load()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingView
        case .empty(let dashboardContent):
            dashboard(for: dashboardContent, isEmpty: true)
        case .loaded(let dashboardContent):
            dashboard(for: dashboardContent, isEmpty: false)
        case .failure(let message):
            errorView(message: message)
        }
    }

    private func dashboard(for dashboardContent: AllergyDashboardContent, isEmpty: Bool) -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.section) {
            header(dashboardContent)

            if isEmpty {
                emptyState
            }

            pollenSection(items: dashboardContent.pollenItems)
            symptomsSection(items: dashboardContent.symptomItems)
            entryButton
        }
    }

    private func header(_ dashboardContent: AllergyDashboardContent) -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm) {
            Text(dashboardContent.title)
                .font(TypographyToken.largeTitle)
                .foregroundStyle(ColorToken.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(dashboardContent.subtitle)
                .font(TypographyToken.body)
                .foregroundStyle(ColorToken.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(dashboardContent.generatedAtText)
                .font(TypographyToken.footnote)
                .foregroundStyle(ColorToken.textTertiary)
        }
    }

    private func pollenSection(items: [PollenDashboardItem]) -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            DashboardSectionHeader(
                title: "Pollendaten",
                subtitle: items.isEmpty ? "Noch keine Pollenwerte verfügbar." : "Die stärksten Werte für heute."
            )

            if items.isEmpty {
                PlaceholderRow(
                    systemImageName: "leaf",
                    title: "Keine aktuellen Werte",
                    subtitle: "Sobald Daten verfügbar sind, erscheinen sie hier."
                )
            } else {
                VStack(spacing: SpacingToken.md) {
                    ForEach(items) { item in
                        PollenRow(item: item)
                    }
                }
            }
        }
        .cujanaCard()
    }

    private func symptomsSection(items: [SymptomDashboardItem]) -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            DashboardSectionHeader(
                title: "Letzte Symptome",
                subtitle: items.isEmpty ? "Noch keine Einträge vorhanden." : "Deine letzten Beobachtungen."
            )

            if items.isEmpty {
                PlaceholderRow(
                    systemImageName: "heart.text.square",
                    title: "Noch keine Symptome",
                    subtitle: "Erfasse deinen ersten Eintrag, um Muster sichtbar zu machen."
                )
            } else {
                VStack(spacing: SpacingToken.md) {
                    ForEach(items) { item in
                        SymptomRow(item: item)
                    }
                }
            }
        }
        .cujanaCard()
    }

    private var loadingView: some View {
        VStack(alignment: .leading, spacing: SpacingToken.section) {
            Text("Deine Allergie-Übersicht")
                .font(TypographyToken.largeTitle)
                .foregroundStyle(ColorToken.textPrimary)

            VStack(spacing: SpacingToken.lg) {
                ProgressView()
                Text("Pollendaten und Symptome werden geladen ...")
                    .font(TypographyToken.body)
                    .foregroundStyle(ColorToken.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .cujanaCard()
        }
    }

    private var emptyState: some View {
        PlaceholderRow(
            systemImageName: "sparkles",
            title: "Bereit für deine ersten Daten",
            subtitle: "Starte mit einer Symptomerfassung oder prüfe später die Pollenlage."
        )
        .cujanaCard()
    }

    private func errorView(message: String) -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.section) {
            Text("Deine Allergie-Übersicht")
                .font(TypographyToken.largeTitle)
                .foregroundStyle(ColorToken.textPrimary)

            VStack(alignment: .leading, spacing: SpacingToken.lg) {
                PlaceholderRow(
                    systemImageName: "exclamationmark.triangle",
                    title: "Nicht geladen",
                    subtitle: message
                )

                Button {
                    Task {
                        await viewModel.load()
                    }
                } label: {
                    Text("Erneut laden")
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .cujanaCard()
        }
    }

    private var entryButton: some View {
        Button(action: onStartSymptomEntry) {
            Label("Symptom erfassen", systemImage: "plus")
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

#Preview {
    AllergyDashboardView(
        viewModel: AppDemoData.makeDashboardViewModel(),
        onStartSymptomEntry: {}
    )
}

private struct DashboardSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs) {
            Text(title)
                .font(TypographyToken.headline)
                .foregroundStyle(ColorToken.textPrimary)

            Text(subtitle)
                .font(TypographyToken.footnote)
                .foregroundStyle(ColorToken.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct PollenRow: View {
    let item: PollenDashboardItem

    var body: some View {
        HStack(alignment: .top, spacing: SpacingToken.md) {
            DashboardIcon(systemImageName: item.systemImageName, background: item.background)

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                HStack(alignment: .firstTextBaseline, spacing: SpacingToken.sm) {
                    Text(item.title)
                        .font(TypographyToken.bodyEmphasized)
                        .foregroundStyle(ColorToken.textPrimary)

                    Spacer(minLength: SpacingToken.sm)

                    Text(item.levelText)
                        .font(TypographyToken.footnote)
                        .foregroundStyle(ColorToken.brandPrimary)
                        .cujanaChip()
                }

                Text(item.levelDescription)
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct SymptomRow: View {
    let item: SymptomDashboardItem

    var body: some View {
        HStack(alignment: .top, spacing: SpacingToken.md) {
            DashboardIcon(systemImageName: item.systemImageName, background: item.background)

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                HStack(alignment: .firstTextBaseline, spacing: SpacingToken.sm) {
                    Text(item.title)
                        .font(TypographyToken.bodyEmphasized)
                        .foregroundStyle(ColorToken.textPrimary)

                    Spacer(minLength: SpacingToken.sm)

                    Text(item.severityText)
                        .font(TypographyToken.footnote)
                        .foregroundStyle(ColorToken.brandPrimary)
                        .cujanaChip()
                }

                Text(item.dateText)
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textSecondary)

                if let noteText = item.noteText {
                    Text(noteText)
                        .font(TypographyToken.footnote)
                        .foregroundStyle(ColorToken.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

private struct PlaceholderRow: View {
    let systemImageName: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: SpacingToken.md) {
            DashboardIcon(systemImageName: systemImageName, background: ChipToken.calmBackground)

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text(title)
                    .font(TypographyToken.bodyEmphasized)
                    .foregroundStyle(ColorToken.textPrimary)

                Text(subtitle)
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct DashboardIcon: View {
    let systemImageName: String
    let background: Color

    var body: some View {
        Image(systemName: systemImageName)
            .font(TypographyToken.bodyEmphasized)
            .foregroundStyle(ColorToken.brandPrimary)
            .frame(width: SelectionToken.size, height: SelectionToken.size)
            .background(background)
            .clipShape(Circle())
    }
}
