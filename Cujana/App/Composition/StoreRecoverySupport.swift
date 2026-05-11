import Foundation

nonisolated enum PersistentStoreRecoveryReason: String, Equatable, Sendable {
    case unknownModelVersion
    case migrationFailure
    case loadFailure

    var headline: String {
        switch self {
        case .unknownModelVersion:
            "Der lokale Datenspeicher stammt aus einer neueren oder unbekannten App-Version."
        case .migrationFailure:
            "Der lokale Datenspeicher konnte nicht migriert werden."
        case .loadFailure:
            "Der lokale Datenspeicher konnte nicht geöffnet werden."
        }
    }

    var explanation: String {
        switch self {
        case .unknownModelVersion:
            """
            Cujana hat den vorhandenen Store nicht ersetzt. Du kannst die Dateien sichern und später mit einer \
            passenden App-Version erneut öffnen.
            """
        case .migrationFailure:
            """
            Cujana hat die Migration gestoppt und keine Store-Dateien gelöscht. Sichere die Dateien, bevor du \
            weitere Schritte setzt.
            """
        case .loadFailure:
            """
            Cujana startet in einem geschützten Wiederherstellungsmodus. Der vorhandene Store bleibt unverändert, \
            solange du keine Löschung bestätigst.
            """
        }
    }
}

nonisolated struct PersistentStoreRecoveryContext: Equatable, Sendable {
    let storeURL: URL
    let reason: PersistentStoreRecoveryReason
    let errorSummary: String
}

nonisolated enum PersistentStoreLoadError: Error, Equatable {
    case recoveryRequired(PersistentStoreRecoveryContext)
}

nonisolated enum PersistentStoreRecoveryFileError: LocalizedError, Equatable {
    case noStoreFilesFound

    var errorDescription: String? {
        switch self {
        case .noStoreFilesFound:
            "Es wurden keine Store-Dateien gefunden, die gesichert werden können."
        }
    }
}

nonisolated enum AppStartupPreparationError: LocalizedError, Equatable {
    case applicationSupportDirectoryUnavailable

    var errorDescription: String? {
        switch self {
        case .applicationSupportDirectoryUnavailable:
            "Das Application-Support-Verzeichnis konnte nicht gefunden werden."
        }
    }
}

nonisolated enum AppStartupFailureReason: Equatable, Sendable {
    case bootstrapFailure

    var headline: String {
        switch self {
        case .bootstrapFailure:
            "Cujana konnte nicht vollständig gestartet werden."
        }
    }

    var explanation: String {
        switch self {
        case .bootstrapFailure:
            """
            Cujana bleibt in einem geschützten Safe-Mode, damit Diagnoseinformationen sichtbar bleiben und \
            vorhandene Store-Dateien nicht verändert werden.
            """
        }
    }
}

nonisolated struct AppStartupFailureContext: Equatable, Sendable {
    let reason: AppStartupFailureReason
    let errorSummary: String
    let storeURL: URL?
    let recoveryContext: PersistentStoreRecoveryContext?
}

nonisolated enum PersistentStoreRecoveryService {
    static let unknownModelVersionErrorCode = 134504
    static let migrationErrorCodeRange = 134100...134199

    static func recoveryContext(for error: Error, storeURL: URL) -> PersistentStoreRecoveryContext {
        PersistentStoreRecoveryContext(
            storeURL: storeURL,
            reason: recoveryReason(for: error),
            errorSummary: sanitizedSummary(for: error)
        )
    }

    static func recoveryReason(for error: Error) -> PersistentStoreRecoveryReason {
        let nsError = error as NSError
        let description = [
            String(describing: error),
            nsError.localizedDescription
        ]
        .joined(separator: " ")
        .lowercased()

        if nsError.domain == NSCocoaErrorDomain, nsError.code == unknownModelVersionErrorCode {
            return .unknownModelVersion
        }

        if description.contains("unknown model version")
            || description.contains("loadissuemodelcontainer")
            || description.contains(String(unknownModelVersionErrorCode)) {
            return .unknownModelVersion
        }

        if nsError.domain == NSCocoaErrorDomain, migrationErrorCodeRange.contains(nsError.code) {
            return .migrationFailure
        }

        if description.contains("migration")
            || description.contains("migrate")
            || description.contains("incompatible version hash") {
            return .migrationFailure
        }

        return .loadFailure
    }

    static func sanitizedSummary(for error: Error) -> String {
        let nsError = error as NSError
        return "\(nsError.domain) \(nsError.code)"
    }

    static func existingStoreFileURLs(for storeURL: URL, fileManager: FileManager = .default) -> [URL] {
        storeFileCandidates(for: storeURL).filter { fileManager.fileExists(atPath: $0.path) }
    }

    static func copyStoreFilesForSharing(
        from storeURL: URL,
        fileManager: FileManager = .default,
        now: Date = .now
    ) throws -> [URL] {
        let sourceURLs = existingStoreFileURLs(for: storeURL, fileManager: fileManager)
        guard !sourceURLs.isEmpty else {
            throw PersistentStoreRecoveryFileError.noStoreFilesFound
        }

        let targetDirectory = fileManager.temporaryDirectory.appending(
            path: "Cujana-Store-Sicherung-\(fileDateString(from: now))-\(UUID().uuidString)",
            directoryHint: .isDirectory
        )
        try fileManager.createDirectory(at: targetDirectory, withIntermediateDirectories: true)

        return try sourceURLs.map { sourceURL in
            let targetURL = targetDirectory.appending(path: sourceURL.lastPathComponent)
            if fileManager.fileExists(atPath: targetURL.path) {
                try fileManager.removeItem(at: targetURL)
            }
            try fileManager.copyItem(at: sourceURL, to: targetURL)
            return targetURL
        }
    }

    static func removeStoreFilesAfterUserConfirmation(
        at storeURL: URL,
        fileManager: FileManager = .default
    ) throws {
        for url in existingStoreFileURLs(for: storeURL, fileManager: fileManager) {
            try fileManager.removeItem(at: url)
        }
    }

    static func storeFileCandidates(for storeURL: URL) -> [URL] {
        let directoryURL = storeURL.deletingLastPathComponent()
        let storeFileName = storeURL.lastPathComponent

        return [
            storeURL,
            directoryURL.appending(path: "\(storeFileName)-shm"),
            directoryURL.appending(path: "\(storeFileName)-wal"),
            directoryURL.appending(path: "\(storeFileName)_SUPPORT", directoryHint: .isDirectory)
        ]
    }

    private static func fileDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter.string(from: date)
    }
}
