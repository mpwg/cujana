import Foundation

nonisolated public enum SymptomEntryError: Error, Equatable, Sendable {
    case emptySymptoms
    case noteTooLong(maxLength: Int)
    case storageUnavailable
}
