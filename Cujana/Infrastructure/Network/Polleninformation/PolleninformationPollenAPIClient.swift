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

nonisolated public struct PolleninformationURLSessionClient: PolleninformationPollenAPIClient {
    private let apiKey: String?
    private let country: CountryCode
    private let language: LanguageCode
    private let calendar: Calendar
    private let now: @Sendable () -> Date

    public init(
        apiKey: String? = ProcessInfo.processInfo.environment["POLLENINFORMATION_API_KEY"],
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
            throw PollenDataError.unavailable
        }

        let client = PolleninformationClient(apiKey: apiKey)
        return try await Self.makeResponse(
            client: client,
            coordinate: coordinate,
            country: country,
            language: language,
            calendar: calendar,
            generatedAt: now(),
            startDate: startDate,
            endDate: endDate
        )
    }

    static func makeResponse(
        client: any PolleninformationForecastLoading,
        coordinate: LocationCoordinate,
        country: CountryCode,
        language: LanguageCode,
        calendar: Calendar,
        generatedAt: Date,
        startDate: Date,
        endDate: Date
    ) async throws -> PolleninformationPollenResponseDTO {
        do {
            let forecast = try await client.forecast(
                country: country,
                language: language,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )

            return try map(
                forecast,
                coordinate: coordinate,
                generatedAt: generatedAt,
                calendar: calendar,
                startDate: startDate,
                endDate: endDate
            )
        } catch let error as PollenDataError {
            throw error
        } catch let error as PolleninformationError {
            throw map(error)
        } catch {
            throw PollenDataError.networkFailure
        }
    }

    static func map(
        _ forecast: ForecastResponse,
        coordinate: LocationCoordinate,
        generatedAt: Date,
        calendar: Calendar,
        startDate: Date,
        endDate: Date
    ) throws -> PolleninformationPollenResponseDTO {
        let allDates = forecastDates(generatedAt: generatedAt, calendar: calendar)
        let dates = allDates
            .filter { date in
                calendar.compare(date, to: startDate, toGranularity: .day) != .orderedAscending
                    && calendar.compare(date, to: endDate, toGranularity: .day) != .orderedDescending
            }

        let dateOffsets = dates.compactMap { date in
            allDates.firstIndex(of: date)
        }

        let variables = forecast.contamination.compactMap { contamination -> PolleninformationPollenResponseDTO.DailyVariable? in
            guard let pollenType = pollenType(for: contamination) else {
                return nil
            }

            return PolleninformationPollenResponseDTO.DailyVariable(
                pollenType: pollenType,
                values: dateOffsets.map { contamination.dailyValues[$0] }
            )
        }
        let dailyAllergyRisks = zip(dates, dateOffsets).map { date, offset in
            PolleninformationPollenResponseDTO.DailyAllergyRisk(
                date: date,
                value: forecast.allergyRisk.dailyValues[offset],
                hourlyValues: forecast.hourlyAllergyRisk.dailyValues[offset]
            )
        }

        return PolleninformationPollenResponseDTO(
            coordinate: coordinate,
            generatedAt: generatedAt,
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

    private static func pollenType(for contamination: PollenContamination) -> PollenType? {
        let title = contamination.pollTitle.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)

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
}
