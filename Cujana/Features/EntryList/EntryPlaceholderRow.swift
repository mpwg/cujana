import SwiftUI

struct EntryPlaceholderRow: View {
    let systemImageName: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: SpacingToken.md) {
            EntryIcon(systemImageName: systemImageName, background: ChipToken.calmBackground)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text(title)
                    .font(TypographyToken.bodyEmphasized)
                    .foregroundStyle(ColorToken.textPrimary)

                Text(subtitle)
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct EntryIcon: View {
    let systemImageName: String
    let background: Color

    var body: some View {
        Image(systemName: systemImageName)
            .font(TypographyToken.bodyEmphasized)
            .foregroundStyle(ColorToken.accentPrimary)
            .frame(width: SelectionToken.size, height: SelectionToken.size)
            .background(background)
            .clipShape(Circle())
    }
}
