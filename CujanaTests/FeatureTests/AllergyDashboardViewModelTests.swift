import Foundation
import Testing
@testable import Cujana

struct AllergyDashboardViewModelTests {

    @Test
    func locationCoordinateCoarsensForPrivacy() throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)

        #expect(coordinate.coarsenedForPrivacy() == (try LocationCoordinate(latitude: 48.2, longitude: 16.35)))
    }

    @Test
    @MainActor
    func loadShowsLocationSpecificPollenEmptyTextWhenOnlyWeatherIsAvailable() async throws {
        let date = Date(timeIntervalSince1970: 1_800)
        let coordinate = try LocationCoordinate(latitude: 37.75, longitude: -122.4)
        let weather = dashboardWeather(date: date, coordinate: coordinate)
        let viewModel = AllergyDashboardViewModel(
            loadUseCase: LoadAllergyOverviewUseCase(
                pollenRepository: DashboardStubPollenRepository(forecasts: []),
                weatherRepository: DashboardStubWeatherRepository(forecasts: [weather]),
                symptomEntryRepository: DashboardStubSymptomEntryRepository(entries: [])
            ),
            coordinate: coordinate,
            calendar: calendar,
            now: { date }
        )

        await viewModel.load()

        guard case .loaded(let content) = viewModel.state else {
            Issue.record("Expected loaded state.")
            return
        }

        #expect(content.forecastDays.first?.pollenText == "Keine Polleninformationen für diesen Standort.")
    }

    @Test
    @MainActor
    func loadMapsPollenAndSymptomsIntoDashboardContent() async throws {
        let date = Date(timeIntervalSince1970: 1_800)
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let forecast = try dashboardForecast(date: date, coordinate: coordinate)
        let weather = dashboardWeather(date: date, coordinate: coordinate)
        let symptom = try dashboardSymptom(date: date, coordinate: coordinate)
        let viewModel = AllergyDashboardViewModel(
            loadUseCase: LoadAllergyOverviewUseCase(
                pollenRepository: DashboardStubPollenRepository(forecasts: [forecast]),
                weatherRepository: DashboardStubWeatherRepository(forecasts: [weather]),
                symptomEntryRepository: DashboardStubSymptomEntryRepository(entries: [symptom])
            ),
            coordinate: coordinate,
            calendar: calendar,
            now: { date }
        )

        await viewModel.load()

        guard case .loaded(let content) = viewModel.state else {
            Issue.record("Expected loaded state.")
            return
        }

        #expect(content.forecastDays.map(\.title) == ["Heute", "Morgen", "Übermorgen"])
        #expect(content.forecastDays.first?.temperatureText == "18°")
        #expect(content.forecastDays.first?.weatherText == "leicht bewölkt")
        #expect(content.forecastDays.first?.pollenText == "Birke: hoch")
        #expect(content.forecastDays.first?.allergenItems.map(\.title) == ["Birke", "Gräser"])
        #expect(content.forecastDays.first?.allergyRiskText == "Allergierisiko: hoch")
        #expect(content.forecastDays.first?.hourlyAllergyRiskText == "Höchster Stundenwert ab 02:00: sehr hoch")
        #expect(content.forecastDays[1].temperatureText == "21°")
        #expect(content.forecastDays[1].weatherText == "regnerisch")
        #expect(content.forecastDays[1].pollenText == "Gräser: mittel")
        #expect(content.forecastDays[1].allergenItems.map(\.title) == ["Gräser"])
        #expect(content.forecastDays[1].allergyRiskText == "Allergierisiko: mittel")
        #expect(content.forecastDays.last?.temperatureText == "19°")
        #expect(content.forecastDays.last?.weatherText == "sonnig")
        #expect(content.forecastDays.last?.allergenItems.map(\.title) == ["Beifuß"])
        #expect(content.forecastDetailDays.map(\.title) == ["Heute", "Morgen", "Übermorgen"])
        #expect(content.forecastDetailDays.first?.pollenItems.map(\.title) == ["Birke", "Gräser"])
        #expect(content.forecastDetailDays.first?.hourlyAllergyRiskItems.map(\.hourText) == ["00:00", "01:00", "02:00"])
        #expect(content.forecastDetailDays.first?.hourlyAllergyRiskItems.map(\.levelText) == [
            "Niedrig",
            "Hoch",
            "Sehr hoch"
        ])
        #expect(content.symptomItems.first?.title == "Juckende Augen")
        #expect(content.symptomItems.first?.severityText == "Sehr stark")
        #expect(content.symptomItems.first?.noteText == "Abends stärker.")
    }

    @Test
    @MainActor
    func loadShowsLoadingStateBeforeUseCaseFinishes() async throws {
        let date = Date(timeIntervalSince1970: 1_800)
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let pollenRepository = DashboardSuspendedPollenRepository()
        let viewModel = AllergyDashboardViewModel(
            loadUseCase: LoadAllergyOverviewUseCase(
                pollenRepository: pollenRepository,
                symptomEntryRepository: DashboardStubSymptomEntryRepository(entries: [])
            ),
            coordinate: coordinate,
            calendar: calendar,
            now: { date }
        )

        let loadTask = Task {
            await viewModel.load()
        }

        await pollenRepository.waitUntilRequested()
        #expect(viewModel.state == .loading)
        await pollenRepository.resume(returning: [])
        await loadTask.value
    }

    @Test
    @MainActor
    func loadShowsEmptyStateWhenOverviewHasNoVisibleItems() async throws {
        let date = Date(timeIntervalSince1970: 1_800)
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let viewModel = AllergyDashboardViewModel(
            loadUseCase: LoadAllergyOverviewUseCase(
                pollenRepository: DashboardStubPollenRepository(forecasts: []),
                symptomEntryRepository: DashboardStubSymptomEntryRepository(entries: [])
            ),
            coordinate: coordinate,
            calendar: calendar,
            now: { date }
        )

        await viewModel.load()

        guard case .empty(let content) = viewModel.state else {
            Issue.record("Expected empty state.")
            return
        }

        #expect(content.symptomItems.isEmpty)
    }

    @Test
    @MainActor
    func loadUsesCurrentLocationWhenAvailable() async throws {
        let date = Date(timeIntervalSince1970: 1_800)
        let currentCoordinate = try LocationCoordinate(latitude: 47.0707, longitude: 15.4395)
        let pollenRepository = DashboardCapturingPollenRepository()
        let viewModel = AllergyDashboardViewModel(
            loadUseCase: LoadAllergyOverviewUseCase(
                pollenRepository: pollenRepository,
                symptomEntryRepository: DashboardStubSymptomEntryRepository(entries: [])
            ),
            locationProvider: DashboardStubLocationCoordinateProvider(coordinate: currentCoordinate),
            calendar: calendar,
            now: { date }
        )

        await viewModel.load()

        #expect(await pollenRepository.requestedCoordinates() == [currentCoordinate])
    }

    @Test
    @MainActor
    func loadDoesNotUseDefaultLocationWhenCurrentLocationIsUnavailable() async throws {
        let date = Date(timeIntervalSince1970: 1_800)
        let pollenRepository = DashboardCapturingPollenRepository()
        let viewModel = AllergyDashboardViewModel(
            loadUseCase: LoadAllergyOverviewUseCase(
                pollenRepository: pollenRepository,
                symptomEntryRepository: DashboardStubSymptomEntryRepository(entries: [])
            ),
            locationProvider: DashboardStubLocationCoordinateProvider(coordinate: nil),
            calendar: calendar,
            now: { date }
        )

        await viewModel.load()

        #expect(await pollenRepository.requestedCoordinates().isEmpty)
        #expect(
            viewModel.state == .failure("Aktiviere den Standort, damit Cujana deine lokale Pollenlage anzeigen kann.")
        )
    }

    @Test
    @MainActor
    func loadKeepsOnlyTodaysTopPollenAndMostRecentSymptoms() async throws {
        let date = Date(timeIntervalSince1970: 86_400)
        let yesterday = Date(timeIntervalSince1970: 0)
        let tomorrow = Date(timeIntervalSince1970: 172_800)
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let forecast = try PollenForecast(
            coordinate: coordinate,
            sourceKind: .forecast,
            generatedAt: date,
            validFrom: yesterday,
            validUntil: tomorrow,
            dailyLevels: [
                PollenForecast.DailyLevel(date: yesterday, pollenType: .ragweed, level: .extreme),
                PollenForecast.DailyLevel(date: date, pollenType: .birch, level: .high),
                PollenForecast.DailyLevel(date: date, pollenType: .alder, level: .high),
                PollenForecast.DailyLevel(date: date, pollenType: .grass, level: .moderate),
                PollenForecast.DailyLevel(date: date, pollenType: .mugwort, level: .low),
                PollenForecast.DailyLevel(date: date, pollenType: .oak, level: .extreme),
                PollenForecast.DailyLevel(date: tomorrow, pollenType: .grass, level: .moderate)
            ]
        )
        let symptoms = try [
            symptom(date: date.addingTimeInterval(-60), type: .sneezing),
            symptom(date: date.addingTimeInterval(-120), type: .runnyNose),
            symptom(date: date.addingTimeInterval(-180), type: .blockedNose),
            symptom(date: date.addingTimeInterval(-240), type: .fatigue)
        ]
        let viewModel = AllergyDashboardViewModel(
            loadUseCase: LoadAllergyOverviewUseCase(
                pollenRepository: DashboardStubPollenRepository(forecasts: [forecast]),
                symptomEntryRepository: DashboardStubSymptomEntryRepository(entries: symptoms)
            ),
            coordinate: coordinate,
            calendar: calendar,
            now: { date }
        )

        await viewModel.load()

        guard case .loaded(let content) = viewModel.state else {
            Issue.record("Expected loaded state.")
            return
        }

        #expect(content.forecastDays.first?.allergenItems.map(\.title) == [
            "Eiche",
            "Birke",
            "Erle",
            "Gräser",
            "Beifuß"
        ])
        #expect(content.symptomItems.map(\.title) == ["Niesen", "Laufende Nase", "Verstopfte Nase"])
    }

    @Test
    @MainActor
    func loadShowsFailureStateWhenUseCaseThrows() async throws {
        let date = Date(timeIntervalSince1970: 1_800)
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let viewModel = AllergyDashboardViewModel(
            loadUseCase: LoadAllergyOverviewUseCase(
                pollenRepository: DashboardStubPollenRepository(forecasts: []),
                symptomEntryRepository: DashboardFailingSymptomEntryRepository()
            ),
            coordinate: coordinate,
            calendar: calendar,
            now: { date }
        )

        await viewModel.load()

        #expect(
            viewModel.state == .failure("Die Übersicht konnte gerade nicht geladen werden. Bitte versuche es erneut.")
        )
    }
}

private extension AllergyDashboardViewModelTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    private func dashboardForecast(date: Date, coordinate: LocationCoordinate) throws -> PollenForecast {
        try PollenForecast(
            coordinate: coordinate,
            sourceKind: .forecast,
            generatedAt: date,
            validFrom: date,
            validUntil: date.addingTimeInterval(172_800),
            dailyLevels: [
                PollenForecast.DailyLevel(date: date, pollenType: .birch, level: .high),
                PollenForecast.DailyLevel(date: date, pollenType: .grass, level: .moderate),
                PollenForecast.DailyLevel(
                    date: date.addingTimeInterval(86_400),
                    pollenType: .grass,
                    level: .moderate
                ),
                PollenForecast.DailyLevel(
                    date: date.addingTimeInterval(172_800),
                    pollenType: .mugwort,
                    level: .low
                ),
                PollenForecast.DailyLevel(
                    date: date.addingTimeInterval(172_800),
                    pollenType: .ragweed,
                    level: .none
                )
            ],
            dailyAllergyRisks: [
                PollenForecast.DailyAllergyRisk(
                    date: date,
                    level: .high,
                    hourlyLevels: [.low, .high, .veryHigh]
                ),
                PollenForecast.DailyAllergyRisk(
                    date: date.addingTimeInterval(86_400),
                    level: .moderate,
                    hourlyLevels: [.low, .moderate]
                )
            ]
        )
    }

    private func dashboardWeather(date: Date, coordinate: LocationCoordinate) -> WeatherForecast {
        WeatherForecast(
            coordinate: coordinate,
            generatedAt: date,
            dailyConditions: [
                WeatherForecast.DailyCondition(date: date, temperature: 18.4, conditionCode: 2),
                WeatherForecast.DailyCondition(
                    date: date.addingTimeInterval(86_400),
                    temperature: 21.2,
                    conditionCode: 61
                ),
                WeatherForecast.DailyCondition(
                    date: date.addingTimeInterval(172_800),
                    temperature: 19.1,
                    conditionCode: 0
                )
            ]
        )
    }

    private func dashboardSymptom(date: Date, coordinate: LocationCoordinate) throws -> AllergySymptomEntry {
        try AllergySymptomEntry(
            id: UUID(uuidString: "7B4D4D42-A192-4873-8C2C-2E8103536787") ?? UUID(),
            date: date,
            symptomType: .itchyEyes,
            severity: .severe,
            note: "Abends stärker.",
            coordinate: coordinate
        )
    }

    private func symptom(date: Date, type: SymptomType) throws -> AllergySymptomEntry {
        try AllergySymptomEntry(
            date: date,
            symptomType: type,
            severity: .moderate
        )
    }
}
