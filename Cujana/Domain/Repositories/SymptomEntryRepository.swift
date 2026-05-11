import Foundation

nonisolated public protocol SymptomEntryRepository: Sendable {
    func save(_ entry: AllergySymptomEntry) async throws
    func delete(id: UUID) async throws
    func symptomEntries(from startDate: Date, to endDate: Date) async throws -> [AllergySymptomEntry]
}

extension SymptomEntryRepository {
    func delete(id: UUID) async throws {
        throw SymptomEntryError.storageUnavailable
    }
}
