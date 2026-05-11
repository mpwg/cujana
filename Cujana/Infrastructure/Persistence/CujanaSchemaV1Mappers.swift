import Foundation

extension CujanaSchemaV1.SymptomEntryRecord {
    func domainEntry() throws -> AllergySymptomEntry {
        let symptoms = symptomTypeRawValues.compactMap(SymptomType.init(rawValue:))
        guard symptoms.count == symptomTypeRawValues.count else {
            throw SymptomEntryError.storageUnavailable
        }

        return try AllergySymptomEntry(
            id: id,
            date: date,
            symptoms: symptoms,
            severity: SymptomSeverity(rawValue: severityRawValue),
            note: note,
            medications: medications(),
            tags: tags,
            coordinate: coordinate(),
            weatherSnapshot: weatherSnapshot()
        )
    }

    private func coordinate() throws -> LocationCoordinate? {
        switch (latitude, longitude) {
        case (.none, .none):
            return nil
        case let (.some(latitude), .some(longitude)):
            return try LocationCoordinate(latitude: latitude, longitude: longitude)
        default:
            throw SymptomEntryError.storageUnavailable
        }
    }

    private func medications() -> [Medication] {
        zip(medicationIDRawValues, medicationNames).map { idRawValue, name in
            Medication(id: UUID(uuidString: idRawValue) ?? UUID(), name: name)
        }
    }

    private func weatherSnapshot() throws -> WeatherSnapshot? {
        guard weatherSnapshotID != nil
                || weatherSnapshotCollectedAt != nil
                || weatherSnapshotEntryDate != nil
                || weatherSnapshotTemperature != nil
                || weatherSnapshotConditionCode != nil else {
            return nil
        }

        guard let id = weatherSnapshotID,
              let collectedAt = weatherSnapshotCollectedAt,
              let entryDate = weatherSnapshotEntryDate,
              let latitude = weatherSnapshotCoordinateLatitude,
              let longitude = weatherSnapshotCoordinateLongitude,
              let generatedAt = weatherSnapshotGeneratedAt,
              let rowKindRawValue = weatherSnapshotRowKindRawValue,
              let rowKind = WeatherDataEntryKind(rawValue: rowKindRawValue),
              let temperature = weatherSnapshotTemperature,
              let conditionCode = weatherSnapshotConditionCode else {
            throw SymptomEntryError.storageUnavailable
        }

        return try WeatherSnapshot(
            id: id,
            collectedAt: collectedAt,
            entryDate: entryDate,
            coordinate: LocationCoordinate(latitude: latitude, longitude: longitude),
            generatedAt: generatedAt,
            rowKind: rowKind,
            temperature: temperature,
            conditionCode: conditionCode,
            humidityPercent: weatherSnapshotHumidityPercent,
            windSpeedKilometersPerHour: weatherSnapshotWindSpeedKPH
        )
    }
}

extension CujanaSchemaV1.PollenEntryRecord {
    func domainEntry() throws -> PollenDataEntry {
        guard let sourceKind = InformationSourceKind(rawValue: sourceKindRawValue),
              let rowKind = PollenDataEntryKind(rawValue: rowKindRawValue) else {
            throw PollenDataError.decodingFailed
        }

        var entry = PollenDataEntry(
            id: id,
            collectedAt: collectedAt,
            entryDate: entryDate,
            coordinate: try LocationCoordinate(latitude: coordinateLatitude, longitude: coordinateLongitude),
            sourceKind: sourceKind,
            generatedAt: generatedAt,
            validFrom: validFrom,
            validUntil: validUntil,
            rowKind: rowKind
        )
        entry.alderLevel = level(from: alderLevelRawValue)
        entry.ashLevel = level(from: ashLevelRawValue)
        entry.birchLevel = level(from: birchLevelRawValue)
        entry.grassLevel = level(from: grassLevelRawValue)
        entry.hazelLevel = level(from: hazelLevelRawValue)
        entry.mugwortLevel = level(from: mugwortLevelRawValue)
        entry.oakLevel = level(from: oakLevelRawValue)
        entry.ragweedLevel = level(from: ragweedLevelRawValue)
        entry.ryeLevel = level(from: ryeLevelRawValue)
        entry.allergyRiskLevel = level(from: allergyRiskLevelRawValue)
        entry.allergyRiskHour0 = level(from: allergyRiskHour0RawValue)
        entry.allergyRiskHour1 = level(from: allergyRiskHour1RawValue)
        entry.allergyRiskHour2 = level(from: allergyRiskHour2RawValue)
        entry.allergyRiskHour3 = level(from: allergyRiskHour3RawValue)
        entry.allergyRiskHour4 = level(from: allergyRiskHour4RawValue)
        entry.allergyRiskHour5 = level(from: allergyRiskHour5RawValue)
        entry.allergyRiskHour6 = level(from: allergyRiskHour6RawValue)
        entry.allergyRiskHour7 = level(from: allergyRiskHour7RawValue)
        entry.allergyRiskHour8 = level(from: allergyRiskHour8RawValue)
        entry.allergyRiskHour9 = level(from: allergyRiskHour9RawValue)
        entry.allergyRiskHour10 = level(from: allergyRiskHour10RawValue)
        entry.allergyRiskHour11 = level(from: allergyRiskHour11RawValue)
        entry.allergyRiskHour12 = level(from: allergyRiskHour12RawValue)
        entry.allergyRiskHour13 = level(from: allergyRiskHour13RawValue)
        entry.allergyRiskHour14 = level(from: allergyRiskHour14RawValue)
        entry.allergyRiskHour15 = level(from: allergyRiskHour15RawValue)
        entry.allergyRiskHour16 = level(from: allergyRiskHour16RawValue)
        entry.allergyRiskHour17 = level(from: allergyRiskHour17RawValue)
        entry.allergyRiskHour18 = level(from: allergyRiskHour18RawValue)
        entry.allergyRiskHour19 = level(from: allergyRiskHour19RawValue)
        entry.allergyRiskHour20 = level(from: allergyRiskHour20RawValue)
        entry.allergyRiskHour21 = level(from: allergyRiskHour21RawValue)
        entry.allergyRiskHour22 = level(from: allergyRiskHour22RawValue)
        entry.allergyRiskHour23 = level(from: allergyRiskHour23RawValue)
        return entry
    }

    private func level(from rawValue: Int?) -> PollenLevel? {
        rawValue.map(PollenLevel.init(rawValue:))
    }
}

extension CujanaSchemaV1.WeatherEntryRecord {
    func domainEntry() throws -> WeatherDataEntry {
        guard let rowKind = WeatherDataEntryKind(rawValue: rowKindRawValue) else {
            throw WeatherDataError.decodingFailed
        }

        return WeatherDataEntry(
            id: id,
            collectedAt: collectedAt,
            entryDate: entryDate,
            coordinate: try LocationCoordinate(latitude: coordinateLatitude, longitude: coordinateLongitude),
            generatedAt: generatedAt,
            rowKind: rowKind,
            temperature: temperature,
            conditionCode: conditionCode,
            humidityPercent: humidityPercent,
            windSpeedKilometersPerHour: windSpeedKilometersPerHour
        )
    }
}
