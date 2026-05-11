import Foundation
import Observation

@MainActor
@Observable
final class EntryListViewModel {
    var state = EntryListState.idle

    private let loadEntriesUseCase: LoadAllergySymptomEntriesUseCase
    private let saveEntryUseCase: SaveAllergySymptomEntryUseCase
    private let deleteEntryUseCase: DeleteAllergySymptomEntryUseCase
    private let loadPollenUseCase: LoadPollenForecastUseCase
    private let entryChangeObserver: (any SymptomEntryChangeObserving)?
    private let entryChangePublisher: (any SymptomEntryChangePublishing)?
    private let locationProvider: (any LocationCoordinateProviding)?
    private let previewCoordinate: LocationCoordinate?
    private let calendar: Calendar
    private let contentMapper: EntryListContentMapper
    private var entries: [HealthEntry] = []
    private var pollenForecasts: [PollenForecast] = []

    init(
        loadEntriesUseCase: LoadAllergySymptomEntriesUseCase,
        saveEntryUseCase: SaveAllergySymptomEntryUseCase,
        deleteEntryUseCase: DeleteAllergySymptomEntryUseCase,
        loadPollenUseCase: LoadPollenForecastUseCase,
        entryChangeObserver: (any SymptomEntryChangeObserving)? = nil,
        entryChangePublisher: (any SymptomEntryChangePublishing)? = nil,
        locationProvider: (any LocationCoordinateProviding)? = nil,
        coordinate: LocationCoordinate? = nil,
        calendar: Calendar = .current
    ) {
        self.loadEntriesUseCase = loadEntriesUseCase
        self.saveEntryUseCase = saveEntryUseCase
        self.deleteEntryUseCase = deleteEntryUseCase
        self.loadPollenUseCase = loadPollenUseCase
        self.entryChangeObserver = entryChangeObserver
        self.entryChangePublisher = entryChangePublisher
        self.locationProvider = locationProvider
        self.previewCoordinate = coordinate
        self.calendar = calendar
        self.contentMapper = EntryListContentMapper(calendar: calendar)
    }

    func load() async {
        state = .loading

        do {
            entries = try await loadEntriesUseCase.execute(from: .distantPast, to: .distantFuture)
                .sorted { $0.date > $1.date }

            pollenForecasts = try await loadPollenForecasts(for: entries)
            publishCurrentContent()
        } catch {
            state = .failure("Die Einträge konnten gerade nicht geladen werden. Bitte versuche es erneut.")
        }
    }

    func observeEntryChanges() async {
        guard let entryChangeObserver else {
            return
        }

        for await change in entryChangeObserver.changes {
            apply(change)
        }
    }

    func makeEditorViewModel(for entry: HealthEntry) -> EntryEditorViewModel {
        EntryEditorViewModel(
            saveUseCase: saveEntryUseCase,
            entryChangePublisher: entryChangePublisher,
            mode: .edit(existing: entry)
        )
    }

    func upsertLocal(_ entry: HealthEntry) {
        if let existingIndex = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[existingIndex] = entry
        } else {
            entries.append(entry)
        }

        entries.sort { $0.date > $1.date }
        publishCurrentContent()
    }

    func delete(_ entry: HealthEntry) async {
        do {
            try await deleteEntryUseCase.execute(id: entry.id)
            entryChangePublisher?.publish(.deleted(entry.id))
        } catch {
            state = .failure("Die Einträge konnten gerade nicht geladen werden. Bitte versuche es erneut.")
        }
    }

    private func apply(_ change: SymptomEntryChange) {
        switch change {
        case .saved(let entry):
            upsertLocal(entry)
        case .deleted(let id):
            entries.removeAll { $0.id == id }
            publishCurrentContent()
        }
    }

    private func loadPollenForecasts(for entries: [AllergySymptomEntry]) async throws -> [PollenForecast] {
        guard
            let firstDate = entries.map(\.date).min(),
            let lastDate = entries.map(\.date).max()
        else {
            return []
        }

        guard let currentCoordinate = await currentCoordinate() else {
            return []
        }

        return try await loadPollenUseCase.execute(
            for: currentCoordinate,
            from: calendar.startOfDay(for: firstDate),
            to: endOfDay(for: lastDate)
        )
    }

    private func currentCoordinate() async -> LocationCoordinate? {
        if let locationProvider {
            return await locationProvider.currentCoordinate()
        }

        return previewCoordinate
    }

    private func endOfDay(for date: Date) -> Date {
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date)) else {
            return date
        }

        return nextDay.addingTimeInterval(-1)
    }

    private func publishCurrentContent() {
        let content = contentMapper.makeContent(
            entries: entries,
            pollenForecasts: pollenForecasts
        )

        state = entries.isEmpty ? .empty(content) : .loaded(content)
    }
}
