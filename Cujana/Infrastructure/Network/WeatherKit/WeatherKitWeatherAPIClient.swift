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
                return try await makeResponse(for: coordinate, location: location, dateRange: dateRange)
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

    private func makeResponse(
        for coordinate: LocationCoordinate,
        location: CLLocation,
        dateRange: WeatherKitForecastDateRange
    ) async throws -> WeatherKitWeatherResponseDTO {
        let dailyForecast = try await service.weather(
            for: location,
            including: .daily(startDate: dateRange.startDate, endDate: dateRange.endDate)
        )
        let hourlyForecast = try await service.weather(
            for: location,
            including: .hourly(startDate: dateRange.startDate, endDate: dateRange.endDate)
        )
        let days = filteredDays(dailyForecast.forecast, in: dateRange)
        let hours = filteredHours(hourlyForecast.forecast, in: dateRange)

        AppObservability.log(
            .info,
            "WeatherKit Forecast geladen.",
            category: "WeatherKit",
            metadata: [
                "dayCount": "\(days.count)",
                "hourCount": "\(hours.count)"
            ]
        )

        return WeatherKitWeatherResponseDTO(
            coordinate: coordinate,
            days: days.map(mapDay(_:)),
            hours: hours.map(mapHour(_:))
        )
    }

    private func filteredDays(_ days: [DayWeather], in dateRange: WeatherKitForecastDateRange) -> [DayWeather] {
        days.filter { day in
            calendar.compare(day.date, to: dateRange.startDate, toGranularity: .day) != .orderedAscending
                && calendar.compare(day.date, to: dateRange.endDate, toGranularity: .day) != .orderedDescending
        }
    }

    private func filteredHours(
        _ hours: [HourWeather],
        in dateRange: WeatherKitForecastDateRange
    ) -> [HourWeather] {
        hours.filter { hour in
            hour.date >= dateRange.startDate && hour.date <= dateRange.endDate
        }
    }

    private func mapDay(_ day: DayWeather) -> WeatherKitWeatherDayDTO {
        WeatherKitWeatherDayDTO(
            date: calendar.startOfDay(for: day.date),
            condition: day.condition.rawValue,
            highTemperatureCelsius: day.highTemperature.converted(to: .celsius).value,
            humidityPercent: day.maximumHumidity * 100,
            windSpeedKilometersPerHour: day.wind.speed.converted(to: .kilometersPerHour).value
        )
    }

    private func mapHour(_ hour: HourWeather) -> WeatherKitWeatherResponseDTO.HourDTO {
        WeatherKitWeatherResponseDTO.HourDTO(
            date: hour.date,
            condition: hour.condition.rawValue,
            temperatureCelsius: hour.temperature.converted(to: .celsius).value,
            humidityPercent: hour.humidity * 100,
            windSpeedKilometersPerHour: hour.wind.speed.converted(to: .kilometersPerHour).value
        )
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
