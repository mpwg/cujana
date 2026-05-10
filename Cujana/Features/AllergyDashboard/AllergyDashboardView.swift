import SwiftUI

struct AllergyDashboardView: View {
    @Bindable var viewModel: AllergyDashboardViewModel
    let onStartSymptomEntry: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                content
                    .padding(.horizontal, SpacingToken.xl)
                    .padding(.top, SpacingToken.sm)
                    .padding(.bottom, SpacingToken.lg)
            }
            .scrollIndicators(.hidden)
            .background(ColorToken.backgroundPrimary.ignoresSafeArea())
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ColorToken.backgroundPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
#endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Übersicht")
                        .font(TypographyToken.headline)
                        .foregroundStyle(ColorToken.textPrimary)
                }
            }
            .task {
                await viewModel.load()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            VStack(spacing: SpacingToken.xl) {
                ForecastSummaryCard(
                    days: [],
                    detailDays: [],
                    isLoading: true
                )
                FeelingCTAView(action: onStartSymptomEntry)
            }
        case .empty(let dashboardContent), .loaded(let dashboardContent):
            dashboard(for: dashboardContent)
        case .failure:
            VStack(spacing: SpacingToken.xl) {
                ForecastSummaryCard(
                    days: [],
                    detailDays: [],
                    isLoading: false
                )
                FeelingCTAView(action: onStartSymptomEntry)
            }
        }
    }

    private func dashboard(for dashboardContent: AllergyDashboardContent) -> some View {
        VStack(spacing: SpacingToken.xl) {
            ForecastSummaryCard(
                days: dashboardContent.forecastDays,
                detailDays: dashboardContent.forecastDetailDays,
                isLoading: false
            )
            FeelingCTAView(action: onStartSymptomEntry)
        }
    }
}

private struct ForecastSummaryCard: View {
    let days: [ForecastDaySummaryItem]
    let detailDays: [ForecastDetailDayItem]
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            HStack(alignment: .center, spacing: SpacingToken.md) {
                Image(systemName: "leaf.fill")
                    .font(.system(.title3, design: .rounded).weight(.medium))
                    .foregroundStyle(ColorToken.accentPrimary)
                    .frame(width: 42, height: 42)
                    .background(ColorToken.accentSoft)
                    .clipShape(Circle())
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: SpacingToken.xs) {
                    Text("3-Tages-Überblick")
                        .font(TypographyToken.title)
                        .foregroundStyle(ColorToken.textPrimary)

                    Text("Allergene im Vordergrund")
                        .font(TypographyToken.footnote)
                        .foregroundStyle(ColorToken.textSecondary)
                }

                Spacer(minLength: SpacingToken.sm)

                if detailDays.isEmpty == false {
                    NavigationLink {
                        ForecastDetailView(days: detailDays)
                    } label: {
                        Label("Alle Details", systemImage: "leaf")
                            .font(TypographyToken.footnote.weight(.semibold))
                    }
                    .buttonStyle(CompactNavigationButtonStyle())
                    .accessibilityLabel("Alle Allergendetails anzeigen")
                }
            }

            if isLoading {
                ForecastLoadingState()
            } else {
                if days.isEmpty == false {
                    VStack(spacing: SpacingToken.sm) {
                        ForEach(days) { day in
                            DayOverviewCard(day: day)
                        }
                    }
                } else {
                    ForecastEmptyState()
                }
            }

            ForecastAttributionView()
        }
        .padding(CardToken.padding)
        .background(ColorToken.cardBackground.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
        .softShadow(ShadowToken.card)
    }
}

private struct ForecastLoadingState: View {
    var body: some View {
        HStack(spacing: SpacingToken.md) {
            ProgressView()
                .tint(ColorToken.accentPrimary)

            Text("Allergenlage wird geladen.")
                .font(TypographyToken.body)
                .foregroundStyle(ColorToken.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, SpacingToken.md)
    }
}

private struct DayOverviewCard: View {
    let day: ForecastDaySummaryItem

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            Text(day.title)
                .font(TypographyToken.bodyEmphasized)
                .foregroundStyle(ColorToken.textPrimary)

