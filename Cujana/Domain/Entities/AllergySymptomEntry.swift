import Foundation

nonisolated public struct Medication: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public var name: String

    public init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

nonisolated public struct AllergySymptomEntry: Equatable, Identifiable, Sendable {
    public static let maximumNoteLength = 500

    public let id: UUID
    public let date: Date
    public let symptoms: [SymptomType]
    public let severity: SymptomSeverity
    public let note: String?
    public let medications: [Medication]
    public let tags: [String]
    public let coordinate: LocationCoordinate?
    public let weatherSnapshot: WeatherSnapshot?

    public init(
        id: UUID = UUID(),
        date: Date,
        symptoms: [SymptomType],
        severity: SymptomSeverity,
        note: String? = nil,
        medications: [Medication] = [],
        tags: [String] = [],
        coordinate: LocationCoordinate? = nil,
        weatherSnapshot: WeatherSnapshot? = nil
    ) throws {
        let trimmedNote = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        let uniqueSymptoms = symptoms.reduce(into: [SymptomType]()) { result, symptom in
            if result.contains(symptom) == false {
                result.append(symptom)
            }
        }
        let normalizedMedications = medications
            .map { Medication(id: $0.id, name: $0.name) }
            .filter { $0.name.isEmpty == false }
        let normalizedTags = tags.reduce(into: [String]()) { result, tag in
            let trimmedTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedTag.isEmpty == false else {
                return
            }

            if result.contains(trimmedTag) == false {
                result.append(trimmedTag)
            }
        }

        guard uniqueSymptoms.isEmpty == false else {
            throw SymptomEntryError.emptySymptoms
        }

        guard (trimmedNote?.count ?? 0) <= Self.maximumNoteLength else {
            throw SymptomEntryError.noteTooLong(maxLength: Self.maximumNoteLength)
        }

        self.id = id
        self.date = date
        self.symptoms = uniqueSymptoms
        self.severity = severity
        self.note = trimmedNote?.isEmpty == true ? nil : trimmedNote
        self.medications = normalizedMedications
        self.tags = normalizedTags
        self.coordinate = coordinate
        self.weatherSnapshot = weatherSnapshot
    }
}

public typealias HealthEntry = AllergySymptomEntry
public typealias WeatherSnapshot = EnvironmentalDataSnapshot
