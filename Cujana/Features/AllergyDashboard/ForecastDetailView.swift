import SwiftUI

struct ForecastDetailView: View {
    let days: [ForecastDetailDayItem]

    @Environment(\.dismiss) private var dismiss
    @State private var selectedDayID: ForecastDetailDayItem.ID?
    @Namespace private var dayPickerNamespace

    private var selectedDay: ForecastDetailDayItem? {
        guard let selectedDayID else {
            return days.first
        }

        return days.first { $0.id == selectedDayID } ?? days.first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpacingToken.xl) {
                DetailNavigationHeader {
                    dismiss()
                }

                if let selectedDay {
                    DayPicker(
                        days: days,
                        selectedDayID: bindingForSelectedDay,
                        namespace: dayPickerNamespace
                    )

                    WeatherContextCard(day: selectedDay)
                        .transition(.opacity.combined(with: .move(edge: .top)))

                    FocusedAllergenSection(day: selectedDay)
                        .transition(.opacity)

                    HourlyAllergyRiskSection(day: selectedDay)
                        .transition(.opacity)
                } else {
                    DetailEmptyState()
                }

                DetailInfoCard()
                ForecastAttributionView()
            }
            .padding(.horizontal, SpacingToken.xl)
            .padding(.top, SpacingToken.sm)
            .padding(.bottom, SpacingToken.xl)
        }
        .scrollIndicators(.hidden)
        .background(ColorToken.backgroundPrimary.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
#if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
#endif
        .onAppear {
            if selectedDayID == nil {
                selectedDayID = days.first?.id
            }
        }
        .animation(.spring(response: 0.36, dampingFraction: 0.86), value: selectedDayID)
    }

    private var bindingForSelectedDay: Binding<ForecastDetailDayItem.ID?> {
        Binding(
            get: { selectedDayID ?? days.first?.id },
            set: { selectedDayID = $0 }
        )
    }
}

private struct DetailNavigationHeader: View {
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Text("Alle Details")
                .font(TypographyToken.headline)
                .foregroundStyle(ColorToken.textPrimary)
                .frame(maxWidth: .infinity)

            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .foregroundStyle(ColorToken.textPrimary)
                        .frame(width: 52, height: 52)
                        .background(.thinMaterial)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(ColorToken.separatorSoft, lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Zurück")

                Spacer()
            }
        }
        .frame(minHeight: 56)
    }
}

private struct DayPicker: View {
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
                    HStack(spacing: SpacingToken.xs) {
                        Image(systemName: "leaf")
                            .font(.system(.footnote, design: .rounded).weight(.semibold))

                        Text(day.title)
                            .font(TypographyToken.footnote.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }
                    .foregroundStyle(isSelected ? ColorToken.accentPrimary : ColorToken.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .padding(.horizontal, SpacingToken.sm)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(ColorToken.accentSoft.opacity(SurfaceOpacityToken.accentProminent))
                                .matchedGeometryEffect(id: "active-day", in: namespace)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(day.title) auswählen")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(SpacingToken.xs)
        .background(ColorToken.cardBackground.opacity(SurfaceOpacityToken.primaryCard))
        .clipShape(Capsule())
        .softShadow(ShadowToken.card)
    }
}

private struct WeatherContextCard: View {
    let day: ForecastDetailDayItem

