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
    private let now: @Sendable () -> Date

    public init(
        service: WeatherService = .shared,
        calendar: Calendar = Calendar(identifier: .gregorian),
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.service = service
        self.calendar = calendar
        self.now = now
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
                let dateRange = Self.forecastDateRange(
                    from: startDate,
                    to: endDate,
                    now: now(),
                    calendar: calendar
                )
                let dailyForecast = try await service.weather(
                    for: location,
                    including: .daily(startDate: dateRange.startDate, endDate: dateRange.endDate)
                )
                let days = dailyForecast.forecast.filter { day in
                    calendar.compare(day.date, to: dateRange.startDate, toGranularity: .day) != .orderedAscending
                        && calendar.compare(day.date, to: dateRange.endDate, toGranularity: .day) != .orderedDescending
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

    nonisolated static func forecastDateRange(
        from startDate: Date,
        to endDate: Date,
        now: Date,
        calendar: Calendar
    ) -> WeatherKitForecastDateRange {
        let today = calendar.startOfDay(for: now)
        let requestedStart = calendar.startOfDay(for: startDate)
        let normalizedStart = max(requestedStart, today)
        let requestedEnd = calendar.startOfDay(for: endDate)
        let paddedEnd = calendar.date(byAdding: .day, value: 1, to: requestedEnd) ?? endDate

        return WeatherKitForecastDateRange(
            startDate: normalizedStart,
            endDate: max(paddedEnd, normalizedStart)
        )
    }
}

nonisolated struct WeatherKitForecastDateRange: Equatable {
    let startDate: Date
    let endDate: Date
}
