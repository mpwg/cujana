import Foundation

nonisolated public struct EnvironmentalDataCollection: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let coordinate: LocationCoordinate
    public let collectedAt: Date
    public let pollenEntries: [PollenDataEntry]
    public let weatherEntries: [WeatherDataEntry]

    public init(
        id: UUID = UUID(),
        coordinate: LocationCoordinate,
        collectedAt: Date,
        pollenEntries: [PollenDataEntry],
        weatherEntries: [WeatherDataEntry]
    ) {
        self.id = id
        self.coordinate = coordinate
        self.collectedAt = collectedAt
        self.pollenEntries = pollenEntries
        self.weatherEntries = weatherEntries
    }

    public init(
        coordinate: LocationCoordinate,
        collectedAt: Date,
        pollenForecasts: [PollenForecast],
        weatherForecasts: [WeatherForecast]
    ) {
        self.init(
            coordinate: coordinate,
            collectedAt: collectedAt,
            pollenEntries: PollenDataEntry.entries(from: pollenForecasts, collectedAt: collectedAt),
            weatherEntries: WeatherDataEntry.entries(from: weatherForecasts, collectedAt: collectedAt)
        )
    }
}

nonisolated public struct PollenDataEntry: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let collectedAt: Date
    public let entryDate: Date
    public let coordinate: LocationCoordinate
    public let sourceKind: InformationSourceKind
    public let generatedAt: Date
    public let validFrom: Date
    public let validUntil: Date
    public let rowKind: PollenDataEntryKind
    public var alderLevel: PollenLevel?
    public var ashLevel: PollenLevel?
    public var birchLevel: PollenLevel?
    public var grassLevel: PollenLevel?
    public var hazelLevel: PollenLevel?
    public var mugwortLevel: PollenLevel?
    public var oakLevel: PollenLevel?
    public var ragweedLevel: PollenLevel?
    public var ryeLevel: PollenLevel?
    public var allergyRiskLevel: PollenLevel?
    public var allergyRiskHour0: PollenLevel?
    public var allergyRiskHour1: PollenLevel?
    public var allergyRiskHour2: PollenLevel?
    public var allergyRiskHour3: PollenLevel?
    public var allergyRiskHour4: PollenLevel?
    public var allergyRiskHour5: PollenLevel?
    public var allergyRiskHour6: PollenLevel?
    public var allergyRiskHour7: PollenLevel?
    public var allergyRiskHour8: PollenLevel?
    public var allergyRiskHour9: PollenLevel?
    public var allergyRiskHour10: PollenLevel?
    public var allergyRiskHour11: PollenLevel?
    public var allergyRiskHour12: PollenLevel?
    public var allergyRiskHour13: PollenLevel?
    public var allergyRiskHour14: PollenLevel?
    public var allergyRiskHour15: PollenLevel?
    public var allergyRiskHour16: PollenLevel?
    public var allergyRiskHour17: PollenLevel?
    public var allergyRiskHour18: PollenLevel?
    public var allergyRiskHour19: PollenLevel?
    public var allergyRiskHour20: PollenLevel?
    public var allergyRiskHour21: PollenLevel?
    public var allergyRiskHour22: PollenLevel?
    public var allergyRiskHour23: PollenLevel?

    public init(
        id: UUID = UUID(),
        collectedAt: Date,
        entryDate: Date,
        coordinate: LocationCoordinate,
        sourceKind: InformationSourceKind,
        generatedAt: Date,
        validFrom: Date,
        validUntil: Date,
        rowKind: PollenDataEntryKind
    ) {
        self.id = id
        self.collectedAt = collectedAt
        self.entryDate = entryDate
        self.coordinate = coordinate
        self.sourceKind = sourceKind
        self.generatedAt = generatedAt
        self.validFrom = validFrom
        self.validUntil = validUntil
        self.rowKind = rowKind
    }

    public mutating func setLevel(_ level: PollenLevel, for pollenType: PollenType) {
        switch pollenType {
        case .alder:
            alderLevel = level
        case .ash:
            ashLevel = level
        case .birch:
            birchLevel = level
        case .grass:
            grassLevel = level
        case .hazel:
            hazelLevel = level
        case .mugwort:
            mugwortLevel = level
        case .oak:
            oakLevel = level
        case .ragweed:
            ragweedLevel = level
        case .rye:
            ryeLevel = level
        }
    }
}

