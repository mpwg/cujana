import Foundation

nonisolated struct FileSymptomEntryStore: SymptomEntryStore {
    private let fileURL: URL

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    static func applicationSupportStore() throws -> FileSymptomEntryStore {
        let directoryURL = try applicationSupportDirectory()
        return FileSymptomEntryStore(fileURL: directoryURL.appending(path: "symptom-entries.json"))
    }

    func loadEntries() async throws -> [StoredSymptomEntry] {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        guard !data.isEmpty else {
            return []
        }

        let decoder = JSONDecoder()
        return try decoder.decode([StoredSymptomEntry].self, from: data)
    }

    func saveEntries(_ entries: [StoredSymptomEntry]) async throws {
        let fileManager = FileManager.default
        let directoryURL = fileURL.deletingLastPathComponent()
        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(entries)
        try data.write(to: fileURL, options: [.atomic])
    }

    private static func applicationSupportDirectory() throws -> URL {
        let baseURL = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "eu.mpwg.Cujana"
        return baseURL.appending(path: bundleIdentifier, directoryHint: .isDirectory)
    }
}
