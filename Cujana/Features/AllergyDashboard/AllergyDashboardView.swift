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
                    .padding(.bottom, SpacingToken.xl)
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
            VStack(spacing: SpacingToken.lg) {
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
            VStack(spacing: SpacingToken.lg) {
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
        VStack(spacing: SpacingToken.lg) {
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
        VStack(alignment: .leading, spacing: SpacingToken.sm) {
            HStack(alignment: .firstTextBaseline, spacing: SpacingToken.md) {
                VStack(alignment: .leading, spacing: SpacingToken.xs) {
                    Text("3-Tages-Überblick")
                        .font(TypographyToken.headline)
                        .foregroundStyle(ColorToken.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Relevante Belastungen")
                        .font(TypographyToken.caption)
                        .foregroundStyle(ColorToken.textSecondary)
                }
                .layoutPriority(HomeOverviewToken.titleLayoutPriority)

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
                    .layoutPriority(HomeOverviewToken.detailsButtonLayoutPriority)
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
        .padding(SpacingToken.lg)
        .background(ColorToken.cardBackground.opacity(SurfaceOpacityToken.primaryCard))
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
        VStack(alignment: .leading, spacing: SpacingToken.sm) {
            HStack(alignment: .top, spacing: SpacingToken.md) {
                VStack(alignment: .leading, spacing: SpacingToken.xs) {
                    Text(day.title)
                        .font(TypographyToken.bodyEmphasized)
                        .foregroundStyle(ColorToken.textPrimary)

                    WeatherSummary(day: day)
                }

                Spacer(minLength: SpacingToken.sm)
            }

            if day.allergenItems.isEmpty {
                Text("Keine relevante Belastung")
                    .font(TypographyToken.caption)
                    .foregroundStyle(ColorToken.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, SpacingToken.xs)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(
                            .adaptive(minimum: HomeOverviewToken.allergenGridMinimumWidth),
                            spacing: SpacingToken.xs
                        )
                    ],
                    alignment: .leading,
                    spacing: SpacingToken.xs
                ) {
                    ForEach(day.allergenItems) { item in
                        AllergenLoadBadge(item: item)
                    }
                }
            }
        }
        .padding(.horizontal, SpacingToken.md)
        .padding(.vertical, SpacingToken.sm)
        .background(ColorToken.cardMutedBackground.opacity(SurfaceOpacityToken.mutedCard))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(day.accessibilityText)
    }
}

private struct AllergenLoadBadge: View {
    let item: ForecastDayAllergenItem

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: SpacingToken.xs) {
            Text(item.title)
                .font(TypographyToken.footnote)
                .foregroundStyle(ColorToken.textPrimary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Text(item.levelText)
                .font(TypographyToken.caption.weight(.semibold))
                .foregroundStyle(ColorToken.textPrimary)
                .padding(.horizontal, SpacingToken.sm)
                .padding(.vertical, SpacingToken.xs)
                .background(item.background)
                .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusSmall, style: .continuous))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, SpacingToken.sm)
        .padding(.vertical, SpacingToken.xs)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ColorToken.cardBackground.opacity(AllergenLoadToken.backgroundOpacity))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusSmall, style: .continuous))
    }
}

private struct WeatherSummary: View {
    let day: ForecastDaySummaryItem

    var body: some View {
        HStack(alignment: .center, spacing: SpacingToken.sm) {
            Image(systemName: day.weatherSystemImageName)
                .font(.system(.footnote, design: .rounded).weight(.medium))
                .foregroundStyle(ColorToken.accentPrimary)
                .frame(width: HomeOverviewToken.weatherIconSize, height: HomeOverviewToken.weatherIconSize)
                .background(ColorToken.accentSoft.opacity(SurfaceOpacityToken.accentProminent))
                .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusSmall, style: .continuous))
                .accessibilityHidden(true)

            Text(summaryText)
                .font(TypographyToken.caption)
                .foregroundStyle(ColorToken.textSecondary)
                .lineLimit(nil)

            Spacer(minLength: SpacingToken.sm)
        }
    }

    private var summaryText: String {
        if day.temperatureText == "--" {
            return "Wetter noch nicht verfügbar"
        }

        return "\(day.temperatureText), \(day.weatherText)"
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
            .background(
                ColorToken.accentSoft.opacity(
                    configuration.isPressed
                        ? SurfaceOpacityToken.accentProminent
                        : SurfaceOpacityToken.accentSubtle
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusSmall, style: .continuous))
    }
}

struct ForecastAttributionView: View {
    private let attributionText = "Wetterdaten: Apple Weather. Pollen- und Allergierisiko: "
        + "Österreichischer Polleninformationsdienst, www.polleninformation.at."

    var body: some View {
        Text(attributionText)
            .multilineTextAlignment(.leading)
            .font(.system(.caption2))
            .foregroundStyle(ColorToken.textTertiary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(attributionText)
    }
}

private struct FeelingCTAView: View {
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text("Wie fühlst du dich?")
                    .font(TypographyToken.headline)
                    .foregroundStyle(ColorToken.textPrimary)

                Text("Ein kurzer Check-in genügt.")
                    .font(TypographyToken.footnote)
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
        .padding(SpacingToken.lg)
        .background {
            RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous)
                .fill(ColorToken.cardMutedBackground)
                .overlay {
                    LinearGradient(
                        colors: [
                            ColorToken.accentSoft.opacity(SurfaceOpacityToken.accentSubtle),
                            ColorToken.cardMutedBackground.opacity(SurfaceOpacityToken.backgroundWash)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous)
                        .stroke(ColorToken.accentPrimary.opacity(SurfaceOpacityToken.accentSubtle))
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
            .padding(.horizontal, SpacingToken.lg)
            .padding(.vertical, SpacingToken.md)
            .frame(minHeight: SymptomCheckInToken.buttonMinHeight)
            .background(ColorToken.accentPrimary)
            .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
            .opacity(configuration.isPressed ? PressFeedbackToken.prominentOpacity : 1)
            .scaleEffect(configuration.isPressed ? PressFeedbackToken.prominentScale : 1)
            .animation(.easeInOut(duration: PressFeedbackToken.animationDuration), value: configuration.isPressed)
    }
}