    var body: some View {
        HStack(alignment: .center, spacing: SpacingToken.md) {
            Image(systemName: day.weatherSystemImageName)
                .font(.system(.title2, design: .rounded).weight(.medium))
                .foregroundStyle(ColorToken.accentPrimary)
                .frame(width: 48, height: 48)
                .background(ColorToken.accentSoft.opacity(SurfaceOpacityToken.accentProminent))
                .clipShape(Circle())
                .accessibilityHidden(true)

            Text(day.temperatureText)
                .font(.system(.title, design: .rounded).weight(.semibold))
                .foregroundStyle(ColorToken.textPrimary)
                .monospacedDigit()
                .accessibilityLabel("Temperatur \(day.temperatureText)")

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text(day.weatherText.capitalized)
                    .font(TypographyToken.bodyEmphasized)
                    .foregroundStyle(ColorToken.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                HStack(spacing: SpacingToken.md) {
                    WeatherMetricText(systemImageName: "humidity", text: day.humidityText ?? "n. v.")
                    WeatherMetricText(systemImageName: "wind", text: day.windText ?? "n. v.")
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, SpacingToken.lg)
        .padding(.vertical, SpacingToken.md)
        .background(ColorToken.cardBackground.opacity(SurfaceOpacityToken.primaryCard))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
        .softShadow(ShadowToken.card)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(weatherAccessibilityLabel)
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

private struct WeatherMetricText: View {
    let systemImageName: String
    let text: String

    var body: some View {
        Label(text, systemImage: systemImageName)
            .font(TypographyToken.caption)
            .foregroundStyle(ColorToken.textSecondary)
            .labelStyle(.titleAndIcon)
            .lineLimit(1)
    }
}

private struct FocusedAllergenSection: View {
    let day: ForecastDetailDayItem

    private var relevantItems: [ForecastDetailPollenItem] {
        day.pollenItems.filter(\.isRelevant)
    }

    private var noRiskItems: [ForecastDetailPollenItem] {
        day.pollenItems.filter { $0.isRelevant == false }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            SectionTitle("Allergene im Fokus")

            if relevantItems.isEmpty {
                CalmEmptyAllergenState()
            } else {
                VStack(spacing: SpacingToken.sm) {
                    ForEach(relevantItems) { item in
                        AllergenRow(item: item)
                    }
                }
            }

            if noRiskItems.isEmpty == false {
                CompactNoRiskSection(items: noRiskItems)
            }
        }
    }
}

private struct AllergenRow: View {
    let item: ForecastDetailPollenItem
    @State private var isExpanded = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: isExpanded ? SpacingToken.md : 0) {
                HStack(spacing: SpacingToken.md) {
                    Image(systemName: "leaf.fill")
                        .font(.system(.body, design: .rounded).weight(.medium))
                        .foregroundStyle(ColorToken.accentPrimary)
                        .frame(width: 40, height: 40)
                        .background(item.background)
                        .clipShape(Circle())
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: SpacingToken.xs) {
                        Text(item.title)
                            .font(TypographyToken.bodyEmphasized)
                            .foregroundStyle(ColorToken.textPrimary)
                            .lineLimit(1)

                        Text(item.levelDescription)
                            .font(TypographyToken.caption)
                            .foregroundStyle(ColorToken.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer(minLength: SpacingToken.sm)

                    RiskBadge(text: item.levelText, background: item.background)

                    Image(systemName: "chevron.right")
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(ColorToken.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .accessibilityHidden(true)
                }

                if isExpanded {
                    Text("Aktuelle Belastung: \(item.levelText.lowercased()).")
                        .font(TypographyToken.caption)
                        .foregroundStyle(ColorToken.textSecondary)
                        .padding(.leading, 52)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, SpacingToken.lg)
            .padding(.vertical, SpacingToken.md)
            .background(ColorToken.cardBackground.opacity(SurfaceOpacityToken.primaryCard))
            .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
            .softShadow(ShadowToken.card)
        }
        .buttonStyle(SoftPressButtonStyle())
        .accessibilityLabel("\(item.title), \(item.levelText). \(item.levelDescription)")
    }
}

private struct RiskBadge: View {
    let text: String
    let background: Color

    var body: some View {
        Text(text)
            .font(TypographyToken.caption.weight(.semibold))
            .foregroundStyle(ColorToken.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .padding(.horizontal, SpacingToken.sm)
            .padding(.vertical, SpacingToken.xs)
            .background(background)
            .clipShape(Capsule())
    }
}

private struct CompactNoRiskSection: View {
    let items: [ForecastDetailPollenItem]
    @State private var isExpanded = false

    private var visibleItems: [ForecastDetailPollenItem] {
        isExpanded ? items : Array(items.prefix(6))
    }

    private var allergenText: String {
        visibleItems.map(\.title).joined(separator: ", ")
    }

    var body: some View {
        Button {
            if items.count > 6 {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                    isExpanded.toggle()
                }
            }
        } label: {
            HStack(alignment: .top, spacing: SpacingToken.md) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(ColorToken.accentPositive)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: SpacingToken.xs) {
                    Text("Keine Belastung")
                        .font(TypographyToken.bodyEmphasized)
                        .foregroundStyle(ColorToken.textPrimary)

                    Text(allergenText)
                        .font(TypographyToken.caption)
                        .foregroundStyle(ColorToken.textSecondary)
                        .lineLimit(isExpanded ? nil : 2)

                    if remainingCount > 0 {
                        Text("\(remainingCount) weitere Allergene ohne Belastung")
                            .font(TypographyToken.caption.weight(.medium))
                            .foregroundStyle(ColorToken.accentPrimary)
                    }
                }

                Spacer(minLength: SpacingToken.sm)

                if items.count > 6 {
                    Image(systemName: "chevron.down")
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(ColorToken.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .accessibilityHidden(true)
                }
            }
            .padding(SpacingToken.lg)
            .background(ColorToken.cardMutedBackground.opacity(SurfaceOpacityToken.mutedCard))
            .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private var remainingCount: Int {
        max(items.count - visibleItems.count, 0)
    }

    private var accessibilityLabel: String {
        "Keine Belastung: \(items.map(\.title).joined(separator: ", "))"
    }
}

private struct HourlyAllergyRiskSection: View {
    let day: ForecastDetailDayItem

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            SectionTitle("Stündliches Allergierisiko")

            if day.hourlyAllergyRiskItems.isEmpty {
                Text("Stündliche Werte sind aktuell nicht verfügbar.")
                    .font(TypographyToken.body)
                    .foregroundStyle(ColorToken.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(SpacingToken.lg)
                    .background(ColorToken.cardMutedBackground.opacity(SurfaceOpacityToken.mutedCard))
                    .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: SpacingToken.sm) {
                        ForEach(day.hourlyAllergyRiskItems) { item in
                            HourlyRiskChip(
                                item: item,
                                temperatureText: day.temperatureText,
                                isCurrentHour: isCurrentHour(item)
                            )
                        }
                    }
                    .padding(.vertical, SpacingToken.xs)
                }
                .scrollIndicators(.hidden)

                NavigationLink {
                    HourlyRiskOverviewView(day: day)
                } label: {
                    HStack {
                        Text("Zur 24h-Übersicht")
                            .font(TypographyToken.bodyEmphasized)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                    }
                    .foregroundStyle(ColorToken.accentPrimary)
                    .padding(.horizontal, SpacingToken.lg)
                    .padding(.vertical, SpacingToken.md)
                    .background(ColorToken.accentSoft.opacity(SurfaceOpacityToken.accentSubtle))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Zur 24 Stunden Übersicht")
            }
        }
    }

    private func isCurrentHour(_ item: ForecastDetailHourlyRiskItem) -> Bool {
        day.title == "Heute" && item.hour == Calendar.current.component(.hour, from: Date())
    }
}

private struct HourlyRiskChip: View {
    let item: ForecastDetailHourlyRiskItem
    let temperatureText: String
    let isCurrentHour: Bool

    var body: some View {
        VStack(spacing: SpacingToken.xs) {
            Text(item.hourText)
                .font(TypographyToken.caption.weight(.medium))
                .foregroundStyle(ColorToken.textSecondary)
                .monospacedDigit()

            Circle()
                .fill(dotColor)
                .frame(width: isCurrentHour ? 9 : 7, height: isCurrentHour ? 9 : 7)
                .accessibilityHidden(true)

            Text(item.levelText)
                .font(TypographyToken.caption.weight(.semibold))
                .foregroundStyle(ColorToken.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Text(temperatureText)
                .font(TypographyToken.caption)
                .foregroundStyle(ColorToken.textSecondary)
                .monospacedDigit()
        }
        .frame(width: isCurrentHour ? 84 : 72)
        .frame(minHeight: isCurrentHour ? 108 : 96)
        .padding(.vertical, isCurrentHour ? SpacingToken.md : SpacingToken.sm)
        .background(item.background.opacity(isCurrentHour ? 1 : 0.72))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous)
                .stroke(isCurrentHour ? ColorToken.accentPrimary.opacity(0.28) : Color.clear, lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(item.hourText), Risiko \(item.levelText), \(temperatureText)")
    }

    private var dotColor: Color {
        switch item.levelText {
        case "Keine Belastung", "Niedrig":
            ColorToken.accentPositive
        case "Mittel":
            ColorToken.accentWarning
        default:
            ColorToken.accentNegative
        }
    }
}

private struct HourlyRiskOverviewView: View {
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
                            .fill(item.levelText == "Keine Belastung" ? ColorToken.accentPositive : ColorToken.accentPrimary)
                            .frame(width: 8, height: 8)
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
                    .background(item.background.opacity(0.72))
                    .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous))
                }
            }
            .padding(SpacingToken.xl)
        }
        .background(ColorToken.backgroundPrimary.ignoresSafeArea())
        .navigationTitle("24h-Übersicht")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

