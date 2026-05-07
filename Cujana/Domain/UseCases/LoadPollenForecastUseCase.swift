import Foundation

nonisolated public struct LoadPollenForecastUseCase: Sendable {
    private let repository: any PollenRepository

    public init(repository: any PollenRepository) {
        self.repository = repository
    }

    public func execute(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [PollenForecast] {
        guard startDate <= endDate else {
            throw PollenDataError.invalidForecastPeriod(start: startDate, end: endDate)
        }

        return try await repository.pollenForecast(for: coordinate, from: startDate, to: endDate)
    }
}