nonisolated public enum PollenDataEntryKind: String, Equatable, Sendable {
    case dailyLevel
    case hourlyLevel
    case dailyAllergyRisk
}

nonisolated public struct WeatherDataEntry: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let collectedAt: Date
    public let entryDate: Date
    public let coordinate: LocationCoordinate
    public let generatedAt: Date
    public let rowKind: WeatherDataEntryKind
    public let temperature: Double
    public let conditionCode: Int
    public let humidityPercent: Double?
    public let windSpeedKilometersPerHour: Double?

    public init(
        id: UUID = UUID(),
        collectedAt: Date,
        entryDate: Date,
        coordinate: LocationCoordinate,
        generatedAt: Date,
        rowKind: WeatherDataEntryKind,
        temperature: Double,
        conditionCode: Int,
        humidityPercent: Double? = nil,
        windSpeedKilometersPerHour: Double? = nil
    ) {
        self.id = id
        self.collectedAt = collectedAt
        self.entryDate = entryDate
        self.coordinate = coordinate
        self.generatedAt = generatedAt
        self.rowKind = rowKind
        self.temperature = temperature
        self.conditionCode = conditionCode
        self.humidityPercent = humidityPercent
        self.windSpeedKilometersPerHour = windSpeedKilometersPerHour
    }
}

nonisolated public enum WeatherDataEntryKind: String, Equatable, Sendable {
    case daily
    case hourly
}

extension PollenDataEntry {
    nonisolated static func entries(from forecasts: [PollenForecast], collectedAt: Date) -> [PollenDataEntry] {
        forecasts.flatMap { forecast in
            dailyLevelEntries(from: forecast, collectedAt: collectedAt)
                + hourlyLevelEntries(from: forecast, collectedAt: collectedAt)
                + dailyAllergyRiskEntries(from: forecast, collectedAt: collectedAt)
        }
    }

    nonisolated private static func dailyLevelEntries(
        from forecast: PollenForecast,
        collectedAt: Date
    ) -> [PollenDataEntry] {
        groupedPollenLevels(forecast.dailyLevels).map { entryDate, levels in
            var entry = makeEntry(from: forecast, collectedAt: collectedAt, entryDate: entryDate, rowKind: .dailyLevel)
            levels.forEach { entry.setLevel($0.level, for: $0.pollenType) }
            return entry
        }
    }

    nonisolated private static func hourlyLevelEntries(
        from forecast: PollenForecast,
        collectedAt: Date
    ) -> [PollenDataEntry] {
        groupedPollenLevels(forecast.hourlyLevels).map { entryDate, levels in
            var entry = makeEntry(from: forecast, collectedAt: collectedAt, entryDate: entryDate, rowKind: .hourlyLevel)
            levels.forEach { entry.setLevel($0.level, for: $0.pollenType) }
            return entry
        }
    }

    nonisolated private static func dailyAllergyRiskEntries(
        from forecast: PollenForecast,
        collectedAt: Date
    ) -> [PollenDataEntry] {
        forecast.dailyAllergyRisks.map { risk in
            var entry = makeEntry(
                from: forecast,
                collectedAt: collectedAt,
                entryDate: risk.date,
                rowKind: .dailyAllergyRisk
            )
            entry.allergyRiskLevel = risk.level
            entry.setAllergyRiskHourlyLevels(risk.hourlyLevels)
            return entry
        }
    }

