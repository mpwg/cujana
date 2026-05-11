import Foundation

nonisolated protocol EnvironmentalDataSnapshotStore: Sendable {
    func loadLatestSnapshot() async throws -> EnvironmentalDataSnapshot?
    func save(_ snapshot: EnvironmentalDataSnapshot) async throws
}
