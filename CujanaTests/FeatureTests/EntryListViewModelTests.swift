import Foundation
import Testing
@testable import Cujana

struct EntryListViewModelTests {

    @Test
    @MainActor
    func loadGroupsSymptomsByCheckInTimeWithMatchingPollenContext() async throws {
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
                symptoms: [.itchyEyes, .coughing],
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
        let viewModel = makeEntryListViewModel(
            entries: entries,
            forecasts: [forecast],
            coordinate: coordinate,
            calendar: calendar
        )

        await viewModel.load()

        guard case .loaded(let content) = viewModel.state else {
            Issue.record("Expected loaded state.")
            return
        }

        #expect(content.sections.flatMap(\.entries).count == 2)
        #expect(content.sections.first?.entries.first?.symptoms.map(\.title) == ["Juckende Augen", "Husten"])
        #expect(content.sections.first?.entries.first?.noteText == "Nach dem Park.")
        #expect(
            content.sections.first?.entries.first?.contextText
                == "Stark · Hohe Birkebelastung · Mittlere Gräserbelastung"
        )
        #expect(content.sections.last?.entries.first?.symptoms.map(\.title) == ["Verstopfte Nase"])
        #expect(content.sections.last?.entries.first?.contextText == "Mild · Sehr hohe Ragweedbelastung")
    }

    @Test
    @MainActor
    func loadShowsEmptyStateWithoutRequestingPollenWhenNoEntriesExist() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let pollenRepository = CapturingEntryListPollenRepository()
        let viewModel = EntryListViewModel(
            loadEntriesUseCase: LoadAllergySymptomEntriesUseCase(
                repository: StubEntryListSymptomRepository(entries: [])
            ),
            saveEntryUseCase: SaveAllergySymptomEntryUseCase(
                repository: StubEntryListSymptomRepository(entries: [])
            ),
            deleteEntryUseCase: DeleteAllergySymptomEntryUseCase(
                repository: StubEntryListSymptomRepository(entries: [])
            ),
            loadPollenUseCase: LoadPollenForecastUseCase(repository: pollenRepository),
            coordinate: coordinate,
            calendar: calendar
        )

        await viewModel.load()

        guard case .empty(let content) = viewModel.state else {
            Issue.record("Expected empty state.")
            return
        }

        #expect(content.sections.isEmpty)
        #expect(await pollenRepository.requestCount() == 0)
    }

    @Test
    @MainActor
    func loadKeepsEntriesButSkipsPollenWhenLocationIsUnavailable() async throws {
        let date = Date(timeIntervalSince1970: 86_400)
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let entries = try [
            symptom(seed: SymptomSeed(
                id: "F2F0C101-6F5B-4AA4-9867-66D9BA7B0483",
                date: date,
                type: .itchyEyes,
                severity: .severe,
                note: nil
            ), coordinate: coordinate)
        ]
        let pollenRepository = CapturingEntryListPollenRepository()
        let viewModel = EntryListViewModel(
            loadEntriesUseCase: LoadAllergySymptomEntriesUseCase(
                repository: StubEntryListSymptomRepository(entries: entries)
            ),
            saveEntryUseCase: SaveAllergySymptomEntryUseCase(
                repository: StubEntryListSymptomRepository(entries: entries)
            ),
            deleteEntryUseCase: DeleteAllergySymptomEntryUseCase(
                repository: StubEntryListSymptomRepository(entries: entries)
            ),
            loadPollenUseCase: LoadPollenForecastUseCase(repository: pollenRepository),
            locationProvider: StubEntryListLocationProvider(coordinate: nil),
            calendar: calendar
        )

        await viewModel.load()

        guard case .loaded(let content) = viewModel.state else {
            Issue.record("Expected loaded state.")
            return
        }

        #expect(content.sections.flatMap(\.entries).first?.symptoms.map(\.title) == ["Juckende Augen"])
        #expect(content.sections.flatMap(\.entries).first?.contextText == "Stark")
        #expect(await pollenRepository.requestCount() == 0)
    }

    @Test
    @MainActor
    func loadShowsFailureStateWhenEntriesCannotBeLoaded() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let viewModel = EntryListViewModel(
            loadEntriesUseCase: LoadAllergySymptomEntriesUseCase(
                repository: FailingEntryListSymptomRepository()
            ),
            saveEntryUseCase: SaveAllergySymptomEntryUseCase(
                repository: FailingEntryListSymptomRepository()
            ),
            deleteEntryUseCase: DeleteAllergySymptomEntryUseCase(
                repository: FailingEntryListSymptomRepository()
            ),
            loadPollenUseCase: LoadPollenForecastUseCase(
                repository: StubEntryListPollenRepository(forecasts: [])
            ),
            coordinate: coordinate,
            calendar: calendar
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
        let symptoms: [SymptomType]
        let severity: SymptomSeverity
        let note: String?

        init(
            id: String,
            date: Date,
            type: SymptomType,
            severity: SymptomSeverity,
            note: String?
        ) {
            self.id = id
            self.date = date
            self.symptoms = [type]
            self.severity = severity
            self.note = note
        }

        init(
            id: String,
            date: Date,
            symptoms: [SymptomType],
            severity: SymptomSeverity,
            note: String?
        ) {
            self.id = id
            self.date = date
            self.symptoms = symptoms
            self.severity = severity
            self.note = note
        }
    }

    private func symptom(seed: SymptomSeed, coordinate: LocationCoordinate) throws -> AllergySymptomEntry {
        try AllergySymptomEntry(
            id: UUID(uuidString: seed.id) ?? UUID(),
            date: seed.date,
            symptoms: seed.symptoms,
            severity: seed.severity,
            note: seed.note,
            coordinate: coordinate
        )
    }

    private func makeEntryListViewModel(
        entries: [AllergySymptomEntry],
        forecasts: [PollenForecast],
        coordinate: LocationCoordinate,
        calendar: Calendar
    ) -> EntryListViewModel {
        EntryListViewModel(
            loadEntriesUseCase: LoadAllergySymptomEntriesUseCase(
                repository: StubEntryListSymptomRepository(entries: entries)
            ),
            saveEntryUseCase: SaveAllergySymptomEntryUseCase(
                repository: StubEntryListSymptomRepository(entries: entries)
            ),
            deleteEntryUseCase: DeleteAllergySymptomEntryUseCase(
                repository: StubEntryListSymptomRepository(entries: entries)
            ),
            loadPollenUseCase: LoadPollenForecastUseCase(
                repository: StubEntryListPollenRepository(forecasts: forecasts)
            ),
            coordinate: coordinate,
            calendar: calendar
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

@MainActor
private final class StubEntryListLocationProvider: LocationCoordinateProviding {
    private let coordinate: LocationCoordinate?

    init(coordinate: LocationCoordinate?) {
        self.coordinate = coordinate
    }

    func currentCoordinate() async -> LocationCoordinate? {
        coordinate
    }
}
