import Foundation
import polleninformation

nonisolated public protocol PolleninformationPollenAPIClient: Sendable {
    func pollenResponse(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> PolleninformationPollenResponseDTO
}

nonisolated protocol PolleninformationForecastLoading: Sendable {
    func forecast(
        country: CountryCode,
        language: LanguageCode,
        latitude: Double,
        longitude: Double
    ) async throws -> ForecastResponse
}

extension PolleninformationClient: PolleninformationForecastLoading {}

nonisolated struct PolleninformationResponseContext: Sendable {
    let coordinate: LocationCoordinate
    let country: CountryCode
    let language: LanguageCode
    let calendar: Calendar
    let generatedAt: Date
    let startDate: Date
    let endDate: Date
}

nonisolated public struct PolleninformationURLSessionClient: PolleninformationPollenAPIClient {
    private let apiKey: String?
    private let country: CountryCode
    private let language: LanguageCode
    private let calendar: Calendar
    private let now: @Sendable () -> Date

    public init(
        apiKey: String? = Self.defaultAPIKey(),
        country: CountryCode = .austria,
        language: LanguageCode = .german,
        calendar: Calendar = Calendar(identifier: .gregorian),
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.apiKey = apiKey
        self.country = country
        self.language = language
        self.calendar = calendar
        self.now = now
    }

    public func pollenResponse(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> PolleninformationPollenResponseDTO {
        guard let apiKey, !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            AppObservability.log(
                .warning,
                "Polleninformation API-Key fehlt.",
                category: "Polleninformation"
            )
            throw PollenDataError.unavailable
        }

        let client = PolleninformationClient(apiKey: apiKey)
        return try await Self.makeResponse(
            client: client,
            context: PolleninformationResponseContext(
                coordinate: coordinate,
                country: country,
                language: language,
                calendar: calendar,
                generatedAt: now(),
                startDate: startDate,
                endDate: endDate
            )
        )
    }

    static func makeResponse(
        client: any PolleninformationForecastLoading,
        context: PolleninformationResponseContext
    ) async throws -> PolleninformationPollenResponseDTO {
        try await AppObservability.trace(
            name: "Polleninformation API Forecast",
            operation: "http.client",
            category: "Polleninformation",
            metadata: [
                "country": context.country.rawValue,
                "language": context.language.rawValue
            ]
        ) {
            do {
                let forecast = try await client.forecast(
                    country: context.country,
                    language: context.language,
                    latitude: context.coordinate.latitude,
                    longitude: context.coordinate.longitude
                )

                AppObservability.log(
                    .info,
                    "Polleninformation API Forecast geladen.",
                    category: "Polleninformation",
                    metadata: ["contaminationCount": "\(forecast.contamination.count)"]
                )
                return try map(
                    forecast,
                    context: context
                )
            } catch let error as PollenDataError {
                throw error
            } catch let error as PolleninformationError {
                if Self.isMissingLocationPayload(error) {
                    AppObservability.log(
                        .info,
                        "Keine Polleninformationen für diesen Standort.",
                        category: "Polleninformation",
                        metadata: [
                            "latitude": String(format: "%.2f", context.coordinate.latitude),
                            "longitude": String(format: "%.2f", context.coordinate.longitude)
                        ]
                    )
                    return emptyResponse(context: context)
                }
                throw map(error)
            } catch {
                throw PollenDataError.networkFailure
            }
        }
    }

    private static func emptyResponse(
        context: PolleninformationResponseContext
    ) -> PolleninformationPollenResponseDTO {
        let allDates = forecastDates(generatedAt: context.generatedAt, calendar: context.calendar)
        let dates = allDates
            .filter { date in
                context.calendar.compare(date, to: context.startDate, toGranularity: .day) != .orderedAscending
                    && context.calendar.compare(date, to: context.endDate, toGranularity: .day) != .orderedDescending
            }

        return PolleninformationPollenResponseDTO(
            coordinate: context.coordinate,
            generatedAt: context.generatedAt,
            daily: PolleninformationPollenResponseDTO.Daily(
                dates: dates,
                variables: []
            ),
            dailyAllergyRisks: []
        )
    }

    static func map(
        _ forecast: ForecastResponse,
        context: PolleninformationResponseContext
    ) throws -> PolleninformationPollenResponseDTO {
        let allDates = forecastDates(generatedAt: context.generatedAt, calendar: context.calendar)
        let dates = allDates
            .filter { date in
                context.calendar.compare(date, to: context.startDate, toGranularity: .day) != .orderedAscending
                    && context.calendar.compare(date, to: context.endDate, toGranularity: .day) != .orderedDescending
            }

        let dateOffsets = dates.compactMap { date in
            allDates.firstIndex(of: date)
        }

        let variables = try forecast.contamination.compactMap { contamination
            -> PolleninformationPollenResponseDTO.DailyVariable? in
            guard let pollenType = pollenType(for: contamination) else {
                return nil
            }

            return PolleninformationPollenResponseDTO.DailyVariable(
                pollenType: pollenType,
                values: try values(
                    from: contamination.dailyValues,
                    offsets: dateOffsets,
                    fieldName: "contamination.dailyValues"
                )
            )
        }
        let allergyRiskValues = try values(
            from: forecast.allergyRisk.dailyValues,
            offsets: dateOffsets,
            fieldName: "allergyRisk.dailyValues"
        )
        let hourlyAllergyRiskValues = try values(
            from: forecast.hourlyAllergyRisk.dailyValues,
            offsets: dateOffsets,
            fieldName: "hourlyAllergyRisk.dailyValues"
        )
        let dailyAllergyRisks = zip(dates, zip(allergyRiskValues, hourlyAllergyRiskValues)).map { date, risk in
            PolleninformationPollenResponseDTO.DailyAllergyRisk(
                date: date,
                value: risk.0,
                hourlyValues: risk.1
            )
        }

        return PolleninformationPollenResponseDTO(
            coordinate: context.coordinate,
            generatedAt: context.generatedAt,
            daily: PolleninformationPollenResponseDTO.Daily(
                dates: dates,
                variables: variables
            ),
            dailyAllergyRisks: dailyAllergyRisks
        )
    }

    private static func forecastDates(generatedAt: Date, calendar: Calendar) -> [Date] {
        let firstDate = calendar.startOfDay(for: generatedAt)
        return (0..<4).compactMap { calendar.date(byAdding: .day, value: $0, to: firstDate) }
    }

    static func values<Value>(
        from source: [Value],
        offsets: [Int],
        fieldName: String
    ) throws -> [Value] {
        try offsets.map { offset in
            guard source.indices.contains(offset) else {
                AppObservability.log(
                    .error,
                    "Polleninformation API-Payload enthält zu wenige Tageswerte.",
                    category: "Polleninformation",
                    metadata: [
                        "field": fieldName,
                        "offset": "\(offset)",
                        "count": "\(source.count)"
                    ]
                )
                throw PollenDataError.decodingFailed
            }

            return source[offset]
        }
    }

    private static func pollenType(for contamination: PollenContamination) -> PollenType? {
        let title = contamination.pollTitle.folding(
            options: [.caseInsensitive, .diacriticInsensitive],
            locale: .current
        )

        if title.contains("erle") || title.contains("alder") {
            return .alder
        }
        if title.contains("esche") || title.contains("ash") {
            return .ash
        }
        if title.contains("birke") || title.contains("birch") {
            return .birch
        }
        if title.contains("gras") || title.contains("grass") {
            return .grass
        }
        if title.contains("hasel") || title.contains("hazel") {
            return .hazel
        }
        if title.contains("beifuss") || title.contains("mugwort") {
            return .mugwort
        }
        if title.contains("eiche") || title.contains("oak") {
            return .oak
        }
        if title.contains("ambrosia") || title.contains("ragweed") {
            return .ragweed
        }
        if title.contains("roggen") || title.contains("rye") {
            return .rye
        }

        return nil
    }

    private static func map(_ error: PolleninformationError) -> PollenDataError {
        switch error {
        case .invalidURL, .invalidResponse:
            return .unavailable
        case let .httpStatus(statusCode):
            return .apiFailure(reason: "HTTP \(statusCode)")
        case let .api(message):
            return .apiFailure(reason: message)
        case .decoding:
            return .decodingFailed
        }
    }

    private static func isMissingLocationPayload(_ error: PolleninformationError) -> Bool {
        guard case let .decoding(message) = error else {
            return false
        }

        return message.localizedCaseInsensitiveContains("no payload for coordinate")
    }

    public static func defaultAPIKey(bundle: Bundle = .main) -> String? {
        normalizedAPIKey(bundle.object(forInfoDictionaryKey: "POLLENINFORMATION_API_KEY") as? String)
    }

    private static func normalizedAPIKey(_ value: String?) -> String? {
        guard let value else {
            return nil
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return nil
        }

        if trimmed.hasPrefix("$("), trimmed.hasSuffix(")") {
            return nil
        }

        return trimmed
    }
}