private struct DetailInfoCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: SpacingToken.md) {
            Image(systemName: "info.circle")
                .font(.system(.body, design: .rounded).weight(.medium))
                .foregroundStyle(ColorToken.textTertiary)
                .accessibilityHidden(true)

            Text("Die Werte basieren auf Pollenflug-Prognosen und können sich im Tagesverlauf ändern.")
                .font(TypographyToken.caption)
                .foregroundStyle(ColorToken.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(SpacingToken.lg)
        .background(ColorToken.cardMutedBackground.opacity(SurfaceOpacityToken.mutedCard))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

private struct SectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(TypographyToken.headline)
            .foregroundStyle(ColorToken.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CalmEmptyAllergenState: View {
    var body: some View {
        HStack(spacing: SpacingToken.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(ColorToken.accentPositive)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text("Aktuell keine relevante Belastung")
                    .font(TypographyToken.bodyEmphasized)
                    .foregroundStyle(ColorToken.textPrimary)

                Text("Alle gemeldeten Allergene liegen im ruhigen Bereich.")
                    .font(TypographyToken.caption)
                    .foregroundStyle(ColorToken.textSecondary)
            }
        }
        .padding(SpacingToken.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ColorToken.cardBackground.opacity(SurfaceOpacityToken.primaryCard))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
        .softShadow(ShadowToken.card)
    }
}

private struct DetailEmptyState: View {
    var body: some View {
        Text("Keine Detailprognose verfügbar.")
            .font(TypographyToken.body)
            .foregroundStyle(ColorToken.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(SpacingToken.lg)
            .background(ColorToken.cardBackground.opacity(SurfaceOpacityToken.primaryCard))
            .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
    }
}

private struct SoftPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? PressFeedbackToken.prominentScale : 1)
            .opacity(configuration.isPressed ? PressFeedbackToken.prominentOpacity : 1)
            .animation(.easeOut(duration: PressFeedbackToken.animationDuration), value: configuration.isPressed)
    }
}

private extension ForecastDetailPollenItem {
    var isRelevant: Bool {
        levelText != "Keine Belastung"
    }
}
