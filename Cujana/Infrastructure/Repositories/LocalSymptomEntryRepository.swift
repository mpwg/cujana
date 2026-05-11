import Foundation

actor LocalSymptomEntryRepository: SymptomEntryRepository {
    private let store: any SymptomEntryStore

    init(store: any SymptomEntryStore) {
        self.store = store
    }

    func save(_ entry: AllergySymptomEntry) async throws {
        do {
            var entries = try await store.loadEntries()
            let storedEntry = StoredSymptomEntry(entry: entry)

            if let existingIndex = entries.firstIndex(where: { $0.id == entry.id }) {
                entries[existingIndex] = storedEntry
            } else {
                entries.append(storedEntry)
            }

            try await store.saveEntries(entries)
        } catch {
            throw SymptomEntryError.storageUnavailable
        }
    }

    func delete(id: UUID) async throws {
        do {
            var entries = try await store.loadEntries()
            entries.removeAll { $0.id == id }
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
