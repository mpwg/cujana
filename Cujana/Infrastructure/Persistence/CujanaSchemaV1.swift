import Foundation
import SwiftData

enum CujanaSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static let models: [any PersistentModel.Type] = [
        SymptomEntryRecord.self,
        PollenEntryRecord.self,
        WeatherEntryRecord.self
    ]

    @Model
    final class SymptomEntryRecord {
        var id: UUID = UUID()
        var date: Date = Date()
        var symptomTypeRawValues: [String] = []
        var severityRawValue: Int = 0
        var note: String?
        var medicationIDRawValues: [String] = []
        var medicationNames: [String] = []
        var tags: [String] = []
        var latitude: Double?
        var longitude: Double?
        var weatherSnapshotID: UUID?
        var weatherSnapshotCollectedAt: Date?
        var weatherSnapshotEntryDate: Date?
        var weatherSnapshotCoordinateLatitude: Double?
        var weatherSnapshotCoordinateLongitude: Double?
        var weatherSnapshotGeneratedAt: Date?
        var weatherSnapshotRowKindRawValue: String?
        var weatherSnapshotTemperature: Double?
        var weatherSnapshotConditionCode: Int?
        var weatherSnapshotHumidityPercent: Double?
        var weatherSnapshotWindSpeedKPH: Double?

        init(entry: AllergySymptomEntry) {
            id = entry.id
            date = entry.date
            symptomTypeRawValues = entry.symptoms.map(\.rawValue)
            severityRawValue = entry.severity.rawValue
            note = entry.note
            medicationIDRawValues = entry.medications.map { $0.id.uuidString }
            medicationNames = entry.medications.map(\.name)
            tags = entry.tags
            latitude = entry.coordinate?.latitude
            longitude = entry.coordinate?.longitude
            weatherSnapshotID = entry.weatherSnapshot?.id
            weatherSnapshotCollectedAt = entry.weatherSnapshot?.collectedAt
            weatherSnapshotEntryDate = entry.weatherSnapshot?.entryDate
            weatherSnapshotCoordinateLatitude = entry.weatherSnapshot?.coordinate.latitude
            weatherSnapshotCoordinateLongitude = entry.weatherSnapshot?.coordinate.longitude
            weatherSnapshotGeneratedAt = entry.weatherSnapshot?.generatedAt
            weatherSnapshotRowKindRawValue = entry.weatherSnapshot?.rowKind.rawValue
            weatherSnapshotTemperature = entry.weatherSnapshot?.temperature
            weatherSnapshotConditionCode = entry.weatherSnapshot?.conditionCode
            weatherSnapshotHumidityPercent = entry.weatherSnapshot?.humidityPercent
            weatherSnapshotWindSpeedKPH = entry.weatherSnapshot?.windSpeedKilometersPerHour
        }
    }

    @Model
    final class PollenEntryRecord {
        var id: UUID = UUID()
        var rowKindRawValue: String = PollenDataEntryKind.dailyLevel.rawValue
        var collectedAt: Date = Date()
        var entryDate: Date = Date()
        var coordinateLatitude: Double = 0
        var coordinateLongitude: Double = 0
        var sourceKindRawValue: String = InformationSourceKind.forecast.rawValue
        var generatedAt: Date = Date()
        var validFrom: Date = Date()
        var validUntil: Date = Date()
        var alderLevelRawValue: Int?
        var ashLevelRawValue: Int?
        var birchLevelRawValue: Int?
        var grassLevelRawValue: Int?
        var hazelLevelRawValue: Int?
        var mugwortLevelRawValue: Int?
        var oakLevelRawValue: Int?
        var ragweedLevelRawValue: Int?
        var ryeLevelRawValue: Int?
        var allergyRiskLevelRawValue: Int?
        var allergyRiskHour0RawValue: Int?
        var allergyRiskHour1RawValue: Int?
        var allergyRiskHour2RawValue: Int?
        var allergyRiskHour3RawValue: Int?
        var allergyRiskHour4RawValue: Int?
        var allergyRiskHour5RawValue: Int?
        var allergyRiskHour6RawValue: Int?
        var allergyRiskHour7RawValue: Int?
        var allergyRiskHour8RawValue: Int?
        var allergyRiskHour9RawValue: Int?
        var allergyRiskHour10RawValue: Int?
        var allergyRiskHour11RawValue: Int?
        var allergyRiskHour12RawValue: Int?
        var allergyRiskHour13RawValue: Int?
        var allergyRiskHour14RawValue: Int?
        var allergyRiskHour15RawValue: Int?
        var allergyRiskHour16RawValue: Int?
        var allergyRiskHour17RawValue: Int?
        var allergyRiskHour18RawValue: Int?
        var allergyRiskHour19RawValue: Int?
        var allergyRiskHour20RawValue: Int?
        var allergyRiskHour21RawValue: Int?
        var allergyRiskHour22RawValue: Int?
        var allergyRiskHour23RawValue: Int?

        init(entry: PollenDataEntry) {
            id = entry.id
            rowKindRawValue = entry.rowKind.rawValue
            collectedAt = entry.collectedAt
            entryDate = entry.entryDate
            coordinateLatitude = entry.coordinate.latitude
            coordinateLongitude = entry.coordinate.longitude
            sourceKindRawValue = entry.sourceKind.rawValue
            generatedAt = entry.generatedAt
            validFrom = entry.validFrom
            validUntil = entry.validUntil
            alderLevelRawValue = entry.alderLevel?.rawValue
            ashLevelRawValue = entry.ashLevel?.rawValue
            birchLevelRawValue = entry.birchLevel?.rawValue
            grassLevelRawValue = entry.grassLevel?.rawValue
            hazelLevelRawValue = entry.hazelLevel?.rawValue
            mugwortLevelRawValue = entry.mugwortLevel?.rawValue
            oakLevelRawValue = entry.oakLevel?.rawValue
            ragweedLevelRawValue = entry.ragweedLevel?.rawValue
            ryeLevelRawValue = entry.ryeLevel?.rawValue
            allergyRiskLevelRawValue = entry.allergyRiskLevel?.rawValue
            allergyRiskHour0RawValue = entry.allergyRiskHour0?.rawValue
            allergyRiskHour1RawValue = entry.allergyRiskHour1?.rawValue
            allergyRiskHour2RawValue = entry.allergyRiskHour2?.rawValue
            allergyRiskHour3RawValue = entry.allergyRiskHour3?.rawValue
            allergyRiskHour4RawValue = entry.allergyRiskHour4?.rawValue
            allergyRiskHour5RawValue = entry.allergyRiskHour5?.rawValue
            allergyRiskHour6RawValue = entry.allergyRiskHour6?.rawValue
            allergyRiskHour7RawValue = entry.allergyRiskHour7?.rawValue
            allergyRiskHour8RawValue = entry.allergyRiskHour8?.rawValue
            allergyRiskHour9RawValue = entry.allergyRiskHour9?.rawValue
            allergyRiskHour10RawValue = entry.allergyRiskHour10?.rawValue
            allergyRiskHour11RawValue = entry.allergyRiskHour11?.rawValue
            allergyRiskHour12RawValue = entry.allergyRiskHour12?.rawValue
            allergyRiskHour13RawValue = entry.allergyRiskHour13?.rawValue
            allergyRiskHour14RawValue = entry.allergyRiskHour14?.rawValue
            allergyRiskHour15RawValue = entry.allergyRiskHour15?.rawValue
            allergyRiskHour16RawValue = entry.allergyRiskHour16?.rawValue
            allergyRiskHour17RawValue = entry.allergyRiskHour17?.rawValue
            allergyRiskHour18RawValue = entry.allergyRiskHour18?.rawValue
            allergyRiskHour19RawValue = entry.allergyRiskHour19?.rawValue
            allergyRiskHour20RawValue = entry.allergyRiskHour20?.rawValue
            allergyRiskHour21RawValue = entry.allergyRiskHour21?.rawValue
            allergyRiskHour22RawValue = entry.allergyRiskHour22?.rawValue
            allergyRiskHour23RawValue = entry.allergyRiskHour23?.rawValue
        }
    }

    @Model
    final class WeatherEntryRecord {
        var id: UUID = UUID()
        var rowKindRawValue: String = WeatherDataEntryKind.daily.rawValue
        var collectedAt: Date = Date()
        var entryDate: Date = Date()
        var coordinateLatitude: Double = 0
        var coordinateLongitude: Double = 0
        var generatedAt: Date = Date()
        var temperature: Double = 0
        var conditionCode: Int = 0
        var humidityPercent: Double?
        var windSpeedKilometersPerHour: Double?

        init(entry: WeatherDataEntry) {
            id = entry.id
            rowKindRawValue = entry.rowKind.rawValue
            collectedAt = entry.collectedAt
            entryDate = entry.entryDate
            coordinateLatitude = entry.coordinate.latitude
            coordinateLongitude = entry.coordinate.longitude
            generatedAt = entry.generatedAt
            temperature = entry.temperature
            conditionCode = entry.conditionCode
            humidityPercent = entry.humidityPercent
            windSpeedKilometersPerHour = entry.windSpeedKilometersPerHour
        }
    }
}

enum CujanaMigrationPlan: SchemaMigrationPlan {
    static let schemas: [any VersionedSchema.Type] = [CujanaSchemaV1.self]

    static let stages: [MigrationStage] = []
}
