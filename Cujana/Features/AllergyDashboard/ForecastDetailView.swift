import SwiftUI

struct ForecastDetailView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let days: [ForecastDetailDayItem]

    @State private var selectedDayID: ForecastDetailDayItem.ID?
    @Namespace private var dayPickerNamespace

    private var selectedDay: ForecastDetailDayItem? {
        guard let selectedDayID else {
            return days.first
        }

        return days.first { $0.id == selectedDayID } ?? days.first
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: ForecastDetailToken.sectionSpacing) {
                VStack(alignment: .leading, spacing: ForecastDetailToken.titleBottomPadding) {
                    Text("Alle Details")
                        .font(TypographyToken.detailTitle)
                        .tracking(-0.7)
                        .foregroundStyle(ColorToken.textPrimary)

                    DetailDayPicker(
                        days: days,
                        selectedDayID: bindingForSelectedDay,
                        namespace: dayPickerNamespace
                    )
                }

                if let selectedDay {
                    VStack(alignment: .leading, spacing: ForecastDetailToken.contextSpacing) {
                        WeatherContextRow(day: selectedDay)
                            .transition(.opacity)

                        DetailContextLine(day: selectedDay)
                    }

                    AllergenFocusSection(day: selectedDay)
                        .transition(.opacity)

                    HourlyRiskSection(day: selectedDay)
                        .transition(.opacity)
                } else {
                    DetailEmptyState()
                }

                DetailInfoCard()
                AttributionFooter()
            }
            .padding(.horizontal, ForecastDetailToken.screenHorizontalPadding)
            .padding(.top, ForecastDetailToken.screenTopPadding)
            .padding(.bottom, SpacingToken.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .safeAreaInset(edge: .bottom) {
            Spacer()
                .frame(height: ForecastDetailToken.bottomInsetHeight)
        }
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        .scrollBounceBehavior(.basedOnSize, axes: .vertical)
        .scrollIndicators(.hidden)
        .background(DetailColorToken.background.ignoresSafeArea())
        .navigationTitle("")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
        #endif
            .onAppear {
                if selectedDayID == nil {
                    selectedDayID = days.first?.id
                }
            }
            .animation(reduceMotion ? nil : MotionToken.detailSelection, value: selectedDayID)
    }

    private var bindingForSelectedDay: Binding<ForecastDetailDayItem.ID?> {
        Binding(
            get: { selectedDayID ?? days.first?.id },
            set: { selectedDayID = $0 }
        )
    }
}

private struct AllergenFocusSection: View {
    let day: ForecastDetailDayItem

    private var relevantItems: [ForecastDetailPollenItem] {
        day.pollenItems.filter(\.isRelevant)
    }

    private var noRiskItems: [ForecastDetailPollenItem] {
        day.pollenItems.filter { $0.isRelevant == false }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            SectionTitle("Allergene im Fokus", prominence: .primary)

            if relevantItems.isEmpty {
                CalmEmptyAllergenState()
            } else {
                VStack(spacing: SpacingToken.md) {
                    ForEach(relevantItems) { item in
                        AllergenFocusRow(item: item)
                    }
                }
            }

            if noRiskItems.isEmpty == false {
                CompactNoRiskCard(items: noRiskItems)
            }
        }
    }
}

private struct AllergenFocusRow: View {
    let item: ForecastDetailPollenItem

    var body: some View {
        HStack(alignment: .center, spacing: SpacingToken.md) {
            Image(systemName: "leaf.fill")
                .font(ForecastDetailToken.allergenIconFont)
                .foregroundStyle(SemanticColorToken.foreground(for: item.levelText))
                .frame(
                    width: ForecastDetailToken.allergenIconFrameSize,
                    height: ForecastDetailToken.allergenIconFrameSize
                )
                .background(DetailColorToken.riskBackground(for: item.levelText))
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: ForecastDetailToken.allergenTextSpacing) {
                Text(item.title)
                    .font(TypographyToken.allergenTitle)
                    .foregroundStyle(ColorToken.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)

                Text(item.symptomImpactText)
                    .font(TypographyToken.allergenDescription)
                    .foregroundStyle(ColorToken.textSecondary.opacity(DetailColorToken.secondaryTextReadable))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .layoutPriority(1)

            Spacer(minLength: SpacingToken.sm)

            RiskBadge(text: item.levelText)
                .layoutPriority(0)
        }
        .frame(minHeight: ForecastDetailToken.allergenRowMinHeight)
        .padding(ForecastDetailToken.allergenCardPadding)
        .premiumSurface(cornerRadius: ForecastDetailToken.allergenCardCornerRadius)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.levelText). \(item.symptomImpactText)")
    }

}

