import Foundation

struct AllergyDashboardContentMapper {
    private enum Constant {
        static let visibleHomeForecastDays = 3
        static let visibleSymptomCount = 3
    }

    private let calendar: Calendar

    init(calendar: Calendar) {
        self.calendar = calendar
    }

    func makeContent(from overview: AllergyOverview, currentDate: Date) -> AllergyDashboardContent {
        AllergyDashboardContent(
            title: "Deine Allergie-Übersicht",
            subtitle: "Pollenlage und Symptome für Wien, ruhig zusammengefasst.",
            forecastDays: makeForecastDays(from: overview, currentDate: currentDate),
            forecastDetailDays: makeForecastDetailDays(from: overview, currentDate: currentDate),
            symptomItems: makeSymptomItems(from: overview.symptomEntries),
            sourceStatuses: overview.sourceStatuses,
            generatedAtText: "Aktualisiert \(relativeText(for: overview.generatedAt, currentDate: currentDate))"
        )
    }
}

private extension AllergyDashboardContentMapper {
    func makeForecastDays(from overview: AllergyOverview, currentDate: Date) -> [ForecastDaySummaryItem] {
        forecastDates(from: currentDate).map { item in
            makeForecastDaySummaryItem(
                dayOffset: item.offset,
                date: item.date,
                overview: overview
            )
        }
    }

    func makeForecastDaySummaryItem(
        dayOffset: Int,
        date: Date,
        overview: AllergyOverview
    ) -> ForecastDaySummaryItem {
        let weather = weatherCondition(from: overview.weatherForecasts, for: date)
        let allergenItems = forecastAllergenItems(from: overview.pollenForecasts, for: date)
        let allergyRisk = allergyRisk(from: overview.pollenForecasts, for: date)
        let dayTitle = titleForForecastDay(offset: dayOffset)
        let temperatureText = weather.map { formattedTemperatureText(for: $0.temperature) } ?? "--"
        let weatherText = forecastWeatherText(for: weather, sourceStatuses: overview.sourceStatuses)
        let allergyRiskText = allergyRisk.map { "Allergierisiko: \(shortLevelText(for: $0.level))" }
        let hourlyAllergyRiskText = allergyRisk.flatMap(hourlyAllergyRiskText(for:))

        return ForecastDaySummaryItem(
            id: dayTitle,
            title: dayTitle,
            temperatureText: temperatureText,
            weatherText: weatherText,
            weatherSystemImageName: weather.map { systemImageName(forWeatherCode: $0.conditionCode) } ?? "cloud.sun",
            allergenItems: allergenItems,
            pollenText: forecastPollenText(for: allergenItems, sourceStatuses: overview.sourceStatuses),
            allergyRiskText: allergyRiskText,
            hourlyAllergyRiskText: hourlyAllergyRiskText,
            accessibilityText: [
                dayTitle,
                temperatureText == "--" ? weatherText : "\(temperatureText), \(weatherText)",
                allergenAccessibilityText(for: allergenItems),
                allergyRiskText,
                hourlyAllergyRiskText
            ]
            .compactMap(\.self)
            .joined(separator: ", ")
        )
    }

    func makeForecastDetailDays(from overview: AllergyOverview, currentDate: Date) -> [ForecastDetailDayItem] {
        forecastDates(from: currentDate).map { item in
            makeForecastDetailDayItem(
                dayOffset: item.offset,
                date: item.date,
                overview: overview
            )
        }
    }

    func makeForecastDetailDayItem(
        dayOffset: Int,
        date: Date,
        overview: AllergyOverview
    ) -> ForecastDetailDayItem {
        let weather = weatherCondition(from: overview.weatherForecasts, for: date)
        let hourlyWeather = hourlyWeatherConditions(from: overview.weatherForecasts, for: date)
        let allergyRisk = allergyRisk(from: overview.pollenForecasts, for: date)

        return ForecastDetailDayItem(
            id: "day-\(dayOffset)",
            title: titleForForecastDay(offset: dayOffset),
            temperatureText: weather.map { formattedTemperatureText(for: $0.temperature) } ?? "--",
            weatherText: detailWeatherText(for: weather, sourceStatuses: overview.sourceStatuses),
            weatherSystemImageName: weather.map { systemImageName(forWeatherCode: $0.conditionCode) } ?? "cloud.sun",
            humidityText: weather.flatMap { formattedHumidityText(for: $0.humidityPercent) },
            windText: weather.flatMap { formattedWindText(for: $0.windSpeedKilometersPerHour) },
            pollenItems: detailPollenItems(from: overview.pollenForecasts, for: date),
            allergyRiskText: allergyRisk.map { "Allergierisiko: \(shortLevelText(for: $0.level))" },
            hourlyAllergyRiskItems: allergyRisk.map {
                hourlyAllergyRiskItems(for: $0, hourlyWeather: hourlyWeather, fallbackWeather: weather)
            } ?? []
        )
    }

