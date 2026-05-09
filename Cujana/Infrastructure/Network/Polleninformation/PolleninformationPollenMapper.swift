import Foundation

nonisolated public enum PolleninformationPollenMapper {
    public static func map(_ dto: PolleninformationPollenResponseDTO) throws -> [PollenForecast] {
        guard let validFrom = dto.daily.dates.first, let validUntil = dto.daily.dates.last else {
            return []
        }

        let dailyLevels = dto.daily.variables.flatMap { variable in
            variable.values.enumerated().compactMap { index, rawLevel -> PollenForecast.DailyLevel? in
                guard dto.daily.dates.indices.contains(index) else {
                    return nil
                }

                return PollenForecast.DailyLevel(
                    date: dto.daily.dates[index],
                    pollenType: variable.pollenType,
                    level: PollenLevel(rawValue: rawLevel)
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
                dailyLevels: dailyLevels,
                dailyAllergyRisks: dto.dailyAllergyRisks.map { risk in
                    PollenForecast.DailyAllergyRisk(
                        date: risk.date,
                        level: allergyRiskLevel(for: risk.value),
                        hourlyLevels: risk.hourlyValues.map(allergyRiskLevel(for:))
                    )
                }
            )
        ]
    }

    private static func allergyRiskLevel(for rawValue: Int) -> PollenLevel {
        PollenLevel(rawValue: Int((Double(rawValue) / 2.0).rounded(.up)))
    }

}
