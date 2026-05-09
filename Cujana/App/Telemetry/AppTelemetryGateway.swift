import Foundation
import Sentry
import TelemetryDeck

@MainActor
final class AppTelemetryGateway: AppTelemetryGatewaying {
    private(set) var isSentryStarted = false
    private(set) var isTelemetryDeckStarted = false
    private let sentryObservabilitySender = SentryObservabilitySender()

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
        AppObservability.configureSentrySender(sentryObservabilitySender)
    }

    func stopSentry() {
        AppObservability.configureSentrySender(nil)
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

private final class SentryObservabilitySender: AppObservabilitySentrySending {
    nonisolated func sendLog(
        level: AppLogLevel,
        category: String,
        message: String,
        metadata: [String: String]
    ) {
        let breadcrumb = Breadcrumb(level: sentryLevel(for: level), category: category)
        breadcrumb.message = message
        breadcrumb.type = "log"
        breadcrumb.data = metadata
        SentrySDK.addBreadcrumb(breadcrumb)

        switch level {
        case .debug, .info:
            break
        case .warning, .error:
            SentrySDK.capture(message: message) { scope in
                scope.setLevel(self.sentryLevel(for: level))
                scope.setTag(value: category, key: "category")
                metadata.forEach { key, value in
                    scope.setExtra(value: value, key: key)
                }
            }
        }
    }

    nonisolated func startTrace(
        name: String,
        operation: String,
        metadata: [String: String]
    ) -> (any AppTraceSpan)? {
        let span = SentrySDK.startTransaction(name: name, operation: operation, bindToScope: false)
        metadata.forEach { key, value in
            span.setData(value: value, key: key)
        }
        return SentryTraceSpan(span: span)
    }

    nonisolated private func sentryLevel(for level: AppLogLevel) -> SentryLevel {
        switch level {
        case .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .warning
        case .error:
            return .error
        }
    }
}

private final class SentryTraceSpan: AppTraceSpan {
    nonisolated(unsafe) private let span: any Span

    nonisolated init(span: any Span) {
        self.span = span
    }

    nonisolated func finish(status: AppTraceStatus) {
        switch status {
        case .ok:
            span.finish(status: .ok)
        case .internalError:
            span.finish(status: .internalError)
        }
    }
}
