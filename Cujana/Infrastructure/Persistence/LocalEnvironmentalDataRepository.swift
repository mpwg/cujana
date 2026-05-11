import Foundation
import SwiftData

actor LocalEnvironmentalDataRepository: EnvironmentalDataRepository {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func latestPollenEntry(for coordinate: LocationCoordinate) async throws -> PollenDataEntry? {
        let context = ModelContext(modelContainer)
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        var descriptor = FetchDescriptor<CujanaSchemaV1.PollenEntryRecord>(
            predicate: #Predicate { record in
                record.coordinateLatitude == latitude
                    && record.coordinateLongitude == longitude
            },
            sortBy: [SortDescriptor(\.collectedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1

        return try context.fetch(descriptor).first?.domainEntry()
    }

    func latestWeatherEntry(for coordinate: LocationCoordinate) async throws -> WeatherDataEntry? {
        let context = ModelContext(modelContainer)
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        var descriptor = FetchDescriptor<CujanaSchemaV1.WeatherEntryRecord>(
            predicate: #Predicate { record in
                record.coordinateLatitude == latitude
                    && record.coordinateLongitude == longitude
            },
            sortBy: [SortDescriptor(\.collectedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1

        return try context.fetch(descriptor).first?.domainEntry()
    }

    func savePollenEntries(_ entries: [PollenDataEntry]) async throws {
        let context = ModelContext(modelContainer)
        for entry in entries {
            let latitude = entry.coordinate.latitude
            let longitude = entry.coordinate.longitude
            let entryDate = entry.entryDate
            let rowKindRawValue = entry.rowKind.rawValue
            let existingRecords = try context.fetch(
                FetchDescriptor<CujanaSchemaV1.PollenEntryRecord>(
                    predicate: #Predicate { record in
                        record.coordinateLatitude == latitude
                            && record.coordinateLongitude == longitude
                            && record.entryDate == entryDate
                            && record.rowKindRawValue == rowKindRawValue
                    }
                )
            )
            existingRecords.forEach(context.delete)
            context.insert(CujanaSchemaV1.PollenEntryRecord(entry: entry))
        }
        try context.save()
    }

    func saveWeatherEntries(_ entries: [WeatherDataEntry]) async throws {
        let context = ModelContext(modelContainer)
        for entry in entries {
            let latitude = entry.coordinate.latitude
            let longitude = entry.coordinate.longitude
            let entryDate = entry.entryDate
            let rowKindRawValue = entry.rowKind.rawValue
            let existingRecords = try context.fetch(
                FetchDescriptor<CujanaSchemaV1.WeatherEntryRecord>(
                    predicate: #Predicate { record in
                        record.coordinateLatitude == latitude
                            && record.coordinateLongitude == longitude
                            && record.entryDate == entryDate
                            && record.rowKindRawValue == rowKindRawValue
                    }
                )
            )
            existingRecords.forEach(context.delete)
            context.insert(CujanaSchemaV1.WeatherEntryRecord(entry: entry))
        }
        try context.save()
    }
}
