import SwiftUI

struct HomeHeroCard: View {
    var body: some View {
        ZStack(alignment: .leading) {
            Image("HomeHeroOrganicLandscape")
                .resizable()
                .scaledToFill()
                .accessibilityHidden(true)

            Image("HomeHeroLeafSprig")
                .resizable()
                .scaledToFit()
                .frame(width: HomeOverviewToken.heroLeafWidth, height: HomeOverviewToken.heroLeafHeight)
                .opacity(HomeOverviewToken.heroLeafOpacity)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .padding(.trailing, HomeOverviewToken.heroLeafTrailingPadding)
                .padding(.top, HomeOverviewToken.heroLeafTopPadding)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: SpacingToken.sm) {
                Text("Guten Morgen, Sam")
                    .font(TypographyToken.largeTitle)
                    .tracking(-0.5)
                    .foregroundStyle(ColorToken.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Ein ruhiger Überblick für deinen Tag.")
                    .font(TypographyToken.body)
                    .foregroundStyle(ColorToken.textSecondary)
                    .lineSpacing(4)
            }
            .padding(HomeOverviewToken.heroContentPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(height: HomeOverviewToken.heroHeight)
        .clipShape(RoundedRectangle(cornerRadius: HomeOverviewToken.heroCornerRadius, style: .continuous))
        .softShadow(ShadowToken.card)
        .accessibilityElement(children: .combine)
    }
}

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
                Label("Symptome erfassen", systemImage: "plus.circle.fill")
                    .font(TypographyToken.button)
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
            .frame(height: SymptomCheckInToken.buttonMinHeight)
            .background(ColorToken.accentPrimary)
            .clipShape(RoundedRectangle(cornerRadius: ButtonToken.Primary.radius, style: .continuous))
            .opacity(configuration.isPressed ? PressFeedbackToken.prominentOpacity : 1)
            .scaleEffect(configuration.isPressed ? PressFeedbackToken.prominentScale : 1)
            .animation(.easeInOut(duration: PressFeedbackToken.animationDuration), value: configuration.isPressed)
    }
}
