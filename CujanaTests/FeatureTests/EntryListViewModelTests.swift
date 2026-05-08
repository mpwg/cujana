import Foundation
import Testing
@testable import Cujana

struct EntryListViewModelTests {

    @Test
    @MainActor
    func loadMapsAllEntriesWithWeatherStatusAndMatchingPollen() async throws {
        let date = Date(timeIntervalSince1970: 86_400)
        let olderDate = Date(timeIntervalSince1970: 3_600)
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let entries = try [
            symptom(seed: SymptomSeed(
                id: "E03EB066-3395-4A3A-B997-DFBD00F6B830",
                date: olderDate,
                type: .blockedNose,
                severity: .mild,
                note: nil
            ), coordinate: coordinate),
            symptom(seed: SymptomSeed(
                id: "F2F0C101-6F5B-4AA4-9867-66D9BA7B0483",
                date: date,
                type: .itchyEyes,
                severity: .severe,
                note: "Nach dem Park."
            ), coordinate: coordinate)
        ]
        let forecast = try PollenForecast(
            coordinate: coordinate,
            sourceKind: .forecast,
            generatedAt: date,
            validFrom: olderDate,
            validUntil: date,
            dailyLevels: [
                PollenForecast.DailyLevel(date: olderDate, pollenType: .ragweed, level: .extreme),
                PollenForecast.DailyLevel(date: date, pollenType: .birch, level: .high),
                PollenForecast.DailyLevel(date: date, pollenType: .grass, level: .moderate)
            ]
        )
        let viewModel = EntryListViewModel(
            loadEntriesUseCase: LoadAllergySymptomEntriesUseCase(
                repository: StubEntryListSymptomRepository(entries: entries)
            ),
            loadPollenUseCase: LoadPollenForecastUseCase(
                repository: StubEntryListPollenRepository(forecasts: [forecast])
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

        #expect(content.items.map(\.symptomTitle) == ["Juckende Augen", "Verstopfte Nase"])
        #expect(content.items.first?.severityText == "Sehr stark")
        #expect(content.items.first?.noteText == "Nach dem Park.")
        #expect(content.items.first?.weatherTitle == "Wetterdaten")
        #expect(content.items.first?.weatherDescription == "Noch nicht angebunden.")
        #expect(content.items.first?.pollenItems.map(\.title) == ["Birke", "Gräser"])
        #expect(content.items.last?.pollenItems.map(\.title) == ["Ragweed"])
    }

    @Test
    @MainActor
    func loadShowsEmptyStateWithoutRequestingPollenWhenNoEntriesExist() async throws {
        let date = Date(timeIntervalSince1970: 86_400)
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let pollenRepository = CapturingEntryListPollenRepository()
        let viewModel = EntryListViewModel(
            loadEntriesUseCase: LoadAllergySymptomEntriesUseCase(
                repository: StubEntryListSymptomRepository(entries: [])
            ),
            loadPollenUseCase: LoadPollenForecastUseCase(repository: pollenRepository),
            coordinate: coordinate,
            calendar: calendar,
            now: { date }
        )

        await viewModel.load()

        guard case .empty(let content) = viewModel.state else {
            Issue.record("Expected empty state.")
            return
        }

        #expect(content.items.isEmpty)
        #expect(await pollenRepository.requestCount() == 0)
    }

    @Test
    @MainActor
    func loadShowsFailureStateWhenEntriesCannotBeLoaded() async throws {
        let date = Date(timeIntervalSince1970: 86_400)
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let viewModel = EntryListViewModel(
            loadEntriesUseCase: LoadAllergySymptomEntriesUseCase(
                repository: FailingEntryListSymptomRepository()
            ),
            loadPollenUseCase: LoadPollenForecastUseCase(
                repository: StubEntryListPollenRepository(forecasts: [])
            ),
            coordinate: coordinate,
            calendar: calendar,
            now: { date }
        )

        await viewModel.load()

        #expect(
            viewModel.state == .failure("Die Einträge konnten gerade nicht geladen werden. Bitte versuche es erneut.")
        )
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    private struct SymptomSeed {
        let id: String
        let date: Date
        let type: SymptomType
        let severity: SymptomSeverity
        let note: String?
    }

    private func symptom(seed: SymptomSeed, coordinate: LocationCoordinate) throws -> AllergySymptomEntry {
        try AllergySymptomEntry(
            id: UUID(uuidString: seed.id) ?? UUID(),
            date: seed.date,
            symptomType: seed.type,
            severity: seed.severity,
            note: seed.note,
            coordinate: coordinate
        )
    }
}

private struct StubEntryListSymptomRepository: SymptomEntryRepository {
    let entries: [AllergySymptomEntry]

    func save(_ entry: AllergySymptomEntry) async throws {}

    func symptomEntries(from startDate: Date, to endDate: Date) async throws -> [AllergySymptomEntry] {
        entries
    }
}

private struct FailingEntryListSymptomRepository: SymptomEntryRepository {
    func save(_ entry: AllergySymptomEntry) async throws {}

    func symptomEntries(from startDate: Date, to endDate: Date) async throws -> [AllergySymptomEntry] {
        throw SymptomEntryError.storageUnavailable
    }
}

private struct StubEntryListPollenRepository: PollenRepository {
    let forecasts: [PollenForecast]

    func pollenForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [PollenForecast] {
        forecasts
    }
}

private actor CapturingEntryListPollenRepository: PollenRepository {
    private var requests = 0

    func pollenForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [PollenForecast] {
        requests += 1
        return []
    }

    func requestCount() -> Int {
        requests
    }
}
