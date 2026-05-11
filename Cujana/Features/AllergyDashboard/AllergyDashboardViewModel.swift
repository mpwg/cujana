import Foundation
import Observation

@MainActor
@Observable
final class AllergyDashboardViewModel {
    var state = AllergyDashboardState.idle

    private enum Constant {
        static let forecastDays = 3
        static let symptomHistoryDays = 7
        static let visibleSymptomCount = 3
        static let visibleHomeForecastDays = 3
    }

    private let loadUseCase: LoadAllergyOverviewUseCase
    private let locationProvider: (any LocationCoordinateProviding)?
    private let previewCoordinate: LocationCoordinate?
    private let calendar: Calendar
    private let contentMapper: AllergyDashboardContentMapper
    private let now: () -> Date

    init(
        loadUseCase: LoadAllergyOverviewUseCase,
        locationProvider: (any LocationCoordinateProviding)? = nil,
        coordinate: LocationCoordinate? = nil,
        calendar: Calendar = .current,
        now: @escaping () -> Date = Date.init
    ) {
        self.loadUseCase = loadUseCase
        self.locationProvider = locationProvider
        self.previewCoordinate = coordinate
        self.calendar = calendar
        self.contentMapper = AllergyDashboardContentMapper(calendar: calendar)
        self.now = now
    }

    func load() async {
        state = .loading

        do {
            let currentDate = now()
            let startDate = startOfHistory(for: currentDate)
            let endDate = forecastEndDate(from: currentDate)
            guard let currentCoordinate = await currentCoordinate() else {
                AppObservability.log(
                    .warning,
                    "Allergie-Übersicht ohne Standort abgebrochen.",
                    category: "AllergyDashboard"
                )
                state = .failure("Aktiviere den Standort, damit Cujana deine lokale Pollenlage anzeigen kann.")
                return
            }

            let overview = try await AppObservability.trace(
                name: "Allergie-Übersicht laden",
                operation: "dashboard.load",
                category: "AllergyDashboard"
            ) {
                try await loadUseCase.execute(
                    for: currentCoordinate,
                    from: startDate,
                    to: endDate
                )
            }
            let content = contentMapper.makeContent(from: overview, currentDate: currentDate)

            logDegradedSources(overview.sourceStatuses)
            state = content.hasOverviewData ? .loaded(content) : .empty(content)
        } catch {
            AppObservability.log(
                .error,
                "Allergie-Übersicht konnte nicht geladen werden.",
                category: "AllergyDashboard",
                metadata: ["error": String(describing: error)]
            )
            state = .failure("Die Übersicht konnte gerade nicht geladen werden. Bitte versuche es erneut.")
        }
    }

    private func currentCoordinate() async -> LocationCoordinate? {
        guard let locationProvider else { return previewCoordinate }
        return await locationProvider.currentCoordinate()
    }

}

private extension AllergyDashboardViewModel {
    private func startOfHistory(for date: Date) -> Date {
        let historyDate = calendar.date(byAdding: .day, value: -Constant.symptomHistoryDays, to: date) ?? date
        return calendar.startOfDay(for: historyDate)
    }

    private func forecastEndDate(from date: Date) -> Date {
        calendar.date(byAdding: .day, value: Constant.forecastDays, to: date) ?? date
    }
}