            if day.allergenItems.isEmpty {
                Text("Keine relevante Belastung")
                    .font(TypographyToken.caption)
                    .foregroundStyle(ColorToken.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, SpacingToken.xs)
            } else {
                VStack(spacing: SpacingToken.sm) {
                    ForEach(day.allergenItems) { item in
                        AllergenLoadRow(item: item)
                    }
                }
            }

            WeatherSummary(day: day)
        }
        .padding(.horizontal, SpacingToken.md)
        .padding(.vertical, SpacingToken.md)
        .background(ColorToken.cardMutedBackground.opacity(0.56))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(day.accessibilityText)
    }
}

private struct AllergenLoadRow: View {
    let item: ForecastDayAllergenItem

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: SpacingToken.md) {
            Text(item.title)
                .font(TypographyToken.footnote)
                .foregroundStyle(ColorToken.textPrimary)
                .lineLimit(nil)

            Spacer(minLength: SpacingToken.sm)

            Text(item.levelText)
                .font(TypographyToken.caption.weight(.semibold))
                .foregroundStyle(ColorToken.textPrimary)
                .padding(.horizontal, SpacingToken.sm)
                .padding(.vertical, SpacingToken.xs)
                .background(item.background)
                .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusSmall, style: .continuous))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct WeatherSummary: View {
    let day: ForecastDaySummaryItem

    var body: some View {
        HStack(alignment: .center, spacing: SpacingToken.sm) {
            Image(systemName: day.weatherSystemImageName)
                .font(.system(.footnote, design: .rounded).weight(.medium))
                .foregroundStyle(ColorToken.accentPrimary)
                .frame(width: 28, height: 28)
                .background(ColorToken.accentSoft.opacity(0.72))
                .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusSmall, style: .continuous))
                .accessibilityHidden(true)

            Text("\(day.temperatureText), \(day.weatherText)")
                .font(TypographyToken.caption)
                .foregroundStyle(ColorToken.textSecondary)
                .lineLimit(nil)

            Spacer(minLength: SpacingToken.sm)
        }
    }
}

private struct ForecastEmptyState: View {
    var body: some View {
        Text("Prognose aktuell nicht verfügbar.")
            .font(TypographyToken.body)
            .foregroundStyle(ColorToken.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, SpacingToken.md)
    }
}

private struct CompactNavigationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(ColorToken.accentPrimary)
            .padding(.horizontal, SpacingToken.sm)
            .padding(.vertical, SpacingToken.xs)
            .background(ColorToken.accentSoft.opacity(configuration.isPressed ? 0.72 : 0.52))
            .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusSmall, style: .continuous))
    }
}

struct ForecastAttributionView: View {
    private let attributionText = "Wetterdaten: Apple Weather. Pollen- und Allergierisiko: "
        + "Österreichischer Polleninformationsdienst, www.polleninformation.at."

    var body: some View {
        Text(attributionText)
            .multilineTextAlignment(.leading)
            .font(TypographyToken.caption)
            .foregroundStyle(ColorToken.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(attributionText)
    }
}

private struct FeelingCTAView: View {
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text("Wie fühlst du dich?")
                    .font(TypographyToken.title)
                    .foregroundStyle(ColorToken.textPrimary)

                Text("Ein kurzer Check-in genügt.")
                    .font(TypographyToken.body)
                    .foregroundStyle(ColorToken.textSecondary)
            }

            Button(action: action) {
                Label("Symptome erfassen", systemImage: "plus.circle.fill")
                    .font(TypographyToken.button)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(FeelingCTAButtonStyle())
            .accessibilityLabel("Symptome erfassen")
        }
        .padding(CardToken.padding)
        .background {
            RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous)
                .fill(ColorToken.cardMutedBackground)
                .overlay {
                    LinearGradient(
                        colors: [
                            ColorToken.accentSoft.opacity(0.52),
                            ColorToken.cardMutedBackground.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
        .softShadow(ShadowToken.card)
    }
}

private struct FeelingCTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(ColorToken.cardBackground)
            .padding(.horizontal, SpacingToken.xl)
            .padding(.vertical, SpacingToken.lg)
            .frame(minHeight: SpacingToken.xxl + SpacingToken.xl)
            .background(ColorToken.accentPrimary)
            .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
            .opacity(configuration.isPressed ? 0.9 : 1)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
