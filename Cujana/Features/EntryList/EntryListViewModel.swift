import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class EntryListViewModel {
    var state = EntryListState.idle

    private enum Constant {
        static let visiblePollenCount = 4
    }

    private let loadEntriesUseCase: LoadAllergySymptomEntriesUseCase
    private let loadPollenUseCase: LoadPollenForecastUseCase
    private let locationProvider: (any LocationCoordinateProviding)?
    private let previewCoordinate: LocationCoordinate?
    private let calendar: Calendar
    private let now: () -> Date

    init(
        loadEntriesUseCase: LoadAllergySymptomEntriesUseCase,
        loadPollenUseCase: LoadPollenForecastUseCase,
        locationProvider: (any LocationCoordinateProviding)? = nil,
        coordinate: LocationCoordinate? = nil,
        calendar: Calendar = .current,
        now: @escaping () -> Date = Date.init
    ) {
        self.loadEntriesUseCase = loadEntriesUseCase
        self.loadPollenUseCase = loadPollenUseCase
        self.locationProvider = locationProvider
        self.previewCoordinate = coordinate
        self.calendar = calendar
        self.now = now
    }

    func load() async {
        state = .loading

        do {
            let currentDate = now()
            let entries = try await loadEntriesUseCase.execute(from: .distantPast, to: .distantFuture)
                .sorted { $0.date > $1.date }

            let pollenForecasts = try await loadPollenForecasts(for: entries)
            let content = makeContent(
                entries: entries,
                pollenForecasts: pollenForecasts,
                currentDate: currentDate
            )

            state = entries.isEmpty ? .empty(content) : .loaded(content)
        } catch {
            state = .failure("Die Einträge konnten gerade nicht geladen werden. Bitte versuche es erneut.")
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
        pollenForecasts: [PollenForecast],
        currentDate: Date
    ) -> EntryListContent {
        EntryListContent(
            title: "Alle Einträge",
            subtitle: entries.isEmpty
                ? "Noch keine Symptome erfasst."
                : "\(journalEntries(from: entries).count) Check-ins nach Tagen sortiert.",
            sections: makeSections(entries: entries, pollenForecasts: pollenForecasts),
            generatedAtText: "Aktualisiert \(relativeText(for: currentDate, currentDate: currentDate))"
        )
    }

    private func makeSections(
        entries: [AllergySymptomEntry],
        pollenForecasts: [PollenForecast]
    ) -> [EntryListDaySection] {
        let journalEntries = journalEntries(from: entries)
        let groupedByDay = Dictionary(grouping: journalEntries) { entry in
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

    private func journalEntries(from entries: [AllergySymptomEntry]) -> [JournalEntry] {
        Dictionary(grouping: entries, by: \.date)
            .values
            .map { entriesAtDate in
                let sortedEntries = entriesAtDate.sorted { first, second in
                    symptomSortOrder(first: first.symptoms[0], second: second.symptoms[0])
                }
                let representativeEntry = sortedEntries[0]
                let symptoms = sortedEntries
                    .flatMap(\.symptoms)
                    .reduce(into: [SymptomType]()) { result, symptom in
                        if result.contains(symptom) == false {
                            result.append(symptom)
                        }
                    }
                    .sorted(by: symptomSortOrder)
                let note = sortedEntries.compactMap(\.note).first
                let strongestSeverity = sortedEntries.map(\.severity).max() ?? representativeEntry.severity

                return JournalEntry(
                    date: representativeEntry.date,
                    symptoms: symptoms,
                    severity: strongestSeverity,
                    note: note
                )
            }
            .sorted { $0.date > $1.date }
    }

    private func makeItem(
        from entry: JournalEntry,
        pollenForecasts: [PollenForecast]
    ) -> JournalEntryItem {
        JournalEntryItem(
            id: entry.date.ISO8601Format(),
            dateText: dateText(for: entry.date),
            timeText: entry.date.formatted(.dateTime.hour().minute()),
            severityText: AllergyDashboardPresentationState.severityText(for: entry.severity),
            noteText: entry.note,
            contextText: contextText(for: entry.date, pollenForecasts: pollenForecasts),
            contextSystemImageName: "cloud.sun",
            symptoms: entry.symptoms.map { symptom in
                JournalEntrySymptomItem(
                    type: symptom,
                    title: AllergyDashboardPresentationState.title(for: symptom),
                    background: symptomBackground(for: entry.severity)
                )
            },
            severityBackground: AllergyDashboardPresentationState.symptomBackground(for: entry.severity)
        )
    }

    private func contextText(
        for date: Date,
        pollenForecasts: [PollenForecast]
    ) -> String? {
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
                "\(pollenContextPrefix(for: level.level)) \(AllergyDashboardPresentationState.title(for: level.pollenType))belastung"
            }

        guard pollenItems.isEmpty == false else {
            return nil
        }

        return pollenItems.joined(separator: " · ")
    }

    private func endOfDay(for date: Date) -> Date {
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date)) else {
            return date
        }

        return nextDay.addingTimeInterval(-1)
    }

    private func dateText(for date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "Heute"
        }

        if calendar.isDateInYesterday(date) {
            return "Gestern"
        }

        return date.formatted(.dateTime.weekday(.abbreviated).day().month(.wide).year())
    }

    private func sectionTitle(for date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "Heute"
        }

        if calendar.isDateInYesterday(date) {
            return "Gestern"
        }

        return date.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }

    private func relativeText(for date: Date, currentDate: Date) -> String {
        if calendar.isDate(date, inSameDayAs: currentDate) {
            return "heute"
        }

        return date.formatted(.dateTime.day().month(.abbreviated))
    }

    private func symptomBackground(for severity: SymptomSeverity) -> Color {
        severity.rawValue >= SymptomSeverity.moderate.rawValue
            ? Color(hex: "#F3E8D7")
            : Color(hex: "#EEF3ED")
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

    private struct JournalEntry {
        let date: Date
        let symptoms: [SymptomType]
        let severity: SymptomSeverity
        let note: String?
    }
}
