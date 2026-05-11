import Foundation

nonisolated struct LocalEnvironmentalDataRepository: EnvironmentalDataRepository {
    private let store: any EnvironmentalDataSnapshotStore

    init(store: any EnvironmentalDataSnapshotStore) {
        self.store = store
    }

    func latestSnapshot() async throws -> EnvironmentalDataSnapshot? {
        try await store.loadLatestSnapshot()
    }

    func save(_ snapshot: EnvironmentalDataSnapshot) async throws {
        try await store.save(snapshot)
    }
}
