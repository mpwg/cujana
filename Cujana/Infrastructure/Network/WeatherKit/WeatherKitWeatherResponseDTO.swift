import Foundation

nonisolated public struct WeatherKitWeatherDayDTO: Codable, Equatable, Sendable {
    public let date: Date
    public let condition: String
    public let highTemperatureCelsius: Double
    public let humidityPercent: Double?
    public let windSpeedKilometersPerHour: Double?

    public init(
        date: Date,
        condition: String,
        highTemperatureCelsius: Double,
        humidityPercent: Double? = nil,
        windSpeedKilometersPerHour: Double? = nil
    ) {
        self.date = date
        self.condition = condition
        self.highTemperatureCelsius = highTemperatureCelsius
        self.humidityPercent = humidityPercent
        self.windSpeedKilometersPerHour = windSpeedKilometersPerHour
    }
}

nonisolated public struct WeatherKitWeatherResponseDTO: Codable, Equatable, Sendable {
    public let coordinate: LocationCoordinate
    public let days: [WeatherKitWeatherDayDTO]

    public init(coordinate: LocationCoordinate, days: [WeatherKitWeatherDayDTO]) {
        self.coordinate = coordinate
        self.days = days
    }
}
