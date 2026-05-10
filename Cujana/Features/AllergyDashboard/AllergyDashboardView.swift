import SwiftUI

struct AllergyDashboardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Bindable var viewModel: AllergyDashboardViewModel
    let onStartSymptomEntry: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    HomeLogoHeader()
                    content
                }
                    .padding(.horizontal, SpacingToken.xl)
                    .padding(.top, 0)
                    .padding(.bottom, scrollBottomPadding)
            }
            .scrollIndicators(.hidden)
            .background(ColorToken.backgroundPrimary.ignoresSafeArea())
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ColorToken.backgroundPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
#endif
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
        VStack(spacing: SpacingToken.section) {
            ForecastSummaryCard(
                days: dashboardContent.forecastDays,
                detailDays: dashboardContent.forecastDetailDays,
                isLoading: false
            )
            FeelingCTAView(action: onStartSymptomEntry)
        }
    }

    private var scrollBottomPadding: CGFloat {
        if dynamicTypeSize >= .xxLarge {
            return HomeOverviewToken.largeTextScrollBottomPadding
        }

        return HomeOverviewToken.scrollBottomPadding
    }
}

private struct HomeLogoHeader: View {
    var body: some View {
        Image("Cujana")
            .resizable()
            .scaledToFit()
            .frame(
                width: HomeOverviewToken.navigationLogoWidth,
                height: HomeOverviewToken.navigationLogoHeight
            )
            .opacity(HomeOverviewToken.navigationLogoOpacity)
            .padding(.top, HomeOverviewToken.navigationLogoTopPadding)
            .padding(.bottom, HomeOverviewToken.navigationLogoBottomPadding)
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Cujana")
    }
}

private struct ForecastSummaryCard: View {
    let days: [ForecastDaySummaryItem]
    let detailDays: [ForecastDetailDayItem]
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.section) {
            VStack(alignment: .leading, spacing: SpacingToken.md) {
                HStack(alignment: .firstTextBaseline, spacing: SpacingToken.md) {
                    Text("3-Tage-Überblick")
                        .font(TypographyToken.headline)
                        .foregroundStyle(ColorToken.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: SpacingToken.sm)

                    if detailDays.isEmpty == false {
                        NavigationLink {
                            ForecastDetailView(days: detailDays)
                        } label: {
                            Label("Alle Details", systemImage: "chevron.right")
                                .labelStyle(.titleAndIcon)
                                .font(TypographyToken.caption)
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
                        ScrollView(.horizontal) {
                            HStack(spacing: SpacingToken.md) {
                                ForEach(days) { day in
                                    DayOverviewCard(day: day)
                                }
                            }
                            .padding(.vertical, SpacingToken.xs)
                        }
                        .scrollIndicators(.hidden)
                        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
                    } else {
                        ForecastEmptyState()
                    }
                }

                ForecastAttributionView()
            }
        }
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
            Text(day.title)
                .font(TypographyToken.caption)
                .tracking(HomeOverviewToken.dayLabelTracking)
                .textCase(.uppercase)
                .foregroundStyle(ColorToken.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(HomeOverviewToken.weatherDescriptionMinimumScale)

            HStack(alignment: .top, spacing: SpacingToken.sm) {
                VStack(alignment: .leading, spacing: SpacingToken.xs) {
                    Text(day.temperatureText)
                        .font(TypographyToken.dayTemperature)
                        .tracking(HomeOverviewToken.dayTemperatureTracking)
                        .foregroundStyle(ColorToken.textPrimary)
                        .monospacedDigit()
                }

                Spacer(minLength: SpacingToken.sm)

                Image(systemName: day.weatherSystemImageName)
                    .font(.system(size: HomeOverviewToken.dayWeatherIconFontSize, weight: .medium, design: .rounded))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(ColorToken.accentDark)
                    .frame(
                        width: HomeOverviewToken.dayWeatherIconSize,
                        height: HomeOverviewToken.dayWeatherIconSize
                    )
                    .background(ColorToken.accentSoft.opacity(HomeOverviewToken.dayWeatherIconBackgroundOpacity))
                    .clipShape(Circle())
                    .accessibilityHidden(true)
            }

            Text(day.weatherText.capitalized)
                .font(TypographyToken.secondaryBody)
                .foregroundStyle(ColorToken.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(HomeOverviewToken.weatherDescriptionMinimumScale)
                .fixedSize(horizontal: false, vertical: true)

            if day.allergenItems.isEmpty {
                Text("Keine relevante Belastung")
                    .font(TypographyToken.caption)
                    .foregroundStyle(ColorToken.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, SpacingToken.xs)
            } else {
                WrappingChipLayout(spacing: SpacingToken.xs) {
                    ForEach(day.allergenItems.prefix(2)) { item in
                        AllergenLoadBadge(item: item)
                    }
                }
            }
        }
        .padding(.top, HomeOverviewToken.dayCardPadding)
        .padding(.horizontal, HomeOverviewToken.dayCardPadding)
        .padding(.bottom, HomeOverviewToken.dayCardBottomPadding)
        .frame(
            width: HomeOverviewToken.dayCardWidth,
            height: HomeOverviewToken.dayCardHeight,
            alignment: .topLeading
        )
        .premiumSurface(cornerRadius: HomeOverviewToken.dayCardCornerRadius)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(day.accessibilityText)
    }
}

