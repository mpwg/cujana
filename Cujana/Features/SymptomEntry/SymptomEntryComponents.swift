import SwiftUI

struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs) {
            Text(title)
                .font(TypographyToken.symptomSectionTitle)
                .tracking(SymptomCheckInToken.sectionTitleTracking)
                .foregroundStyle(ColorToken.textPrimary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(subtitle)
                .font(TypographyToken.symptomSectionDescription)
                .foregroundStyle(SymptomCheckInToken.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct SymptomChip: View {
    let option: SymptomOption
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: SymptomCheckInToken.symptomPillSpacing) {
                Image(systemName: option.systemImageName)
                    .font(.system(size: SymptomCheckInToken.symptomIconSize, weight: .medium, design: .rounded))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(iconColor)
                    .accessibilityHidden(true)

                symptomLabel
            }
            .padding(.horizontal, SymptomCheckInToken.symptomPillPaddingH)
            .padding(.vertical, SymptomCheckInToken.symptomPillPaddingV)
            .frame(maxWidth: .infinity, minHeight: SymptomCheckInToken.symptomPillMinHeight, alignment: .leading)
            .background(chipBackground)
            .clipShape(RoundedRectangle(cornerRadius: SymptomCheckInToken.symptomPillCornerRadius, style: .continuous))
            .overlay(chipBorder)
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: SymptomCheckInToken.symptomCheckmarkSize, weight: .semibold))
                        .foregroundStyle(SymptomCheckInToken.selectedBorder)
                        .opacity(SymptomCheckInToken.symptomCheckmarkOpacity)
                        .padding(SpacingToken.md)
                        .accessibilityHidden(true)
                }
            }
            .softShadow(chipShadow)
        }
        .buttonStyle(SymptomChipButtonStyle())
        .accessibilityLabel(option.title)
        .accessibilityHint("Mehrfachauswahl möglich")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .sensoryFeedback(.selection, trigger: isSelected)
        .animation(
            .spring(
                response: SymptomCheckInToken.animationDuration,
                dampingFraction: SymptomCheckInToken.animationDamping
            ),
            value: isSelected
        )
    }

    private var symptomLabel: some View {
        Text(option.title)
            .font(TypographyToken.symptomPill.weight(.semibold))
            .foregroundStyle(isSelected ? SymptomCheckInToken.selectedText : ColorToken.textPrimary)
            .lineLimit(2)
            .minimumScaleFactor(SymptomCheckInToken.symptomTextMinimumScale)
            .allowsTightening(true)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var iconColor: Color {
        if isSelected {
            return SymptomCheckInToken.selectedIcon
        }

        return SymptomCheckInToken.accent.opacity(SymptomCheckInToken.symptomUnselectedIconOpacity)
    }

    private var chipShadow: ShadowTokenValue {
        isSelected ? ShadowTokenValue(color: .clear, radius: 0, y: 0) : SymptomCheckInToken.symptomPillShadow
    }

    @ViewBuilder
    private var chipBackground: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: SymptomCheckInToken.symptomPillCornerRadius, style: .continuous)
                .fill(SymptomCheckInToken.symptomSelectedBackground)
                .matchedGeometryEffect(id: "symptom-\(option.id)", in: namespace)
        } else {
            RoundedRectangle(cornerRadius: SymptomCheckInToken.symptomPillCornerRadius, style: .continuous)
                .fill(ColorToken.cardBackground)
        }
    }

    private var chipBorder: some View {
        RoundedRectangle(cornerRadius: SymptomCheckInToken.symptomPillCornerRadius, style: .continuous)
            .stroke(chipBorderColor, lineWidth: chipBorderWidth)
    }

    private var chipBorderColor: Color {
        isSelected ? SymptomCheckInToken.selectedBorder : SymptomCheckInToken.symptomUnselectedBorder
    }

    private var chipBorderWidth: CGFloat {
        isSelected ? SymptomCheckInToken.symptomSelectedBorderWidth : SymptomCheckInToken.symptomUnselectedBorderWidth
    }
}

private struct SymptomChipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? SymptomCheckInToken.symptomPressedScale : 1)
            .animation(.easeInOut(duration: PressFeedbackToken.animationDuration), value: configuration.isPressed)
    }
}

struct SeveritySelector: View {
    let options: [SeverityOption]
    let selectedLevel: Int?
    let namespace: Namespace.ID
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SymptomCheckInToken.severityPillSpacing) {
            severityRow(for: Array(options.prefix(3)))
            severityRow(for: Array(options.dropFirst(3)))
        }
    }

    private func severityRow(for options: [SeverityOption]) -> some View {
        HStack(spacing: SymptomCheckInToken.severityPillSpacing) {
            ForEach(options) { option in
                SeverityPill(
                    option: option,
                    isSelected: selectedLevel == option.level,
                    namespace: namespace
                ) {
                    onSelect(option.level)
                }
            }
        }
    }
}

