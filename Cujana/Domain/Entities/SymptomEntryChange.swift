import Foundation

nonisolated public enum SymptomEntryChange: Sendable {
    case saved(HealthEntry)
    case deleted(UUID)
}

extension Notification.Name {
    nonisolated static let symptomEntryDidChange = Notification.Name("Cujana.symptomEntryDidChange")
}
