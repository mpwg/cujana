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
        .clipShape(RoundedRectangle(cornerRadius: ForecastDetailToken.dayPickerCornerRadius, style: .continuous))
        .softShadow(ShadowToken.floating)
    }
}

struct WeatherContextRow: View {
    let day: ForecastDetailDayItem

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text(statusHeadline)
                    .font(TypographyToken.detailStatusTitle)
                    .tracking(-0.6)
                    .foregroundStyle(ColorToken.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(ForecastDetailToken.weatherTextMinimumScale)
                    .opacity(DetailColorToken.weatherDescriptionText)

                Text(statusSubtitle)
                    .font(TypographyToken.detailStatusSubtitle)
                    .foregroundStyle(ColorToken.textSecondary)
                    .lineLimit(1)
            }

            Text(weatherContextText)
                .font(TypographyToken.caption)
                .foregroundStyle(
                    ForecastDetailToken.allergyWeatherContextText
                        .opacity(ForecastDetailToken.allergyWeatherContextOpacity)
                )
                .lineLimit(1)
                .minimumScaleFactor(ForecastDetailToken.weatherTextMinimumScale)
        }
        .padding(ForecastDetailToken.weatherCardPadding)
        .frame(minHeight: ForecastDetailToken.weatherMinHeight, alignment: .center)
        .premiumSurface(cornerRadius: ForecastDetailToken.weatherCardCornerRadius)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(weatherAccessibilityLabel)
    }

    private var statusHeadline: String {
        guard let focusedAllergen = day.primaryRelevantAllergen else {
            return "\(day.title) keine relevante Belastung"
        }

        return "\(day.title) \(focusedAllergen.levelAdjective) Belastung durch \(focusedAllergen.title)"
    }

    private var statusSubtitle: String {
        day.primaryRelevantAllergen == nil
            ? "Aktuell sind allergische Trigger eher ruhig."
            : "Symptome können heute stärker auftreten."
    }

    private var weatherContextText: String {
        let metrics = [
            day.temperatureText == "--" ? nil : day.temperatureText,
            day.weatherText.capitalized,
            day.humidityText,
            day.windText
        ]
        .compactMap(\.self)

        return metrics.joined(separator: " · ")
    }

    private var weatherAccessibilityLabel: String {
        [
            statusHeadline,
            statusSubtitle,
            day.temperatureText == "--" ? nil : day.temperatureText,
            day.weatherText.capitalized,
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
