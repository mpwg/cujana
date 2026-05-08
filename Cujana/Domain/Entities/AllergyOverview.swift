import Foundation

nonisolated public struct AllergyOverview: Equatable, Sendable {
    public let coordinate: LocationCoordinate
    public let pollenForecasts: [PollenForecast]
    public let weatherForecasts: [WeatherForecast]
    public let symptomEntries: [AllergySymptomEntry]
    public let generatedAt: Date

    public init(
        coordinate: LocationCoordinate,
        pollenForecasts: [PollenForecast],
        weatherForecasts: [WeatherForecast] = [],
        symptomEntries: [AllergySymptomEntry],
        generatedAt: Date = Date()
    ) {
        self.coordinate = coordinate
        self.pollenForecasts = pollenForecasts
        self.weatherForecasts = weatherForecasts
        self.symptomEntries = symptomEntries
        self.generatedAt = generatedAt
    }
}
