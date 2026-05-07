import Foundation

nonisolated public struct OpenMeteoPollenResponseDTO: Codable, Equatable, Sendable {
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
        public let values: [Float]

        public init(pollenType: PollenType, values: [Float]) {
            self.pollenType = pollenType
            self.values = values
        }
    }

    public let coordinate: LocationCoordinate
    public let generatedAt: Date
    public let daily: Daily

    public init(coordinate: LocationCoordinate, generatedAt: Date, daily: Daily) {
        self.coordinate = coordinate
        self.generatedAt = generatedAt
        self.daily = daily
    }
}
