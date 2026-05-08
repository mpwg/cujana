import SwiftUI

struct SymptomEntryView: View {
    @Bindable var viewModel: SymptomEntryViewModel

    private let symptomColumns = [
        GridItem(.flexible(), spacing: SpacingToken.md),
        GridItem(.flexible(), spacing: SpacingToken.md)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SpacingToken.section) {
                    header
                    symptomSection
                    severitySection
                    dateSection
                    noteSection
                    statusMessage
                    saveButton
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
                    Text("Symptom erfassen")
                        .font(TypographyToken.headline)
                        .foregroundStyle(ColorToken.textPrimary)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm) {
            Text("Wie fühlst du dich?")
                .font(TypographyToken.title)
                .foregroundStyle(ColorToken.textPrimary)

            Text("Halte fest, was du spürst. Das hilft dir, Muster ruhiger zu erkennen.")
                .font(TypographyToken.body)
                .foregroundStyle(ColorToken.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var symptomSection: some View {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            SectionHeader(title: "Symptom", subtitle: "Wähle aus, was gerade am besten passt.")

            LazyVGrid(columns: symptomColumns, spacing: SpacingToken.md) {
                ForEach(viewModel.symptomOptions) { option in
                    SymptomChip(
                        option: option,
                        isSelected: viewModel.selectedSymptom == option.type
                    ) {
                        viewModel.selectSymptom(option.type)
                    }
                }
            }
        }
        .cujanaCard()
    }

    private var severitySection: some View {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            SectionHeader(title: "Wie stark ist es?", subtitle: "1 ist sehr mild, 5 sehr stark.")

            HStack(spacing: SpacingToken.sm) {
                ForEach(viewModel.severityOptions) { option in
                    SeverityButton(
                        option: option,
                        isSelected: viewModel.selectedSeverityLevel == option.level
                    ) {
                        viewModel.selectSeverity(level: option.level)
                    }
                }
            }
        }
        .cujanaCard()
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            SectionHeader(title: "Zeitpunkt", subtitle: "Du kannst auch frühere Einträge nachtragen.")

            DatePicker(
                "Datum",
                selection: $viewModel.entryDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .font(TypographyToken.body)
            .foregroundStyle(ColorToken.textPrimary)
            .cujanaInput()

            DatePicker(
                "Uhrzeit",
                selection: $viewModel.entryDate,
                displayedComponents: .hourAndMinute
            )
            .font(TypographyToken.body)
            .foregroundStyle(ColorToken.textPrimary)
            .cujanaInput()
        }
        .cujanaCard()
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            SectionHeader(title: "Notiz", subtitle: "Optional")

            TextEditor(text: $viewModel.note)
                .font(TypographyToken.body)
                .foregroundStyle(ColorToken.textPrimary)
                .frame(minHeight: InputToken.minHeight)
                .scrollContentBackground(.hidden)
                .cujanaInput()
                .accessibilityLabel("Notiz")
        }
        .cujanaCard()
    }

    @ViewBuilder
    private var statusMessage: some View {
        if let message = viewModel.saveStatus.message {
            Text(message)
                .cujanaStatus(isError: viewModel.saveStatus.isError)
        }
    }

    private var saveButton: some View {
        Button {
            Task {
                await viewModel.submit()
            }
        } label: {
            HStack(spacing: SpacingToken.sm) {
                if viewModel.isSaving {
                    ProgressView()
                }

                Text(viewModel.isSaving ? "Speichern ..." : "Eintrag speichern")
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(!viewModel.canSubmit)
        .opacity(viewModel.canSubmit ? 1 : ButtonToken.Primary.disabledOpacity)
    }
}

#Preview {
    SymptomEntryView(viewModel: AppDemoData.makeSymptomEntryViewModel())
}

private struct SectionHeader: View {
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

private struct SymptomChip: View {
    let option: SymptomOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SpacingToken.sm) {
                Image(systemName: option.systemImageName)
                    .font(TypographyToken.bodyEmphasized)
                    .foregroundStyle(ColorToken.brandPrimary)
                    .frame(width: ChipToken.iconSize, height: ChipToken.iconSize)

                Text(option.title)
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: SpacingToken.xs)
            }
            .padding(.horizontal, ChipToken.paddingH)
            .padding(.vertical, ChipToken.paddingV)
            .frame(maxWidth: .infinity, minHeight: ChipToken.minHeight, alignment: .leading)
            .background(isSelected ? ChipToken.selectedBackground : option.background)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? ChipToken.selectedBorder : ChipToken.border, lineWidth: ChipToken.borderWidth)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.title)
    }
}

private struct SeverityButton: View {
    let option: SeverityOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(option.level)")
                .font(TypographyToken.bodyEmphasized)
                .foregroundStyle(isSelected ? SelectionToken.selectedText : SelectionToken.text)
                .frame(width: SelectionToken.size, height: SelectionToken.size)
                .background(isSelected ? SelectionToken.selectedBackground : SelectionToken.background)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(SelectionToken.border, lineWidth: SelectionToken.borderWidth)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.title)
    }
}
