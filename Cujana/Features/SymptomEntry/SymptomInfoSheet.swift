import SwiftUI

struct SymptomInfoSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: SpacingToken.lg) {
                Text("Welche Symptome soll ich auswählen?")
                    .font(TypographyToken.symptomInfoTitle)
                    .foregroundStyle(ColorToken.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(
                    "Wähle alle Symptome aus, die gerade auf dich zutreffen. "
                    + "Du kannst mehrere Symptome kombinieren und zusätzlich eine Notiz ergänzen."
                )
                .font(TypographyToken.body)
                .foregroundStyle(ColorToken.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: SpacingToken.md) {
                    InfoSheetRow(
                        iconName: "chart.line.uptrend.xyaxis",
                        text: "Mehrere Symptome helfen, deinen Verlauf später besser einzuordnen."
                    )
                    InfoSheetRow(
                        iconName: "pencil",
                        text: "Du kannst Einträge später ergänzen oder korrigieren."
                    )
                }

                Spacer()
            }
            .padding(InputToken.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ColorToken.backgroundPrimary.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                    .foregroundStyle(SymptomCheckInToken.accentPressed)
                }
            }
        }
    }
}

private struct InfoSheetRow: View {
    let iconName: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: SpacingToken.md) {
            Image(systemName: iconName)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(SymptomCheckInToken.accentPressed)
                .frame(width: SymptomCheckInToken.hintIconSize)
                .accessibilityHidden(true)

            Text(text)
                .font(TypographyToken.secondaryBody)
                .foregroundStyle(ColorToken.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
