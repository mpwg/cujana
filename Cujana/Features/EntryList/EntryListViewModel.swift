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
    private let loadPollenUseCase: LoadPollenForecastUseCase
    private let locationProvider: (any LocationCoordinateProviding)?
    private let previewCoordinate: LocationCoordinate?
    private let calendar: Calendar

    init(
        loadEntriesUseCase: LoadAllergySymptomEntriesUseCase,
        loadPollenUseCase: LoadPollenForecastUseCase,
        locationProvider: (any LocationCoordinateProviding)? = nil,
        coordinate: LocationCoordinate? = nil,
        calendar: Calendar = .current
    ) {
        self.loadEntriesUseCase = loadEntriesUseCase
        self.loadPollenUseCase = loadPollenUseCase
        self.locationProvider = locationProvider
        self.previewCoordinate = coordinate
        self.calendar = calendar
    }

    func load() async {
        state = .loading

        do {
            let entries = try await loadEntriesUseCase.execute(from: .distantPast, to: .distantFuture)
                .sorted { $0.date > $1.date }

            let pollenForecasts = try await loadPollenForecasts(for: entries)
            let content = makeContent(
                entries: entries,
                pollenForecasts: pollenForecasts
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

    private struct JournalEntry {
        let date: Date
        let symptoms: [SymptomType]
        let severity: SymptomSeverity
        let note: String?
    }
}
