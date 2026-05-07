import Foundation
import Observation

@MainActor
@Observable
final class AllergyDashboardViewModel {
    var state = AllergyDashboardState.idle

    private enum Constant {
        static let forecastDays = 3
        static let symptomHistoryDays = 7
        static let visiblePollenCount = 4
        static let visibleSymptomCount = 3
    }

    private let loadUseCase: LoadAllergyOverviewUseCase
    private let coordinate: LocationCoordinate
    private let calendar: Calendar
    private let now: () -> Date

    init(
        loadUseCase: LoadAllergyOverviewUseCase,
        coordinate: LocationCoordinate,
        calendar: Calendar = .current,
        now: @escaping () -> Date = Date.init
    ) {
        self.loadUseCase = loadUseCase
        self.coordinate = coordinate
        self.calendar = calendar
        self.now = now
    }

    func load() async {
        state = .loading

        do {
            let currentDate = now()
            let startDate = startOfHistory(for: currentDate)
            let endDate = forecastEndDate(from: currentDate)
            let overview = try await loadUseCase.execute(
                for: coordinate,
                from: startDate,
                to: endDate
            )
            let content = makeContent(from: overview, currentDate: currentDate)

            state = content.pollenItems.isEmpty && content.symptomItems.isEmpty ? .empty(content) : .loaded(content)
        } catch {
            state = .failure("Die Übersicht konnte gerade nicht geladen werden. Bitte versuche es erneut.")
        }
    }

    private func makeContent(from overview: AllergyOverview, currentDate: Date) -> AllergyDashboardContent {
        AllergyDashboardContent(
            title: "Deine Allergie-Übersicht",
            subtitle: "Pollenlage und Symptome für Wien, ruhig zusammengefasst.",
            pollenItems: makePollenItems(from: overview.pollenForecasts, currentDate: currentDate),
            symptomItems: makeSymptomItems(from: overview.symptomEntries),
            generatedAtText: "Aktualisiert \(relativeText(for: overview.generatedAt, currentDate: currentDate))"
        )
    }

    private func makePollenItems(
        from forecasts: [PollenForecast],
        currentDate: Date
    ) -> [PollenDashboardItem] {
        forecasts
            .flatMap(\.dailyLevels)
            .filter { calendar.isDate($0.date, inSameDayAs: currentDate) }
            .sorted { first, second in
                if first.level == second.level {
                    return AllergyDashboardPresentationState.title(for: first.pollenType)
                        < AllergyDashboardPresentationState.title(for: second.pollenType)
                }

                return first.level > second.level
            }
            .prefix(Constant.visiblePollenCount)
            .map { level in
                PollenDashboardItem(
                    type: level.pollenType,
                    title: AllergyDashboardPresentationState.title(for: level.pollenType),
                    levelText: AllergyDashboardPresentationState.levelText(for: level.level),
                    levelDescription: AllergyDashboardPresentationState.levelDescription(for: level.level),
                    systemImageName: "leaf",
                    background: AllergyDashboardPresentationState.pollenBackground(for: level.level)
                )
            }
    }

    private func makeSymptomItems(from entries: [AllergySymptomEntry]) -> [SymptomDashboardItem] {
        entries
            .sorted { $0.date > $1.date }
            .prefix(Constant.visibleSymptomCount)
            .map { entry in
                SymptomDashboardItem(
                    id: entry.id,
                    title: AllergyDashboardPresentationState.title(for: entry.symptomType),
                    severityText: AllergyDashboardPresentationState.severityText(for: entry.severity),
                    dateText: dateText(for: entry.date),
                    noteText: entry.note,
                    systemImageName: systemImageName(for: entry.symptomType),
                    background: AllergyDashboardPresentationState.symptomBackground(for: entry.severity)
                )
            }
    }

    private func startOfHistory(for date: Date) -> Date {
        guard let historyDate = calendar.date(
            byAdding: .day,
            value: -Constant.symptomHistoryDays,
            to: date
        ) else {
            return date
        }

        return calendar.startOfDay(for: historyDate)
    }

    private func forecastEndDate(from date: Date) -> Date {
        guard let endDate = calendar.date(
            byAdding: .day,
            value: Constant.forecastDays,
            to: date
        ) else {
            return date
        }

        return endDate
    }

    private func dateText(for date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "Heute"
        }

        if calendar.isDateInYesterday(date) {
            return "Gestern"
        }

        return date.formatted(.dateTime.day().month(.wide))
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
