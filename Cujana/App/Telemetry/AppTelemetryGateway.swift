import Foundation
import Sentry
import TelemetryDeck

@MainActor
final class AppTelemetryGateway: AppTelemetryGatewaying {
    private(set) var isSentryStarted = false
    private(set) var isTelemetryDeckStarted = false

    func startSentry(dsn: String) {
        SentrySDK.start { options in
            options.dsn = dsn
            options.sendDefaultPii = false
            options.tracesSampleRate = 0.2
            options.attachScreenshot = false
            options.attachViewHierarchy = false
            options.debug = false
            options.enableLogs = true
        }
        isSentryStarted = true
    }

    func stopSentry() {
        SentrySDK.close()
        isSentryStarted = false
    }

    func startTelemetryDeck(appID: String) {
        TelemetryDeck.initialize(config: .init(appID: appID))
        isTelemetryDeckStarted = true
    }

    func stopTelemetryDeck() {
        TelemetryDeck.terminate()
        isTelemetryDeckStarted = false
    }
}
