import Foundation

nonisolated struct StoredSymptomEntry: Codable, Equatable, Sendable {
    let id: UUID
    let date: Date
    let symptomTypeRawValue: String
    let severityRawValue: Int
    let note: String?
    let latitude: Double?
    let longitude: Double?

    init(entry: AllergySymptomEntry) {
        id = entry.id
        date = entry.date
        symptomTypeRawValue = entry.symptomType.rawValue
        severityRawValue = entry.severity.rawValue
        note = entry.note
        latitude = entry.coordinate?.latitude
        longitude = entry.coordinate?.longitude
    }

    init(
        id: UUID,
        date: Date,
        symptomTypeRawValue: String,
        severityRawValue: Int,
        note: String?,
        latitude: Double?,
        longitude: Double?
    ) {
        self.id = id
        self.date = date
        self.symptomTypeRawValue = symptomTypeRawValue
        self.severityRawValue = severityRawValue
        self.note = note
        self.latitude = latitude
        self.longitude = longitude
    }

    func domainEntry() throws -> AllergySymptomEntry {
        guard let symptomType = SymptomType(rawValue: symptomTypeRawValue) else {
            throw SymptomEntryError.storageUnavailable
        }

        return try AllergySymptomEntry(
            id: id,
            date: date,
            symptomType: symptomType,
            severity: SymptomSeverity(rawValue: severityRawValue),
            note: note,
            coordinate: coordinate()
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