struct RiskBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(TypographyToken.severityPill.weight(.semibold))
            .foregroundStyle(SemanticColorToken.foreground(for: text))
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, ForecastDetailToken.badgeHorizontalPadding)
            .frame(minHeight: ForecastDetailToken.badgeHeight)
            .background(DetailColorToken.riskBackground(for: text))
            .clipShape(RoundedRectangle(cornerRadius: ForecastDetailToken.badgeCornerRadius, style: .continuous))
    }

}

private struct CompactNoRiskCard: View {
    let items: [ForecastDetailPollenItem]

    var body: some View {
        HStack(spacing: SpacingToken.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(TypographyToken.footnote.weight(.semibold))
                .foregroundStyle(DetailColorToken.sageTertiary)
                .accessibilityHidden(true)

            Text("\(items.count) weitere Allergene aktuell ohne Belastung")
                .font(TypographyToken.footnote.weight(.medium))
                .foregroundStyle(ColorToken.textSecondary.opacity(DetailColorToken.secondaryTextReadable))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: SpacingToken.sm)
        }
        .frame(minHeight: ForecastDetailToken.noRiskMinHeight)
        .padding(.horizontal, SpacingToken.md)
        .padding(.vertical, ForecastDetailToken.noRiskVerticalPadding)
        .background(ColorToken.cardMutedBackground)
        .clipShape(RoundedRectangle(cornerRadius: ForecastDetailToken.noRiskCornerRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(items.count) Allergene aktuell ohne Belastung")
    }
}

private struct HourlyRiskSection: View {
    let day: ForecastDetailDayItem

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            SectionTitle("Belastungsverlauf", prominence: .secondary)

            if day.hourlyAllergyRiskItems.isEmpty {
                Text("Stündliche Werte sind aktuell nicht verfügbar.")
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(SpacingToken.lg)
                    .background(DetailColorToken.mutedSurface)
                    .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous))
            } else {
                HourlyRiskScroller(day: day)

                SubtleNavigationRow(title: "Zur 24h-Übersicht") {
                    HourlyRiskOverviewView(day: day)
                }
            }
        }
    }
}

private struct HourlyRiskScroller: View {
    let day: ForecastDetailDayItem

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: ForecastDetailToken.hourlyChipSpacing) {
                ForEach(displayItems) { item in
                    HourlyRiskChip(
                        item: item,
                        isCurrentHour: isNow(item)
                    )
                }
            }
            .padding(.horizontal, ForecastDetailToken.hourlyScrollerHorizontalPadding)
            .padding(.vertical, SpacingToken.xs)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
    }

    private var displayItems: [ForecastDetailHourlyRiskItem] {
        guard day.title == "Heute" else {
            return day.hourlyAllergyRiskItems
        }

        let currentHour = Calendar.current.component(.hour, from: Date())
        let upcoming = day.hourlyAllergyRiskItems.filter { $0.hour >= currentHour }
        let earlier = day.hourlyAllergyRiskItems.filter { $0.hour < currentHour }
        return upcoming + earlier
    }

    private func isCurrentHour(_ item: ForecastDetailHourlyRiskItem) -> Bool {
        day.title == "Heute" && item.hour == Calendar.current.component(.hour, from: Date())
    }

    private func isNow(_ item: ForecastDetailHourlyRiskItem) -> Bool {
        guard day.title == "Heute" else {
            return false
        }

        return isCurrentHour(item) || item.id == displayItems.first?.id
    }
}

