import Foundation

nonisolated public struct LoadAllergyOverviewUseCase: Sendable {
    private let pollenRepository: any PollenRepository
    private let weatherRepository: (any WeatherRepository)?
    private let symptomEntryRepository: any SymptomEntryRepository

    public init(
        pollenRepository: any PollenRepository,
        weatherRepository: (any WeatherRepository)? = nil,
        symptomEntryRepository: any SymptomEntryRepository
    ) {
        self.pollenRepository = pollenRepository
        self.weatherRepository = weatherRepository
        self.symptomEntryRepository = symptomEntryRepository
    }

    public func execute(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> AllergyOverview {
        guard startDate <= endDate else {
            throw PollenDataError.invalidForecastPeriod(start: startDate, end: endDate)
        }

        async let pollenForecasts = pollenRepository.pollenForecast(for: coordinate, from: startDate, to: endDate)
        async let weatherForecasts = loadWeatherForecasts(for: coordinate, from: startDate, to: endDate)
        async let symptomEntries = symptomEntryRepository.symptomEntries(from: startDate, to: endDate)

        return try await AllergyOverview(
            coordinate: coordinate,
            pollenForecasts: pollenForecasts,
            weatherForecasts: weatherForecasts,
            symptomEntries: symptomEntries
        )
    }

    private func loadWeatherForecasts(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async -> [WeatherForecast] {
        guard let weatherRepository else {
            return []
        }

        do {
            return try await weatherRepository.weatherForecast(for: coordinate, from: startDate, to: endDate)
        } catch {
            return []
        }
    }
}
