import Foundation
import Testing
@testable import Cujana

struct LocalSymptomEntryRepositoryTests {

    @Test func savePersistsEntryThroughStore() async throws {
        let store = FakeSymptomEntryStore()
        let repository = LocalSymptomEntryRepository(store: store)
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let entryID = try #require(UUID(uuidString: "11111111-1111-1111-1111-111111111111"))
        let entry = try AllergySymptomEntry(
            id: entryID,
            date: Date(timeIntervalSince1970: 1_000),
            symptoms: [.itchyEyes],
            severity: .moderate,
            note: "Draußen stärker gespürt.",
            coordinate: coordinate
        )

        try await repository.save(entry)

        let storedEntries = await store.entries()
        #expect(storedEntries == [
            StoredSymptomEntry(
                id: entry.id,
                date: entry.date,
                symptomTypeRawValues: [SymptomType.itchyEyes.rawValue],
                severityRawValue: SymptomSeverity.moderate.rawValue,
                note: "Draußen stärker gespürt.",
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
        ])
    }

    @Test func loadReturnsEmptyArrayWhenStoreIsEmpty() async throws {
        let repository = LocalSymptomEntryRepository(store: FakeSymptomEntryStore())

        let entries = try await repository.symptomEntries(
            from: Date(timeIntervalSince1970: 0),
            to: Date(timeIntervalSince1970: 2_000)
        )

        #expect(entries.isEmpty)
    }

    @Test func loadMapsStoredEntriesToDomainAndFiltersDateRange() async throws {
        let inRangeEntryID = try #require(UUID(uuidString: "22222222-2222-2222-2222-222222222222"))
        let laterEntryID = try #require(UUID(uuidString: "33333333-3333-3333-3333-333333333333"))
        let inRangeEntry = try AllergySymptomEntry(
            id: inRangeEntryID,
            date: Date(timeIntervalSince1970: 1_000),
            symptoms: [.runnyNose],
            severity: .mild
        )
        let laterEntry = try AllergySymptomEntry(
            id: laterEntryID,
            date: Date(timeIntervalSince1970: 2_000),
            symptoms: [.sneezing],
            severity: .severe
        )
        let store = FakeSymptomEntryStore(
            entries: [
                StoredSymptomEntry(entry: laterEntry),
                StoredSymptomEntry(entry: inRangeEntry)
            ]
        )
        let repository = LocalSymptomEntryRepository(store: store)

        let entries = try await repository.symptomEntries(
            from: Date(timeIntervalSince1970: 500),
            to: Date(timeIntervalSince1970: 1_500)
        )

        #expect(entries == [inRangeEntry])
    }

    @Test func saveAndLoadPreservesMultipleSymptomsInOneCheckIn() async throws {
        let store = FakeSymptomEntryStore()
        let repository = LocalSymptomEntryRepository(store: store)
        let entry = try AllergySymptomEntry(
            date: Date(timeIntervalSince1970: 1_000),
            symptoms: [.blockedNose, .coughing, .headache],
            severity: .severe,
            note: "Morgens gebündelt erfasst."
        )

        try await repository.save(entry)
        let entries = try await repository.symptomEntries(
            from: Date(timeIntervalSince1970: 0),
            to: Date(timeIntervalSince1970: 2_000)
        )

        #expect(entries == [entry])
        #expect((await store.entries()).first?.symptomTypeRawValues == [
            SymptomType.blockedNose.rawValue,
            SymptomType.coughing.rawValue,
            SymptomType.headache.rawValue
        ])
    }

    @Test func loadMapsStoreFailuresToSymptomEntryError() async {
        let repository = LocalSymptomEntryRepository(
            store: FakeSymptomEntryStore(loadError: SymptomEntryError.storageUnavailable)
        )

        await #expect(throws: SymptomEntryError.storageUnavailable) {
            _ = try await repository.symptomEntries(
                from: Date(timeIntervalSince1970: 0),
                to: Date(timeIntervalSince1970: 1_000)
            )
        }
    }

    @Test func saveMapsStoreFailuresToSymptomEntryError() async throws {
        let repository = LocalSymptomEntryRepository(
            store: FakeSymptomEntryStore(saveError: SymptomEntryError.storageUnavailable)
        )
        let entry = try AllergySymptomEntry(
            date: Date(timeIntervalSince1970: 0),
            symptoms: [.fatigue],
            severity: .moderate
        )

        await #expect(throws: SymptomEntryError.storageUnavailable) {
            try await repository.save(entry)
        }
    }

    @Test func inMemoryRepositoryFiltersEntriesByInclusiveDateRange() async throws {
        let earlyEntry = try AllergySymptomEntry(
            date: Date(timeIntervalSince1970: 500),
            symptoms: [.itchyEyes],
            severity: .mild
        )
        let startEntry = try AllergySymptomEntry(
            date: Date(timeIntervalSince1970: 1_000),
            symptoms: [.runnyNose],
            severity: .moderate
        )
        let endEntry = try AllergySymptomEntry(
            date: Date(timeIntervalSince1970: 2_000),
            symptoms: [.sneezing],
            severity: .severe
        )
        let repository = InMemorySymptomEntryRepository(
            entries: [earlyEntry, startEntry, endEntry]
        )

        let entries = try await repository.symptomEntries(
            from: Date(timeIntervalSince1970: 1_000),
            to: Date(timeIntervalSince1970: 2_000)
        )

        #expect(entries == [startEntry, endEntry])
    }
}

private actor FakeSymptomEntryStore: SymptomEntryStore {
    private var storedEntries: [StoredSymptomEntry]
    private let loadError: Error?
    private let saveError: Error?

    init(
        entries: [StoredSymptomEntry] = [],
        loadError: Error? = nil,
        saveError: Error? = nil
    ) {
        storedEntries = entries
        self.loadError = loadError
        self.saveError = saveError
    }

    func loadEntries() async throws -> [StoredSymptomEntry] {
        if let loadError {
            throw loadError
        }

        return storedEntries
    }

    func saveEntries(_ entries: [StoredSymptomEntry]) async throws {
        if let saveError {
            throw saveError
        }

        storedEntries = entries
    }

    func entries() -> [StoredSymptomEntry] {
        storedEntries
    }
}
