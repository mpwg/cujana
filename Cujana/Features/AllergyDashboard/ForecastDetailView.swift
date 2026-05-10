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
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: ForecastDetailToken.sectionSpacing) {
                if let selectedDay {
                    DetailDayPicker(
                        days: days,
                        selectedDayID: bindingForSelectedDay,
                        namespace: dayPickerNamespace
                    )

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
            .padding(.top, SpacingToken.lg)
            .padding(.bottom, SpacingToken.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
            .containerRelativeFrame(.horizontal)
        }
        .safeAreaInset(edge: .bottom) {
            Spacer()
                .frame(height: ForecastDetailToken.bottomInsetHeight)
        }
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        .scrollBounceBehavior(.basedOnSize, axes: .vertical)
        .scrollIndicators(.hidden)
        .background(DetailColorToken.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        #if os(iOS)
            .toolbarBackground(.hidden, for: .navigationBar)
        #endif
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    DetailBackButton {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Alle Details")
                        .font(TypographyToken.headline)
                        .foregroundStyle(ColorToken.textPrimary)
                }
            }
            .onAppear {
                if selectedDayID == nil {
                    selectedDayID = days.first?.id
                }
            }
            .animation(.spring(response: 0.38, dampingFraction: 0.94), value: selectedDayID)
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
                VStack(spacing: SpacingToken.sm) {
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
        HStack(spacing: SpacingToken.md) {
            Image(systemName: "leaf.fill")
                .font(.system(.footnote, design: .rounded).weight(.semibold))
                .foregroundStyle(DetailColorToken.sage)
                .frame(width: ForecastDetailToken.allergenIconSize, height: ForecastDetailToken.allergenIconSize)
                .background(DetailColorToken.riskBackground(for: item.levelText))
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(TypographyToken.bodyEmphasized)
                    .foregroundStyle(ColorToken.textPrimary)
                    .lineLimit(1)

                Text(item.levelDescription)
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: SpacingToken.sm)

            RiskBadge(text: item.levelText)
        }
        .frame(minHeight: ForecastDetailToken.allergenRowMinHeight)
        .padding(.horizontal, SpacingToken.lg)
        .padding(.vertical, SpacingToken.sm)
        .background(.thinMaterial)
        .background(DetailColorToken.surface)
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous)
                .stroke(
                    DetailColorToken.neutralStroke.opacity(DetailColorToken.rowStroke),
                    lineWidth: ForecastDetailToken.hairlineStrokeWidth
                )
        }
        .softShadow(ShadowToken.card)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.levelText). \(item.levelDescription)")
    }
}

struct RiskBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(TypographyToken.caption.weight(.semibold))
            .foregroundStyle(ColorToken.textPrimary.opacity(DetailColorToken.primaryTextSubtle))
            .lineLimit(1)
            .minimumScaleFactor(ForecastDetailToken.badgeTextMinimumScale)
            .padding(.horizontal, SpacingToken.sm)
            .padding(.vertical, ForecastDetailToken.badgeVerticalPadding)
            .background(DetailColorToken.riskBackground(for: text))
            .clipShape(Capsule())
    }
}

private struct CompactNoRiskCard: View {
    let items: [ForecastDetailPollenItem]

    var body: some View {
        HStack(spacing: SpacingToken.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(.footnote, design: .rounded).weight(.semibold))
                .foregroundStyle(DetailColorToken.sageTertiary)
                .accessibilityHidden(true)

            Text("\(items.count) Allergene aktuell ohne Belastung")
                .font(TypographyToken.footnote.weight(.medium))
                .foregroundStyle(ColorToken.textSecondary)
                .lineLimit(1)

            Spacer(minLength: SpacingToken.sm)
        }
        .frame(minHeight: ForecastDetailToken.noRiskMinHeight)
        .padding(.horizontal, SpacingToken.md)
        .padding(.vertical, ForecastDetailToken.noRiskVerticalPadding)
        .background(DetailColorToken.mutedSurface)
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusSmall, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(items.count) Allergene aktuell ohne Belastung")
    }
}

private struct HourlyRiskSection: View {
    let day: ForecastDetailDayItem

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            SectionTitle("Stündlicher Verlauf", prominence: .secondary)

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
    let item: ForecastDetailHourlyRiskItem
    let isCurrentHour: Bool

    var body: some View {
        VStack(spacing: 5) {
            Text(isCurrentHour ? "Jetzt" : item.hourText)
                .font(.system(.caption2, design: .rounded).weight(.medium))
                .foregroundStyle(isCurrentHour ? ColorToken.textPrimary : ColorToken.textSecondary)
                .monospacedDigit()

            Circle()
                .fill(DetailColorToken.riskDot(for: item.levelText))
                .frame(width: dotSize, height: dotSize)
                .accessibilityHidden(true)

            Text(item.levelText)
                .font(.system(.caption2, design: .rounded).weight(.semibold))
                .foregroundStyle(ColorToken.textPrimary.opacity(DetailColorToken.hourlyPrimaryText))
                .lineLimit(1)
                .minimumScaleFactor(ForecastDetailToken.hourlyTextMinimumScale)

            Text(item.temperatureText)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(ColorToken.textSecondary)
                .monospacedDigit()
        }
        .frame(width: chipWidth)
        .frame(minHeight: chipMinHeight)
        .background(chipBackground)
        .clipShape(RoundedRectangle(cornerRadius: ForecastDetailToken.hourlyChipCornerRadius, style: .continuous))
        .scaleEffect(isCurrentHour ? ForecastDetailToken.hourlyCurrentScale : 1)
        .overlay {
            RoundedRectangle(cornerRadius: ForecastDetailToken.hourlyChipCornerRadius, style: .continuous)
                .stroke(strokeColor, lineWidth: ForecastDetailToken.hairlineStrokeWidth)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(item.hourText), Risiko \(item.levelText), \(item.temperatureText)")
    }

    private var chipBackground: Color {
        if isCurrentHour {
            return DetailColorToken.riskBackground(for: item.levelText)
                .opacity(DetailColorToken.currentRiskBackground)
        }

        return DetailColorToken.riskBackground(for: item.levelText)
            .opacity(DetailColorToken.quietRiskBackground)
    }

    private var strokeColor: Color {
        isCurrentHour ? DetailColorToken.sageAccentBorder : DetailColorToken.neutralStroke
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
                    .font(TypographyToken.footnote.weight(.medium))
                    .foregroundStyle(ColorToken.textPrimary.opacity(DetailColorToken.primaryTextSubtle))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(.caption2, design: .rounded).weight(.semibold))
                    .foregroundStyle(ColorToken.textTertiary)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: ForecastDetailToken.subtleNavigationRowMinHeight)
            .padding(.horizontal, SpacingToken.lg)
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
