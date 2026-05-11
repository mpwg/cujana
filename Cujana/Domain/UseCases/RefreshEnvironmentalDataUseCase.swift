import Foundation

nonisolated public struct RefreshEnvironmentalDataUseCase: Sendable {
    public static let minimumRefreshInterval: TimeInterval = 6 * 60 * 60

    private let pollenRepository: any PollenRepository
    private let weatherRepository: any WeatherRepository
    private let environmentalDataRepository: any EnvironmentalDataRepository
    private let calendar: Calendar

    public init(
        pollenRepository: any PollenRepository,
        weatherRepository: any WeatherRepository,
        environmentalDataRepository: any EnvironmentalDataRepository,
        calendar: Calendar = .current
    ) {
        self.pollenRepository = pollenRepository
        self.weatherRepository = weatherRepository
        self.environmentalDataRepository = environmentalDataRepository
        self.calendar = calendar
    }

    @discardableResult
    public func execute(
        for coordinate: LocationCoordinate,
        currentDate: Date,
        force: Bool = false
    ) async throws -> EnvironmentalDataSnapshot? {
        if force == false, try await isRefreshTooRecent(for: coordinate, currentDate: currentDate) {
            return nil
        }

        let startDate = calendar.startOfDay(for: currentDate)
        let endDate = calendar.date(byAdding: .day, value: 3, to: startDate) ?? currentDate

        async let pollenForecasts = pollenRepository.pollenForecast(for: coordinate, from: startDate, to: endDate)
        async let weatherForecasts = weatherRepository.weatherForecast(for: coordinate, from: startDate, to: endDate)

        let snapshot = try await EnvironmentalDataSnapshot(
            coordinate: coordinate,
            collectedAt: currentDate,
            pollenForecasts: pollenForecasts,
            weatherForecasts: weatherForecasts
        )
        try await environmentalDataRepository.save(snapshot)

        return snapshot
    }

    private func isRefreshTooRecent(for coordinate: LocationCoordinate, currentDate: Date) async throws -> Bool {
        guard
            let latestSnapshot = try await environmentalDataRepository.latestSnapshot(),
            latestSnapshot.coordinate == coordinate
        else {
            return false
        }

        return currentDate.timeIntervalSince(latestSnapshot.collectedAt) < Self.minimumRefreshInterval
    }
}
