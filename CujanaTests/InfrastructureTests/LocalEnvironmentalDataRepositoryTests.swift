import Foundation
import SwiftData
import Testing
@testable import Cujana

@MainActor
struct LocalEnvironmentalDataRepositoryTests {

    @Test func saveAndLoadLatestPollenEntryThroughFlatSwiftDataRecord() async throws {
        let modelContainer = try CujanaPersistence.makeInMemoryModelContainer()
        let repository = LocalEnvironmentalDataRepository(modelContainer: modelContainer)
        let entry = try pollenEntry(collectedAt: Date(timeIntervalSince1970: 1_000))

        try await repository.savePollenEntries([entry])

        let loadedEntry = try await repository.latestPollenEntry(for: entry.coordinate)
        #expect(loadedEntry == entry)
    }

    @Test func saveAndLoadLatestWeatherEntryThroughFlatSwiftDataRecord() async throws {
        let modelContainer = try CujanaPersistence.makeInMemoryModelContainer()
        let repository = LocalEnvironmentalDataRepository(modelContainer: modelContainer)
        let entry = try weatherEntry(
            collectedAt: Date(timeIntervalSince1970: 1_000),
            entryDate: Date(timeIntervalSince1970: 2_000),
            temperature: 22
        )

        try await repository.saveWeatherEntries([entry])

        let loadedEntry = try await repository.latestWeatherEntry(for: entry.coordinate)
        #expect(loadedEntry == entry)
    }

    @Test func savePollenEntriesOnlyReplacesRowsForTheSameEntryDateAndKind() async throws {
        let modelContainer = try CujanaPersistence.makeInMemoryModelContainer()
        let repository = LocalEnvironmentalDataRepository(modelContainer: modelContainer)
        let entryDate = Date(timeIntervalSince1970: 2_000)
        var firstEntry = try pollenEntry(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111") ?? UUID(),
            collectedAt: Date(timeIntervalSince1970: 1_000),
            entryDate: entryDate
        )
        firstEntry.grassLevel = .low
        var replacementEntry = try pollenEntry(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222") ?? UUID(),
            collectedAt: Date(timeIntervalSince1970: 3_000),
            entryDate: entryDate
        )
        replacementEntry.grassLevel = .high
        let independentEntry = try pollenEntry(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333") ?? UUID(),
            collectedAt: Date(timeIntervalSince1970: 1_000),
            entryDate: Date(timeIntervalSince1970: 4_000)
        )

        try await repository.savePollenEntries([firstEntry, independentEntry])
        try await repository.savePollenEntries([replacementEntry])

        let records = try fetchPollenRecords(from: modelContainer)
        let storedIDs = records.map(\.id).sorted { $0.uuidString < $1.uuidString }
        let expectedIDs = [independentEntry.id, replacementEntry.id].sorted { $0.uuidString < $1.uuidString }
        #expect(storedIDs == expectedIDs)
    }

    @Test func saveWeatherEntriesDoesNotDeletePollenRows() async throws {
        let modelContainer = try CujanaPersistence.makeInMemoryModelContainer()
        let repository = LocalEnvironmentalDataRepository(modelContainer: modelContainer)
        let pollen = try pollenEntry(collectedAt: Date(timeIntervalSince1970: 1_000))
        let weather = try weatherEntry(
            collectedAt: Date(timeIntervalSince1970: 2_000),
            entryDate: Date(timeIntervalSince1970: 2_000),
            temperature: 20
        )

        try await repository.savePollenEntries([pollen])
        try await repository.saveWeatherEntries([weather])

        #expect(try fetchPollenRecords(from: modelContainer).count == 1)
        #expect(try fetchWeatherRecords(from: modelContainer).count == 1)
    }

    private func pollenEntry(
        id: UUID = UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA") ?? UUID(),
        collectedAt: Date,
        entryDate: Date = Date(timeIntervalSince1970: 2_000)
    ) throws -> PollenDataEntry {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        var entry = PollenDataEntry(
            id: id,
            collectedAt: collectedAt,
            entryDate: entryDate,
            coordinate: coordinate,
            sourceKind: .forecast,
            generatedAt: collectedAt,
            validFrom: entryDate,
            validUntil: entryDate.addingTimeInterval(86_400),
            rowKind: .dailyLevel
        )
        entry.grassLevel = .high
        entry.birchLevel = .moderate
        entry.allergyRiskHour0 = .low
        return entry
    }

    private func weatherEntry(
        collectedAt: Date,
        entryDate: Date,
        temperature: Double
    ) throws -> WeatherDataEntry {
        try WeatherDataEntry(
            id: UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB") ?? UUID(),
            collectedAt: collectedAt,
            entryDate: entryDate,
            coordinate: LocationCoordinate(latitude: 48.2082, longitude: 16.3738),
            generatedAt: collectedAt,
            rowKind: .hourly,
            temperature: temperature,
            conditionCode: 2,
            humidityPercent: 58,
            windSpeedKilometersPerHour: 8
        )
    }

    private func fetchPollenRecords(from modelContainer: ModelContainer) throws -> [CujanaSchemaV1.PollenEntryRecord] {
        let context = ModelContext(modelContainer)
        return try context.fetch(FetchDescriptor<CujanaSchemaV1.PollenEntryRecord>())
    }

    private func fetchWeatherRecords(
        from modelContainer: ModelContainer
    ) throws -> [CujanaSchemaV1.WeatherEntryRecord] {
        let context = ModelContext(modelContainer)
        return try context.fetch(FetchDescriptor<CujanaSchemaV1.WeatherEntryRecord>())
    }
}