private struct SeverityPill: View {
    let option: SeverityOption
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(option.title)
                .font(TypographyToken.severityControl)
                .foregroundStyle(isSelected ? ColorToken.cardBackground : SymptomCheckInToken.severityUnselectedText)
                .lineLimit(1)
                .minimumScaleFactor(SymptomCheckInToken.severityTextMinimumScale)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, SymptomCheckInToken.severityPillPaddingH)
                .frame(height: SymptomCheckInToken.severityPillMinHeight)
                .background(pillBackground)
                .clipShape(
                    RoundedRectangle(cornerRadius: SymptomCheckInToken.severityPillCornerRadius, style: .continuous)
                )
                .overlay(pillBorder)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .sensoryFeedback(.selection, trigger: isSelected)
        .animation(
            .spring(
                response: SymptomCheckInToken.animationDuration,
                dampingFraction: SymptomCheckInToken.animationDamping
            ),
            value: isSelected
        )
    }

    @ViewBuilder
    private var pillBackground: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: SymptomCheckInToken.severityPillCornerRadius, style: .continuous)
                .fill(SymptomCheckInToken.accent)
                .matchedGeometryEffect(id: "severity-\(option.id)", in: namespace)
        } else {
            RoundedRectangle(cornerRadius: SymptomCheckInToken.severityPillCornerRadius, style: .continuous)
                .fill(SymptomCheckInToken.severityUnselectedBackground)
        }
    }

    @ViewBuilder
    private var pillBorder: some View {
        if isSelected == false {
            RoundedRectangle(cornerRadius: SymptomCheckInToken.severityPillCornerRadius, style: .continuous)
                .stroke(
                    SymptomCheckInToken.severityUnselectedBorder,
                    lineWidth: SymptomCheckInToken.symptomUnselectedBorderWidth
                )
        }
    }
}

struct ExpandableDateCard: View {
    @Binding var entryDate: Date
    @Binding var isExpanded: Bool
    let reduceMotion: Bool

    var body: some View {
        Button {
            withAnimation(animation) {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: SpacingToken.md) {
                collapsedHeader

                if isExpanded {
                    compactPickers
                }
            }
            .padding(SpacingToken.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: isExpanded ? nil : SymptomCheckInToken.dateCardCollapsedHeight)
            .background(ColorToken.cardBackground)
            .clipShape(
                RoundedRectangle(cornerRadius: SymptomCheckInToken.dateCardCornerRadius, style: .continuous)
            )
            .softShadow(SymptomCheckInToken.dateCardShadow)
        }
        .buttonStyle(DateCardButtonStyle())
        .accessibilityLabel("Zeitpunkt, \(dateSummary)")
        .accessibilityHint(isExpanded ? "Zum Einklappen tippen" : "Zum Bearbeiten tippen")
    }

    private var collapsedHeader: some View {
        HStack(spacing: SpacingToken.md) {
            Image(systemName: "calendar")
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(SymptomCheckInToken.accent)
                .frame(width: SymptomCheckInToken.dateIconSize, height: SymptomCheckInToken.dateIconSize)
                .background(SymptomCheckInToken.hintBackground)
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text("Zeitpunkt")
                    .font(TypographyToken.bodyEmphasized)
                    .foregroundStyle(ColorToken.textPrimary)

                Text(dateSummary)
                    .font(TypographyToken.secondaryBody)
                    .foregroundStyle(SymptomCheckInToken.secondaryText)
                    .contentTransition(.opacity)
            }

            Spacer(minLength: SpacingToken.sm)

            Image(systemName: "chevron.down")
                .font(.system(size: SymptomCheckInToken.hintIconSize, weight: .semibold, design: .rounded))
                .foregroundStyle(SymptomCheckInToken.tertiaryText.opacity(SymptomCheckInToken.chevronOpacity))
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                .accessibilityHidden(true)
        }
    }

    private var compactPickers: some View {
        VStack(spacing: SpacingToken.sm) {
            DatePicker("Datum", selection: $entryDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .tint(SymptomCheckInToken.accent)
                .frame(maxWidth: .infinity, minHeight: SymptomCheckInToken.datePickerMinHeight)

            DatePicker("Uhrzeit", selection: $entryDate, displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
                .tint(SymptomCheckInToken.accent)
                .frame(maxWidth: .infinity, minHeight: SymptomCheckInToken.datePickerMinHeight)
        }
        .padding(.top, SpacingToken.xs)
    }

    private var dateSummary: String {
        let time = entryDate.formatted(date: .omitted, time: .shortened)

        if Calendar.current.isDateInToday(entryDate) {
            return "Heute, \(time)"
        }

        let date = entryDate.formatted(date: .abbreviated, time: .omitted)
        return "\(date), \(time)"
    }

    private var animation: Animation {
        reduceMotion
            ? .easeInOut(duration: MotionToken.reducedMotionDuration)
            : .spring(
                response: SymptomCheckInToken.animationDuration,
                dampingFraction: SymptomCheckInToken.animationDamping
            )
    }
}

private struct DateCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? PressFeedbackToken.prominentOpacity : 1)
            .scaleEffect(configuration.isPressed ? PressFeedbackToken.prominentScale : 1)
            .animation(.easeInOut(duration: PressFeedbackToken.animationDuration), value: configuration.isPressed)
    }
}

