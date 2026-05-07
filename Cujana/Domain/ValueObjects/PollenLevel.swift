nonisolated public struct PollenLevel: Comparable, Equatable, Hashable, Sendable {
    public static let none = PollenLevel(rawValue: 0)
    public static let low = PollenLevel(rawValue: 1)
    public static let moderate = PollenLevel(rawValue: 2)
    public static let high = PollenLevel(rawValue: 3)
    public static let veryHigh = PollenLevel(rawValue: 4)
    public static let extreme = PollenLevel(rawValue: 5)

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = min(max(rawValue, 0), 5)
    }

    public static func < (lhs: PollenLevel, rhs: PollenLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
