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
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            HStack(alignment: .center, spacing: SpacingToken.md) {
                Image(systemName: "allergens")
                    .font(TypographyToken.ctaHeroTitle)
                    .foregroundStyle(SemanticColorToken.foreground(for: severityText))
                    .frame(
                        width: HomeOverviewToken.personalStatusIconSize,
                        height: HomeOverviewToken.personalStatusIconSize
                    )
                    .background(SemanticColorToken.background(for: severityText))
                    .clipShape(Circle())
                    .accessibilityHidden(true)

                HomeRiskBadge(text: severityText)
                    .layoutPriority(HomeOverviewToken.titleLayoutPriority)
            }

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text(statusTitle)
                    .font(TypographyToken.personalStatusTitle)
                    .tracking(HomeOverviewToken.personalStatusTitleTracking)
                    .foregroundStyle(ColorToken.textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHidden(true)

                Text(statusSubtitle)
                    .font(TypographyToken.personalStatusSubtitle)
                    .foregroundStyle(ColorToken.textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHidden(true)
            }
            .layoutPriority(HomeOverviewToken.titleLayoutPriority)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, CardToken.padding)
        .padding(.vertical, HomeOverviewToken.personalStatusVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: HomeOverviewToken.personalStatusHeight)
        .premiumSurface(cornerRadius: HomeOverviewToken.personalStatusCornerRadius)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(statusTitle). \(statusSubtitle)")
    }

    private var statusTitle: String {
        guard let primaryAllergen else {
            return "Aktuell keine relevante Belastung"
        }

        return "\(loadAdjective(for: primaryAllergen.levelText)) Belastung durch \(primaryAllergen.title)"
    }

    private var statusSubtitle: String {
        primaryAllergen == nil ? "Trigger heute ruhig." : "Trigger heute erhöht."
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

private struct HomeRiskBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(TypographyToken.severityPill.weight(.semibold))
            .foregroundStyle(SemanticColorToken.foreground(for: text))
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, HomeOverviewToken.personalStatusBadgePaddingH)
            .frame(minHeight: HomeOverviewToken.personalStatusBadgeHeight)
            .background(SemanticColorToken.background(for: text))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: HomeOverviewToken.personalStatusBadgeCornerRadius,
                    style: .continuous
                )
            )
    }
}

struct FeelingCTAView: View {
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs) {
            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text("Heute")
                    .font(TypographyToken.ctaLabel)
                    .tracking(HomeOverviewToken.ctaLabelTracking)
                    .foregroundStyle(HomeOverviewToken.ctaLabelText)

                Text("Wie fühlst du dich heute?")
                    .font(TypographyToken.ctaHeroTitle)
                    .tracking(HomeOverviewToken.ctaTitleTracking)
                    .foregroundStyle(ColorToken.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Ein kurzer Check-in hilft dir, Muster und Trigger besser zu verstehen.")
                    .font(TypographyToken.ctaSupporting)
                    .foregroundStyle(ColorToken.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: action) {
                HStack(spacing: HomeOverviewToken.ctaButtonIconSpacing) {
                    Image(systemName: "plus.circle.fill")
                        .font(TypographyToken.ctaButton.weight(.bold))
                        .accessibilityHidden(true)

                    Text("Symptome erfassen")
                        .font(TypographyToken.ctaButton)
                }
            }
            .buttonStyle(FeelingCTAButtonStyle())
            .accessibilityLabel("Symptome erfassen")
        }
        .padding(HomeOverviewToken.ctaPadding)
        .frame(minHeight: HomeOverviewToken.ctaHeight, alignment: .center)
        .background {
            RoundedRectangle(cornerRadius: HomeOverviewToken.ctaCornerRadius, style: .continuous)
                .fill(ColorToken.cardBackground)
        }
        .clipShape(RoundedRectangle(cornerRadius: HomeOverviewToken.ctaCornerRadius, style: .continuous))
        .softShadow(ShadowToken.card)
    }
}

private struct FeelingCTAButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(ColorToken.cardBackground)
            .padding(.horizontal, HomeOverviewToken.ctaButtonPaddingH)
            .frame(minHeight: HomeOverviewToken.ctaButtonHeight)
            .background(ColorToken.accentPrimary)
            .clipShape(RoundedRectangle(cornerRadius: HomeOverviewToken.ctaButtonCornerRadius, style: .continuous))
            .softShadow(ShadowToken.ctaButton)
            .opacity(configuration.isPressed ? PressFeedbackToken.prominentOpacity : 1)
            .scaleEffect(pressedScale(configuration: configuration))
            .animation(pressAnimation, value: configuration.isPressed)
    }

    private var pressAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: PressFeedbackToken.animationDuration)
    }

    private func pressedScale(configuration: Configuration) -> CGFloat {
        reduceMotion ? 1 : (configuration.isPressed ? PressFeedbackToken.prominentScale : 1)
    }
}
