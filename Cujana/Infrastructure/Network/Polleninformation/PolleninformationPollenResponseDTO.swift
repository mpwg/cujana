import Foundation

nonisolated public struct PolleninformationPollenResponseDTO: Codable, Equatable, Sendable {
    public struct Daily: Codable, Equatable, Sendable {
        public let dates: [Date]
        public let variables: [DailyVariable]

        public init(dates: [Date], variables: [DailyVariable]) {
            self.dates = dates
            self.variables = variables
        }
    }

    public struct DailyVariable: Codable, Equatable, Sendable {
        public let pollenType: PollenType
        public let values: [Int]

        public init(pollenType: PollenType, values: [Int]) {
            self.pollenType = pollenType
            self.values = values
        }
    }

    public struct DailyAllergyRisk: Codable, Equatable, Sendable {
        public let date: Date
        public let value: Int
        public let hourlyValues: [Int]

        public init(date: Date, value: Int, hourlyValues: [Int]) {
            self.date = date
            self.value = value
            self.hourlyValues = hourlyValues
        }
    }

    public let coordinate: LocationCoordinate
    public let generatedAt: Date
    public let daily: Daily
    public let dailyAllergyRisks: [DailyAllergyRisk]

    public init(
        coordinate: LocationCoordinate,
        generatedAt: Date,
        daily: Daily,
        dailyAllergyRisks: [DailyAllergyRisk] = []
    ) {
        self.coordinate = coordinate
        self.generatedAt = generatedAt
        self.daily = daily
        self.dailyAllergyRisks = dailyAllergyRisks
    }
}
