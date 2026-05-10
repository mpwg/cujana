import SwiftUI

struct AllergenFocusCard: View {
    let items: [PollenDashboardItem]
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            header

            if isLoading {
                loadingState
            } else if items.isEmpty {
                emptyState
            } else {
                VStack(spacing: SpacingToken.sm) {
                    ForEach(items) { item in
                        AllergenFocusRow(item: item)
                    }
                }
            }
        }
        .padding(CardToken.padding)
        .background(ColorToken.cardBackground.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
        .softShadow(ShadowToken.card)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: SpacingToken.md) {
            Image(systemName: "leaf.fill")
                .font(.system(.title3, design: .rounded).weight(.medium))
                .foregroundStyle(ColorToken.accentPrimary)
                .frame(width: 42, height: 42)
                .background(ColorToken.accentSoft)
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text("Allergene heute")
                    .font(TypographyToken.title)
                    .foregroundStyle(ColorToken.textPrimary)

                Text(headerSubtitle)
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textSecondary)
            }
        }
    }

    private var loadingState: some View {
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

    private var emptyState: some View {
        Text("Keine Polleninformationen für diesen Standort.")
            .font(TypographyToken.body)
            .foregroundStyle(ColorToken.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, SpacingToken.md)
    }

    private var headerSubtitle: String {
        guard let firstItem = items.first else {
            return "Die stärksten Belastungen auf einen Blick"
        }

        return "\(firstItem.title) ist aktuell am relevantesten"
    }
}

private struct AllergenFocusRow: View {
    let item: PollenDashboardItem

    var body: some View {
        HStack(alignment: .center, spacing: SpacingToken.md) {
            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text(item.title)
                    .font(TypographyToken.bodyEmphasized)
                    .foregroundStyle(ColorToken.textPrimary)

                Text(item.levelDescription)
                    .font(TypographyToken.caption)
                    .foregroundStyle(ColorToken.textSecondary)
            }

            Spacer(minLength: SpacingToken.sm)

            Text(item.levelText)
                .font(TypographyToken.caption.weight(.semibold))
                .foregroundStyle(ColorToken.textPrimary)
                .padding(.horizontal, SpacingToken.sm)
                .padding(.vertical, SpacingToken.xs)
                .background(item.background)
                .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusSmall, style: .continuous))
                .minimumScaleFactor(0.82)
        }
        .padding(.horizontal, SpacingToken.md)
        .padding(.vertical, SpacingToken.sm)
        .background(ColorToken.cardMutedBackground.opacity(0.58))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(item.title), \(item.levelText), \(item.levelDescription)")
    }
}
