import Foundation

nonisolated public struct AllergySymptomEntry: Equatable, Identifiable, Sendable {
    public static let maximumNoteLength = 500

    public let id: UUID
    public let date: Date
    public let symptomType: SymptomType
    public let severity: SymptomSeverity
    public let note: String?
    public let coordinate: LocationCoordinate?

    public init(
        id: UUID = UUID(),
        date: Date,
        symptomType: SymptomType,
        severity: SymptomSeverity,
        note: String? = nil,
        coordinate: LocationCoordinate? = nil
    ) throws {
        let trimmedNote = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (trimmedNote?.count ?? 0) <= Self.maximumNoteLength else {
            throw SymptomEntryError.noteTooLong(maxLength: Self.maximumNoteLength)
        }

        self.id = id
        self.date = date
        self.symptomType = symptomType
        self.severity = severity
        self.note = trimmedNote?.isEmpty == true ? nil : trimmedNote
        self.coordinate = coordinate
    }
}