    nonisolated private static func makeEntry(
        from forecast: PollenForecast,
        collectedAt: Date,
        entryDate: Date,
        rowKind: PollenDataEntryKind
    ) -> PollenDataEntry {
        PollenDataEntry(
            collectedAt: collectedAt,
            entryDate: entryDate,
            coordinate: forecast.coordinate,
            sourceKind: forecast.sourceKind,
            generatedAt: forecast.generatedAt,
            validFrom: forecast.validFrom,
            validUntil: forecast.validUntil,
            rowKind: rowKind
        )
    }

    nonisolated private static func groupedPollenLevels<T>(
        _ levels: [T]
    ) -> [(entryDate: Date, levels: [(pollenType: PollenType, level: PollenLevel)])] where T: PollenLevelEntry {
        let grouped = Dictionary(grouping: levels, by: \.date)
        return grouped
            .map { entryDate, levels in
                (
                    entryDate: entryDate,
                    levels: levels.map { (pollenType: $0.pollenType, level: $0.level) }
                )
            }
            .sorted { $0.entryDate < $1.entryDate }
    }

    nonisolated private mutating func setAllergyRiskHourlyLevels(_ levels: [PollenLevel]) {
        allergyRiskHour0 = levels[safe: 0]
        allergyRiskHour1 = levels[safe: 1]
        allergyRiskHour2 = levels[safe: 2]
        allergyRiskHour3 = levels[safe: 3]
        allergyRiskHour4 = levels[safe: 4]
        allergyRiskHour5 = levels[safe: 5]
        allergyRiskHour6 = levels[safe: 6]
        allergyRiskHour7 = levels[safe: 7]
        allergyRiskHour8 = levels[safe: 8]
        allergyRiskHour9 = levels[safe: 9]
        allergyRiskHour10 = levels[safe: 10]
        allergyRiskHour11 = levels[safe: 11]
        allergyRiskHour12 = levels[safe: 12]
        allergyRiskHour13 = levels[safe: 13]
        allergyRiskHour14 = levels[safe: 14]
        allergyRiskHour15 = levels[safe: 15]
        allergyRiskHour16 = levels[safe: 16]
        allergyRiskHour17 = levels[safe: 17]
        allergyRiskHour18 = levels[safe: 18]
        allergyRiskHour19 = levels[safe: 19]
        allergyRiskHour20 = levels[safe: 20]
        allergyRiskHour21 = levels[safe: 21]
        allergyRiskHour22 = levels[safe: 22]
        allergyRiskHour23 = levels[safe: 23]
    }
}

extension WeatherDataEntry {
    nonisolated static func entries(from forecasts: [WeatherForecast], collectedAt: Date) -> [WeatherDataEntry] {
        forecasts.flatMap { forecast in
            forecast.dailyConditions.map { condition in
                WeatherDataEntry(
                    collectedAt: collectedAt,
                    entryDate: condition.date,
                    coordinate: forecast.coordinate,
                    generatedAt: forecast.generatedAt,
                    rowKind: .daily,
                    temperature: condition.temperature,
                    conditionCode: condition.conditionCode,
                    humidityPercent: condition.humidityPercent,
                    windSpeedKilometersPerHour: condition.windSpeedKilometersPerHour
                )
            } + forecast.hourlyConditions.map { condition in
                WeatherDataEntry(
                    collectedAt: collectedAt,
                    entryDate: condition.date,
                    coordinate: forecast.coordinate,
                    generatedAt: forecast.generatedAt,
                    rowKind: .hourly,
                    temperature: condition.temperature,
                    conditionCode: condition.conditionCode,
                    humidityPercent: condition.humidityPercent,
                    windSpeedKilometersPerHour: condition.windSpeedKilometersPerHour
                )
            }
        }
    }
}

private protocol PollenLevelEntry {
    nonisolated var date: Date { get }
    nonisolated var pollenType: PollenType { get }
    nonisolated var level: PollenLevel { get }
}

extension PollenForecast.DailyLevel: PollenLevelEntry {}
extension PollenForecast.HourlyLevel: PollenLevelEntry {}

private extension Array {
    nonisolated subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
