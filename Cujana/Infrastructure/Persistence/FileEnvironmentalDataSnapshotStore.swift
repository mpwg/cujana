import Foundation

nonisolated struct FileEnvironmentalDataSnapshotStore: EnvironmentalDataSnapshotStore {
    let fileURL: URL

    static func applicationSupportStore() throws -> FileEnvironmentalDataSnapshotStore {
        let directoryURL = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return FileEnvironmentalDataSnapshotStore(fileURL: directoryURL.appending(path: "environmental-data.json"))
    }

    func loadLatestSnapshot() async throws -> EnvironmentalDataSnapshot? {
        guard FileManager.default.fileExists(atPath: fileURL.path()) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(EnvironmentalDataSnapshot.self, from: data)
    }

    func save(_ snapshot: EnvironmentalDataSnapshot) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(snapshot)
        try data.write(to: fileURL, options: [.atomic])
    }
}
