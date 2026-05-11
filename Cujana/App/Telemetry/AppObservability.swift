import Foundation
import OSLog

enum AppLogLevel: String, Sendable {
    case debug
    case info
    case warning
    case error
}

enum AppObservability {
    nonisolated static func log(
        _ level: AppLogLevel,
        _ message: String,
        category: String,
        metadata: [String: String] = [:]
    ) {
        writeDebugOutput(level, message, category: category, metadata: metadata)
    }

    nonisolated static func trace<T>(
        name: String,
        operation: String,
        category: String,
        metadata: [String: String] = [:],
        _ body: () throws -> T
    ) rethrows -> T {
        startTrace(name: name, operation: operation, category: category, metadata: metadata)
        do {
            let value = try body()
            log(.debug, "Trace abgeschlossen: \(name)", category: category, metadata: metadata)
            return value
        } catch {
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
        startTrace(name: name, operation: operation, category: category, metadata: metadata)
        do {
            let value = try await body()
            log(.debug, "Trace abgeschlossen: \(name)", category: category, metadata: metadata)
            return value
        } catch {
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
    ) {
        log(.debug, "Trace gestartet: \(name)", category: category, metadata: metadata)
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
