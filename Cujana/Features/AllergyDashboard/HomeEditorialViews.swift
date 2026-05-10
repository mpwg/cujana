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
                .font(.system(.title2, design: .rounded).weight(.semibold))
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
                    .font(TypographyToken.personalStatusTitle)
                    .tracking(HomeOverviewToken.personalStatusTitleTracking)
                    .foregroundStyle(ColorToken.textPrimary)
                    .lineLimit(2)

                Text(statusSubtitle)
                    .font(TypographyToken.personalStatusSubtitle)
                    .foregroundStyle(ColorToken.textSecondary.opacity(HomeOverviewToken.personalStatusSubtitleOpacity))
                    .lineLimit(1)
            }

            Spacer(minLength: SpacingToken.sm)

            HomeRiskBadge(text: severityText)
        }
        .padding(.horizontal, CardToken.padding)
        .padding(.vertical, HomeOverviewToken.personalStatusVerticalPadding)
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

private struct HomeRiskBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(TypographyToken.severityPill.weight(.semibold))
            .foregroundStyle(SemanticColorToken.foreground(for: text))
            .lineLimit(1)
            .padding(.horizontal, HomeOverviewToken.personalStatusBadgePaddingH)
            .frame(height: HomeOverviewToken.personalStatusBadgeHeight)
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
                    .lineLimit(2)
                    .minimumScaleFactor(HomeOverviewToken.weatherDescriptionMinimumScale)

                Text("Ein kurzer Check-in hilft dir, Muster und Trigger besser zu verstehen.")
                    .font(TypographyToken.ctaSupporting)
                    .foregroundStyle(ColorToken.textSecondary.opacity(HomeOverviewToken.ctaSupportingOpacity))
                    .lineLimit(1)
                    .minimumScaleFactor(HomeOverviewToken.weatherDescriptionMinimumScale)
                    .frame(maxWidth: HomeOverviewToken.ctaSupportingMaxWidth, alignment: .leading)
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
                        .font(TypographyToken.ctaButton)
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
