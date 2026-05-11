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

            LazyVStack(alignment: .leading, spacing: SpacingToken.xl) {
                ForEach(content.sections) { section in
                    EntryDaySection(section: section)
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
                subtitle: "Sobald du Symptome erfasst, erscheinen deine Check-ins hier als ruhiges Journal."
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

private struct EntryDaySection: View {
    let section: EntryListDaySection

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            Text(section.title.uppercased())
                .font(TypographyToken.caption)
                .foregroundStyle(ColorToken.textTertiary)

            LazyVStack(spacing: SpacingToken.md) {
                ForEach(section.entries) { item in
                    EntryCard(item: item)
                }
            }
        }
    }
}

private struct EntryCard: View {
    let item: JournalEntryItem

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            HStack(alignment: .top, spacing: SpacingToken.md) {
                VStack(alignment: .leading, spacing: SpacingToken.xs) {
                    Text(item.dateText)
                        .font(TypographyToken.headline)
                        .foregroundStyle(ColorToken.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(item.timeText)
                        .font(TypographyToken.caption)
                        .foregroundStyle(ColorToken.textSecondary)
                }

                Spacer(minLength: SpacingToken.sm)

                Text(item.severityText)
                    .font(TypographyToken.caption)
                    .foregroundStyle(ColorToken.accentPrimary)
                    .padding(.horizontal, EntryListToken.severityPillPaddingH)
                    .frame(height: EntryListToken.severityPillHeight)
                    .background(item.severityBackground)
                    .clipShape(Capsule())
            }

            FlexibleSymptomChips(items: item.symptoms)

            if let noteText = item.noteText {
                Text(noteText)
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let contextText = item.contextText {
                HStack(spacing: SpacingToken.xs) {
                    Image(systemName: item.contextSystemImageName)
                        .font(TypographyToken.caption)
                        .foregroundStyle(ColorToken.textTertiary)

                    Text(contextText)
                        .font(TypographyToken.caption)
                        .foregroundStyle(ColorToken.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(EntryListToken.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ColorToken.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: EntryListToken.cardCornerRadius, style: .continuous))
        .softShadow(EntryListToken.cardShadow)
    }
}

private struct FlexibleSymptomChips: View {
    let items: [JournalEntrySymptomItem]

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(
                    .adaptive(minimum: EntryListToken.symptomChipGridMinimumWidth),
                    spacing: SpacingToken.sm,
                    alignment: .leading
                )
            ],
            alignment: .leading,
            spacing: SpacingToken.sm
        ) {
            ForEach(items) { item in
                Text(item.title)
                    .font(TypographyToken.caption)
                    .foregroundStyle(ColorToken.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .padding(.horizontal, EntryListToken.symptomChipPaddingH)
                    .frame(height: EntryListToken.symptomChipHeight)
                    .frame(maxWidth: .infinity, alignment: .center)
                .background(item.background)
                    .clipShape(Capsule())
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
