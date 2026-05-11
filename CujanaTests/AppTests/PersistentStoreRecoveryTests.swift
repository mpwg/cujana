import Foundation
import Testing
@testable import Cujana

@MainActor
struct PersistentStoreRecoveryTests {
    @Test
    func unknownModelVersionIsClassifiedForRecovery() {
        let error = NSError(
            domain: NSCocoaErrorDomain,
            code: PersistentStoreRecoveryService.unknownModelVersionErrorCode
        )

        let reason = PersistentStoreRecoveryService.recoveryReason(for: error)

        #expect(reason == .unknownModelVersion)
    }

    @Test
    func injectedContainerFailureDoesNotDeleteStoreFiles() throws {
        let directory = try makeTemporaryDirectory()
        let storeURL = directory.appending(path: "default.store")
        let walURL = directory.appending(path: "default.store-wal")
        let storeData = Data("store-sentinel".utf8)
        let walData = Data("wal-sentinel".utf8)
        try storeData.write(to: storeURL)
        try walData.write(to: walURL)
        let error = NSError(
            domain: NSCocoaErrorDomain,
            code: PersistentStoreRecoveryService.unknownModelVersionErrorCode
        )

        do {
            _ = try CujanaPersistence.makeProductionModelContainer(applicationSupportDirectoryURL: directory) { _, _ in
                throw error
            }
            Issue.record("Ein Container-Fehler muss in den Recovery-Zustand laufen.")
        } catch PersistentStoreLoadError.recoveryRequired(let context) {
            #expect(context.reason == .unknownModelVersion)
            #expect(context.storeURL == storeURL)
        } catch {
            Issue.record("Unerwarteter Fehler: \(error)")
        }

        #expect(try Data(contentsOf: storeURL) == storeData)
        #expect(try Data(contentsOf: walURL) == walData)
    }

    @Test
    func migrationErrorsAreClassifiedForRecovery() {
        let error = NSError(
            domain: NSCocoaErrorDomain,
            code: PersistentStoreRecoveryService.migrationErrorCodeRange.lowerBound + 10
        )

        let reason = PersistentStoreRecoveryService.recoveryReason(for: error)

        #expect(reason == .migrationFailure)
    }

    @Test
    func backupPreparationCopiesStoreFilesWithoutChangingOriginals() throws {
        let directory = try makeTemporaryDirectory()
        let storeURL = directory.appending(path: "default.store")
        let walURL = directory.appending(path: "default.store-wal")
        let storeData = Data("store-sentinel".utf8)
        let walData = Data("wal-sentinel".utf8)
        try storeData.write(to: storeURL)
        try walData.write(to: walURL)

        let backupURLs = try PersistentStoreRecoveryService.copyStoreFilesForSharing(
            from: storeURL,
            now: Date(timeIntervalSince1970: 1_000)
        )

        #expect(backupURLs.count == 2)
        #expect(try Data(contentsOf: storeURL) == storeData)
        #expect(try Data(contentsOf: walURL) == walData)
        #expect(backupURLs.allSatisfy { FileManager.default.fileExists(atPath: $0.path) })
    }

    @Test
    func removeStoreFilesOnlyRemovesSwiftDataCandidates() throws {
        let directory = try makeTemporaryDirectory()
        let storeURL = directory.appending(path: "default.store")
        let walURL = directory.appending(path: "default.store-wal")
        let unrelatedURL = directory.appending(path: "keep.txt")
        try Data("store".utf8).write(to: storeURL)
        try Data("wal".utf8).write(to: walURL)
        try Data("keep".utf8).write(to: unrelatedURL)

        try PersistentStoreRecoveryService.removeStoreFilesAfterUserConfirmation(at: storeURL)

        #expect(!FileManager.default.fileExists(atPath: storeURL.path))
        #expect(!FileManager.default.fileExists(atPath: walURL.path))
        #expect(FileManager.default.fileExists(atPath: unrelatedURL.path))
    }
}

private func makeTemporaryDirectory() throws -> URL {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
}
