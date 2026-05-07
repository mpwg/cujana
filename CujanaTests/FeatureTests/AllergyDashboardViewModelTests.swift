import Foundation
import Testing
@testable import Cujana

struct AllergyDashboardViewModelTests {

    @Test
    @MainActor
    func loadMapsPollenAndSymptomsIntoDashboardContent() async throws {
        let date = Date(timeIntervalSince1970: 1_800)
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let forecast = try PollenForecast(
            coordinate: coordinate,
            sourceKind: .forecast,
            generatedAt: date,
            validFrom: date,
            validUntil: date,
            dailyLevels: [
                PollenForecast.DailyLevel(date: date, pollenType: .birch, level: .high),
                PollenForecast.DailyLevel(date: date, pollenType: .grass, level: .moderate)
            ]
        )
        let symptom = try AllergySymptomEntry(
            id: UUID(uuidString: "7B4D4D42-A192-4873-8C2C-2E8103536787") ?? UUID(),
            date: date,
            symptomType: .itchyEyes,
            severity: .severe,
            note: "Abends stärker.",
            coordinate: coordinate
        )
        let viewModel = AllergyDashboardViewModel(
            loadUseCase: LoadAllergyOverviewUseCase(
                pollenRepository: StubPollenRepository(forecasts: [forecast]),
                symptomEntryRepository: StubSymptomEntryRepository(entries: [symptom])
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

        #expect(content.pollenItems.map(\.title) == ["Birke", "Gräser"])
        #expect(content.pollenItems.first?.levelText == "Hoch")
        #expect(content.symptomItems.first?.title == "Juckende Augen")
        #expect(content.symptomItems.first?.severityText == "Sehr stark")
        #expect(content.symptomItems.first?.noteText == "Abends stärker.")
    }

    @Test
    @MainActor
    func loadShowsEmptyStateWhenOverviewHasNoVisibleItems() async throws {
        let date = Date(timeIntervalSince1970: 1_800)
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let viewModel = AllergyDashboardViewModel(
            loadUseCase: LoadAllergyOverviewUseCase(
                pollenRepository: StubPollenRepository(forecasts: []),
                symptomEntryRepository: StubSymptomEntryRepository(entries: [])
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

        #expect(content.pollenItems.isEmpty)
        #expect(content.symptomItems.isEmpty)
    }

    @Test
    @MainActor
    func loadShowsFailureStateWhenUseCaseThrows() async throws {
        let date = Date(timeIntervalSince1970: 1_800)
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let viewModel = AllergyDashboardViewModel(
            loadUseCase: LoadAllergyOverviewUseCase(
                pollenRepository: FailingPollenRepository(),
                symptomEntryRepository: StubSymptomEntryRepository(entries: [])
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

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }
}

private struct StubPollenRepository: PollenRepository {
    let forecasts: [PollenForecast]

    func pollenForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [PollenForecast] {
        forecasts
    }
}

private struct FailingPollenRepository: PollenRepository {
    func pollenForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [PollenForecast] {
        throw PollenDataError.unavailable
    }
}

private struct StubSymptomEntryRepository: SymptomEntryRepository {
    let entries: [AllergySymptomEntry]

    func save(_ entry: AllergySymptomEntry) async throws {}

    func symptomEntries(from startDate: Date, to endDate: Date) async throws -> [AllergySymptomEntry] {
        entries
    }
}
