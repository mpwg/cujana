import SwiftUI

struct HomeLogoHeader: View {
    var body: some View {
        Image("Cujana")
            .resizable()
            .scaledToFit()
            .frame(
                width: HomeOverviewToken.navigationLogoWidth,
                height: HomeOverviewToken.navigationLogoHeight
            )
            .opacity(HomeOverviewToken.navigationLogoOpacity)
            .padding(.top, HomeOverviewToken.navigationLogoTopPadding)
            .padding(.bottom, HomeOverviewToken.navigationLogoBottomPadding)
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Cujana")
    }
}

struct PersonalLoadStatusCard: View {
    let days: [ForecastDaySummaryItem]

    private var primaryAllergen: ForecastDayAllergenItem? {
        days.first?.allergenItems.first
    }

    var body: some View {
        HStack(spacing: SpacingToken.md) {
            Image(systemName: "allergens")
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(SemanticColorToken.foreground(for: severityText))
                .frame(
                    width: HomeOverviewToken.personalStatusIconSize,
                    height: HomeOverviewToken.personalStatusIconSize
                )
                .background(SemanticColorToken.background(for: severityText))
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text(statusTitle)
                    .font(TypographyToken.bodyEmphasized)
                    .foregroundStyle(ColorToken.textPrimary)
                    .lineLimit(2)

                Text(statusSubtitle)
                    .font(TypographyToken.secondaryBody)
                    .foregroundStyle(ColorToken.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: SpacingToken.sm)

            RiskBadge(text: severityText)
        }
        .padding(CardToken.padding)
        .frame(height: HomeOverviewToken.personalStatusHeight)
        .premiumSurface(cornerRadius: HomeOverviewToken.personalStatusCornerRadius)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(statusTitle). \(statusSubtitle)")
    }

    private var statusTitle: String {
        guard let primaryAllergen else {
            return "Aktuell keine relevante Belastung"
        }

        return "\(loadAdjective(for: primaryAllergen.levelText)) Belastung durch \(primaryAllergen.title)"
    }

    private var statusSubtitle: String {
        primaryAllergen == nil ? "Deine Trigger wirken heute ruhig." : "Mögliche Trigger heute erhöht."
    }

    private var severityText: String {
        primaryAllergen?.levelText ?? "Keine Belastung"
    }

    private func loadAdjective(for levelText: String) -> String {
        switch levelText {
        case "Niedrig":
            "Niedrige"
        case "Mittel":
            "Mittlere"
        case "Hoch":
            "Hohe"
        case "Sehr hoch":
            "Sehr hohe"
        default:
            "Auffällige"
        }
    }
}

struct FeelingCTAView: View {
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            VStack(alignment: .leading, spacing: SpacingToken.sm) {
                Text("Heute")
                    .font(TypographyToken.severityPill)
                    .foregroundStyle(HomeOverviewToken.ctaLabelText)

                Text("Wie fühlst du dich heute?")
                    .font(TypographyToken.ctaHeroTitle)
                    .tracking(HomeOverviewToken.ctaTitleTracking)
                    .foregroundStyle(ColorToken.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(HomeOverviewToken.weatherDescriptionMinimumScale)

                Text("Ein kurzer Check-in hilft dir, Muster und Trigger besser zu verstehen.")
                    .font(TypographyToken.secondaryBody)
                    .foregroundStyle(ColorToken.textSecondary)
                    .frame(maxWidth: HomeOverviewToken.ctaSupportingMaxWidth, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
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
                        .opacity(HomeOverviewToken.ctaBackgroundOpacity)
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
            .clipShape(RoundedRectangle(cornerRadius: HomeOverviewToken.ctaButtonCornerRadius, style: .continuous))
            .softShadow(ShadowToken.ctaButton)
            .opacity(configuration.isPressed ? PressFeedbackToken.prominentOpacity : 1)
            .scaleEffect(configuration.isPressed ? PressFeedbackToken.prominentScale : 1)
            .animation(.easeInOut(duration: PressFeedbackToken.animationDuration), value: configuration.isPressed)
    }
}
