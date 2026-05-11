import Foundation

public actor InMemoryEnvironmentalDataRepository: EnvironmentalDataRepository {
    private var snapshot: EnvironmentalDataSnapshot?

    public init(snapshot: EnvironmentalDataSnapshot? = nil) {
        self.snapshot = snapshot
    }

    public func latestSnapshot() async throws -> EnvironmentalDataSnapshot? {
        snapshot
    }

    public func save(_ snapshot: EnvironmentalDataSnapshot) async throws {
        self.snapshot = snapshot
    }
}
