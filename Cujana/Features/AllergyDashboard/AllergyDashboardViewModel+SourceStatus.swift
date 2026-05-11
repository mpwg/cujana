import Foundation

extension AllergyDashboardViewModel {
    func logDegradedSources(_ sourceStatuses: [AllergyOverviewSourceStatus]) {
        sourceStatuses.forEach { sourceStatus in
            guard case .unavailable(let category) = sourceStatus.state else {
                return
            }

            AppObservability.log(
                .warning,
                "Datenquelle konnte nicht geladen werden.",
                category: "AllergyDashboard",
                metadata: [
                    "source": sourceStatus.source.rawValue,
                    "errorCategory": category.rawValue
                ]
            )
        }
    }
}
