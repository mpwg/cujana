import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class EntryListViewModel {
    var state = EntryListState.idle

    private enum Constant {
        static let visiblePollenCount = 4
        static let germanLocale = Locale(identifier: "de_AT")
    }

    private let loadEntriesUseCase: LoadAllergySymptomEntriesUseCase
    private let saveEntryUseCase: SaveAllergySymptomEntryUseCase
    private let deleteEntryUseCase: DeleteAllergySymptomEntryUseCase
    private let loadPollenUseCase: LoadPollenForecastUseCase
    private let entryChangeObserver: (any SymptomEntryChangeObserving)?
    private let entryChangePublisher: (any SymptomEntryChangePublishing)?
    private let locationProvider: (any LocationCoordinateProviding)?
    private let previewCoordinate: LocationCoordinate?
    private let calendar: Calendar
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
        withAnimation(.smooth) {
            switch change {
            case .saved(let entry):
                upsertLocal(entry)
            case .deleted(let id):
                entries.removeAll { $0.id == id }
                publishCurrentContent()
            }
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

    private func makeContent(
        entries: [AllergySymptomEntry],
        pollenForecasts: [PollenForecast]
    ) -> EntryListContent {
        EntryListContent(
            sections: makeSections(entries: entries, pollenForecasts: pollenForecasts)
        )
    }

    private func makeSections(
        entries: [AllergySymptomEntry],
        pollenForecasts: [PollenForecast]
    ) -> [EntryListDaySection] {
        let groupedByDay = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.date)
        }

        return groupedByDay.keys
            .sorted(by: >)
            .map { day in
                let entriesForDay = groupedByDay[day, default: []]
                    .sorted { $0.date > $1.date }
                    .map { entry in
                        makeItem(from: entry, pollenForecasts: pollenForecasts)
                    }

                return EntryListDaySection(
                    id: day.ISO8601Format(),
                    title: sectionTitle(for: day),
                    entries: entriesForDay
                )
            }
    }

    private func makeItem(
        from entry: HealthEntry,
        pollenForecasts: [PollenForecast]
    ) -> JournalEntryItem {
        JournalEntryItem(
            id: entry.id.uuidString,
            entry: entry,
            timeText: entry.date.formatted(.dateTime.hour().minute()),
            noteText: entry.note,
            contextText: contextText(for: entry.date, severity: entry.severity, pollenForecasts: pollenForecasts),
            contextSystemImageName: "cloud.sun",
            symptoms: entry.symptoms.map { symptom in
                JournalEntrySymptomItem(
                    type: symptom,
                    title: AllergyDashboardPresentationState.title(for: symptom),
                    background: EntryListToken.symptomBackground(for: entry.severity),
                    foreground: EntryListToken.symptomForeground(for: entry.severity)
                )
            }
        )
    }

    private func contextText(
        for date: Date,
        severity: SymptomSeverity,
        pollenForecasts: [PollenForecast]
    ) -> String {
        let pollenItems = pollenForecasts
            .flatMap(\.dailyLevels)
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .filter { $0.level.rawValue > PollenLevel.none.rawValue }
            .sorted { first, second in
                if first.level == second.level {
                    return AllergyDashboardPresentationState.title(for: first.pollenType)
                        < AllergyDashboardPresentationState.title(for: second.pollenType)
                }

                return first.level > second.level
            }
            .prefix(Constant.visiblePollenCount)
            .map { level in
                pollenContextText(for: level)
            }

        return ([severityContextText(for: severity)] + pollenItems).joined(separator: " · ")
    }

    private func endOfDay(for date: Date) -> Date {
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date)) else {
            return date
        }

        return nextDay.addingTimeInterval(-1)
    }

    private func sectionTitle(for date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "Heute"
        }

        if calendar.isDateInYesterday(date) {
            return "Gestern"
        }

        return date.formatted(
            .dateTime
                .weekday(.wide)
                .day()
                .month(.wide)
                .locale(Constant.germanLocale)
        )
    }

    private func severityContextText(for severity: SymptomSeverity) -> String {
        switch severity.rawValue {
        case 0...3:
            "Mild"
        case 4...6:
            "Mittel"
        default:
            "Stark"
        }
    }

    private func pollenContextText(for level: PollenForecast.DailyLevel) -> String {
        let title = AllergyDashboardPresentationState.title(for: level.pollenType)
        return "\(pollenContextPrefix(for: level.level)) \(title)belastung"
    }

    private func pollenContextPrefix(for level: PollenLevel) -> String {
        switch level.rawValue {
        case 1:
            "Niedrige"
        case 2:
            "Mittlere"
        case 3:
            "Hohe"
        default:
            "Sehr hohe"
        }
    }

    private func symptomSortOrder(first: SymptomType, second: SymptomType) -> Bool {
        let options = SymptomEntryPresentationState.symptomOptions
        guard let firstIndex = options.firstIndex(where: { $0.type == first }),
              let secondIndex = options.firstIndex(where: { $0.type == second }) else {
            return AllergyDashboardPresentationState.title(for: first)
                < AllergyDashboardPresentationState.title(for: second)
        }

        return firstIndex < secondIndex
    }

    private func publishCurrentContent() {
        let content = makeContent(
            entries: entries,
            pollenForecasts: pollenForecasts
        )

        state = entries.isEmpty ? .empty(content) : .loaded(content)
    }
}
