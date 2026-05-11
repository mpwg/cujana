import Foundation
import Testing
@testable import Cujana

struct AllergyDomainTests {

    @Test func locationCoordinateAcceptsBoundaryValues() throws {
        let coordinate = try LocationCoordinate(latitude: -90, longitude: 180)

        #expect(coordinate.latitude == -90)
        #expect(coordinate.longitude == 180)
    }

    @Test func locationCoordinateRejectsOutOfRangeValues() {
        #expect(throws: PollenDataError.invalidCoordinate(latitude: 91, longitude: 16)) {
            _ = try LocationCoordinate(latitude: 91, longitude: 16)
        }
    }

    @Test func pollenLevelClampsToSupportedRange() {
        #expect(PollenLevel(rawValue: -3) == .none)
        #expect(PollenLevel(rawValue: 99) == .extreme)
    }

    @Test func symptomSeverityClampsToSupportedRange() {
        #expect(SymptomSeverity(rawValue: -4) == .none)
        #expect(SymptomSeverity(rawValue: 42) == .severe)
    }

    @Test func pollenForecastRejectsInvalidDateRange() throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let startDate = Date(timeIntervalSince1970: 1_800)
        let endDate = Date(timeIntervalSince1970: 900)

        #expect(throws: PollenDataError.invalidForecastPeriod(start: startDate, end: endDate)) {
            _ = try PollenForecast(
                coordinate: coordinate,
                sourceKind: .forecast,
                generatedAt: Date(timeIntervalSince1970: 0),
                validFrom: startDate,
                validUntil: endDate,
                dailyLevels: []
            )
        }
    }

    @Test func pollenForecastCanStoreHourlyAllergenLevelsIndependentlyFromSymptoms() throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let startDate = Date(timeIntervalSince1970: 0)
        let hourDate = Date(timeIntervalSince1970: 3_600)
        let hourlyLevel = PollenForecast.HourlyLevel(
            date: hourDate,
            pollenType: .birch,
            level: .high
        )
        let symptomEntry = try AllergySymptomEntry(
            date: Date(timeIntervalSince1970: 5_400),
            symptoms: [.itchyEyes],
            severity: .moderate
        )

        let forecast = try PollenForecast(
            coordinate: coordinate,
            sourceKind: .forecast,
            generatedAt: startDate,
            validFrom: startDate,
            validUntil: Date(timeIntervalSince1970: 86_400),
            dailyLevels: [],
            hourlyLevels: [hourlyLevel]
        )

        #expect(forecast.hourlyLevels == [hourlyLevel])
        #expect(forecast.hourlyLevels.first?.date == hourDate)
        #expect(symptomEntry.date != forecast.hourlyLevels.first?.date)
    }

    @Test func weatherForecastCanStoreHourlyConditionsIndependentlyFromSymptoms() throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let hourDate = Date(timeIntervalSince1970: 3_600)
        let hourlyCondition = WeatherForecast.HourlyCondition(
            date: hourDate,
            temperature: 18.4,
            conditionCode: 2,
            humidityPercent: 58,
            windSpeedKilometersPerHour: 12
        )
        let symptomEntry = try AllergySymptomEntry(
            date: Date(timeIntervalSince1970: 5_400),
            symptoms: [.sneezing],
            severity: .mild
        )

        let forecast = WeatherForecast(
            coordinate: coordinate,
            generatedAt: Date(timeIntervalSince1970: 0),
            dailyConditions: [],
            hourlyConditions: [hourlyCondition]
        )

        #expect(forecast.hourlyConditions == [hourlyCondition])
        #expect(forecast.hourlyConditions.first?.date == hourDate)
        #expect(symptomEntry.date != forecast.hourlyConditions.first?.date)
    }

    @Test func symptomEntryNormalizesBlankNote() throws {
        let entry = try AllergySymptomEntry(
            date: Date(timeIntervalSince1970: 0),
            symptoms: [.itchyEyes],
            severity: .moderate,
            note: "   \n  "
        )

        #expect(entry.note == nil)
    }

    @Test func symptomEntryStoresMultipleSymptomsAsOneCheckIn() throws {
        let date = Date(timeIntervalSince1970: 0)
        let entry = try AllergySymptomEntry(date: date, symptoms: [.sneezing, .itchyEyes], severity: .moderate)

        #expect(entry.symptoms == [.sneezing, .itchyEyes])
    }

    @Test func symptomEntryRejectsEmptySymptoms() {
        #expect(throws: SymptomEntryError.emptySymptoms) {
            _ = try AllergySymptomEntry(date: Date(timeIntervalSince1970: 0), symptoms: [], severity: .mild)
        }
    }

    @Test func symptomEntryRejectsTooLongNote() {
        let note = String(repeating: "a", count: AllergySymptomEntry.maximumNoteLength + 1)

        #expect(throws: SymptomEntryError.noteTooLong(maxLength: AllergySymptomEntry.maximumNoteLength)) {
            _ = try AllergySymptomEntry(
                date: Date(timeIntervalSince1970: 0),
                symptoms: [.sneezing],
                severity: .mild,
                note: note
            )
        }
    }

    @Test func loadPollenForecastUseCaseDelegatesToRepository() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let forecast = try sampleForecast(coordinate: coordinate)
        let repository = StubPollenRepository(forecasts: [forecast])
        let useCase = LoadPollenForecastUseCase(repository: repository)

        let result = try await useCase.execute(
            for: coordinate,
            from: forecast.validFrom,
            to: forecast.validUntil
        )

        #expect(result == [forecast])
    }

    @Test func loadPollenForecastRejectsInvalidDateRangeBeforeCallingRepository() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let startDate = Date(timeIntervalSince1970: 2_000)
        let endDate = Date(timeIntervalSince1970: 1_000)
        let repository = StubPollenRepository(forecasts: [])
        let useCase = LoadPollenForecastUseCase(repository: repository)

        await #expect(throws: PollenDataError.invalidForecastPeriod(start: startDate, end: endDate)) {
            _ = try await useCase.execute(for: coordinate, from: startDate, to: endDate)
        }
    }

    @Test func saveAndLoadSymptomEntriesUseCasesUseRepositoryBoundary() async throws {
        let repository = TestSymptomEntryRepository()
        let saveUseCase = SaveAllergySymptomEntryUseCase(repository: repository)
        let loadUseCase = LoadAllergySymptomEntriesUseCase(repository: repository)
        let entry = try AllergySymptomEntry(
            date: Date(timeIntervalSince1970: 1_000),
            symptoms: [.runnyNose],
            severity: .mild
        )

        try await saveUseCase.execute(entry)
        let entries = try await loadUseCase.execute(
            from: Date(timeIntervalSince1970: 0),
            to: Date(timeIntervalSince1970: 2_000)
        )

        #expect(entries == [entry])
    }

    @Test func loadAllergyOverviewCombinesForecastAndSymptoms() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let forecast = try sampleForecast(coordinate: coordinate)
        let weatherForecast = WeatherForecast(
            coordinate: coordinate,
            generatedAt: forecast.generatedAt,
            dailyConditions: [
                WeatherForecast.DailyCondition(date: forecast.validFrom, temperature: 18, conditionCode: 2)
            ]
        )
        let symptomEntry = try AllergySymptomEntry(
            date: forecast.validFrom,
            symptoms: [.wateryEyes],
            severity: .severe,
            coordinate: coordinate
        )
        let pollenRepository = StubPollenRepository(forecasts: [forecast])
        let symptomRepository = TestSymptomEntryRepository(entries: [symptomEntry])
        let useCase = LoadAllergyOverviewUseCase(
            pollenRepository: pollenRepository,
            weatherRepository: StubWeatherRepository(forecasts: [weatherForecast]),
            symptomEntryRepository: symptomRepository
        )

        let overview = try await useCase.execute(
            for: coordinate,
            from: forecast.validFrom,
            to: forecast.validUntil
        )

        #expect(overview.coordinate == coordinate)
        #expect(overview.pollenForecasts == [forecast])
        #expect(overview.weatherForecasts == [weatherForecast])
        #expect(overview.symptomEntries == [symptomEntry])
        #expect(overview.sourceStatuses == [
            AllergyOverviewSourceStatus(source: .pollen, state: .available),
            AllergyOverviewSourceStatus(source: .weather, state: .available)
        ])
    }

    @Test func loadAllergyOverviewMarksPollenNoDataWhenRepositoryReturnsEmptyForecasts() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let startDate = Date(timeIntervalSince1970: 0)
        let endDate = Date(timeIntervalSince1970: 86_400)
        let useCase = LoadAllergyOverviewUseCase(
            pollenRepository: StubPollenRepository(forecasts: []),
            symptomEntryRepository: TestSymptomEntryRepository()
        )

        let overview = try await useCase.execute(for: coordinate, from: startDate, to: endDate)

        #expect(overview.pollenForecasts.isEmpty)
        #expect(overview.sourceStatuses.contains(AllergyOverviewSourceStatus(source: .pollen, state: .noData)))
    }

    @Test func loadAllergyOverviewKeepsWeatherAndSymptomsWhenPollenNetworkFails() async throws {
        let coordinate = try LocationCoordinate(latitude: 37.75, longitude: -122.4)
        let startDate = Date(timeIntervalSince1970: 0)
        let endDate = Date(timeIntervalSince1970: 86_400)
        let weatherForecast = WeatherForecast(
            coordinate: coordinate,
            generatedAt: startDate,
            dailyConditions: [
                WeatherForecast.DailyCondition(date: startDate, temperature: 18, conditionCode: 2)
            ]
        )
        let symptomEntry = try AllergySymptomEntry(
            date: startDate,
            symptoms: [.wateryEyes],
            severity: .severe,
            coordinate: coordinate
        )
        let useCase = LoadAllergyOverviewUseCase(
            pollenRepository: FailingPollenRepository(error: PollenDataError.networkFailure),
            weatherRepository: StubWeatherRepository(forecasts: [weatherForecast]),
            symptomEntryRepository: TestSymptomEntryRepository(entries: [symptomEntry])
        )

        let overview = try await useCase.execute(for: coordinate, from: startDate, to: endDate)

        #expect(overview.pollenForecasts.isEmpty)
        #expect(overview.weatherForecasts == [weatherForecast])
        #expect(overview.symptomEntries == [symptomEntry])
        #expect(
            overview.sourceStatuses.contains(
                AllergyOverviewSourceStatus(source: .pollen, state: .unavailable(.network))
            )
        )
    }

    @Test func loadAllergyOverviewMarksDecodingFailureWithoutDroppingOtherSources() async throws {
        let coordinate = try LocationCoordinate(latitude: 37.75, longitude: -122.4)
        let startDate = Date(timeIntervalSince1970: 0)
        let endDate = Date(timeIntervalSince1970: 86_400)
        let useCase = LoadAllergyOverviewUseCase(
            pollenRepository: FailingPollenRepository(error: PollenDataError.decodingFailed),
            weatherRepository: FailingWeatherRepository(error: PollenDataError.apiFailure(reason: "WeatherKit")),
            symptomEntryRepository: TestSymptomEntryRepository()
        )

        let overview = try await useCase.execute(for: coordinate, from: startDate, to: endDate)

        #expect(overview.pollenForecasts.isEmpty)
        #expect(overview.weatherForecasts.isEmpty)
        #expect(
            overview.sourceStatuses.contains(
                AllergyOverviewSourceStatus(source: .pollen, state: .unavailable(.decoding))
            )
        )
        #expect(
            overview.sourceStatuses.contains(
                AllergyOverviewSourceStatus(source: .weather, state: .unavailable(.api))
            )
        )
    }

    @Test func loadAllergyOverviewStillThrowsWhenSymptomsCannotLoad() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let startDate = Date(timeIntervalSince1970: 0)
        let endDate = Date(timeIntervalSince1970: 86_400)
        let useCase = LoadAllergyOverviewUseCase(
            pollenRepository: StubPollenRepository(forecasts: []),
            symptomEntryRepository: FailingSymptomEntryRepository()
        )

        await #expect(throws: SymptomEntryError.storageUnavailable) {
            _ = try await useCase.execute(for: coordinate, from: startDate, to: endDate)
        }
    }

    @Test func loadAllergyOverviewRejectsInvalidDateRange() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let startDate = Date(timeIntervalSince1970: 2_000)
        let endDate = Date(timeIntervalSince1970: 1_000)
        let useCase = LoadAllergyOverviewUseCase(
            pollenRepository: StubPollenRepository(forecasts: []),
            symptomEntryRepository: TestSymptomEntryRepository()
        )

        await #expect(throws: PollenDataError.invalidForecastPeriod(start: startDate, end: endDate)) {
            _ = try await useCase.execute(for: coordinate, from: startDate, to: endDate)
        }
    }

    private func sampleForecast(coordinate: LocationCoordinate) throws -> PollenForecast {
        let validFrom = Date(timeIntervalSince1970: 0)
        let validUntil = Date(timeIntervalSince1970: 86_400)

        return try PollenForecast(
            coordinate: coordinate,
            sourceKind: .forecast,
            generatedAt: validFrom,
            validFrom: validFrom,
            validUntil: validUntil,
            dailyLevels: [
                PollenForecast.DailyLevel(
                    date: validFrom,
                    pollenType: .birch,
                    level: .high
                )
            ]
        )
    }
}

