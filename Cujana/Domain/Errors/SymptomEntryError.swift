import Foundation

nonisolated public enum SymptomEntryError: Error, Equatable, Sendable {
    case noteTooLong(maxLength: Int)
    case storageUnavailable
}