private struct AllergenLoadBadge: View {
    let item: ForecastDayAllergenItem

    var body: some View {
        Text("\(item.title) · \(item.levelText)")
                .font(TypographyToken.severityPill)
                .foregroundStyle(SemanticColorToken.foreground(for: item.levelText))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .padding(.horizontal, HomeOverviewToken.severityPillPaddingH)
                .frame(height: HomeOverviewToken.severityPillHeight)
                .background(SemanticColorToken.background(for: item.levelText))
                .clipShape(
                    RoundedRectangle(cornerRadius: HomeOverviewToken.severityPillCornerRadius, style: .continuous)
                )
        .fixedSize(horizontal: true, vertical: false)
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
            .foregroundStyle(ColorToken.accentDark)
            .padding(.horizontal, SpacingToken.md)
            .padding(.vertical, SpacingToken.sm)
            .background(ColorToken.accentSoft.opacity(
                configuration.isPressed ? HomeOverviewToken.compactButtonPressedOpacity : 1
            ))
            .clipShape(Capsule())
    }
}

struct ForecastAttributionView: View {
    private let attributionText = "Wetterdaten: Apple Weather. Pollen- und Allergierisiko: "
        + "Österreichischer Polleninformationsdienst, www.polleninformation.at."

    var body: some View {
        Text(attributionText)
            .multilineTextAlignment(.leading)
            .font(TypographyToken.attribution)
            .foregroundStyle(ColorToken.textTertiary.opacity(HomeOverviewToken.attributionOpacity))
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, HomeOverviewToken.attributionTopPadding)
            .accessibilityLabel(attributionText)
    }
}

private struct WrappingChipLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        let rows = makeRows(maxWidth: proposal.width, subviews: subviews)
        let width = proposal.width ?? rows.map(\.width).max() ?? .zero
        let height = rows.reduce(CGFloat.zero) { result, row in
            result + row.height
        } + spacing * CGFloat(max(rows.count - 1, .zero))

        return CGSize(width: width, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        let rows = makeRows(maxWidth: bounds.width, subviews: subviews)
        var yPosition = bounds.minY

        for row in rows {
            var xPosition = bounds.minX

            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: xPosition, y: yPosition),
                    proposal: ProposedViewSize(item.size)
                )
                xPosition += item.size.width + spacing
            }

            yPosition += row.height + spacing
        }
    }

    private func makeRows(maxWidth: CGFloat?, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentItems: [Item] = []
        var currentWidth = CGFloat.zero
        var currentHeight = CGFloat.zero
        let availableWidth = maxWidth ?? .infinity

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let itemWidth = currentItems.isEmpty ? size.width : currentWidth + spacing + size.width

            if itemWidth > availableWidth && currentItems.isEmpty == false {
                rows.append(Row(items: currentItems, width: currentWidth, height: currentHeight))
                currentItems = [Item(index: index, size: size)]
                currentWidth = size.width
                currentHeight = size.height
            } else {
                currentItems.append(Item(index: index, size: size))
                currentWidth = itemWidth
                currentHeight = max(currentHeight, size.height)
            }
        }

        if currentItems.isEmpty == false {
            rows.append(Row(items: currentItems, width: currentWidth, height: currentHeight))
        }

        return rows
    }

    private struct Row {
        let items: [Item]
        let width: CGFloat
        let height: CGFloat
    }

    private struct Item {
        let index: Int
        let size: CGSize
    }
}
