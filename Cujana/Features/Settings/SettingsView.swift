import SwiftUI

struct SettingsView: View {
    @Bindable var telemetryService: AppTelemetryService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SpacingToken.section) {
                    header
                    usageDataSection
                }
                .padding(.horizontal, SpacingToken.xl)
                .padding(.vertical, SpacingToken.xl)
            }
            .background(ColorToken.backgroundPrimary)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ColorToken.backgroundPrimary, for: .navigationBar)
#endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Einstellungen")
                        .font(TypographyToken.headline)
                        .foregroundStyle(ColorToken.textPrimary)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm) {
            Text("Einstellungen")
                .font(TypographyToken.largeTitle)
                .foregroundStyle(ColorToken.textPrimary)

            Text("Verwalte Datenschutz und App-Verhalten.")
                .font(TypographyToken.body)
                .foregroundStyle(ColorToken.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var usageDataSection: some View {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text("Nutzungsdaten")
                    .font(TypographyToken.headline)
                    .foregroundStyle(ColorToken.textPrimary)

                Text(consentStatusText)
                    .font(TypographyToken.footnote)
                    .foregroundStyle(consentStatusColor)
            }

            Toggle(
                isOn: Binding(
                    get: { telemetryService.isUsageDataCollectionAllowed },
                    set: { telemetryService.setUsageDataCollectionAllowed($0) }
                ),
                label: {
                    VStack(alignment: .leading, spacing: SpacingToken.xs) {
                        Text("Sentry und TelemetryDeck aktivieren")
                            .font(TypographyToken.bodyEmphasized)
                            .foregroundStyle(ColorToken.textPrimary)

                        Text("Sendet anonyme Nutzungsdaten und technische Fehlerberichte erst nach deiner Zustimmung.")
                            .font(TypographyToken.footnote)
                            .foregroundStyle(ColorToken.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            )
            .tint(ColorToken.brandPrimary)

            VStack(alignment: .leading, spacing: SpacingToken.sm) {
                Label("Keine Gesundheitsnotizen oder genaue Standortdaten.", systemImage: "lock")
                Label("Deaktivieren stoppt Sentry und TelemetryDeck sofort.", systemImage: "power")
            }
            .font(TypographyToken.footnote)
            .foregroundStyle(ColorToken.textSecondary)
        }
        .cujanaCard()
    }

    private var consentStatusText: String {
        switch telemetryService.usageDataConsent {
        case .undecided:
            "Noch nicht entschieden"
        case .allowed:
            "Aktiviert"
        case .denied:
            "Deaktiviert"
        }
    }

    private var consentStatusColor: Color {
        switch telemetryService.usageDataConsent {
        case .undecided:
            ColorToken.textTertiary
        case .allowed:
            ColorToken.feedbackSuccess
        case .denied:
            ColorToken.textSecondary
        }
    }
}
