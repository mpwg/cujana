import Foundation

nonisolated public protocol WeatherRepository: Sendable {
    func weatherForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [WeatherForecast]
}
