import Foundation

nonisolated public struct AllergySymptomEntry: Equatable, Identifiable, Sendable {
    public static let maximumNoteLength = 500

    public let id: UUID
    public let date: Date
    public let symptoms: [SymptomType]
    public let severity: SymptomSeverity
    public let note: String?
    public let coordinate: LocationCoordinate?

    public init(
        id: UUID = UUID(),
        date: Date,
        symptoms: [SymptomType],
        severity: SymptomSeverity,
        note: String? = nil,
        coordinate: LocationCoordinate? = nil
    ) throws {
        let trimmedNote = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        let uniqueSymptoms = symptoms.reduce(into: [SymptomType]()) { result, symptom in
            if result.contains(symptom) == false {
                result.append(symptom)
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
        self.coordinate = coordinate
    }
}
