import CoreLocation
import Foundation
import WeatherKit

nonisolated public protocol WeatherKitWeatherAPIClient: Sendable {
    func weatherResponse(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> WeatherKitWeatherResponseDTO
}

nonisolated public struct WeatherKitWeatherServiceClient: WeatherKitWeatherAPIClient {
    private let service: WeatherService
    private let calendar: Calendar

    public init(
        service: WeatherService = .shared,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) {
        self.service = service
        self.calendar = calendar
    }

    public func weatherResponse(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> WeatherKitWeatherResponseDTO {
        try await AppObservability.trace(
            name: "WeatherKit Forecast laden",
            operation: "weatherkit.daily",
            category: "WeatherKit",
            metadata: [
                "latitude": String(format: "%.2f", coordinate.latitude),
                "longitude": String(format: "%.2f", coordinate.longitude)
            ]
        ) {
            do {
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let dailyForecast = try await service.weather(
                    for: location,
                    including: .daily(startDate: startDate, endDate: endDate)
                )
                let days = dailyForecast.forecast.filter { day in
                    calendar.compare(day.date, to: startDate, toGranularity: .day) != .orderedAscending
                        && calendar.compare(day.date, to: endDate, toGranularity: .day) != .orderedDescending
                }

                AppObservability.log(
                    .info,
                    "WeatherKit Forecast geladen.",
                    category: "WeatherKit",
                    metadata: ["dayCount": "\(days.count)"]
                )

                return WeatherKitWeatherResponseDTO(
                    coordinate: coordinate,
                    days: days.map { day in
                        WeatherKitWeatherDayDTO(
                            date: calendar.startOfDay(for: day.date),
                            condition: day.condition.rawValue,
                            highTemperatureCelsius: day.highTemperature.converted(to: .celsius).value
                        )
                    }
                )
            } catch let error as WeatherDataError {
                throw error
            } catch {
                AppObservability.log(
                    .error,
                    "WeatherKit Forecast konnte nicht geladen werden.",
                    category: "WeatherKit",
                    metadata: ["error": String(describing: error)]
                )
                throw WeatherDataError.networkFailure
            }
        }
    }
}
