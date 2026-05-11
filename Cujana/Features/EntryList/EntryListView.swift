import SwiftUI

struct EntryListView: View {
    @Bindable var viewModel: EntryListViewModel
    @State private var editingEntry: HealthEntry?
    @State private var pendingDeleteEntry: HealthEntry?

    var body: some View {
        NavigationStack {
            content
            .background(EntryListToken.screenBackground)
            .navigationTitle("Einträge")
#if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(EntryListToken.screenBackground, for: .navigationBar)
#endif
            .task {
                await viewModel.load()
            }
            .task {
                await viewModel.observeEntryChanges()
            }
            .sheet(item: $editingEntry) { entry in
                SymptomEntryView(
                    viewModel: viewModel.makeEditorViewModel(for: entry)
                )
#if os(iOS)
                .presentationCornerRadius(TabBarToken.sheetCornerRadius)
                .presentationBackground(ColorToken.backgroundPrimary)
#endif
            }
            .confirmationDialog(
                "Eintrag löschen?",
                isPresented: isDeleteDialogPresented,
                titleVisibility: .visible,
                actions: {
                    if let pendingDeleteEntry {
                        Button("Löschen", role: .destructive) {
                            Task {
                                await viewModel.delete(pendingDeleteEntry)
                            }
                        }
                    }

                    Button("Abbrechen", role: .cancel) {}
                },
                message: {
                    Text("Diese Aktion kann nicht rückgängig gemacht werden.")
                }
            )
        }
    }

    private var isDeleteDialogPresented: Binding<Bool> {
        Binding(
            get: { pendingDeleteEntry != nil },
            set: { isPresented in
                if isPresented == false {
                    pendingDeleteEntry = nil
                }
            }
        )
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingView
        case .empty(let content):
            scrollContent {
                emptyView(content)
            }
        case .loaded(let content):
            listView(content)
        case .failure(let message):
            scrollContent {
                errorView(message: message)
            }
        }
    }

    private func listView(_ content: EntryListContent) -> some View {
        List {
            ForEach(content.sections) { section in
                Section {
                    ForEach(section.entries) { item in
                        TimelineEntryRow(
                            item: item,
                            onEdit: { editingEntry = item.entry },
                            onDelete: { pendingDeleteEntry = item.entry }
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(
                            top: 0,
                            leading: EntryListToken.screenHorizontalPadding,
                            bottom: EntryListToken.cardSpacing,
                            trailing: EntryListToken.screenHorizontalPadding
                        ))
                    }
                } header: {
                    Text(section.title)
                        .font(EntryListToken.dayHeaderFont)
                        .foregroundStyle(EntryListToken.dayHeaderText)
                        .fixedSize(horizontal: false, vertical: true)
                        .textCase(nil)
                        .padding(.top, SpacingToken.sm)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .contentMargins(.bottom, SpacingToken.xxl, for: .scrollContent)
    }

    private var loadingView: some View {
        scrollContent {
            VStack(spacing: SpacingToken.lg) {
                ProgressView()
                Text("Einträge werden geladen ...")
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

    private func scrollContent<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpacingToken.section) {
                content()
            }
            .padding(.horizontal, EntryListToken.screenHorizontalPadding)
            .padding(.top, SpacingToken.sm)
            .padding(.bottom, SpacingToken.xxl)
        }
    }
}

private struct TimelineEntryRow: View {
    let item: JournalEntryItem
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: EntryListToken.timelineCardSpacing) {
            TimelineMarker()
            EntryCard(item: item)
                .onTapGesture(perform: onEdit)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(action: onDelete) {
                        Label("Löschen", systemImage: "trash")
                    }
                    .tint(.red)

                    Button(action: onEdit) {
                        Label("Bearbeiten", systemImage: "pencil")
                    }
                    .tint(ColorToken.accentPrimary)
                }
                .accessibilityAction(named: "Bearbeiten", onEdit)
                .accessibilityAction(named: "Löschen", onDelete)
        }
    }
}

private struct TimelineMarker: View {
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(EntryListToken.timeline)
                .frame(width: EntryListToken.timelineLineWidth)
                .padding(.top, EntryListToken.timelineLineTopInset)
                .padding(.bottom, EntryListToken.timelineLineBottomInset)

            Circle()
                .fill(EntryListToken.timelineDot)
                .frame(width: EntryListToken.timelineDotSize, height: EntryListToken.timelineDotSize)
                .padding(.top, EntryListToken.timelineDotTopInset)
        }
        .frame(width: EntryListToken.timelineWidth)
        .frame(maxHeight: .infinity)
        .accessibilityHidden(true)
    }
}

