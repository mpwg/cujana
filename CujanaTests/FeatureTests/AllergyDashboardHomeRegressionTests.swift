import Foundation
import Testing
@testable import Cujana

struct AllergyDashboardHomeRegressionTests {

    @Test
    @MainActor
    func loadFiltersNoLoadLevelsFromHomeOverview() async throws {
        let date = Date(timeIntervalSince1970: 1_800)
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let forecast = try forecast(
            date: date,
            coordinate: coordinate,
            dailyLevels: [
                PollenForecast.DailyLevel(date: date, pollenType: .birch, level: .none),
                PollenForecast.DailyLevel(date: date, pollenType: .grass, level: .high),
                PollenForecast.DailyLevel(date: date, pollenType: .mugwort, level: .moderate),
                PollenForecast.DailyLevel(date: date, pollenType: .hazel, level: .low)
            ]
        )
        let viewModel = viewModel(date: date, coordinate: coordinate, pollenForecasts: [forecast])

        await viewModel.load()

        guard case .loaded(let content) = viewModel.state else {
            Issue.record("Expected loaded state.")
            return
        }

        #expect(content.forecastDays.first?.allergenItems.map(\.title) == ["Gräser", "Beifuß", "Hasel"])
        #expect(content.forecastDays.first?.allergenItems.map(\.levelText) == ["Hoch", "Mittel", "Niedrig"])
        #expect(content.forecastDays.first?.allergenItems.contains { $0.levelText == "Keine Belastung" } == false)
    }

    @Test
    @MainActor
    func loadShowsEmptyAllergenStateWhenOnlyNoLoadLevelsExist() async throws {
        let date = Date(timeIntervalSince1970: 1_800)
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let forecast = try forecast(
            date: date,
            coordinate: coordinate,
            dailyLevels: [
                PollenForecast.DailyLevel(date: date, pollenType: .birch, level: .none),
                PollenForecast.DailyLevel(date: date, pollenType: .grass, level: .none)
            ]
        )
        let weather = WeatherForecast(
            coordinate: coordinate,
            generatedAt: date,
            dailyConditions: [
                WeatherForecast.DailyCondition(date: date, temperature: 18.4, conditionCode: 2)
            ]
        )
        let viewModel = viewModel(
            date: date,
            coordinate: coordinate,
            pollenForecasts: [forecast],
            weatherForecasts: [weather]
        )

        await viewModel.load()

        guard case .loaded(let content) = viewModel.state else {
            Issue.record("Expected loaded state.")
            return
        }

        #expect(content.forecastDays.first?.allergenItems.isEmpty == true)
        #expect(content.forecastDays.first?.accessibilityText.contains("Keine relevante Belastung") == true)
    }

    @Test
    @MainActor
    func loadUsesReadableHomeWeatherFallbackWhenDailyWeatherIsMissing() async throws {
        let date = Date(timeIntervalSince1970: 1_800)
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let forecast = try forecast(
            date: date,
            coordinate: coordinate,
            dailyLevels: [
                PollenForecast.DailyLevel(date: date, pollenType: .grass, level: .high)
            ]
        )
        let viewModel = viewModel(
            date: date,
            coordinate: coordinate,
            pollenForecasts: [forecast],
            weatherForecasts: []
        )

        await viewModel.load()

        guard case .loaded(let content) = viewModel.state else {
            Issue.record("Expected loaded state.")
            return
        }

        #expect(content.forecastDays.first?.temperatureText == "--")
        #expect(content.forecastDays.first?.weatherText == "Wetter noch nicht verfügbar")
        #expect(content.forecastDays.first?.accessibilityText.contains("--,") == false)
    }
}

private extension AllergyDashboardHomeRegressionTests {
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    func forecast(
        date: Date,
        coordinate: LocationCoordinate,
        dailyLevels: [PollenForecast.DailyLevel]
    ) throws -> PollenForecast {
        try PollenForecast(
            coordinate: coordinate,
            sourceKind: .forecast,
            generatedAt: date,
            validFrom: date,
            validUntil: date.addingTimeInterval(86_400),
            dailyLevels: dailyLevels
        )
    }

    @MainActor
    func viewModel(
        date: Date,
        coordinate: LocationCoordinate,
        pollenForecasts: [PollenForecast],
        weatherForecasts: [WeatherForecast] = []
    ) -> AllergyDashboardViewModel {
        AllergyDashboardViewModel(
            loadUseCase: LoadAllergyOverviewUseCase(
                pollenRepository: DashboardStubPollenRepository(forecasts: pollenForecasts),
                weatherRepository: DashboardStubWeatherRepository(forecasts: weatherForecasts),
                symptomEntryRepository: DashboardStubSymptomEntryRepository(entries: [])
            ),
            coordinate: coordinate,
            calendar: calendar,
            now: { date }
        )
    }
}
