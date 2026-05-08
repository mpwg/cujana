import Foundation
import Observation

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
    private let coordinate: LocationCoordinate
    private let calendar: Calendar
    private let now: () -> Date

    init(
        loadEntriesUseCase: LoadAllergySymptomEntriesUseCase,
        loadPollenUseCase: LoadPollenForecastUseCase,
        locationProvider: (any LocationCoordinateProviding)? = nil,
        coordinate: LocationCoordinate,
        calendar: Calendar = .current,
        now: @escaping () -> Date = Date.init
    ) {
        self.loadEntriesUseCase = loadEntriesUseCase
        self.loadPollenUseCase = loadPollenUseCase
        self.locationProvider = locationProvider
        self.coordinate = coordinate
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

        let currentCoordinate = await locationProvider?.currentCoordinate() ?? coordinate
        return try await loadPollenUseCase.execute(
            for: currentCoordinate,
            from: calendar.startOfDay(for: firstDate),
            to: endOfDay(for: lastDate)
        )
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
                : "\(entries.count) Einträge mit Datum, Wetterstatus und Pollenlage.",
            items: entries.map { entry in
                makeItem(from: entry, pollenForecasts: pollenForecasts)
            },
            generatedAtText: "Aktualisiert \(relativeText(for: currentDate, currentDate: currentDate))"
        )
    }

    private func makeItem(
        from entry: AllergySymptomEntry,
        pollenForecasts: [PollenForecast]
    ) -> EntryListItem {
        EntryListItem(
            id: entry.id,
            dateText: dateText(for: entry.date),
            timeText: entry.date.formatted(.dateTime.hour().minute()),
            symptomTitle: AllergyDashboardPresentationState.title(for: entry.symptomType),
            severityText: AllergyDashboardPresentationState.severityText(for: entry.severity),
            noteText: entry.note,
            weatherTitle: "Wetterdaten",
            weatherDescription: "Noch nicht angebunden.",
            pollenItems: makePollenItems(for: entry.date, pollenForecasts: pollenForecasts),
            symptomSystemImageName: systemImageName(for: entry.symptomType),
            symptomBackground: AllergyDashboardPresentationState.symptomBackground(for: entry.severity)
        )
    }

    private func makePollenItems(
        for date: Date,
        pollenForecasts: [PollenForecast]
    ) -> [EntryListPollenItem] {
        pollenForecasts
            .flatMap(\.dailyLevels)
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { first, second in
                if first.level == second.level {
                    return AllergyDashboardPresentationState.title(for: first.pollenType)
                        < AllergyDashboardPresentationState.title(for: second.pollenType)
                }

                return first.level > second.level
            }
            .prefix(Constant.visiblePollenCount)
            .map { level in
                EntryListPollenItem(
                    type: level.pollenType,
                    title: AllergyDashboardPresentationState.title(for: level.pollenType),
                    levelText: AllergyDashboardPresentationState.levelText(for: level.level),
                    background: AllergyDashboardPresentationState.pollenBackground(for: level.level)
                )
            }
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

    private func relativeText(for date: Date, currentDate: Date) -> String {
        if calendar.isDate(date, inSameDayAs: currentDate) {
            return "heute"
        }

        return date.formatted(.dateTime.day().month(.abbreviated))
    }

    private func systemImageName(for symptomType: SymptomType) -> String {
        SymptomEntryPresentationState.symptomOptions
            .first { $0.type == symptomType }?
            .systemImageName ?? "sparkle"
    }
}
