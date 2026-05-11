import SwiftUI

struct SupplementalEntryField: View {
    @Binding var text: String
    let placeholder: String
    let accessibilityLabel: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(TypographyToken.body)
                    .foregroundStyle(SymptomCheckInToken.tertiaryText)
                    .padding(SymptomCheckInToken.notesPadding)
                    .accessibilityHidden(true)
            }

            TextEditor(text: $text)
                .font(TypographyToken.body)
                .foregroundStyle(ColorToken.textPrimary)
                .scrollContentBackground(.hidden)
                .padding(SymptomCheckInToken.notesPadding)
                .background(Color.clear)
        }
        .frame(minHeight: SymptomCheckInToken.dateCardCollapsedHeight)
        .background(ColorToken.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SymptomCheckInToken.notesCornerRadius, style: .continuous))
        .overlay(fieldBorder)
        .accessibilityLabel(accessibilityLabel)
    }

    private var fieldBorder: some View {
        RoundedRectangle(cornerRadius: SymptomCheckInToken.notesCornerRadius, style: .continuous)
            .stroke(
                SymptomCheckInToken.notesBorder,
                lineWidth: SymptomCheckInToken.notesBorderWidth
            )
    }
}

struct HistoricalContextCard: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: SpacingToken.sm) {
            Image(systemName: "clock.badge.checkmark")
                .font(SymptomCheckInToken.hintIconFont)
                .foregroundStyle(SymptomCheckInToken.accent)
                .accessibilityHidden(true)

            Text(text)
                .font(TypographyToken.symptomSectionDescription)
                .foregroundStyle(SymptomCheckInToken.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(SpacingToken.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SymptomCheckInToken.hintBackground)
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusSmall, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
