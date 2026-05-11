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
            let content = makeContent(from: overview, currentDate: currentDate)

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

    private func makeContent(from overview: AllergyOverview, currentDate: Date) -> AllergyDashboardContent {
        AllergyDashboardContent(
            title: "Deine Allergie-Übersicht",
            subtitle: "Pollenlage und Symptome für Wien, ruhig zusammengefasst.",
            forecastDays: makeForecastDays(
                weatherForecasts: overview.weatherForecasts,
                pollenForecasts: overview.pollenForecasts,
                currentDate: currentDate
            ),
            forecastDetailDays: makeForecastDetailDays(
                weatherForecasts: overview.weatherForecasts,
                pollenForecasts: overview.pollenForecasts,
                currentDate: currentDate
            ),
            symptomItems: makeSymptomItems(from: overview.symptomEntries),
            generatedAtText: "Aktualisiert \(relativeText(for: overview.generatedAt, currentDate: currentDate))"
        )
    }

    private func makeForecastDays(
        weatherForecasts: [WeatherForecast],
        pollenForecasts: [PollenForecast],
        currentDate: Date
    ) -> [ForecastDaySummaryItem] {
        let days = (0..<Constant.visibleHomeForecastDays).compactMap { dayOffset -> ForecastDaySummaryItem? in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: currentDate) else {
                return nil
            }

            let weather = weatherCondition(from: weatherForecasts, for: date)
            let allergenItems = forecastAllergenItems(from: pollenForecasts, for: date)
            let topPollen = allergenItems.first
            let allergyRisk = allergyRisk(from: pollenForecasts, for: date)
            let dayTitle = titleForForecastDay(offset: dayOffset)
            let pollenText = topPollen.map { item in
                "\(item.title): \(item.levelText.lowercased())"
            } ?? "Keine Polleninformationen für diesen Standort."
            let weatherText = weather.map {
                weatherDescription(for: $0.conditionCode)
            } ?? "Wetter noch nicht verfügbar"
            let temperatureText = weather.map { formattedTemperatureText(for: $0.temperature) } ?? "--"
            let weatherSystemImageName = weather.map {
                systemImageName(forWeatherCode: $0.conditionCode)
            } ?? "cloud.sun"
            let allergyRiskText = allergyRisk.map { risk in
                "Allergierisiko: \(shortLevelText(for: risk.level))"
            }
            let hourlyAllergyRiskText = allergyRisk.flatMap(hourlyAllergyRiskText(for:))

            return ForecastDaySummaryItem(
                id: dayTitle,
                title: dayTitle,
                temperatureText: temperatureText,
                weatherText: weatherText,
                weatherSystemImageName: weatherSystemImageName,
                allergenItems: allergenItems,
                pollenText: pollenText,
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

        return days
    }

    private func makeForecastDetailDays(
        weatherForecasts: [WeatherForecast],
        pollenForecasts: [PollenForecast],
        currentDate: Date
    ) -> [ForecastDetailDayItem] {
        (0..<Constant.visibleHomeForecastDays).compactMap { dayOffset -> ForecastDetailDayItem? in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: currentDate) else {
                return nil
            }

            let weather = weatherCondition(from: weatherForecasts, for: date)
            let hourlyWeather = hourlyWeatherConditions(from: weatherForecasts, for: date)
            let pollenItems = detailPollenItems(from: pollenForecasts, for: date)
            let allergyRisk = allergyRisk(from: pollenForecasts, for: date)

            return ForecastDetailDayItem(
                id: "day-\(dayOffset)",
                title: titleForForecastDay(offset: dayOffset),
                temperatureText: weather.map { formattedTemperatureText(for: $0.temperature) } ?? "--",
                weatherText: weather.map {
                    weatherDescription(for: $0.conditionCode)
                } ?? "Wetter aktuell nicht verfügbar",
                weatherSystemImageName: weather.map {
                    systemImageName(forWeatherCode: $0.conditionCode)
                } ?? "cloud.sun",
                humidityText: weather.flatMap { formattedHumidityText(for: $0.humidityPercent) },
                windText: weather.flatMap { formattedWindText(for: $0.windSpeedKilometersPerHour) },
                pollenItems: pollenItems,
                allergyRiskText: allergyRisk.map { "Allergierisiko: \(shortLevelText(for: $0.level))" },
                hourlyAllergyRiskItems: allergyRisk.map {
                    hourlyAllergyRiskItems(for: $0, hourlyWeather: hourlyWeather, fallbackWeather: weather)
                } ?? []
            )
        }
    }
}

