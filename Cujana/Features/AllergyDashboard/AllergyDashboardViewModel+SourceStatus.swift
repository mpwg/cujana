import Foundation

@MainActor
extension AllergyDashboardViewModel {
    func unavailableText(
        for source: AllergyOverviewSource,
        in sourceStatuses: [AllergyOverviewSourceStatus],
        fallback: String
    ) -> String {
        guard sourceStatuses.first(where: { $0.source == source })?.state.isDegraded == true else {
            return fallback
        }

        switch source {
        case .pollen:
            return "Pollendaten gerade nicht verfügbar."
        case .weather:
            return "Wetterdaten gerade nicht verfügbar."
        }
    }

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

    func weatherDescription(for code: Int) -> String {
        switch code {
        case 0:
            "sonnig"
        case 1:
            "überwiegend klar"
        case 2:
            "leicht bewölkt"
        case 3:
            "bewölkt"
        case 45, 48:
            "neblig"
        case 51, 53, 55, 56, 57:
            "leichter Nieselregen"
        case 61, 63, 65, 66, 67, 80, 81, 82:
            "regnerisch"
        case 71, 73, 75, 77, 85, 86:
            "Schnee"
        case 95, 96, 99:
            "Gewitter möglich"
        default:
            "mild"
        }
    }

    func systemImageName(forWeatherCode code: Int) -> String {
        switch code {
        case 0, 1:
            "sun.max"
        case 2:
            "cloud.sun"
        case 3:
            "cloud"
        case 45, 48:
            "cloud.fog"
        case 51, 53, 55, 56, 57:
            "cloud.drizzle"
        case 61, 63, 65, 66, 67, 80, 81, 82:
            "cloud.rain"
        case 71, 73, 75, 77, 85, 86:
            "cloud.snow"
        case 95, 96, 99:
            "cloud.bolt.rain"
        default:
            "cloud.sun"
        }
    }
}