private struct HourlyRiskChip: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let item: ForecastDetailHourlyRiskItem
    let isCurrentHour: Bool

    var body: some View {
        VStack(spacing: ForecastDetailToken.hourlyChipContentSpacing) {
            Text(isCurrentHour ? "Jetzt" : item.hourText)
                .font(TypographyToken.hourlyHour)
                .foregroundStyle(isCurrentHour ? ColorToken.textPrimary : ColorToken.textSecondary)
                .monospacedDigit()

            Circle()
                .fill(DetailColorToken.riskDot(for: item.levelText))
                .frame(width: dotSize, height: dotSize)
                .accessibilityHidden(true)

            Text(item.levelText)
                .font(TypographyToken.hourlySeverity)
                .foregroundStyle(ColorToken.textPrimary.opacity(DetailColorToken.hourlyPrimaryText))
                .fixedSize(horizontal: false, vertical: true)

            Text(item.temperatureText)
                .font(TypographyToken.tinyMeta)
                .foregroundStyle(ColorToken.textSecondary.opacity(ForecastDetailToken.hourlyWeatherTextOpacity))
                .monospacedDigit()
        }
        .frame(minWidth: chipWidth)
        .frame(minHeight: chipMinHeight)
        .background { chipBackground }
        .clipShape(RoundedRectangle(cornerRadius: chipCornerRadius, style: .continuous))
        .scaleEffect(reduceMotion ? 1 : (isCurrentHour ? ForecastDetailToken.hourlyCurrentScale : 1))
        .softShadow(isCurrentHour ? ShadowToken.floating : ShadowTokenValue(color: .clear, radius: 0, y: 0))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(item.hourText), Belastung \(item.levelText), \(item.temperatureText)")
    }

    @ViewBuilder
    private var chipBackground: some View {
        if isCurrentHour {
            LinearGradient(
                colors: [
                    SemanticColorToken.highSeverityBackground.opacity(ForecastDetailToken.hourlyActiveTopOpacity),
                    SemanticColorToken.highSeverityBackground.opacity(ForecastDetailToken.hourlyActiveBottomOpacity)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            SemanticColorToken.highSeverityBackground
                .opacity(ForecastDetailToken.hourlyInactiveBackgroundOpacity)
        }
    }

    private var dotSize: CGFloat {
        isCurrentHour ? ForecastDetailToken.hourlyCurrentDotSize : ForecastDetailToken.hourlyDotSize
    }

    private var chipWidth: CGFloat {
        isCurrentHour ? ForecastDetailToken.hourlyCurrentChipWidth : ForecastDetailToken.hourlyChipWidth
    }

    private var chipMinHeight: CGFloat {
        isCurrentHour ? ForecastDetailToken.hourlyCurrentChipMinHeight : ForecastDetailToken.hourlyChipMinHeight
    }

    private var chipCornerRadius: CGFloat {
        isCurrentHour ? ForecastDetailToken.hourlyChipCornerRadius : ForecastDetailToken.hourlyInactiveChipCornerRadius
    }
}

private struct SubtleNavigationRow<Destination: View>: View {
    let title: String
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: SpacingToken.md) {
                Text(title)
                    .font(TypographyToken.footnote.weight(.semibold))
                    .foregroundStyle(ColorToken.textPrimary.opacity(DetailColorToken.primaryTextSubtle))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(TypographyToken.tinyMeta.weight(.semibold))
                    .foregroundStyle(ColorToken.textSecondary)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: ForecastDetailToken.subtleNavigationRowMinHeight)
            .padding(.horizontal, ForecastDetailToken.subtleNavigationHorizontalPadding)
            .background(.ultraThinMaterial)
            .background(DetailColorToken.mutedSurface.opacity(DetailColorToken.navigationSurface))
            .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusSmall, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: RadiusToken.radiusSmall, style: .continuous)
                    .stroke(
                        DetailColorToken.neutralStroke.opacity(DetailColorToken.quietStroke),
                        lineWidth: ForecastDetailToken.hairlineStrokeWidth
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}
