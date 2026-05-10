import SwiftUI

struct FeelingCTAView: View {
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text("Wie fühlst du dich?")
                    .font(TypographyToken.headline)
                    .foregroundStyle(ColorToken.textPrimary)

                Text("Ein kurzer Check-in genügt.")
                    .font(TypographyToken.secondaryBody)
                    .foregroundStyle(ColorToken.textSecondary)
            }

            Button(action: action) {
                HStack(spacing: HomeOverviewToken.ctaButtonIconSpacing) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(
                            size: HomeOverviewToken.ctaButtonIconSize,
                            weight: .bold,
                            design: .rounded
                        ))
                        .accessibilityHidden(true)

                    Text("Symptome erfassen")
                        .font(TypographyToken.button)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(FeelingCTAButtonStyle())
            .accessibilityLabel("Symptome erfassen")
        }
        .padding(HomeOverviewToken.ctaPadding)
        .frame(height: HomeOverviewToken.ctaHeight, alignment: .center)
        .background {
            RoundedRectangle(cornerRadius: HomeOverviewToken.ctaCornerRadius, style: .continuous)
                .fill(ColorToken.softPeach.opacity(HomeOverviewToken.ctaBackgroundOpacity))
                .overlay {
                    Image("HomeCTASoftGradient")
                        .resizable()
                        .scaledToFill()
                        .blur(radius: HomeOverviewToken.ctaArtworkBlur)
                        .accessibilityHidden(true)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: HomeOverviewToken.ctaCornerRadius, style: .continuous))
        .softShadow(ShadowToken.card)
    }
}

private struct FeelingCTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(ColorToken.cardBackground)
            .padding(.horizontal, SpacingToken.lg)
            .frame(height: HomeOverviewToken.ctaButtonHeight)
            .background(ColorToken.accentPrimary)
            .clipShape(RoundedRectangle(cornerRadius: ButtonToken.Primary.radius, style: .continuous))
            .softShadow(ShadowToken.ctaButton)
            .opacity(configuration.isPressed ? PressFeedbackToken.prominentOpacity : 1)
            .scaleEffect(configuration.isPressed ? PressFeedbackToken.prominentScale : 1)
            .animation(.easeInOut(duration: PressFeedbackToken.animationDuration), value: configuration.isPressed)
    }
}
