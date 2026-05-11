import Foundation

nonisolated public struct WeatherForecast: Codable, Equatable, Identifiable, Sendable {
    nonisolated public struct DailyCondition: Codable, Equatable, Identifiable, Sendable {
        public var id: String {
            "\(date.timeIntervalSince1970)"
        }

        public let date: Date
        public let temperature: Double
        public let conditionCode: Int
        public let humidityPercent: Double?
        public let windSpeedKilometersPerHour: Double?

        public init(
            date: Date,
            temperature: Double,
            conditionCode: Int,
            humidityPercent: Double? = nil,
            windSpeedKilometersPerHour: Double? = nil
        ) {
            self.date = date
            self.temperature = temperature
            self.conditionCode = conditionCode
            self.humidityPercent = humidityPercent
            self.windSpeedKilometersPerHour = windSpeedKilometersPerHour
        }
    }

    nonisolated public struct HourlyCondition: Codable, Equatable, Identifiable, Sendable {
        public var id: String {
            "\(date.timeIntervalSince1970)"
        }

        public let date: Date
        public let temperature: Double
        public let conditionCode: Int
        public let humidityPercent: Double?
        public let windSpeedKilometersPerHour: Double?

        public init(
            date: Date,
            temperature: Double,
            conditionCode: Int,
            humidityPercent: Double? = nil,
            windSpeedKilometersPerHour: Double? = nil
        ) {
            self.date = date
            self.temperature = temperature
            self.conditionCode = conditionCode
            self.humidityPercent = humidityPercent
            self.windSpeedKilometersPerHour = windSpeedKilometersPerHour
        }
    }

    public let id: UUID
    public let coordinate: LocationCoordinate
    public let generatedAt: Date
    public let dailyConditions: [DailyCondition]
    public let hourlyConditions: [HourlyCondition]

    public init(
        id: UUID = UUID(),
        coordinate: LocationCoordinate,
        generatedAt: Date,
        dailyConditions: [DailyCondition],
        hourlyConditions: [HourlyCondition] = []
    ) {
        self.id = id
        self.coordinate = coordinate
        self.generatedAt = generatedAt
        self.dailyConditions = dailyConditions
        self.hourlyConditions = hourlyConditions
    }
}