private struct EntryCard: View {
    let item: JournalEntryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(item.timeText)
                .font(EntryListToken.timeFont)
                .foregroundStyle(EntryListToken.timeText)

            FlexibleSymptomChips(items: item.symptoms)
                .padding(.top, EntryListToken.timeSymptomSpacing)

            if let noteText = item.noteText {
                Text(noteText)
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, SpacingToken.md)
            }

            HStack(alignment: .firstTextBaseline, spacing: SpacingToken.xs) {
                Image(systemName: item.contextSystemImageName)
                    .font(EntryListToken.contextIconFont)
                    .foregroundStyle(EntryListToken.contextText)

                Text(item.contextText)
                    .font(EntryListToken.contextFont)
                    .foregroundStyle(EntryListToken.contextText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, EntryListToken.symptomContextSpacing)
        }
        .padding(.top, EntryListToken.cardPaddingTop)
        .padding(.horizontal, EntryListToken.cardPaddingHorizontal)
        .padding(.bottom, EntryListToken.cardPaddingBottom)
        .frame(maxWidth: .infinity, alignment: .leading)
        .entryJournalSurface()
        .contentShape(RoundedRectangle(cornerRadius: EntryListToken.cardCornerRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
        .animation(EntryListToken.journalAnimation, value: item.symptoms)
    }

    private var accessibilityText: String {
        [
            item.timeText,
            item.symptoms.map(\.title).joined(separator: ", "),
            item.contextText,
            item.noteText
        ]
        .compactMap(\.self)
        .joined(separator: ", ")
    }
}

private struct EntryJournalSurfaceModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(
                    .regular.tint(EntryListToken.cardGlassTint),
                    in: .rect(cornerRadius: EntryListToken.cardCornerRadius)
                )
                .softShadow(EntryListToken.cardShadow)
        } else {
            content
                .background(EntryListToken.cardFallbackBackground)
                .clipShape(RoundedRectangle(cornerRadius: EntryListToken.cardCornerRadius, style: .continuous))
                .softShadow(EntryListToken.cardShadow)
        }
    }
}

private extension View {
    func entryJournalSurface() -> some View {
        modifier(EntryJournalSurfaceModifier())
    }
}

private struct FlexibleSymptomChips: View {
    let items: [JournalEntrySymptomItem]

    var body: some View {
        FlowLayout(spacing: EntryListToken.chipSpacing, rowSpacing: EntryListToken.chipRowSpacing) {
            ForEach(items) { item in
                Text(item.title)
                    .font(EntryListToken.symptomChipFont)
                    .foregroundStyle(item.foreground)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.horizontal, EntryListToken.symptomChipPaddingH)
                    .padding(.vertical, EntryListToken.symptomChipPaddingV)
                    .frame(minHeight: EntryListToken.symptomChipMinHeight)
                    .background(item.background)
                    .clipShape(RoundedRectangle(
                        cornerRadius: EntryListToken.symptomChipCornerRadius,
                        style: .continuous
                    ))
                    .transition(.scale(scale: 0.98).combined(with: .opacity))
                    .accessibilityLabel(item.title)
            }
        }
        .animation(EntryListToken.journalAnimation, value: items)
    }
}

private struct FlowLayout: Layout {
    let spacing: CGFloat
    let rowSpacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        let rows = rows(for: subviews, proposal: proposal)
        let height = rows.reduce(CGFloat.zero) { result, row in
            result + row.height
        } + rowSpacing * CGFloat(max(rows.count - 1, 0))

        return CGSize(width: proposal.width ?? rows.map(\.width).max() ?? 0, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        let rows = rows(for: subviews, proposal: ProposedViewSize(width: bounds.width, height: proposal.height))
        var y = bounds.minY

        for row in rows {
            var x = bounds.minX

            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(
                    at: CGPoint(x: x, y: y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(size)
                )
                x += size.width + spacing
            }

            y += row.height + rowSpacing
        }
    }

    private func rows(for subviews: Subviews, proposal: ProposedViewSize) -> [FlowRow] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [FlowRow] = []
        var current = FlowRow()

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let proposedWidth = current.indices.isEmpty ? size.width : current.width + spacing + size.width

            if proposedWidth > maxWidth && current.indices.isEmpty == false {
                rows.append(current)
                current = FlowRow()
            }

            current.indices.append(index)
            current.width = current.width == 0 ? size.width : current.width + spacing + size.width
            current.height = max(current.height, size.height)
        }

        if current.indices.isEmpty == false {
            rows.append(current)
        }

        return rows
    }

    private struct FlowRow {
        var indices: [Subviews.Index] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
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
