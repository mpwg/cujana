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
                    Text("Heute")
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
                ForecastSummaryCard(days: [], isLoading: true)
                FeelingCTAView(action: onStartSymptomEntry)
            }
        case .empty(let dashboardContent), .loaded(let dashboardContent):
            dashboard(for: dashboardContent)
        case .failure:
            VStack(spacing: SpacingToken.xl) {
                ForecastSummaryCard(days: [], isLoading: false)
                FeelingCTAView(action: onStartSymptomEntry)
            }
        }
    }

    private func dashboard(for dashboardContent: AllergyDashboardContent) -> some View {
        VStack(spacing: SpacingToken.xl) {
            ForecastSummaryCard(days: dashboardContent.forecastDays, isLoading: false)
            FeelingCTAView(action: onStartSymptomEntry)
        }
    }
}

private struct ForecastSummaryCard: View {
    let days: [ForecastDaySummaryItem]
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text("Heute & Morgen")
                    .font(TypographyToken.title)
                    .foregroundStyle(ColorToken.textPrimary)

                Text("Wetter und Pollen auf einen Blick")
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textSecondary)
            }

            if isLoading {
                HStack(spacing: SpacingToken.md) {
                    ProgressView()
                        .tint(ColorToken.accentPrimary)

                    Text("Prognose wird geladen.")
                        .font(TypographyToken.body)
                        .foregroundStyle(ColorToken.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, SpacingToken.md)
            } else if days.isEmpty {
                ForecastEmptyState()
            } else {
                VStack(spacing: SpacingToken.sm) {
                    ForEach(days) { day in
                        ForecastDaySummaryView(day: day)
                    }
                }
            }

            OpenMeteoAttributionView()
        }
        .padding(CardToken.padding)
        .background(ColorToken.cardBackground.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
        .softShadow(ShadowToken.card)
    }
}

private struct ForecastDaySummaryView: View {
    let day: ForecastDaySummaryItem

    var body: some View {
        HStack(alignment: .center, spacing: SpacingToken.md) {
            Image(systemName: day.weatherSystemImageName)
                .font(.system(.title3, design: .rounded).weight(.light))
                .foregroundStyle(ColorToken.accentPrimary)
                .frame(width: 42, height: 42)
                .background(ColorToken.accentSoft)
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text(day.title)
                    .font(TypographyToken.bodyEmphasized)
                    .foregroundStyle(ColorToken.textPrimary)

                Text(day.weatherText)
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textSecondary)

                Text(day.pollenText)
                    .font(TypographyToken.footnote.weight(.medium))
                    .foregroundStyle(ColorToken.accentPrimary)
            }

            Spacer(minLength: SpacingToken.sm)

            Text(day.temperatureText)
                .font(TypographyToken.headline)
                .foregroundStyle(ColorToken.textPrimary)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, SpacingToken.md)
        .padding(.vertical, SpacingToken.sm)
        .background(ColorToken.cardMutedBackground.opacity(0.56))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(day.accessibilityText)
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

private struct OpenMeteoAttributionView: View {
    private let attributionText = "Wetter- und Pollendaten: Open-Meteo.com, CC BY 4.0. Zusammengefasst für Cujana."
    private let openMeteoURL = URL(string: "https://open-meteo.com/")!

    var body: some View {
        Link(destination: openMeteoURL) {
            Text(attributionText)
                .multilineTextAlignment(.leading)
        }
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
                Label("Check-in starten", systemImage: "plus.circle.fill")
                    .font(TypographyToken.button)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(FeelingCTAButtonStyle())
            .accessibilityLabel("Wie fühlst du dich? Check-in starten")
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
