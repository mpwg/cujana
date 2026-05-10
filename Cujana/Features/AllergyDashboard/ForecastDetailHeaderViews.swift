import SwiftUI

struct DetailBackButton: View {
    let onBack: () -> Void

    var body: some View {
        Button(action: onBack) {
            Image(systemName: "chevron.left")
                .font(.system(.body, design: .rounded).weight(.semibold))
                .foregroundStyle(ColorToken.textPrimary)
                .frame(
                    width: ForecastDetailToken.navigationButtonSize,
                    height: ForecastDetailToken.navigationButtonSize
                )
                .background(.ultraThinMaterial)
                .background(DetailColorToken.toolbarOverlay)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(DetailColorToken.toolbarStrokeColor, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Zurück")
        .softShadow(ShadowToken.floating)
    }
}

struct DetailDayPicker: View {
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
                        .font(TypographyToken.footnote.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                        .foregroundStyle(isSelected ? DetailColorToken.sage : ColorToken.textSecondary)
                        .frame(maxWidth: .infinity, minHeight: ForecastDetailToken.dayPickerMinHeight)
                        .padding(.horizontal, SpacingToken.sm)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(DetailColorToken.selectedPickerBackground)
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
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(DetailColorToken.neutralStroke, lineWidth: 1)
        }
    }
}

struct WeatherContextRow: View {
    let day: ForecastDetailDayItem

    var body: some View {
        HStack(alignment: .center, spacing: SpacingToken.md) {
            Image(systemName: day.weatherSystemImageName)
                .font(.system(.title3, design: .rounded).weight(.medium))
                .foregroundStyle(DetailColorToken.sage)
                .frame(width: ForecastDetailToken.weatherIconSize, height: ForecastDetailToken.weatherIconSize)
                .background(DetailColorToken.weatherIconBackground)
                .clipShape(Circle())
                .accessibilityHidden(true)

            Text(day.temperatureText)
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .foregroundStyle(ColorToken.textPrimary)
                .monospacedDigit()
                .accessibilityLabel("Temperatur \(day.temperatureText)")

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text(day.weatherText.capitalized)
                    .font(.system(.title3, design: .rounded).weight(.medium))
                    .foregroundStyle(ColorToken.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.84)

                Text(metricText)
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, ForecastDetailToken.cardHorizontalPadding)
        .padding(.vertical, ForecastDetailToken.compactCardVerticalPadding)
        .frame(minHeight: ForecastDetailToken.weatherMinHeight, alignment: .center)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous)
                .stroke(DetailColorToken.neutralStroke, lineWidth: 1)
        }
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
