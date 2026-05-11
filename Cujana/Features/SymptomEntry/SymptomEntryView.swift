import SwiftUI

struct SymptomEntryView: View {
    @Bindable var viewModel: EntryEditorViewModel
    var onSaved: ((HealthEntry) -> Void)?

    var body: some View {
        EntryFormView(viewModel: viewModel, onSaved: onSaved)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var viewModel: EntryEditorViewModel
    var onSaved: ((HealthEntry) -> Void)?
    @Namespace private var symptomSelectionNamespace
    @Namespace private var severitySelectionNamespace
    @State private var isDateExpanded = false
    @State private var isInfoPresented = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SymptomCheckInToken.sectionSpacing) {
                    EntryFormSections(
                        viewModel: viewModel,
                        symptomSelectionNamespace: symptomSelectionNamespace,
                        severitySelectionNamespace: severitySelectionNamespace,
                        isDateExpanded: $isDateExpanded,
                        reduceMotion: reduceMotion
                    )
                    statusMessage
                }
                .padding(.horizontal, SymptomCheckInToken.screenHorizontalPadding)
                .padding(.top, SymptomCheckInToken.topContentPadding)
                .padding(.bottom, SpacingToken.lg)
                .safeAreaPadding(.bottom, SymptomCheckInToken.scrollBottomPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(ColorToken.backgroundPrimary.ignoresSafeArea())
            .safeAreaInset(edge: .bottom) {
                saveButton
                    .padding(.horizontal, SymptomCheckInToken.screenHorizontalPadding)
                    .padding(.top, SpacingToken.md)
                    .padding(.bottom, SpacingToken.md)
                    .background {
                        ColorToken.backgroundPrimary.opacity(SymptomCheckInToken.bottomBarBackgroundOpacity)
                            .background(.ultraThinMaterial)
                    }
            }
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ColorToken.backgroundPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
#endif
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: SpacingToken.sm) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(.body, design: .rounded).weight(.semibold))
                                .foregroundStyle(ColorToken.textPrimary)
                                .frame(
                                    width: SymptomCheckInToken.infoButtonSize,
                                    height: SymptomCheckInToken.infoButtonSize
                                )
                                .background(SymptomCheckInToken.infoButtonBackground)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Schließen")

                        Text(viewModel.screenTitle)
                            .font(TypographyToken.sheetTitle)
                            .foregroundStyle(ColorToken.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isInfoPresented = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(.body, design: .rounded).weight(.medium))
                            .foregroundStyle(ColorToken.textSecondary)
                            .frame(
                                width: SymptomCheckInToken.infoButtonSize,
                                height: SymptomCheckInToken.infoButtonSize
                            )
                            .background(SymptomCheckInToken.infoButtonBackground)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Information zu Symptomen")
                }
            }
            .sheet(isPresented: $isInfoPresented) {
                SymptomInfoSheet()
                    .presentationDetents([.medium])
            }
        }
    }

    @ViewBuilder
    private var statusMessage: some View {
        if let message = viewModel.saveStatus.message {
            Text(message)
                .cujanaStatus(isError: viewModel.saveStatus.isError)
        }
    }

    private var saveButton: some View {
        PrimaryCTAButton(
            title: viewModel.submitButtonTitle,
            isLoading: viewModel.isSaving,
            isEnabled: viewModel.canSubmit
        ) {
            Task {
                await submitEntry()
            }
        }
    }

    private func submitEntry() async {
        let savedEntry = await viewModel.submit()

        if let savedEntry, case .success = viewModel.saveStatus {
            onSaved?(savedEntry)
            dismiss()
        }
    }
}

struct EntryFormSections: View {
    @Bindable var viewModel: EntryEditorViewModel
    let symptomSelectionNamespace: Namespace.ID
    let severitySelectionNamespace: Namespace.ID
    @Binding var isDateExpanded: Bool
    let reduceMotion: Bool

    private let symptomColumns = [
        GridItem(
            .flexible(minimum: SymptomCheckInToken.symptomGridMinimumWidth),
            spacing: SymptomCheckInToken.symptomPillGridSpacing
        ),
        GridItem(
            .flexible(minimum: SymptomCheckInToken.symptomGridMinimumWidth),
            spacing: SymptomCheckInToken.symptomPillGridSpacing
        )
    ]

    var body: some View {
        symptomSection
        severitySection
        dateSection
        medicationSection
        tagSection
        historicalContextSection
        noteSection
    }

    private var symptomSection: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            SectionHeader(
                title: "Welche Symptome hast du?",
                subtitle: "Du kannst mehrere Symptome auswählen."
            )

            LazyVGrid(columns: symptomColumns, spacing: SymptomCheckInToken.symptomPillGridSpacing) {
                ForEach(viewModel.symptomOptions) { option in
                    SymptomChip(
                        option: option,
                        isSelected: viewModel.selectedSymptoms.contains(option.type),
                        namespace: symptomSelectionNamespace
                    ) {
                        viewModel.selectSymptom(option.type)
                    }
                }
            }
        }
    }

    private var severitySection: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            SectionHeader(title: "Wie belastend sind die Symptome?", subtitle: "1 ist sehr mild, 5 sehr stark.")

            SeveritySelector(
                options: viewModel.severityOptions,
                selectedLevel: viewModel.selectedSeverityLevel,
                namespace: severitySelectionNamespace,
                onSelect: viewModel.selectSeverity(level:)
            )
        }
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            ExpandableDateCard(
                entryDate: $viewModel.entryDate,
                isExpanded: $isDateExpanded,
                reduceMotion: reduceMotion
            )

            DateHintBox()
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            SectionHeader(title: "Notiz", subtitle: "Optional")

            SymptomNoteField(text: $viewModel.note)
        }
    }

    private var medicationSection: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            SectionHeader(title: "Medikamente", subtitle: "Optional, durch Komma oder Zeilen getrennt.")

            SupplementalEntryField(
                text: $viewModel.medicationsText,
                placeholder: "z. B. Antihistaminikum, Nasenspray",
                accessibilityLabel: "Medikamente"
            )
        }
    }

    private var tagSection: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            SectionHeader(title: "Tags", subtitle: "Optional, durch Komma oder Zeilen getrennt.")

            SupplementalEntryField(
                text: $viewModel.tagsText,
                placeholder: "z. B. Park, Arbeit, Schlaf",
                accessibilityLabel: "Tags"
            )
        }
    }

    @ViewBuilder
    private var historicalContextSection: some View {
        if let historicalContextText = viewModel.historicalContextText {
            HistoricalContextCard(text: historicalContextText)
        }
    }
}
