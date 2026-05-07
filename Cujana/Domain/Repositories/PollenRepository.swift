import Foundation

nonisolated public protocol PollenRepository: Sendable {
    func pollenForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [PollenForecast]
}
