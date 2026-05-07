import Foundation

actor LocalSymptomEntryRepository: SymptomEntryRepository {
    private let store: any SymptomEntryStore

    init(store: any SymptomEntryStore) {
        self.store = store
    }

    func save(_ entry: AllergySymptomEntry) async throws {
        do {
            var entries = try await store.loadEntries()
            entries.append(StoredSymptomEntry(entry: entry))
            try await store.saveEntries(entries)
        } catch {
            throw SymptomEntryError.storageUnavailable
        }
    }

    func symptomEntries(from startDate: Date, to endDate: Date) async throws -> [AllergySymptomEntry] {
        do {
            let entries = try await store.loadEntries()

            return try entries
                .map { try $0.domainEntry() }
                .filter { entry in
                    entry.date >= startDate && entry.date <= endDate
                }
                .sorted { lhs, rhs in
                    lhs.date < rhs.date
                }
        } catch {
            throw SymptomEntryError.storageUnavailable
        }
    }
}
