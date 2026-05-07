nonisolated protocol SymptomEntryStore: Sendable {
    func loadEntries() async throws -> [StoredSymptomEntry]
    func saveEntries(_ entries: [StoredSymptomEntry]) async throws
}
