import SwiftUI

struct HourlyRiskOverviewView: View {
    let day: ForecastDetailDayItem

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: SpacingToken.sm) {
                ForEach(day.hourlyAllergyRiskItems) { item in
                    HStack(spacing: SpacingToken.md) {
                        Text(item.hourText)
                            .font(TypographyToken.bodyEmphasized)
                            .foregroundStyle(ColorToken.textPrimary)
                            .monospacedDigit()

                        Circle()
                            .fill(DetailColorToken.riskDot(for: item.levelText))
                            .frame(
                                width: ForecastDetailToken.overviewDotSize,
                                height: ForecastDetailToken.overviewDotSize
                            )
                            .accessibilityHidden(true)

                        Text(item.levelText)
                            .font(TypographyToken.body)
                            .foregroundStyle(ColorToken.textSecondary)

                        Spacer()

                        Text(day.temperatureText)
                            .font(TypographyToken.bodyEmphasized)
                            .foregroundStyle(ColorToken.textPrimary)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, SpacingToken.lg)
                    .padding(.vertical, SpacingToken.md)
                    .background(
                        DetailColorToken.riskBackground(for: item.levelText)
                            .opacity(DetailColorToken.overviewRiskBackground)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous))
                }
            }
            .padding(SpacingToken.xl)
        }
        .background(DetailColorToken.background.ignoresSafeArea())
        .navigationTitle("24h-Übersicht")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

struct DetailInfoCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: SpacingToken.md) {
            Image(systemName: "info.circle")
                .font(.system(.footnote, design: .rounded).weight(.medium))
                .foregroundStyle(ColorToken.textTertiary)
                .accessibilityHidden(true)

            Text("Die Werte basieren auf Pollenflug-Prognosen und können sich im Tagesverlauf ändern.")
                .font(TypographyToken.footnote)
                .foregroundStyle(ColorToken.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, SpacingToken.lg)
        .padding(.vertical, SpacingToken.md)
        .background(DetailColorToken.mutedSurface)
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

struct AttributionFooter: View {
    private let text = "Wetterdaten: Apple Weather · Pollendaten: Österreichischer Polleninformationsdienst"

    var body: some View {
        Text(text)
            .font(.system(.footnote, design: .rounded))
            .foregroundStyle(ColorToken.textTertiary.opacity(DetailColorToken.attributionText))
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel(text)
    }
}

struct SectionTitle: View {
    enum Prominence {
        case primary
        case secondary
    }

    let title: String
    let prominence: Prominence

    init(_ title: String, prominence: Prominence) {
        self.title = title
        self.prominence = prominence
    }

    var body: some View {
        Text(title)
            .font(prominence == .primary ? TypographyToken.headline : TypographyToken.bodyEmphasized)
            .foregroundStyle(
                prominence == .primary
                    ? ColorToken.textPrimary
                    : ColorToken.textPrimary.opacity(DetailColorToken.secondaryTextSubtle)
            )
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CalmEmptyAllergenState: View {
    var body: some View {
        HStack(spacing: SpacingToken.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(DetailColorToken.sageTertiary)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text("Aktuell keine relevante Belastung")
                    .font(TypographyToken.bodyEmphasized)
                    .foregroundStyle(ColorToken.textPrimary)

                Text("Alle gemeldeten Allergene liegen im ruhigen Bereich.")
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textSecondary)
            }
        }
        .padding(.horizontal, SpacingToken.lg)
        .padding(.vertical, SpacingToken.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DetailColorToken.surface)
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous)
                .stroke(DetailColorToken.neutralStroke, lineWidth: 1)
        }
    }
}

struct AllergenDetailSheet: View {
    let item: ForecastDetailPollenItem

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            HStack(spacing: SpacingToken.md) {
                Image(systemName: "leaf.fill")
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(DetailColorToken.sage)
                    .frame(
                        width: ForecastDetailToken.allergenSheetIconSize,
                        height: ForecastDetailToken.allergenSheetIconSize
                    )
                    .background(DetailColorToken.riskBackground(for: item.levelText))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: SpacingToken.xs) {
                    Text(item.title)
                        .font(TypographyToken.headline)
                        .foregroundStyle(ColorToken.textPrimary)

                    RiskBadge(text: item.levelText)
                }
            }

            Text(item.levelDescription)
                .font(TypographyToken.body)
                .foregroundStyle(ColorToken.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(SpacingToken.xl)
        .background(DetailColorToken.background)
    }
}

struct DetailEmptyState: View {
    var body: some View {
        Text("Keine Detailprognose verfügbar.")
            .font(TypographyToken.body)
            .foregroundStyle(ColorToken.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(SpacingToken.lg)
            .background(DetailColorToken.surface)
            .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous))
    }
}

struct SoftPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? PressFeedbackToken.prominentScale : 1)
            .opacity(configuration.isPressed ? PressFeedbackToken.prominentOpacity : 1)
            .animation(.easeOut(duration: PressFeedbackToken.animationDuration), value: configuration.isPressed)
    }
}

extension ForecastDetailPollenItem {
    var isRelevant: Bool {
        levelText != "Keine Belastung"
    }
}
