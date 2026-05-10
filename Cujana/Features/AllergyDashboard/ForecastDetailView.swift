import SwiftUI

struct ForecastDetailView: View {
    let days: [ForecastDetailDayItem]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpacingToken.xl) {
                ForEach(days) { day in
                    ForecastDetailDayView(day: day)
                }

                ForecastAttributionView()
            }
            .padding(.horizontal, SpacingToken.xl)
            .padding(.top, SpacingToken.sm)
            .padding(.bottom, SpacingToken.lg)
        }
        .scrollIndicators(.hidden)
        .background(ColorToken.backgroundPrimary.ignoresSafeArea())
        .navigationTitle("Alle Details")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

private struct ForecastDetailDayView: View {
    let day: ForecastDetailDayItem

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            HStack(alignment: .center, spacing: SpacingToken.md) {
                Image(systemName: "leaf")
                    .font(.system(.title3, design: .rounded).weight(.light))
                    .foregroundStyle(ColorToken.accentPrimary)
                    .frame(width: ForecastDetailToken.dayIconSize, height: ForecastDetailToken.dayIconSize)
                    .background(ColorToken.accentSoft)
                    .clipShape(Circle())
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: SpacingToken.xs) {
                    Text(day.title)
                        .font(TypographyToken.title)
                        .foregroundStyle(ColorToken.textPrimary)

                    Text(day.allergyRiskText ?? "Allergierisiko aktuell nicht verfügbar")
                        .font(TypographyToken.body)
                        .foregroundStyle(ColorToken.textSecondary)
                }

                Spacer(minLength: SpacingToken.sm)

                if let topPollen = day.pollenItems.first {
                    Text(topPollen.levelText)
                        .font(TypographyToken.caption.weight(.semibold))
                        .foregroundStyle(ColorToken.textPrimary)
                        .padding(.horizontal, SpacingToken.sm)
                        .padding(.vertical, SpacingToken.xs)
                        .background(topPollen.background)
                        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusSmall, style: .continuous))
                }
            }

            DetailPollenSection(items: day.pollenItems)

            if day.hourlyAllergyRiskItems.isEmpty == false {
                DetailHourlyRiskSection(items: day.hourlyAllergyRiskItems)
            }

            DetailWeatherContext(day: day)
        }
        .padding(CardToken.padding)
        .background(ColorToken.cardBackground.opacity(SurfaceOpacityToken.primaryCard))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
        .softShadow(ShadowToken.card)
    }
}

private struct DetailWeatherContext: View {
    let day: ForecastDetailDayItem

    var body: some View {
        HStack(spacing: SpacingToken.sm) {
            Image(systemName: day.weatherSystemImageName)
                .foregroundStyle(ColorToken.accentPrimary)
                .frame(width: ForecastDetailToken.weatherIconWidth)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text("Wetter als Kontext")
                    .font(TypographyToken.caption)
                    .foregroundStyle(ColorToken.textSecondary)

                Text("\(day.weatherText), \(day.temperatureText)")
                    .font(TypographyToken.body)
                    .foregroundStyle(ColorToken.textPrimary)
            }
        }
    }
}

private struct DetailPollenSection: View {
    let items: [ForecastDetailPollenItem]

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm) {
            Text("Allergene im Fokus")
                .font(TypographyToken.bodyEmphasized)
                .foregroundStyle(ColorToken.textPrimary)

            if items.isEmpty {
                Text("Keine Polleninformationen für diesen Standort.")
                    .font(TypographyToken.body)
                    .foregroundStyle(ColorToken.textSecondary)
            } else {
                VStack(spacing: SpacingToken.sm) {
                    ForEach(items) { item in
                        DetailPollenRow(item: item)
                    }
                }
            }
        }
    }
}

private struct DetailPollenRow: View {
    let item: ForecastDetailPollenItem

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: SpacingToken.md) {
            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text(item.title)
                    .font(TypographyToken.bodyEmphasized)
                    .foregroundStyle(ColorToken.textPrimary)

                Text(item.levelDescription)
                    .font(TypographyToken.caption)
                    .foregroundStyle(ColorToken.textSecondary)
            }

            Spacer(minLength: SpacingToken.sm)

            Text(item.levelText)
                .font(TypographyToken.caption.weight(.semibold))
                .foregroundStyle(ColorToken.textPrimary)
                .padding(.horizontal, SpacingToken.sm)
                .padding(.vertical, SpacingToken.xs)
                .background(item.background)
                .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusSmall, style: .continuous))
        }
        .padding(.horizontal, SpacingToken.md)
        .padding(.vertical, SpacingToken.sm)
        .background(ColorToken.cardMutedBackground.opacity(SurfaceOpacityToken.mutedRow))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous))
    }
}

private struct DetailHourlyRiskSection: View {
    let items: [ForecastDetailHourlyRiskItem]

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm) {
            Text("Stündliches Allergierisiko")
                .font(TypographyToken.bodyEmphasized)
                .foregroundStyle(ColorToken.textPrimary)

            LazyVGrid(
                columns: [
                    GridItem(
                        .adaptive(minimum: ForecastDetailToken.hourlyRiskGridMinimumWidth),
                        spacing: SpacingToken.sm
                    )
                ],
                spacing: SpacingToken.sm
            ) {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: SpacingToken.xs) {
                        Text(item.hourText)
                            .font(TypographyToken.caption)
                            .foregroundStyle(ColorToken.textSecondary)

                        Text(item.levelText)
                            .font(TypographyToken.caption.weight(.semibold))
                            .foregroundStyle(ColorToken.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, SpacingToken.sm)
                    .padding(.vertical, SpacingToken.xs)
                    .background(item.background)
                    .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusSmall, style: .continuous))
                }
            }
        }
    }
}
