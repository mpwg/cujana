import Foundation
import Observation
import OSLog

enum UsageDataConsent: Equatable {
    case undecided
    case allowed
    case denied
}

protocol UsageDataConsentService: AnyObject {
    var usageDataConsent: UsageDataConsent { get }

    func setUsageDataCollectionAllowed(_ allowed: Bool)
}

final class UsageDataConsentStore {
    private let defaults: UserDefaults
    private let consentKey = "usageDataCollectionAllowed"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var consent: UsageDataConsent {
        guard defaults.object(forKey: consentKey) != nil else {
            return .undecided
        }

        return defaults.bool(forKey: consentKey) ? .allowed : .denied
    }

    func setConsent(_ consent: UsageDataConsent) {
        switch consent {
        case .undecided:
            defaults.removeObject(forKey: consentKey)
        case .allowed:
            defaults.set(true, forKey: consentKey)
        case .denied:
            defaults.set(false, forKey: consentKey)
        }
    }
}

protocol AppTelemetryGatewaying: AnyObject {
    var isSentryStarted: Bool { get }
    var isTelemetryDeckStarted: Bool { get }

    func startSentry(dsn: String)
    func stopSentry()
    func startTelemetryDeck(appID: String)
    func stopTelemetryDeck()
}

struct AppTelemetryConfiguration {
    let sentryDSN: String?
    let telemetryAppID: String?

    static func bundle(_ bundle: Bundle) -> AppTelemetryConfiguration {
        AppTelemetryConfiguration(
            sentryDSN: normalize(bundle.object(forInfoDictionaryKey: "SENTRY_DSN") as? String),
            telemetryAppID: normalize(bundle.object(forInfoDictionaryKey: "TELEMETRY_APP_ID") as? String)
        )
    }

    private static func normalize(_ value: String?) -> String? {
        guard let value else {
            return nil
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return nil
        }

        if trimmed.hasPrefix("$("), trimmed.hasSuffix(")") {
            return nil
        }

        return trimmed
    }
}

@MainActor
@Observable
final class AppTelemetryService: UsageDataConsentService {
    private static let logger = Logger(subsystem: "Cujana", category: "Telemetry")
    private let store: UsageDataConsentStore
    private let gateway: AppTelemetryGatewaying
    private let configuration: AppTelemetryConfiguration
    private var isTelemetrySuppressed = false

    init(
        store: UsageDataConsentStore = UsageDataConsentStore(),
        gateway: AppTelemetryGatewaying = AppTelemetryGateway(),
        configuration: AppTelemetryConfiguration = .bundle(.main)
    ) {
        self.store = store
        self.gateway = gateway
        self.configuration = configuration
    }

    var usageDataConsent: UsageDataConsent {
        store.consent
    }

    var isUsageDataCollectionAllowed: Bool {
        usageDataConsent == .allowed
    }

    var shouldAskForUsageDataConsent: Bool {
        usageDataConsent == .undecided
    }

    func configureIfPermitted(isTelemetrySuppressed: Bool = AppRuntimeEnvironment.isTelemetrySuppressed) {
        self.isTelemetrySuppressed = isTelemetrySuppressed
        guard usageDataConsent == .allowed else {
            stopTelemetry()
            return
        }

        startTelemetryIfPossible()
    }

    func setUsageDataCollectionAllowed(_ allowed: Bool) {
        store.setConsent(allowed ? .allowed : .denied)

        if allowed {
            startTelemetryIfPossible()
        } else {
            stopTelemetry()
        }
    }

    private func startTelemetryIfPossible() {
        guard !isTelemetrySuppressed else {
            return
        }

        if !gateway.isSentryStarted, let sentryDSN {
            gateway.startSentry(dsn: sentryDSN)
        } else if sentryDSN == nil {
            Self.logger.notice(
                "Sentry ist deaktiviert, weil keine gültige DSN in der App-Konfiguration gefunden wurde."
            )
        }

        if !gateway.isTelemetryDeckStarted, let telemetryAppID {
            gateway.startTelemetryDeck(appID: telemetryAppID)
        }
    }

    private func stopTelemetry() {
        if gateway.isSentryStarted {
            gateway.stopSentry()
        }

        if gateway.isTelemetryDeckStarted {
            gateway.stopTelemetryDeck()
        }
    }

    private var sentryDSN: String? {
        configuration.sentryDSN
    }

    private var telemetryAppID: String? {
        configuration.telemetryAppID
    }
}

enum AppRuntimeEnvironment {
    static var isTelemetrySuppressed: Bool {
        let processInfo = ProcessInfo.processInfo
        let arguments = processInfo.arguments
        let environment = processInfo.environment

        return arguments.contains("-ui_testing")
            || arguments.contains("-FASTLANE_SNAPSHOT")
            || arguments.contains("-cujana_screenshot_screen")
            || environment["XCTestConfigurationFilePath"] != nil
    }
}
