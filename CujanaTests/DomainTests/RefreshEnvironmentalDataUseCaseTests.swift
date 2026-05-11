import Foundation
import Testing
@testable import Cujana

struct RefreshEnvironmentalDataUseCaseTests {

    @Test func refreshSavesWeatherAndPollenAsFlatEntriesWithoutSymptoms() async throws {
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

        let collection = try await useCase.execute(for: coordinate, currentDate: currentDate)

        #expect(collection?.coordinate == coordinate)
        #expect(collection?.pollenEntries.count == 1)
        #expect(collection?.pollenEntries.first?.birchLevel == .high)
        #expect(collection?.weatherEntries.count == 1)
        #expect(collection?.weatherEntries.first?.temperature == 18.4)
        #expect(try await environmentalRepository.pollenEntries() == collection?.pollenEntries)
        #expect(try await environmentalRepository.weatherEntries() == collection?.weatherEntries)
    }

    @Test func refreshSkipsSourcesThatWereRefreshedLessThanSixHoursAgo() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let previousDate = Date(timeIntervalSince1970: 1_000)
        let currentDate = previousDate.addingTimeInterval(RefreshEnvironmentalDataUseCase.minimumRefreshInterval - 60)
        let previousPollenEntry = PollenDataEntry(
            collectedAt: previousDate,
            entryDate: previousDate,
            coordinate: coordinate,
            sourceKind: .forecast,
            generatedAt: previousDate,
            validFrom: previousDate,
            validUntil: previousDate,
            rowKind: .dailyLevel
        )
        let previousWeatherEntry = WeatherDataEntry(
            collectedAt: previousDate,
            entryDate: previousDate,
            coordinate: coordinate,
            generatedAt: previousDate,
            rowKind: .daily,
            temperature: 18,
            conditionCode: 2
        )
        let environmentalRepository = StubEnvironmentalDataRepository(
            pollenEntries: [previousPollenEntry],
            weatherEntries: [previousWeatherEntry]
        )
        let useCase = RefreshEnvironmentalDataUseCase(
            pollenRepository: StubPollenRepository(forecasts: []),
            weatherRepository: StubWeatherRepository(forecasts: []),
            environmentalDataRepository: environmentalRepository
        )

        let collection = try await useCase.execute(for: coordinate, currentDate: currentDate)

        #expect(collection == nil)
        #expect(try await environmentalRepository.pollenEntries() == [previousPollenEntry])
        #expect(try await environmentalRepository.weatherEntries() == [previousWeatherEntry])
    }

    @Test func pollenAndWeatherCanRefreshIndependently() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let currentDate = Date(timeIntervalSince1970: 7_200)
        let weatherEntry = WeatherDataEntry(
            collectedAt: currentDate,
            entryDate: currentDate,
            coordinate: coordinate,
            generatedAt: currentDate,
            rowKind: .daily,
            temperature: 18,
            conditionCode: 2
        )
        let environmentalRepository = StubEnvironmentalDataRepository(weatherEntries: [weatherEntry])
        let useCase = RefreshEnvironmentalDataUseCase(
            pollenRepository: StubPollenRepository(forecasts: [try sampleForecast(coordinate: coordinate)]),
            weatherRepository: StubWeatherRepository(forecasts: []),
            environmentalDataRepository: environmentalRepository
        )

        let pollenEntries = try await useCase.refreshPollenEntries(
            for: coordinate,
            currentDate: currentDate.addingTimeInterval(60),
            force: true
        )

        #expect(pollenEntries?.isEmpty == false)
        #expect(try await environmentalRepository.weatherEntries() == [weatherEntry])
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
    private var storedPollenEntries: [PollenDataEntry]
    private var storedWeatherEntries: [WeatherDataEntry]

    init(
        pollenEntries: [PollenDataEntry] = [],
        weatherEntries: [WeatherDataEntry] = []
    ) {
        storedPollenEntries = pollenEntries
        storedWeatherEntries = weatherEntries
    }

    func latestPollenEntry(for coordinate: LocationCoordinate) async throws -> PollenDataEntry? {
        storedPollenEntries
            .filter { $0.coordinate == coordinate }
            .max { $0.collectedAt < $1.collectedAt }
    }

    func latestWeatherEntry(for coordinate: LocationCoordinate) async throws -> WeatherDataEntry? {
        storedWeatherEntries
            .filter { $0.coordinate == coordinate }
            .max { $0.collectedAt < $1.collectedAt }
    }

    func savePollenEntries(_ entries: [PollenDataEntry]) async throws {
        storedPollenEntries.append(contentsOf: entries)
    }

    func saveWeatherEntries(_ entries: [WeatherDataEntry]) async throws {
        storedWeatherEntries.append(contentsOf: entries)
    }

    func pollenEntries() async throws -> [PollenDataEntry] {
        storedPollenEntries
    }

    func weatherEntries() async throws -> [WeatherDataEntry] {
        storedWeatherEntries
    }
}
