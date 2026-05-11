import Foundation

nonisolated struct StoredSymptomEntry: Codable, Equatable, Sendable {
    let id: UUID
    let date: Date
    let symptomTypeRawValues: [String]
    let severityRawValue: Int
    let note: String?
    let medications: [Medication]
    let tags: [String]
    let latitude: Double?
    let longitude: Double?
    let weatherSnapshot: WeatherSnapshot?

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case symptomTypeRawValues
        case severityRawValue
        case note
        case medications
        case tags
        case latitude
        case longitude
        case weatherSnapshot
    }

    init(entry: AllergySymptomEntry) {
        id = entry.id
        date = entry.date
        symptomTypeRawValues = entry.symptoms.map(\.rawValue)
        severityRawValue = entry.severity.rawValue
        note = entry.note
        medications = entry.medications
        tags = entry.tags
        latitude = entry.coordinate?.latitude
        longitude = entry.coordinate?.longitude
        weatherSnapshot = entry.weatherSnapshot
    }

    init(
        id: UUID,
        date: Date,
        symptomTypeRawValues: [String],
        severityRawValue: Int,
        note: String?,
        medications: [Medication] = [],
        tags: [String] = [],
        latitude: Double?,
        longitude: Double?,
        weatherSnapshot: WeatherSnapshot? = nil
    ) {
        self.id = id
        self.date = date
        self.symptomTypeRawValues = symptomTypeRawValues
        self.severityRawValue = severityRawValue
        self.note = note
        self.medications = medications
        self.tags = tags
        self.latitude = latitude
        self.longitude = longitude
        self.weatherSnapshot = weatherSnapshot
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        symptomTypeRawValues = try container.decode([String].self, forKey: .symptomTypeRawValues)
        severityRawValue = try container.decode(Int.self, forKey: .severityRawValue)
        note = try container.decodeIfPresent(String.self, forKey: .note)
        medications = try container.decodeIfPresent([Medication].self, forKey: .medications) ?? []
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        weatherSnapshot = try container.decodeIfPresent(WeatherSnapshot.self, forKey: .weatherSnapshot)
    }

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
            medications: medications,
            tags: tags,
            coordinate: coordinate(),
            weatherSnapshot: weatherSnapshot
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
}
