import SwiftUI

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
                        .accessibilityHidden(true)
                }

                Text(title)
                    .contentTransition(.opacity)
            }
        }
        .buttonStyle(PrimaryCTAButtonStyle(isEnabled: isEnabled))
        .disabled(isEnabled == false)
        .accessibilityLabel(title)
        .accessibilityValue(isLoading ? "Wird gespeichert" : "")
    }
}

private struct PrimaryCTAButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
            .scaleEffect(pressedScale(configuration: configuration))
            .animation(pressAnimation, value: configuration.isPressed)
    }

    private var foreground: Color {
        isEnabled
            ? ColorToken.cardBackground
            : ColorToken.cardBackground.opacity(SurfaceOpacityToken.accentProminent)
    }

    private var buttonShadow: ShadowTokenValue {
        isEnabled ? SymptomCheckInToken.saveButtonShadow : ShadowTokenValue(color: .clear, radius: 0, y: 0)
    }

    private var pressAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: SymptomCheckInToken.animationDuration)
    }

    private func pressedScale(configuration: Configuration) -> CGFloat {
        reduceMotion ? 1 : (configuration.isPressed ? PressFeedbackToken.prominentScale : 1)
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
