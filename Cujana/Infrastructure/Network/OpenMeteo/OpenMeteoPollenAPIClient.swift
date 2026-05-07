import Foundation
import OpenMeteoSdk

nonisolated public protocol OpenMeteoPollenAPIClient: Sendable {
    func pollenResponse(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> OpenMeteoPollenResponseDTO
}

nonisolated public struct OpenMeteoPollenSDKClient: OpenMeteoPollenAPIClient {
    private static let pollenVariables: [(queryName: String, pollenType: PollenType)] = [
        ("alder_pollen", .alder),
        ("birch_pollen", .birch),
        ("grass_pollen", .grass),
        ("mugwort_pollen", .mugwort),
        ("ragweed_pollen", .ragweed)
    ]

    private let baseURL: URL
    private let session: URLSession
    private let now: @Sendable () -> Date

    public init(
        baseURL: URL = OpenMeteoPollenSDKClient.defaultBaseURL(),
        session: URLSession = .shared,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.baseURL = baseURL
        self.session = session
        self.now = now
    }

    public func pollenResponse(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> OpenMeteoPollenResponseDTO {
        do {
            let responses = try await WeatherApiResponse.fetch(
                request: request(for: coordinate, from: startDate, to: endDate),
                session: session
            )

            guard let response = responses.first, let hourly = response.hourly else {
                throw PollenDataError.decodingFailed
            }

            return try Self.aggregateHourlyResponse(
                coordinate: coordinate,
                generatedAt: now(),
                hourlyDates: hourly.getDateTime(offset: response.utcOffsetSeconds),
                hourlyVariables: Self.pollenVariables.enumerated().map { index, variable in
                    guard let values = hourly.variables(at: Int32(index))?.values else {
                        throw PollenDataError.decodingFailed
                    }

                    return (pollenType: variable.pollenType, values: values)
                }
            )
        } catch let error as PollenDataError {
            throw error
        } catch let error as OpenMeteoSdkError {
            throw Self.map(error)
        } catch {
            throw PollenDataError.networkFailure
        }
    }

    private func request(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw PollenDataError.unavailable
        }

        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
            URLQueryItem(
                name: "hourly",
                value: Self.pollenVariables.map(\.queryName).joined(separator: ",")
            ),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "start_date", value: Self.apiDateString(from: startDate)),
            URLQueryItem(name: "end_date", value: Self.apiDateString(from: endDate)),
            URLQueryItem(name: "format", value: "flatbuffers")
        ]

        guard let url = components.url else {
            throw PollenDataError.unavailable
        }

        return URLRequest(url: url)
    }

    static func aggregateHourlyResponse(
        coordinate: LocationCoordinate,
        generatedAt: Date,
        hourlyDates: [Date],
        hourlyVariables: [(pollenType: PollenType, values: [Float])]
    ) throws -> OpenMeteoPollenResponseDTO {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone

        let startOfDays = hourlyDates.map { calendar.startOfDay(for: $0) }
        let dailyDates = Array(Set(startOfDays)).sorted()
        let dailyVariables = hourlyVariables.map { variable in
            let dailyValues = dailyDates.map { day in
                zip(startOfDays, variable.values)
                    .filter { date, value in
                        date == day && value.isFinite
                    }
                    .map(\.1)
                    .max() ?? 0
            }

            return OpenMeteoPollenResponseDTO.DailyVariable(
                pollenType: variable.pollenType,
                values: dailyValues
            )
        }

        return OpenMeteoPollenResponseDTO(
            coordinate: coordinate,
            generatedAt: generatedAt,
            daily: OpenMeteoPollenResponseDTO.Daily(
                dates: dailyDates,
                variables: dailyVariables
            )
        )
    }

    private static func apiDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    public static func defaultBaseURL() -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "air-quality-api.open-meteo.com"
        components.path = "/v1/air-quality"

        guard let url = components.url else {
            preconditionFailure("OpenMeteo base URL must be valid.")
        }

        return url
    }

    private static func map(_ error: OpenMeteoSdkError) -> PollenDataError {
        switch error {
        case let .error(message):
            return .apiFailure(reason: message)
        case .serverError:
            return .unavailable
        }
    }
}
