import Foundation

nonisolated public enum SymptomEntryChange: Sendable {
    case saved(HealthEntry)
    case deleted(UUID)
}
