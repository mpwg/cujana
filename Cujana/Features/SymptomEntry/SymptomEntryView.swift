import SwiftUI

struct SymptomEntryView: View {
    @Bindable var viewModel: SymptomEntryViewModel

    private let symptomColumns = [
        GridItem(.adaptive(minimum: SymptomCheckInToken.symptomGridMinimumWidth), spacing: SpacingToken.md)
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
                }
                .padding(.horizontal, SpacingToken.xl)
                .padding(.vertical, SpacingToken.xl)
                .padding(.bottom, SymptomCheckInToken.scrollBottomPadding)
            }
            .background(ColorToken.backgroundPrimary.ignoresSafeArea())
            .safeAreaInset(edge: .bottom) {
                saveButton
                    .padding(.horizontal, SpacingToken.xl)
                    .padding(.top, SpacingToken.md)
                    .padding(.bottom, SpacingToken.md)
                    .background(ColorToken.backgroundPrimary.opacity(SymptomCheckInToken.bottomBarBackgroundOpacity))
            }
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ColorToken.backgroundPrimary, for: .navigationBar)
#endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Symptom erfassen")
                        .font(TypographyToken.sheetTitle)
                        .foregroundStyle(ColorToken.textPrimary)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm) {
            Text("Wie fühlst du dich?")
                .font(TypographyToken.sheetHeading)
                .tracking(-0.8)
                .foregroundStyle(ColorToken.textPrimary)

            Text("Halte fest, was du spürst. Das hilft dir, Muster ruhiger zu erkennen.")
                .font(TypographyToken.body)
                .foregroundStyle(ColorToken.textSecondary)
                .frame(maxWidth: SymptomCheckInToken.introMaxWidth, alignment: .leading)
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
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            SectionHeader(title: "Zeitpunkt", subtitle: "Du kannst auch frühere Einträge nachtragen.")

            VStack(spacing: SpacingToken.md) {
                DatePicker(
                    "Datum",
                    selection: $viewModel.entryDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .font(TypographyToken.body)
                .foregroundStyle(ColorToken.textPrimary)
                .tint(ColorToken.accentPrimary)

                Divider()
                    .overlay(ColorToken.separatorSoft)

                DatePicker(
                    "Uhrzeit",
                    selection: $viewModel.entryDate,
                    displayedComponents: .hourAndMinute
                )
                .font(TypographyToken.body)
                .foregroundStyle(ColorToken.textPrimary)
                .tint(ColorToken.accentPrimary)
                .frame(minHeight: SymptomCheckInToken.timePickerHeight)
                .padding(.horizontal, SpacingToken.md)
                .background(ColorToken.backgroundPrimary)
                .clipShape(
                    RoundedRectangle(cornerRadius: SymptomCheckInToken.timePickerCornerRadius, style: .continuous)
                )
            }
            .padding(SymptomCheckInToken.fieldContainerPadding)
            .background(ColorToken.cardBackground.opacity(SymptomCheckInToken.calendarContainerOpacity))
            .clipShape(
                RoundedRectangle(cornerRadius: SymptomCheckInToken.calendarContainerCornerRadius, style: .continuous)
            )
            .softShadow(ShadowToken.card)
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            SectionHeader(title: "Notiz", subtitle: "Optional")

            TextEditor(text: $viewModel.note)
                .font(TypographyToken.body)
                .foregroundStyle(ColorToken.textPrimary)
                .frame(minHeight: SymptomCheckInToken.notesMinHeight)
                .scrollContentBackground(.hidden)
                .padding(SymptomCheckInToken.notesPadding)
                .premiumSurface(cornerRadius: SymptomCheckInToken.notesCornerRadius)
                .accessibilityLabel("Notiz")
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
        .buttonStyle(SymptomSaveButtonStyle(isEnabled: viewModel.canSubmit))
        .disabled(!viewModel.canSubmit)
    }
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
                .font(TypographyToken.secondaryBody)
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
                    .font(.system(size: ChipToken.iconSize, weight: .medium, design: .rounded))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(ColorToken.accentPrimary.opacity(SymptomCheckInToken.symptomIconOpacity))
                    .frame(width: ChipToken.iconSize, height: ChipToken.iconSize)

                Text(option.title)
                    .font(TypographyToken.secondaryBody.weight(.medium))
                    .foregroundStyle(ColorToken.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: SpacingToken.xs)
            }
            .padding(.horizontal, SymptomCheckInToken.symptomPillPaddingH)
            .padding(.vertical, ChipToken.paddingV)
            .frame(maxWidth: .infinity, minHeight: SymptomCheckInToken.symptomPillMinHeight, alignment: .leading)
            .background(isSelected ? SymptomCheckInToken.symptomSelectedBackground : ColorToken.cardBackground)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        isSelected
                            ? Color.clear
                            : ColorToken.accentPrimary.opacity(SymptomCheckInToken.symptomBorderOpacity),
                        lineWidth: isSelected ? 0 : 1
                    )
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
            Text(option.title)
                .font(TypographyToken.caption.weight(.semibold))
                .foregroundStyle(isSelected ? SelectionToken.selectedText : SymptomCheckInToken.severityUnselectedText)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(
                    minWidth: SymptomCheckInToken.severityPillMinWidth,
                    maxWidth: .infinity,
                    minHeight: SymptomCheckInToken.severityPillMinHeight
                )
                .padding(.horizontal, SpacingToken.sm)
                .background(isSelected ? ColorToken.accentPrimary : ColorToken.backgroundSecondary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.title)
    }
}

private struct SymptomSaveButtonStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TypographyToken.button)
            .foregroundStyle(
                isEnabled
                    ? ColorToken.cardBackground
                    : ColorToken.cardBackground.opacity(SymptomCheckInToken.disabledTextOpacity)
            )
            .frame(maxWidth: .infinity, minHeight: SymptomCheckInToken.saveButtonMinHeight)
            .background(isEnabled ? ColorToken.accentPrimary : SemanticColorToken.disabledButtonBackground)
            .clipShape(RoundedRectangle(cornerRadius: SymptomCheckInToken.saveButtonRadius, style: .continuous))
            .opacity(disabledOrPressedOpacity(configuration: configuration))
            .scaleEffect(configuration.isPressed ? PressFeedbackToken.prominentScale : 1)
            .animation(.easeInOut(duration: PressFeedbackToken.animationDuration), value: configuration.isPressed)
    }

    private func disabledOrPressedOpacity(configuration: Configuration) -> Double {
        if isEnabled == false {
            return SymptomCheckInToken.disabledButtonOpacity
        }

        return configuration.isPressed ? PressFeedbackToken.prominentOpacity : ButtonToken.Primary.enabledOpacity
    }
}
