import Foundation

nonisolated public struct EnvironmentalDataSnapshot: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let coordinate: LocationCoordinate
    public let collectedAt: Date
    public let pollenForecasts: [PollenForecast]
    public let weatherForecasts: [WeatherForecast]

    public init(
        id: UUID = UUID(),
        coordinate: LocationCoordinate,
        collectedAt: Date,
        pollenForecasts: [PollenForecast],
        weatherForecasts: [WeatherForecast]
    ) {
        self.id = id
        self.coordinate = coordinate
        self.collectedAt = collectedAt
        self.pollenForecasts = pollenForecasts
        self.weatherForecasts = weatherForecasts
    }
}
