nonisolated public enum InformationSourceKind: String, CaseIterable, Equatable, Hashable, Sendable {
    case forecast
    case observed
    case userReported
    case clinical
    case reference
}
