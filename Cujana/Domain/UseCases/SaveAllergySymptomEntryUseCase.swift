nonisolated public struct SaveAllergySymptomEntryUseCase: Sendable {
    private let repository: any SymptomEntryRepository

    public init(repository: any SymptomEntryRepository) {
        self.repository = repository
    }

    public func execute(_ entry: AllergySymptomEntry) async throws {
        try await repository.save(entry)
    }
}
