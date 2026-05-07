nonisolated public struct SymptomSeverity: Comparable, Equatable, Hashable, Sendable {
    public static let none = SymptomSeverity(rawValue: 0)
    public static let mild = SymptomSeverity(rawValue: 3)
    public static let moderate = SymptomSeverity(rawValue: 6)
    public static let severe = SymptomSeverity(rawValue: 10)

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = min(max(rawValue, 0), 10)
    }

    public static func < (lhs: SymptomSeverity, rhs: SymptomSeverity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