struct DateHintBox: View {
    var body: some View {
        HStack(alignment: .top, spacing: SpacingToken.sm) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: SymptomCheckInToken.hintIconSize, weight: .medium, design: .rounded))
                .foregroundStyle(SymptomCheckInToken.accent)
                .accessibilityHidden(true)

            Text("Du kannst auch frühere Einträge nachtragen.")
                .font(TypographyToken.symptomSectionDescription)
                .foregroundStyle(SymptomCheckInToken.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(SpacingToken.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SymptomCheckInToken.hintBackground)
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusSmall, style: .continuous))
    }
}

struct SymptomNoteField: View {
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text("Optional etwas ergänzen ...")
                    .font(TypographyToken.body)
                    .foregroundStyle(SymptomCheckInToken.tertiaryText)
                    .padding(SymptomCheckInToken.notesPadding)
                    .accessibilityHidden(true)
            }

            TextEditor(text: $text)
                .font(TypographyToken.body)
                .foregroundStyle(ColorToken.textPrimary)
                .scrollContentBackground(.hidden)
                .padding(SymptomCheckInToken.notesPadding)
                .background(Color.clear)
        }
        .frame(minHeight: SymptomCheckInToken.notesMinHeight)
        .background(ColorToken.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SymptomCheckInToken.notesCornerRadius, style: .continuous))
        .overlay(noteBorder)
        .accessibilityLabel("Notiz")
    }

    private var noteBorder: some View {
        RoundedRectangle(cornerRadius: SymptomCheckInToken.notesCornerRadius, style: .continuous)
            .stroke(
                SymptomCheckInToken.notesBorder,
                lineWidth: SymptomCheckInToken.notesBorderWidth
            )
    }
}

struct PrimaryCTAButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SpacingToken.sm) {
                if isLoading {
                    ProgressView()
                        .tint(ColorToken.cardBackground)
                }

                Text(title)
                    .contentTransition(.opacity)
            }
        }
        .buttonStyle(PrimaryCTAButtonStyle(isEnabled: isEnabled))
        .disabled(isEnabled == false)
    }
}

private struct PrimaryCTAButtonStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TypographyToken.button)
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, minHeight: SymptomCheckInToken.saveButtonMinHeight)
            .background(buttonBackground(configuration: configuration))
            .clipShape(RoundedRectangle(cornerRadius: SymptomCheckInToken.saveButtonRadius, style: .continuous))
            .softShadow(buttonShadow)
            .opacity(disabledOrPressedOpacity(configuration: configuration))
            .scaleEffect(configuration.isPressed ? PressFeedbackToken.prominentScale : 1)
            .animation(.easeInOut(duration: SymptomCheckInToken.animationDuration), value: configuration.isPressed)
    }

    private var foreground: Color {
        isEnabled
            ? ColorToken.cardBackground
            : ColorToken.cardBackground.opacity(SurfaceOpacityToken.accentProminent)
    }

    private var buttonShadow: ShadowTokenValue {
        isEnabled ? SymptomCheckInToken.saveButtonShadow : ShadowTokenValue(color: .clear, radius: 0, y: 0)
    }

    private func buttonBackground(configuration: Configuration) -> Color {
        if isEnabled == false {
            return SymptomCheckInToken.disabledButtonBackground
        }

        return configuration.isPressed ? SymptomCheckInToken.saveButtonPressedBackground : SymptomCheckInToken.accent
    }

    private func disabledOrPressedOpacity(configuration: Configuration) -> Double {
        if isEnabled == false {
            return ButtonToken.Primary.enabledOpacity
        }

        return configuration.isPressed ? PressFeedbackToken.prominentOpacity : ButtonToken.Primary.enabledOpacity
    }
}
