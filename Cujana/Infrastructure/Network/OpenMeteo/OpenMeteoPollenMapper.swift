import Foundation

nonisolated public enum OpenMeteoPollenMapper {
    public static func map(_ dto: OpenMeteoPollenResponseDTO) throws -> [PollenForecast] {
        guard let validFrom = dto.daily.dates.first, let validUntil = dto.daily.dates.last else {
            return []
        }

        let dailyLevels = dto.daily.variables.flatMap { variable in
            variable.values.enumerated().compactMap { index, concentration -> PollenForecast.DailyLevel? in
                guard dto.daily.dates.indices.contains(index) else {
                    return nil
                }

                return PollenForecast.DailyLevel(
                    date: dto.daily.dates[index],
                    pollenType: variable.pollenType,
                    level: level(for: concentration)
                )
            }
        }

        return [
            try PollenForecast(
                coordinate: dto.coordinate,
                sourceKind: .forecast,
                generatedAt: dto.generatedAt,
                validFrom: validFrom,
                validUntil: validUntil,
                dailyLevels: dailyLevels
            )
        ]
    }

    private static func level(for concentration: Float) -> PollenLevel {
        switch concentration {
        case ..<1:
            return .none
        case ..<10:
            return .low
        case ..<50:
            return .moderate
        case ..<100:
            return .high
        case ..<200:
            return .veryHigh
        default:
            return .extreme
        }
    }
}
