import SwiftUI

struct UsageDataConsentRootView<Content: View>: View {
    @Bindable var telemetryService: AppTelemetryService
    @State private var isUsageDataConsentPromptPresented = false
    private let content: Content

    init(
        telemetryService: AppTelemetryService,
        @ViewBuilder content: () -> Content
    ) {
        self.telemetryService = telemetryService
        self.content = content()
    }

    var body: some View {
        content
            .task {
                telemetryService.configureIfPermitted()
                presentUsageDataConsentPromptIfNeeded()
            }
            .sheet(
                isPresented: $isUsageDataConsentPromptPresented,
                onDismiss: {
                    if telemetryService.shouldAskForUsageDataConsent {
                        telemetryService.setUsageDataCollectionAllowed(false)
                    }
                },
                content: {
                    UsageDataConsentSheet(
                        allowCollection: {
                            telemetryService.setUsageDataCollectionAllowed(true)
                            isUsageDataConsentPromptPresented = false
                        },
                        denyCollection: {
                            telemetryService.setUsageDataCollectionAllowed(false)
                            isUsageDataConsentPromptPresented = false
                        }
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
            )
    }

    private func presentUsageDataConsentPromptIfNeeded() {
        guard !AppRuntimeEnvironment.isTelemetrySuppressed, telemetryService.shouldAskForUsageDataConsent else {
            return
        }

        isUsageDataConsentPromptPresented = true
    }
}

private struct UsageDataConsentSheet: View {
    let allowCollection: () -> Void
    let denyCollection: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.teal)

                Text("Nutzungsdaten teilen?")
                    .font(.title2.weight(.semibold))

                Text(
                    "Cujana kann anonyme Nutzungsdaten und technische Fehlerberichte senden, "
                        + "damit Stabilität und Bedienbarkeit verbessert werden. "
                        + "Ohne deine Zustimmung bleibt diese Erfassung aus."
                )
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 10) {
                Label(
                    "Keine Gesundheitsnotizen, keine genaue Position und keine persönlichen Angaben.",
                    systemImage: "lock"
                )
                Label(
                    "Du kannst die Entscheidung später durch Neuinstallation oder Zurücksetzen der App-Daten ändern.",
                    systemImage: "arrow.counterclockwise"
                )
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Spacer(minLength: 0)

            VStack(spacing: 12) {
                Button(action: allowCollection) {
                    Text("Erlauben")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button(action: denyCollection) {
                    Text("Nicht erlauben")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding(SpacingToken.xl)
    }
}
