import Foundation
import Testing
@testable import Cujana

@MainActor
struct UsageDataConsentTests {

    @Test func consentStorePersistsExplicitDecisions() throws {
        let suiteName = "UsageDataConsentStoreTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = UsageDataConsentStore(defaults: defaults)

        #expect(store.consent == .undecided)

        store.setConsent(.allowed)
        #expect(store.consent == .allowed)

        store.setConsent(.denied)
        #expect(store.consent == .denied)

        store.setConsent(.undecided)
        #expect(store.consent == .undecided)
    }

    @Test func telemetryStartsOnlyAfterOptIn() throws {
        let suiteName = "AppTelemetryServiceTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let gateway = CapturingTelemetryGateway()
        let service = AppTelemetryService(
            store: UsageDataConsentStore(defaults: defaults),
            gateway: gateway,
            configuration: .test
        )

        service.configureIfPermitted(isTelemetrySuppressed: false)

        #expect(!gateway.isSentryStarted)
        #expect(!gateway.isTelemetryDeckStarted)

        service.setUsageDataCollectionAllowed(true)

        #expect(gateway.startedSentryDSN == "https://examplePublicKey@o0.ingest.sentry.io/0")
        #expect(gateway.startedTelemetryAppID == "cujana-telemetry-test")
    }

    @Test func telemetryStopsWhenConsentIsRevoked() throws {
        let suiteName = "AppTelemetryServiceTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let gateway = CapturingTelemetryGateway()
        let service = AppTelemetryService(
            store: UsageDataConsentStore(defaults: defaults),
            gateway: gateway,
            configuration: .test
        )

        service.setUsageDataCollectionAllowed(true)
        service.setUsageDataCollectionAllowed(false)

        #expect(!gateway.isSentryStarted)
        #expect(!gateway.isTelemetryDeckStarted)
        #expect(gateway.didStopSentry)
        #expect(gateway.didStopTelemetryDeck)
    }
}

@MainActor
private final class CapturingTelemetryGateway: AppTelemetryGatewaying {
    private(set) var isSentryStarted = false
    private(set) var isTelemetryDeckStarted = false
    private(set) var startedSentryDSN: String?
    private(set) var startedTelemetryAppID: String?
    private(set) var didStopSentry = false
    private(set) var didStopTelemetryDeck = false

    func startSentry(dsn: String) {
        startedSentryDSN = dsn
        isSentryStarted = true
    }

    func stopSentry() {
        didStopSentry = true
        isSentryStarted = false
    }

    func startTelemetryDeck(appID: String) {
        startedTelemetryAppID = appID
        isTelemetryDeckStarted = true
    }

    func stopTelemetryDeck() {
        didStopTelemetryDeck = true
        isTelemetryDeckStarted = false
    }
}

private extension AppTelemetryConfiguration {
    static let test = AppTelemetryConfiguration(
        sentryDSN: "https://examplePublicKey@o0.ingest.sentry.io/0",
        telemetryAppID: "cujana-telemetry-test"
    )
}