    func forecastDates(from currentDate: Date) -> [(offset: Int, date: Date)] {
        (0..<Constant.visibleHomeForecastDays).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: currentDate).map {
                (offset: dayOffset, date: $0)
            }
        }
    }

    func forecastPollenText(
        for allergenItems: [ForecastDayAllergenItem],
        sourceStatuses: [AllergyOverviewSourceStatus]
    ) -> String {
        allergenItems.first.map { "\($0.title): \($0.levelText.lowercased())" }
            ?? unavailableText(
                for: .pollen,
                in: sourceStatuses,
                fallback: "Keine Polleninformationen für diesen Standort."
            )
    }

    func forecastWeatherText(
        for weather: WeatherForecast.DailyCondition?,
        sourceStatuses: [AllergyOverviewSourceStatus]
    ) -> String {
        weather.map { weatherDescription(for: $0.conditionCode) }
            ?? unavailableText(for: .weather, in: sourceStatuses, fallback: "Wetter noch nicht verfügbar")
    }

    func detailWeatherText(
        for weather: WeatherForecast.DailyCondition?,
        sourceStatuses: [AllergyOverviewSourceStatus]
    ) -> String {
        weather.map { weatherDescription(for: $0.conditionCode) }
            ?? unavailableText(for: .weather, in: sourceStatuses, fallback: "Wetter aktuell nicht verfügbar")
    }

    func weatherCondition(from forecasts: [WeatherForecast], for date: Date) -> WeatherForecast.DailyCondition? {
        forecasts.flatMap(\.dailyConditions).first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func allergyRisk(from forecasts: [PollenForecast], for date: Date) -> PollenForecast.DailyAllergyRisk? {
        forecasts.flatMap(\.dailyAllergyRisks).first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func hourlyWeatherConditions(
        from forecasts: [WeatherForecast],
        for date: Date
    ) -> [WeatherForecast.HourlyCondition] {
        forecasts.flatMap(\.hourlyConditions).filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func forecastAllergenItems(from forecasts: [PollenForecast], for date: Date) -> [ForecastDayAllergenItem] {
        sortedDailyLevels(from: forecasts, for: date)
            .filter { $0.level.rawValue > PollenLevel.none.rawValue }
            .map { level in
                ForecastDayAllergenItem(
                    type: level.pollenType,
                    title: AllergyDashboardPresentationState.title(for: level.pollenType),
                    levelText: AllergyDashboardPresentationState.levelText(for: level.level),
                    background: AllergyDashboardPresentationState.pollenBackground(for: level.level)
                )
            }
    }

    func detailPollenItems(from forecasts: [PollenForecast], for date: Date) -> [ForecastDetailPollenItem] {
        sortedDailyLevels(from: forecasts, for: date).map { level in
            ForecastDetailPollenItem(
                type: level.pollenType,
                title: AllergyDashboardPresentationState.title(for: level.pollenType),
                levelText: AllergyDashboardPresentationState.levelText(for: level.level),
                levelDescription: AllergyDashboardPresentationState.levelDescription(for: level.level),
                background: AllergyDashboardPresentationState.pollenBackground(for: level.level)
            )
        }
    }

    func sortedDailyLevels(from forecasts: [PollenForecast], for date: Date) -> [PollenForecast.DailyLevel] {
        forecasts
            .flatMap(\.dailyLevels)
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { first, second in
                if first.level == second.level {
                    return AllergyDashboardPresentationState.title(for: first.pollenType)
                        < AllergyDashboardPresentationState.title(for: second.pollenType)
                }

                return first.level > second.level
            }
    }

    func hourlyAllergyRiskText(for risk: PollenForecast.DailyAllergyRisk) -> String? {
        guard let peak = risk.hourlyLevels.enumerated().max(by: { $0.element < $1.element }) else {
            return nil
        }

        let hourText = String(format: "%02d:00", peak.offset)
        return "Höchster Stundenwert ab \(hourText): \(shortLevelText(for: peak.element))"
    }

    func hourlyAllergyRiskItems(
        for risk: PollenForecast.DailyAllergyRisk,
        hourlyWeather: [WeatherForecast.HourlyCondition],
        fallbackWeather: WeatherForecast.DailyCondition?
    ) -> [ForecastDetailHourlyRiskItem] {
        risk.hourlyLevels.enumerated().map { hour, level in
            let weather = hourlyWeather.first { calendar.component(.hour, from: $0.date) == hour }
            let temperatureText = weather.map { formattedTemperatureText(for: $0.temperature) }
                ?? fallbackWeather.map { formattedTemperatureText(for: $0.temperature) }
                ?? "--"
            return ForecastDetailHourlyRiskItem(
                hour: hour,
                hourText: String(format: "%02d:00", hour),
                levelText: AllergyDashboardPresentationState.levelText(for: level),
                temperatureText: temperatureText,
                background: AllergyDashboardPresentationState.pollenBackground(for: level)
            )
        }
    }

    func makeSymptomItems(from entries: [AllergySymptomEntry]) -> [SymptomDashboardItem] {
        entries
            .sorted { $0.date > $1.date }
            .prefix(Constant.visibleSymptomCount)
            .map { entry in
                SymptomDashboardItem(
                    id: entry.id,
                    title: symptomTitle(for: entry.symptoms),
                    severityText: AllergyDashboardPresentationState.severityText(for: entry.severity),
                    dateText: dateText(for: entry.date),
                    noteText: entry.note,
                    systemImageName: systemImageName(for: entry.symptoms[0]),
                    background: AllergyDashboardPresentationState.symptomBackground(for: entry.severity)
                )
            }
    }

    func symptomTitle(for symptoms: [SymptomType]) -> String {
        let titles = symptoms.map { AllergyDashboardPresentationState.title(for: $0) }
        return titles.count > 2 ? "\(titles[0]), \(titles[1]) +\(titles.count - 2)" : titles.joined(separator: ", ")
    }

    func allergenAccessibilityText(for items: [ForecastDayAllergenItem]) -> String {
        guard items.isEmpty == false else {
            return "Keine relevante Belastung"
        }

        return items.map { "\($0.title), \($0.levelText)" }.joined(separator: ", ")
    }

    func titleForForecastDay(offset: Int) -> String {
        switch offset {
        case 0:
            "Heute"
        case 1:
            "Morgen"
        case 2:
            "Übermorgen"
        default:
            "Tag \(offset + 1)"
        }
    }

    func dateText(for date: Date) -> String {
        if calendar.isDateInToday(date) { return "Heute" }
        if calendar.isDateInYesterday(date) { return "Gestern" }
        return date.formatted(.dateTime.day().month(.wide))
    }

    func relativeText(for date: Date, currentDate: Date) -> String {
        if calendar.isDate(date, inSameDayAs: currentDate) { return "heute" }
        return date.formatted(.dateTime.day().month(.abbreviated))
    }

    func shortLevelText(for level: PollenLevel) -> String {
        switch level.rawValue {
        case 0:
            "keine"
        case 1:
            "niedrig"
        case 2:
            "mittel"
        case 3:
            "hoch"
        default:
            "sehr hoch"
        }
    }

    func formattedTemperatureText(for temperature: Double) -> String {
        "\(Int(temperature.rounded()))°"
    }

    func formattedHumidityText(for humidityPercent: Double?) -> String? {
        humidityPercent.map { "\(Int($0.rounded()))%" }
    }

    func formattedWindText(for windSpeedKilometersPerHour: Double?) -> String? {
        windSpeedKilometersPerHour.map { "\(Int($0.rounded())) km/h" }
    }

    func systemImageName(for symptomType: SymptomType) -> String {
        SymptomEntryPresentationState.symptomOptions.first { $0.type == symptomType }?.systemImageName ?? "sparkle"
    }

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
