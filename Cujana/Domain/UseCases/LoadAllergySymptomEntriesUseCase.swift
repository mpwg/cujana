import Foundation

nonisolated public struct LoadAllergySymptomEntriesUseCase: Sendable {
    private let repository: any SymptomEntryRepository

    public init(repository: any SymptomEntryRepository) {
        self.repository = repository
    }

    public func execute(from startDate: Date, to endDate: Date) async throws -> [AllergySymptomEntry] {
        try await repository.symptomEntries(from: startDate, to: endDate)
    }
}
