import Foundation

nonisolated public protocol EnvironmentalDataRepository: Sendable {
    func latestSnapshot() async throws -> EnvironmentalDataSnapshot?
    func save(_ snapshot: EnvironmentalDataSnapshot) async throws
}
