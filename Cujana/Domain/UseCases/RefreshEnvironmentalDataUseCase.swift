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
    ) async throws -> EnvironmentalDataCollection? {
        async let pollenEntries = refreshPollenEntries(for: coordinate, currentDate: currentDate, force: force)
        async let weatherEntries = refreshWeatherEntries(for: coordinate, currentDate: currentDate, force: force)

        let refreshedPollenEntries = try await pollenEntries
        let refreshedWeatherEntries = try await weatherEntries
        guard refreshedPollenEntries != nil || refreshedWeatherEntries != nil else {
            return nil
        }

        return EnvironmentalDataCollection(
            coordinate: coordinate,
            collectedAt: currentDate,
            pollenEntries: refreshedPollenEntries ?? [],
            weatherEntries: refreshedWeatherEntries ?? []
        )
    }

    @discardableResult
    public func refreshPollenEntries(
        for coordinate: LocationCoordinate,
        currentDate: Date,
        force: Bool = false
    ) async throws -> [PollenDataEntry]? {
        if force == false, try await isPollenRefreshTooRecent(for: coordinate, currentDate: currentDate) {
            return nil
        }

        let startDate = calendar.startOfDay(for: currentDate)
        let endDate = calendar.date(byAdding: .day, value: 3, to: startDate) ?? currentDate

        let forecasts = try await pollenRepository.pollenForecast(for: coordinate, from: startDate, to: endDate)
        let entries = PollenDataEntry.entries(from: forecasts, collectedAt: currentDate)
        try await environmentalDataRepository.savePollenEntries(entries)
        return entries
    }

    @discardableResult
    public func refreshWeatherEntries(
        for coordinate: LocationCoordinate,
        currentDate: Date,
        force: Bool = false
    ) async throws -> [WeatherDataEntry]? {
        if force == false, try await isWeatherRefreshTooRecent(for: coordinate, currentDate: currentDate) {
            return nil
        }

        let startDate = calendar.startOfDay(for: currentDate)
        let endDate = calendar.date(byAdding: .day, value: 3, to: startDate) ?? currentDate

        let forecasts = try await weatherRepository.weatherForecast(for: coordinate, from: startDate, to: endDate)
        let entries = WeatherDataEntry.entries(from: forecasts, collectedAt: currentDate)
        try await environmentalDataRepository.saveWeatherEntries(entries)
        return entries
    }

    private func isPollenRefreshTooRecent(for coordinate: LocationCoordinate, currentDate: Date) async throws -> Bool {
        guard
            let latestEntry = try await environmentalDataRepository.latestPollenEntry(for: coordinate)
        else {
            return false
        }

        return currentDate.timeIntervalSince(latestEntry.collectedAt) < Self.minimumRefreshInterval
    }

    private func isWeatherRefreshTooRecent(for coordinate: LocationCoordinate, currentDate: Date) async throws -> Bool {
        guard
            let latestEntry = try await environmentalDataRepository.latestWeatherEntry(for: coordinate)
        else {
            return false
        }

        return currentDate.timeIntervalSince(latestEntry.collectedAt) < Self.minimumRefreshInterval
    }
}
