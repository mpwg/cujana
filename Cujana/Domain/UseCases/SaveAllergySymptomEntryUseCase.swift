import Foundation

nonisolated public struct SaveAllergySymptomEntryUseCase: Sendable {
    private let repository: any SymptomEntryRepository

    public init(repository: any SymptomEntryRepository) {
        self.repository = repository
    }

    public func execute(_ entry: AllergySymptomEntry) async throws {
        try await repository.save(entry)
    }
}

nonisolated public struct DeleteAllergySymptomEntryUseCase: Sendable {
    private let repository: any SymptomEntryRepository

    public init(repository: any SymptomEntryRepository) {
        self.repository = repository
    }

    public func execute(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
