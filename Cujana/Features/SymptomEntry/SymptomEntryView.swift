import SwiftUI

struct SymptomEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var viewModel: SymptomEntryViewModel
    @Namespace private var symptomSelectionNamespace
    @Namespace private var severitySelectionNamespace
    @State private var isDateExpanded = false
    @State private var isInfoPresented = false

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
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SymptomCheckInToken.sectionSpacing) {
                    symptomSection
                    severitySection
                    dateSection
                    noteSection
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

                        Text("Symptome erfassen")
                            .font(TypographyToken.sheetTitle)
                            .foregroundStyle(ColorToken.textPrimary)
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

    @ViewBuilder
    private var statusMessage: some View {
        if let message = viewModel.saveStatus.message {
            Text(message)
                .cujanaStatus(isError: viewModel.saveStatus.isError)
        }
    }

    private var saveButton: some View {
        PrimaryCTAButton(
            title: viewModel.isSaving ? "Speichern ..." : "Eintrag speichern",
            isLoading: viewModel.isSaving,
            isEnabled: viewModel.canSubmit
        ) {
            Task {
                await viewModel.submit()
            }
        }
    }
}
