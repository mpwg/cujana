import Foundation

nonisolated public struct LoadAllergyOverviewUseCase: Sendable {
    private let pollenRepository: any PollenRepository
    private let symptomEntryRepository: any SymptomEntryRepository

    public init(
        pollenRepository: any PollenRepository,
        symptomEntryRepository: any SymptomEntryRepository
    ) {
        self.pollenRepository = pollenRepository
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
        async let symptomEntries = symptomEntryRepository.symptomEntries(from: startDate, to: endDate)

        return try await AllergyOverview(
            coordinate: coordinate,
            pollenForecasts: pollenForecasts,
            symptomEntries: symptomEntries
        )
    }
}