private struct StubPollenRepository: PollenRepository {
    let forecasts: [PollenForecast]

    func pollenForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [PollenForecast] {
        forecasts.filter { forecast in
            forecast.coordinate == coordinate
                && forecast.validFrom >= startDate
                && forecast.validUntil <= endDate
        }
    }
}

private struct StubWeatherRepository: WeatherRepository {
    let forecasts: [WeatherForecast]

    func weatherForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [WeatherForecast] {
        forecasts.filter { forecast in
            forecast.coordinate == coordinate
        }
    }
}

private struct FailingPollenRepository: PollenRepository {
    let error: any Error

    func pollenForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [PollenForecast] {
        throw error
    }
}

private struct FailingWeatherRepository: WeatherRepository {
    let error: any Error

    func weatherForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [WeatherForecast] {
        throw error
    }
}

private struct FailingSymptomEntryRepository: SymptomEntryRepository {
    func save(_ entry: AllergySymptomEntry) async throws {
        throw SymptomEntryError.storageUnavailable
    }

    func symptomEntries(from startDate: Date, to endDate: Date) async throws -> [AllergySymptomEntry] {
        throw SymptomEntryError.storageUnavailable
    }
}

private actor TestSymptomEntryRepository: SymptomEntryRepository {
    private var entries: [AllergySymptomEntry]

    init(entries: [AllergySymptomEntry] = []) {
        self.entries = entries
    }

    func save(_ entry: AllergySymptomEntry) async throws {
        entries.append(entry)
    }

    func symptomEntries(from startDate: Date, to endDate: Date) async throws -> [AllergySymptomEntry] {
        entries.filter { entry in
            entry.date >= startDate && entry.date <= endDate
        }
    }
}
