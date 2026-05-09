import Foundation

nonisolated public struct WeatherForecast: Equatable, Identifiable, Sendable {
    nonisolated public struct DailyCondition: Equatable, Identifiable, Sendable {
        public var id: String {
            "\(date.timeIntervalSince1970)"
        }

        public let date: Date
        public let temperature: Double
        public let conditionCode: Int

        public init(date: Date, temperature: Double, conditionCode: Int) {
            self.date = date
            self.temperature = temperature
            self.conditionCode = conditionCode
        }
    }

    public let id: UUID
    public let coordinate: LocationCoordinate
    public let generatedAt: Date
    public let dailyConditions: [DailyCondition]

    public init(
        id: UUID = UUID(),
        coordinate: LocationCoordinate,
        generatedAt: Date,
        dailyConditions: [DailyCondition]
    ) {
        self.id = id
        self.coordinate = coordinate
        self.generatedAt = generatedAt
        self.dailyConditions = dailyConditions
    }
}
