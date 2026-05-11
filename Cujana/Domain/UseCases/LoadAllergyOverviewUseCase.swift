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

        async let pollenResult = loadPollenForecasts(for: coordinate, from: startDate, to: endDate)
        async let weatherResult = loadWeatherForecasts(for: coordinate, from: startDate, to: endDate)
        async let symptomEntries = symptomEntryRepository.symptomEntries(from: startDate, to: endDate)

        let loadedPollenResult = await pollenResult
        let loadedWeatherResult = await weatherResult

        return try await AllergyOverview(
            coordinate: coordinate,
            pollenForecasts: loadedPollenResult.forecasts,
            weatherForecasts: loadedWeatherResult.forecasts,
            symptomEntries: symptomEntries,
            sourceStatuses: [
                loadedPollenResult.sourceStatus,
                loadedWeatherResult.sourceStatus
            ]
        )
    }

    private func loadWeatherForecasts(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async -> ForecastSourceResult<WeatherForecast> {
        guard let weatherRepository else {
            return ForecastSourceResult(
                forecasts: [],
                sourceStatus: AllergyOverviewSourceStatus(source: .weather, state: .noData)
            )
        }

        do {
            let forecasts = try await weatherRepository.weatherForecast(for: coordinate, from: startDate, to: endDate)
            return ForecastSourceResult(forecasts: forecasts, source: .weather)
        } catch {
            return ForecastSourceResult(forecasts: [], source: .weather, error: error)
        }
    }

    private func loadPollenForecasts(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async -> ForecastSourceResult<PollenForecast> {
        do {
            let forecasts = try await pollenRepository.pollenForecast(for: coordinate, from: startDate, to: endDate)
            return ForecastSourceResult(forecasts: forecasts, source: .pollen)
        } catch {
            return ForecastSourceResult(forecasts: [], source: .pollen, error: error)
        }
    }
}

nonisolated private struct ForecastSourceResult<Forecast>: Sendable where Forecast: Sendable {
    let forecasts: [Forecast]
    let sourceStatus: AllergyOverviewSourceStatus

    init(forecasts: [Forecast], source: AllergyOverviewSource) {
        self.forecasts = forecasts
        self.sourceStatus = AllergyOverviewSourceStatus(
            source: source,
            state: forecasts.isEmpty ? .noData : .available
        )
    }

    init(forecasts: [Forecast], source: AllergyOverviewSource, error: any Error) {
        self.forecasts = forecasts
        self.sourceStatus = AllergyOverviewSourceStatus(
            source: source,
            state: .unavailable(AllergyOverviewSourceErrorCategory(error: error))
        )
    }

    init(forecasts: [Forecast], sourceStatus: AllergyOverviewSourceStatus) {
        self.forecasts = forecasts
        self.sourceStatus = sourceStatus
    }
}
