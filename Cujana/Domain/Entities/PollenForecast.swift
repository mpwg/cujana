import Foundation

nonisolated public struct PollenForecast: Equatable, Identifiable, Sendable {
    nonisolated public struct DailyLevel: Equatable, Identifiable, Sendable {
        public var id: String {
            "\(date.timeIntervalSince1970)-\(pollenType.rawValue)"
        }

        public let date: Date
        public let pollenType: PollenType
        public let level: PollenLevel

        public init(date: Date, pollenType: PollenType, level: PollenLevel) {
            self.date = date
            self.pollenType = pollenType
            self.level = level
        }
    }

    nonisolated public struct DailyAllergyRisk: Equatable, Identifiable, Sendable {
        public var id: String {
            "\(date.timeIntervalSince1970)-allergy-risk"
        }

        public let date: Date
        public let level: PollenLevel
        public let hourlyLevels: [PollenLevel]

        public init(date: Date, level: PollenLevel, hourlyLevels: [PollenLevel] = []) {
            self.date = date
            self.level = level
            self.hourlyLevels = hourlyLevels
        }
    }

    public let id: UUID
    public let coordinate: LocationCoordinate
    public let sourceKind: InformationSourceKind
    public let generatedAt: Date
    public let validFrom: Date
    public let validUntil: Date
    public let dailyLevels: [DailyLevel]
    public let dailyAllergyRisks: [DailyAllergyRisk]

    public init(
        id: UUID = UUID(),
        coordinate: LocationCoordinate,
        sourceKind: InformationSourceKind,
        generatedAt: Date,
        validFrom: Date,
        validUntil: Date,
        dailyLevels: [DailyLevel],
        dailyAllergyRisks: [DailyAllergyRisk] = []
    ) throws {
        guard validFrom <= validUntil else {
            throw PollenDataError.invalidForecastPeriod(start: validFrom, end: validUntil)
        }

        self.id = id
        self.coordinate = coordinate
        self.sourceKind = sourceKind
        self.generatedAt = generatedAt
        self.validFrom = validFrom
        self.validUntil = validUntil
        self.dailyLevels = dailyLevels
        self.dailyAllergyRisks = dailyAllergyRisks
    }
}
