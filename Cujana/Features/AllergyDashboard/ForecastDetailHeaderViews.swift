import SwiftUI

struct DetailDayPicker: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let days: [ForecastDetailDayItem]
    @Binding var selectedDayID: ForecastDetailDayItem.ID?
    let namespace: Namespace.ID

    var body: some View {
        HStack(spacing: SpacingToken.xs) {
            ForEach(days) { day in
                let isSelected = day.id == selectedDayID

                Button {
                    selectedDayID = day.id
                } label: {
                    Label(day.title, systemImage: "leaf")
                        .font(TypographyToken.footnote.weight(.medium))
                        .lineLimit(1)
                        .minimumScaleFactor(ForecastDetailToken.dayPickerTextMinimumScale)
                        .foregroundStyle(isSelected ? ColorToken.accentDark : ColorToken.textSecondary)
                        .frame(maxWidth: .infinity, minHeight: ForecastDetailToken.dayPickerMinHeight)
                        .padding(.horizontal, SpacingToken.sm)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(ColorToken.accentSoft)
                                    .matchedGeometryEffect(id: "active-day", in: namespace)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(day.title) auswählen")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(ForecastDetailToken.dayPickerPadding)
        .frame(height: ForecastDetailToken.dayPickerHeight)
        .background(
            reduceTransparency
                ? ColorToken.secondarySurface
                : ColorToken.cardBackground.opacity(ForecastDetailToken.dayPickerSurfaceOpacity)
        )
        .background {
            if reduceTransparency == false {
                Color.clear.background(.ultraThinMaterial)
            }
        }
        .clipShape(Capsule())
        .softShadow(ShadowToken.floating)
    }
}

struct WeatherContextRow: View {
    let day: ForecastDetailDayItem

    var body: some View {
        HStack(alignment: .center, spacing: SpacingToken.md) {
            Image(systemName: day.weatherSystemImageName)
                .font(.system(size: 34, weight: .medium, design: .rounded))
                .foregroundStyle(ColorToken.accentDark)
                .frame(width: ForecastDetailToken.weatherIconSize, height: ForecastDetailToken.weatherIconSize)
                .background(ColorToken.accentSoft)
                .clipShape(Circle())
                .accessibilityHidden(true)

            Text(day.temperatureText)
                .font(.system(size: 38, weight: .semibold, design: .rounded))
                .foregroundStyle(ColorToken.textPrimary)
                .monospacedDigit()
                .accessibilityLabel("Temperatur \(day.temperatureText)")

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text(day.weatherText.capitalized)
                    .font(.system(.body, design: .rounded).weight(.medium))
                    .foregroundStyle(ColorToken.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(ForecastDetailToken.weatherTextMinimumScale)
                    .opacity(DetailColorToken.weatherDescriptionText)

                Text(metricText)
                    .font(TypographyToken.secondaryBody)
                    .foregroundStyle(ColorToken.textSecondary.opacity(DetailColorToken.weatherMetricText))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(ForecastDetailToken.weatherCardPadding)
        .frame(minHeight: ForecastDetailToken.weatherMinHeight, alignment: .center)
        .background(ColorToken.secondarySurface)
        .clipShape(RoundedRectangle(cornerRadius: ForecastDetailToken.weatherCardCornerRadius, style: .continuous))
        .softShadow(ShadowToken.card)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(weatherAccessibilityLabel)
    }

    private var metricText: String {
        let metrics = [
            day.humidityText,
            day.windText
        ]
        .compactMap(\.self)

        if metrics.isEmpty {
            return "Luftwerte nicht verfügbar"
        }

        return metrics.joined(separator: " · ")
    }

    private var weatherAccessibilityLabel: String {
        [
            day.temperatureText,
            day.weatherText,
            day.humidityText.map { "Luftfeuchtigkeit \($0)" },
            day.windText.map { "Wind \($0)" }
        ]
        .compactMap(\.self)
        .joined(separator: ", ")
    }
}

struct DetailContextLine: View {
    let day: ForecastDetailDayItem

    var body: some View {
        Text(text)
            .font(TypographyToken.footnote)
            .foregroundStyle(ColorToken.textSecondary.opacity(DetailColorToken.contextText))
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel(text)
    }

    private var text: String {
        if let focusedAllergen {
            return "\(day.title) \(focusedAllergen.levelAdjective) Belastung durch \(focusedAllergen.title)"
        }

        if let peakHour {
            return "Um \(peakHour.hourText) ist der Verlauf am auffälligsten."
        }

        return "Die Werte können sich im Tagesverlauf ändern."
    }

    private var focusedAllergen: ForecastDetailPollenItem? {
        day.pollenItems.first { $0.isRelevant }
    }

    private var peakHour: ForecastDetailHourlyRiskItem? {
        day.hourlyAllergyRiskItems.max { first, second in
            first.levelSortValue < second.levelSortValue
        }
    }
}
