import Foundation
import SwiftData
import Testing
@testable import Cujana

@MainActor
struct LocalSymptomEntryRepositoryTests {

    @Test func savePersistsEntryThroughSwiftData() async throws {
        let modelContainer = try CujanaPersistence.makeInMemoryModelContainer()
        let repository = LocalSymptomEntryRepository(modelContainer: modelContainer)
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let entryID = try #require(UUID(uuidString: "11111111-1111-1111-1111-111111111111"))
        let entry = try AllergySymptomEntry(
            id: entryID,
            date: Date(timeIntervalSince1970: 1_000),
            symptoms: [.itchyEyes],
            severity: .moderate,
            note: "Draußen stärker gespürt.",
            medications: [Medication(name: "Cetirizin")],
            tags: ["Park"],
            coordinate: coordinate
        )

        try await repository.save(entry)

        let records = try fetchSymptomEntryRecords(from: modelContainer)
        #expect(records.count == 1)
        #expect(records.first?.id == entry.id)
        #expect(records.first?.date == entry.date)
        #expect(records.first?.symptomTypeRawValues == [SymptomType.itchyEyes.rawValue])
        #expect(records.first?.severityRawValue == SymptomSeverity.moderate.rawValue)
        #expect(records.first?.note == "Draußen stärker gespürt.")
        #expect(records.first?.medicationNames == ["Cetirizin"])
        #expect(records.first?.tags == ["Park"])
        #expect(records.first?.latitude == coordinate.latitude)
        #expect(records.first?.longitude == coordinate.longitude)
    }

    @Test func loadReturnsEmptyArrayWhenStoreIsEmpty() async throws {
        let repository = LocalSymptomEntryRepository(modelContainer: try CujanaPersistence.makeInMemoryModelContainer())

        let entries = try await repository.symptomEntries(
            from: Date(timeIntervalSince1970: 0),
            to: Date(timeIntervalSince1970: 2_000)
        )

        #expect(entries.isEmpty)
    }

    @Test func loadMapsStoredEntriesToDomainAndFiltersDateRange() async throws {
        let modelContainer = try CujanaPersistence.makeInMemoryModelContainer()
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
        try insertSymptomEntries([laterEntry, inRangeEntry], into: modelContainer)
        let repository = LocalSymptomEntryRepository(modelContainer: modelContainer)

        let entries = try await repository.symptomEntries(
            from: Date(timeIntervalSince1970: 500),
            to: Date(timeIntervalSince1970: 1_500)
        )

        #expect(entries == [inRangeEntry])
    }

    @Test func saveAndLoadPreservesMultipleSymptomsInOneCheckIn() async throws {
        let modelContainer = try CujanaPersistence.makeInMemoryModelContainer()
        let repository = LocalSymptomEntryRepository(modelContainer: modelContainer)
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
        #expect(try fetchSymptomEntryRecords(from: modelContainer).first?.symptomTypeRawValues == [
            SymptomType.blockedNose.rawValue,
            SymptomType.coughing.rawValue,
            SymptomType.headache.rawValue
        ])
    }

    @Test func saveReplacesExistingEntryWithSameID() async throws {
        let modelContainer = try CujanaPersistence.makeInMemoryModelContainer()
        let entryID = try #require(UUID(uuidString: "44444444-4444-4444-4444-444444444444"))
        let original = try AllergySymptomEntry(
            id: entryID,
            date: Date(timeIntervalSince1970: 1_000),
            symptoms: [.itchyEyes],
            severity: .mild,
            note: "Vorher"
        )
        let edited = try AllergySymptomEntry(
            id: entryID,
            date: Date(timeIntervalSince1970: 1_500),
            symptoms: [.itchyEyes, .coughing],
            severity: .severe,
            note: "Nachher"
        )
        try insertSymptomEntries([original], into: modelContainer)
        let repository = LocalSymptomEntryRepository(modelContainer: modelContainer)

        try await repository.save(edited)

        let entries = try await repository.symptomEntries(
            from: Date(timeIntervalSince1970: 0),
            to: Date(timeIntervalSince1970: 2_000)
        )
        #expect(entries == [edited])
        #expect(try fetchSymptomEntryRecords(from: modelContainer).count == 1)
    }

    @Test func deleteRemovesOnlyMatchingEntry() async throws {
        let modelContainer = try CujanaPersistence.makeInMemoryModelContainer()
        let deletedEntry = try AllergySymptomEntry(
            id: #require(UUID(uuidString: "55555555-5555-5555-5555-555555555555")),
            date: Date(timeIntervalSince1970: 1_000),
            symptoms: [.itchyEyes],
            severity: .mild
        )
        let remainingEntry = try AllergySymptomEntry(
            id: #require(UUID(uuidString: "66666666-6666-6666-6666-666666666666")),
            date: Date(timeIntervalSince1970: 1_200),
            symptoms: [.sneezing],
            severity: .moderate
        )
        try insertSymptomEntries([deletedEntry, remainingEntry], into: modelContainer)
        let repository = LocalSymptomEntryRepository(modelContainer: modelContainer)

        try await repository.delete(id: deletedEntry.id)

        let entries = try await repository.symptomEntries(
            from: Date(timeIntervalSince1970: 0),
            to: Date(timeIntervalSince1970: 2_000)
        )
        #expect(entries == [remainingEntry])
    }

    @Test func loadMapsInvalidStoredValuesToSymptomEntryError() async throws {
        let modelContainer = try CujanaPersistence.makeInMemoryModelContainer()
        let context = ModelContext(modelContainer)
        let entry = try AllergySymptomEntry(
            date: Date(timeIntervalSince1970: 0),
            symptoms: [.fatigue],
            severity: .moderate
        )
        let record = CujanaSchemaV1.SymptomEntryRecord(entry: entry)
        record.symptomTypeRawValues = ["unknown-symptom"]
        context.insert(record)
        try context.save()

        let repository = LocalSymptomEntryRepository(modelContainer: modelContainer)

        await #expect(throws: SymptomEntryError.storageUnavailable) {
            _ = try await repository.symptomEntries(
                from: Date(timeIntervalSince1970: 0),
                to: Date(timeIntervalSince1970: 1_000)
            )
        }
    }

    @Test func testRepositoryFiltersEntriesByInclusiveDateRange() async throws {
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
        let repository = TestSymptomEntryRepository(
            entries: [earlyEntry, startEntry, endEntry]
        )

        let entries = try await repository.symptomEntries(
            from: Date(timeIntervalSince1970: 1_000),
            to: Date(timeIntervalSince1970: 2_000)
        )

        #expect(entries == [startEntry, endEntry])
    }

    private func insertSymptomEntries(
        _ entries: [AllergySymptomEntry],
        into modelContainer: ModelContainer
    ) throws {
        let context = ModelContext(modelContainer)
        for entry in entries {
            context.insert(CujanaSchemaV1.SymptomEntryRecord(entry: entry))
        }
        try context.save()
    }

    private func fetchSymptomEntryRecords(
        from modelContainer: ModelContainer
    ) throws -> [CujanaSchemaV1.SymptomEntryRecord] {
        let context = ModelContext(modelContainer)
        return try context.fetch(FetchDescriptor<CujanaSchemaV1.SymptomEntryRecord>())
    }
}

private actor TestSymptomEntryRepository: SymptomEntryRepository {
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
