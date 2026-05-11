import SwiftUI

struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs) {
            Text(title)
                .font(TypographyToken.symptomSectionTitle)
                .tracking(-0.4)
                .foregroundStyle(ColorToken.textPrimary)

            Text(subtitle)
                .font(TypographyToken.symptomSectionDescription)
                .foregroundStyle(ColorToken.textSecondary.opacity(SymptomCheckInToken.sectionDescriptionOpacity))
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
            HStack(spacing: SymptomCheckInToken.symptomPillSpacing) {
                icon

                Text(option.title)
                    .font(TypographyToken.symptomPill)
                    .foregroundStyle(isSelected ? SymptomCheckInToken.symptomSelectedText : ColorToken.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(SymptomCheckInToken.symptomTextMinimumScale)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: SpacingToken.xs)
            }
            .padding(.horizontal, SymptomCheckInToken.symptomPillPaddingH)
            .padding(.vertical, SymptomCheckInToken.symptomPillPaddingV)
            .frame(maxWidth: .infinity, minHeight: SymptomCheckInToken.symptomPillMinHeight, alignment: .leading)
            .background(chipBackground)
            .clipShape(RoundedRectangle(cornerRadius: SymptomCheckInToken.symptomPillCornerRadius, style: .continuous))
            .softShadow(chipShadow)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var icon: some View {
        Image(systemName: option.systemImageName)
            .font(.system(size: SymptomCheckInToken.symptomIconSize, weight: .medium, design: .rounded))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(iconColor)
            .frame(
                width: SymptomCheckInToken.symptomIconSize,
                height: SymptomCheckInToken.symptomIconSize
            )
    }

    private var iconColor: Color {
        if isSelected {
            return SymptomCheckInToken.accent
        }

        return ColorToken.accentPrimary.opacity(SymptomCheckInToken.symptomIconOpacity)
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
}

struct SeveritySelector: View {
    let options: [SeverityOption]
    let selectedLevel: Int?
    let namespace: Namespace.ID
    let onSelect: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: SpacingToken.sm) {
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
            .padding(.vertical, SpacingToken.xs)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
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
                .padding(.horizontal, SpacingToken.lg)
                .frame(minWidth: SymptomCheckInToken.severityPillMinWidth)
                .frame(height: SymptomCheckInToken.severityPillMinHeight)
                .background(pillBackground)
                .clipShape(Capsule())
                .scaleEffect(isSelected ? SymptomCheckInToken.severitySelectedScale : 1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private var pillBackground: some View {
        if isSelected {
            Capsule()
                .fill(SymptomCheckInToken.accent)
                .matchedGeometryEffect(id: "severity-\(option.id)", in: namespace)
        } else {
            Capsule()
                .fill(SymptomCheckInToken.severityUnselectedBackground)
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
            .padding(SymptomCheckInToken.fieldContainerPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ColorToken.cardBackground)
            .clipShape(
                RoundedRectangle(cornerRadius: SymptomCheckInToken.dateCardCornerRadius, style: .continuous)
            )
            .softShadow(SymptomCheckInToken.dateCardShadow)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Zeitpunkt, \(dateSummary)")
        .accessibilityHint(isExpanded ? "Zum Einklappen tippen" : "Zum Bearbeiten tippen")
    }

    private var collapsedHeader: some View {
        HStack(spacing: SpacingToken.md) {
            Image(systemName: "calendar")
                .font(.system(.body, design: .rounded).weight(.semibold))
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
                    .foregroundStyle(ColorToken.textSecondary)
                    .contentTransition(.opacity)
            }

            Spacer(minLength: SpacingToken.sm)

            Image(systemName: "chevron.down")
                .font(.system(.footnote, design: .rounded).weight(.semibold))
                .foregroundStyle(ColorToken.textTertiary)
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
            ? .easeInOut(duration: SymptomCheckInToken.reducedMotionAnimationDuration)
            : .spring(
                response: SymptomCheckInToken.animationDuration,
                dampingFraction: SymptomCheckInToken.animationDamping
            )
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
                .foregroundStyle(ColorToken.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(SpacingToken.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SymptomCheckInToken.hintBackground)
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusSmall, style: .continuous))
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
            : ColorToken.cardBackground.opacity(SymptomCheckInToken.disabledTextOpacity)
    }

    private var buttonShadow: ShadowTokenValue {
        isEnabled ? SymptomCheckInToken.saveButtonShadow : ShadowTokenValue(color: .clear, radius: 0, y: 0)
    }

    private func buttonBackground(configuration: Configuration) -> Color {
        if isEnabled == false {
            return SemanticColorToken.disabledButtonBackground
        }

        return configuration.isPressed ? SymptomCheckInToken.saveButtonPressedBackground : SymptomCheckInToken.accent
    }

    private func disabledOrPressedOpacity(configuration: Configuration) -> Double {
        if isEnabled == false {
            return SymptomCheckInToken.disabledButtonOpacity
        }

        return configuration.isPressed ? PressFeedbackToken.prominentOpacity : ButtonToken.Primary.enabledOpacity
    }
}
