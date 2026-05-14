import SwiftUI

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var telemetryService: AppTelemetryService
    let backgroundLocationAuthorizer: (any BackgroundLocationAuthorizing)?
    @State private var locationStatusText: String

    init(
        telemetryService: AppTelemetryService,
        backgroundLocationAuthorizer: (any BackgroundLocationAuthorizing)? = nil
    ) {
        self.telemetryService = telemetryService
        self.backgroundLocationAuthorizer = backgroundLocationAuthorizer
        let statusText = backgroundLocationAuthorizer?.backgroundLocationStatusText
            ?? "Nicht verfügbar"
        self.locationStatusText = statusText
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SpacingToken.section) {
                    header
                    backgroundLocationSection
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
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active else {
                    return
                }

                updateLocationStatusText()
            }
        }
    }

    private var backgroundLocationSection: some View {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text("Wetter und Pollen")
                    .font(TypographyToken.headline)
                    .foregroundStyle(ColorToken.textPrimary)

                Text(locationStatusText)
                    .font(TypographyToken.footnote)
                    .foregroundStyle(locationStatusColor)
            }

            Button {
                Task {
                    await requestBackgroundLocationAuthorization()
                }
            } label: {
                Label("Standortzugriff erlauben", systemImage: "location")
                    .font(TypographyToken.bodyEmphasized)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderedProminent)
            .tint(ColorToken.accentPrimary)
            .disabled(backgroundLocationAuthorizer == nil)

            VStack(alignment: .leading, spacing: SpacingToken.sm) {
                Label("Cujana lädt Wetter- und Pollendaten für deine Umgebung beim Öffnen der App.", systemImage: "clock")
                Label(
                    "Die App nutzt keinen dauerhaften Standortzugriff im Hintergrund.",
                    systemImage: "arrow.clockwise"
                )
            }
            .font(TypographyToken.footnote)
            .foregroundStyle(ColorToken.textSecondary)
        }
        .cujanaCard()
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
            .tint(ColorToken.accentPrimary)

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
            ColorToken.accentPositive
        case .denied:
            ColorToken.textSecondary
        }
    }

    private var locationStatusColor: Color {
        guard backgroundLocationAuthorizer?.allowsBackgroundLocationRefresh == true else {
            return ColorToken.textSecondary
        }

        return ColorToken.accentPositive
    }

    @MainActor
    private func requestBackgroundLocationAuthorization() async {
        guard let backgroundLocationAuthorizer else {
            return
        }

        switch backgroundLocationAuthorizer.backgroundLocationAuthorizationState {
        case .always, .whenInUse:
            updateLocationStatusText()
            return
        case .denied, .restricted:
            openAppSettings()
            return
        case .notDetermined, .unknown:
            break
        }

        let isAuthorized = await backgroundLocationAuthorizer.requestBackgroundLocationRefreshAuthorization()
        updateLocationStatusText()

        guard isAuthorized == false,
              backgroundLocationAuthorizer.allowsBackgroundLocationRefresh == false else {
            return
        }

        openAppSettings()
    }

    @MainActor
    private func updateLocationStatusText() {
        locationStatusText = backgroundLocationAuthorizer?.backgroundLocationStatusText
            ?? "Nicht verfügbar"
    }

    @MainActor
    private func openAppSettings() {
        guard let settingsURL = backgroundLocationAuthorizer?.backgroundLocationSettingsURL else {
            return
        }

        openURL(settingsURL)
    }
}
