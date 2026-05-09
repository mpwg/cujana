import Foundation
import OSLog

enum AppLogLevel: String, Sendable {
    case debug
    case info
    case warning
    case error
}

protocol AppTraceSpan: AnyObject, Sendable {
    nonisolated func finish(status: AppTraceStatus)
}

enum AppTraceStatus: Sendable {
    case ok
    case internalError
}

protocol AppObservabilitySentrySending: AnyObject, Sendable {
    nonisolated func sendLog(
        level: AppLogLevel,
        category: String,
        message: String,
        metadata: [String: String]
    )

    nonisolated func startTrace(
        name: String,
        operation: String,
        metadata: [String: String]
    ) -> (any AppTraceSpan)?
}

enum AppObservability {
    nonisolated(unsafe) private static var lock = NSRecursiveLock()
    nonisolated(unsafe) private static var sentrySender: (any AppObservabilitySentrySending)?

    nonisolated static func configureSentrySender(_ sender: (any AppObservabilitySentrySending)?) {
        lock.withLock {
            sentrySender = sender
        }
    }

    nonisolated static func log(
        _ level: AppLogLevel,
        _ message: String,
        category: String,
        metadata: [String: String] = [:]
    ) {
        writeDebugOutput(level, message, category: category, metadata: metadata)

        lock.withLock {
            sentrySender?.sendLog(
                level: level,
                category: category,
                message: message,
                metadata: metadata
            )
        }
    }

    nonisolated static func trace<T>(
        name: String,
        operation: String,
        category: String,
        metadata: [String: String] = [:],
        _ body: () throws -> T
    ) rethrows -> T {
        let span = startTrace(name: name, operation: operation, category: category, metadata: metadata)
        do {
            let value = try body()
            span?.finish(status: .ok)
            log(.debug, "Trace abgeschlossen: \(name)", category: category, metadata: metadata)
            return value
        } catch {
            span?.finish(status: .internalError)
            log(
                .error,
                "Trace fehlgeschlagen: \(name)",
                category: category,
                metadata: metadata.merging(["error": String(describing: error)]) { _, new in new }
            )
            throw error
        }
    }

    nonisolated static func trace<T>(
        name: String,
        operation: String,
        category: String,
        metadata: [String: String] = [:],
        _ body: () async throws -> T
    ) async rethrows -> T {
        let span = startTrace(name: name, operation: operation, category: category, metadata: metadata)
        do {
            let value = try await body()
            span?.finish(status: .ok)
            log(.debug, "Trace abgeschlossen: \(name)", category: category, metadata: metadata)
            return value
        } catch {
            span?.finish(status: .internalError)
            log(
                .error,
                "Trace fehlgeschlagen: \(name)",
                category: category,
                metadata: metadata.merging(["error": String(describing: error)]) { _, new in new }
            )
            throw error
        }
    }

    nonisolated private static func startTrace(
        name: String,
        operation: String,
        category: String,
        metadata: [String: String]
    ) -> (any AppTraceSpan)? {
        log(.debug, "Trace gestartet: \(name)", category: category, metadata: metadata)
        return lock.withLock {
            sentrySender?.startTrace(name: name, operation: operation, metadata: metadata)
        }
    }

    nonisolated private static func writeDebugOutput(
        _ level: AppLogLevel,
        _ message: String,
        category: String,
        metadata: [String: String]
    ) {
        let logger = Logger(subsystem: "Cujana", category: category)
        let metadataText = metadata.isEmpty
            ? ""
            : " \(metadata.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }.joined(separator: " "))"

        switch level {
        case .debug:
            logger.debug("\(message, privacy: .public)\(metadataText, privacy: .public)")
        case .info:
            logger.info("\(message, privacy: .public)\(metadataText, privacy: .public)")
        case .warning:
            logger.warning("\(message, privacy: .public)\(metadataText, privacy: .public)")
        case .error:
            logger.error("\(message, privacy: .public)\(metadataText, privacy: .public)")
        }
    }
}

private extension NSRecursiveLock {
    nonisolated func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
