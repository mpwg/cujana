import Foundation

nonisolated public protocol SymptomEntryRepository: Sendable {
    func save(_ entry: AllergySymptomEntry) async throws
    func symptomEntries(from startDate: Date, to endDate: Date) async throws -> [AllergySymptomEntry]
}