private extension AllergyDashboardViewModel {
    private func weatherCondition(
        from forecasts: [WeatherForecast],
        for date: Date
    ) -> WeatherForecast.DailyCondition? {
        forecasts.flatMap(\.dailyConditions).first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func allergyRisk(
        from forecasts: [PollenForecast],
        for date: Date
    ) -> PollenForecast.DailyAllergyRisk? {
        forecasts.flatMap(\.dailyAllergyRisks).first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func hourlyWeatherConditions(
        from forecasts: [WeatherForecast],
        for date: Date
    ) -> [WeatherForecast.HourlyCondition] {
        forecasts.flatMap(\.hourlyConditions).filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func hourlyAllergyRiskText(for risk: PollenForecast.DailyAllergyRisk) -> String? {
        guard let peak = risk.hourlyLevels.enumerated().max(by: { $0.element < $1.element }) else {
            return nil
        }

        let hourText = String(format: "%02d:00", peak.offset)
        return "Höchster Stundenwert ab \(hourText): \(shortLevelText(for: peak.element))"
    }

    private func hourlyAllergyRiskItems(
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

    private func forecastAllergenItems(
        from forecasts: [PollenForecast],
        for date: Date
    ) -> [ForecastDayAllergenItem] {
        sortedRelevantDailyLevels(from: forecasts, for: date).map { level in
            ForecastDayAllergenItem(
                type: level.pollenType,
                title: AllergyDashboardPresentationState.title(for: level.pollenType),
                levelText: AllergyDashboardPresentationState.levelText(for: level.level),
                background: AllergyDashboardPresentationState.pollenBackground(for: level.level)
            )
        }
    }

    private func sortedRelevantDailyLevels(
        from forecasts: [PollenForecast],
        for date: Date
    ) -> [PollenForecast.DailyLevel] {
        forecasts
            .flatMap(\.dailyLevels)
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .filter { isRelevantPollenLevel($0.level) }
            .sorted { first, second in
                if first.level == second.level {
                    return AllergyDashboardPresentationState.title(for: first.pollenType)
                        < AllergyDashboardPresentationState.title(for: second.pollenType)
                }

                return first.level > second.level
            }
    }

    private func isRelevantPollenLevel(_ level: PollenLevel) -> Bool {
        level.rawValue > PollenLevel.none.rawValue
    }

    private func allergenAccessibilityText(for items: [ForecastDayAllergenItem]) -> String {
        guard items.isEmpty == false else {
            return "Keine relevante Belastung"
        }

        return items
            .map { "\($0.title), \($0.levelText)" }
            .joined(separator: ", ")
    }

    private func titleForForecastDay(offset: Int) -> String {
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

    private func shortLevelText(for level: PollenLevel) -> String {
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

    private func formattedTemperatureText(for temperature: Double) -> String {
        "\(Int(temperature.rounded()))°"
    }

    private func formattedHumidityText(for humidityPercent: Double?) -> String? {
        humidityPercent.map { "\(Int($0.rounded()))%" }
    }

    private func formattedWindText(for windSpeedKilometersPerHour: Double?) -> String? {
        windSpeedKilometersPerHour.map { "\(Int($0.rounded())) km/h" }
    }

    private func weatherDescription(for code: Int) -> String {
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

    private func systemImageName(forWeatherCode code: Int) -> String {
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

    private func detailPollenItems(
        from forecasts: [PollenForecast],
        for date: Date
    ) -> [ForecastDetailPollenItem] {
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
            .map { level in
                ForecastDetailPollenItem(
                    type: level.pollenType,
                    title: AllergyDashboardPresentationState.title(for: level.pollenType),
                    levelText: AllergyDashboardPresentationState.levelText(for: level.level),
                    levelDescription: AllergyDashboardPresentationState.levelDescription(for: level.level),
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
                    title: symptomTitle(for: entry.symptoms),
                    severityText: AllergyDashboardPresentationState.severityText(for: entry.severity),
                    dateText: dateText(for: entry.date),
                    noteText: entry.note,
                    systemImageName: systemImageName(for: entry.symptoms[0]),
                    background: AllergyDashboardPresentationState.symptomBackground(for: entry.severity)
                )
            }
    }

    private func symptomTitle(for symptoms: [SymptomType]) -> String {
        let titles = symptoms.map { AllergyDashboardPresentationState.title(for: $0) }
        return titles.count > 2 ? "\(titles[0]), \(titles[1]) +\(titles.count - 2)" : titles.joined(separator: ", ")
    }

    private func startOfHistory(for date: Date) -> Date {
        let historyDate = calendar.date(byAdding: .day, value: -Constant.symptomHistoryDays, to: date) ?? date
        return calendar.startOfDay(for: historyDate)
    }

    private func forecastEndDate(from date: Date) -> Date {
        calendar.date(byAdding: .day, value: Constant.forecastDays, to: date) ?? date
    }

    private func dateText(for date: Date) -> String {
        if calendar.isDateInToday(date) { return "Heute" }
        if calendar.isDateInYesterday(date) { return "Gestern" }
        return date.formatted(.dateTime.day().month(.wide))
    }

    private func relativeText(for date: Date, currentDate: Date) -> String {
        if calendar.isDate(date, inSameDayAs: currentDate) { return "heute" }
        return date.formatted(.dateTime.day().month(.abbreviated))
    }

    private func systemImageName(for symptomType: SymptomType) -> String {
        SymptomEntryPresentationState.symptomOptions.first { $0.type == symptomType }?.systemImageName ?? "sparkle"
    }
}
