import Foundation

actor InMemorySymptomEntryRepository: SymptomEntryRepository {
    private var entries: [AllergySymptomEntry]

    init(entries: [AllergySymptomEntry] = []) {
        self.entries = entries
    }

    func save(_ entry: AllergySymptomEntry) async throws {
        if let existingIndex = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[existingIndex] = entry
        } else {
            entries.append(entry)
        }
    }

    func delete(id: UUID) async throws {
        entries.removeAll { $0.id == id }
    }

    func symptomEntries(from startDate: Date, to endDate: Date) async throws -> [AllergySymptomEntry] {
        entries.filter { entry in
            entry.date >= startDate && entry.date <= endDate
        }
    }
}
