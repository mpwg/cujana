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
        let repository = InMemorySymptomEntryRepository()
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
        let symptomRepository = InMemorySymptomEntryRepository(entries: [symptomEntry])
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
    }

    @Test func loadAllergyOverviewKeepsWeatherAndSymptomsWhenPollenFails() async throws {
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
            pollenRepository: FailingPollenRepository(),
            weatherRepository: StubWeatherRepository(forecasts: [weatherForecast]),
            symptomEntryRepository: InMemorySymptomEntryRepository(entries: [symptomEntry])
        )

        let overview = try await useCase.execute(for: coordinate, from: startDate, to: endDate)

        #expect(overview.pollenForecasts.isEmpty)
        #expect(overview.weatherForecasts == [weatherForecast])
        #expect(overview.symptomEntries == [symptomEntry])
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
            symptomEntryRepository: InMemorySymptomEntryRepository()
        )

        await #expect(throws: PollenDataError.invalidForecastPeriod(start: startDate, end: endDate)) {
            _ = try await useCase.execute(for: coordinate, from: startDate, to: endDate)
        }
    }

    @Test func refreshEnvironmentalDataSavesWeatherAndPollenWithoutSymptoms() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let currentDate = Date(timeIntervalSince1970: 7_200)
        let pollenForecast = try sampleForecast(coordinate: coordinate)
        let weatherForecast = WeatherForecast(
            coordinate: coordinate,
            generatedAt: currentDate,
            dailyConditions: [],
            hourlyConditions: [
                WeatherForecast.HourlyCondition(date: currentDate, temperature: 18.4, conditionCode: 2)
            ]
        )
        let environmentalRepository = StubEnvironmentalDataRepository()
        let useCase = RefreshEnvironmentalDataUseCase(
            pollenRepository: StubPollenRepository(forecasts: [pollenForecast]),
            weatherRepository: StubWeatherRepository(forecasts: [weatherForecast]),
            environmentalDataRepository: environmentalRepository
        )

        let snapshot = try await useCase.execute(for: coordinate, currentDate: currentDate)

        #expect(snapshot?.coordinate == coordinate)
        #expect(snapshot?.pollenForecasts == [pollenForecast])
        #expect(snapshot?.weatherForecasts == [weatherForecast])
        #expect(try await environmentalRepository.latestSnapshot() == snapshot)
    }

    @Test func refreshEnvironmentalDataSkipsWhenLastSnapshotIsLessThanSixHoursOld() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let previousDate = Date(timeIntervalSince1970: 1_000)
        let currentDate = previousDate.addingTimeInterval(RefreshEnvironmentalDataUseCase.minimumRefreshInterval - 60)
        let previousSnapshot = EnvironmentalDataSnapshot(
            coordinate: coordinate,
            collectedAt: previousDate,
            pollenForecasts: [],
            weatherForecasts: []
        )
        let environmentalRepository = StubEnvironmentalDataRepository(snapshot: previousSnapshot)
        let useCase = RefreshEnvironmentalDataUseCase(
            pollenRepository: StubPollenRepository(forecasts: []),
            weatherRepository: StubWeatherRepository(forecasts: []),
            environmentalDataRepository: environmentalRepository
        )

        let snapshot = try await useCase.execute(for: coordinate, currentDate: currentDate)

        #expect(snapshot == nil)
        #expect(try await environmentalRepository.latestSnapshot() == previousSnapshot)
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

private actor StubEnvironmentalDataRepository: EnvironmentalDataRepository {
    private var snapshot: EnvironmentalDataSnapshot?

    init(snapshot: EnvironmentalDataSnapshot? = nil) {
        self.snapshot = snapshot
    }

    func latestSnapshot() async throws -> EnvironmentalDataSnapshot? {
        snapshot
    }

    func save(_ snapshot: EnvironmentalDataSnapshot) async throws {
        self.snapshot = snapshot
    }
}

private struct FailingPollenRepository: PollenRepository {
    func pollenForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [PollenForecast] {
        throw PollenDataError.decodingFailed
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

private actor InMemorySymptomEntryRepository: SymptomEntryRepository {
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
