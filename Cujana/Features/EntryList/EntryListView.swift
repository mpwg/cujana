import SwiftUI

struct EntryListView: View {
    @Bindable var viewModel: EntryListViewModel

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
                    Text("Einträge")
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
        case .empty(let content):
            emptyView(content)
        case .loaded(let content):
            listView(content)
        case .failure(let message):
            errorView(message: message)
        }
    }

    private func listView(_ content: EntryListContent) -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.section) {
            header(content)

            LazyVStack(spacing: SpacingToken.lg) {
                ForEach(content.items) { item in
                    EntryCard(item: item)
                }
            }
        }
    }

    private func header(_ content: EntryListContent) -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm) {
            Text(content.title)
                .font(TypographyToken.largeTitle)
                .foregroundStyle(ColorToken.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(content.subtitle)
                .font(TypographyToken.body)
                .foregroundStyle(ColorToken.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(content.generatedAtText)
                .font(TypographyToken.footnote)
                .foregroundStyle(ColorToken.textTertiary)
        }
    }

    private var loadingView: some View {
        VStack(alignment: .leading, spacing: SpacingToken.section) {
            Text("Alle Einträge")
                .font(TypographyToken.largeTitle)
                .foregroundStyle(ColorToken.textPrimary)

            VStack(spacing: SpacingToken.lg) {
                ProgressView()
                Text("Einträge, Polleninfos und Wetterstatus werden geladen ...")
                    .font(TypographyToken.body)
                    .foregroundStyle(ColorToken.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .cujanaCard()
        }
    }

    private func emptyView(_ content: EntryListContent) -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.section) {
            header(content)

            EntryPlaceholderRow(
                systemImageName: "list.bullet.rectangle",
                title: "Noch keine Einträge",
                subtitle: "Sobald du Symptome erfasst, erscheinen sie hier mit Datum, Wetterstatus und Polleninfos."
            )
            .cujanaCard()
        }
    }

    private func errorView(message: String) -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.section) {
            Text("Alle Einträge")
                .font(TypographyToken.largeTitle)
                .foregroundStyle(ColorToken.textPrimary)

            VStack(alignment: .leading, spacing: SpacingToken.lg) {
                EntryPlaceholderRow(
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
}

private struct EntryCard: View {
    let item: EntryListItem

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            HStack(alignment: .top, spacing: SpacingToken.md) {
                EntryIcon(systemImageName: item.symptomSystemImageName, background: item.symptomBackground)

                VStack(alignment: .leading, spacing: SpacingToken.xs) {
                    HStack(alignment: .firstTextBaseline, spacing: SpacingToken.sm) {
                        Text(item.symptomTitle)
                            .font(TypographyToken.headline)
                            .foregroundStyle(ColorToken.textPrimary)

                        Spacer(minLength: SpacingToken.sm)

                        Text(item.severityText)
                            .font(TypographyToken.footnote)
                            .foregroundStyle(ColorToken.accentPrimary)
                            .cujanaChip()
                    }

                    Text("\(item.dateText), \(item.timeText)")
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

            Divider()

            EntryInfoBlock(
                systemImageName: "cloud.sun",
                title: item.weatherTitle,
                subtitle: item.weatherDescription
            )

            VStack(alignment: .leading, spacing: SpacingToken.md) {
                EntryInfoBlock(
                    systemImageName: "leaf",
                    title: "Polleninfos",
                    subtitle: item.pollenItems.isEmpty
                        ? "Keine Pollenwerte für dieses Datum."
                        : "Belastung am Tag des Eintrags."
                )

                if !item.pollenItems.isEmpty {
                    FlexiblePollenChips(items: item.pollenItems)
                }
            }
        }
        .cujanaCard()
    }
}

private struct EntryInfoBlock: View {
    let systemImageName: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: SpacingToken.md) {
            EntryIcon(systemImageName: systemImageName, background: ChipToken.calmBackground)

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

private struct FlexiblePollenChips: View {
    let items: [EntryListPollenItem]

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(
                    .adaptive(minimum: EntryListToken.pollenChipGridMinimumWidth),
                    spacing: SpacingToken.sm,
                    alignment: .leading
                )
            ],
            alignment: .leading,
            spacing: SpacingToken.sm
        ) {
            ForEach(items) { item in
                VStack(alignment: .leading, spacing: SpacingToken.xs) {
                    Text(item.title)
                        .font(TypographyToken.footnote)
                        .foregroundStyle(ColorToken.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(item.levelText)
                        .font(TypographyToken.caption)
                        .foregroundStyle(ColorToken.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(.horizontal, SpacingToken.md)
                .padding(.vertical, SpacingToken.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(item.background)
                .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusSmall, style: .continuous))
            }
        }
    }
}

private struct EntryPlaceholderRow: View {
    let systemImageName: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: SpacingToken.md) {
            EntryIcon(systemImageName: systemImageName, background: ChipToken.calmBackground)

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

private struct EntryIcon: View {
    let systemImageName: String
    let background: Color

    var body: some View {
        Image(systemName: systemImageName)
            .font(TypographyToken.bodyEmphasized)
            .foregroundStyle(ColorToken.accentPrimary)
            .frame(width: SelectionToken.size, height: SelectionToken.size)
            .background(background)
            .clipShape(Circle())
    }
}

#if DEBUG
#Preview {
    EntryListView(viewModel: AppDemoData.makeEntryListViewModel())
}
#endif
