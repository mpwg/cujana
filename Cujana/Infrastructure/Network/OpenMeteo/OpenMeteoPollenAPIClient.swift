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
    private static let dailyVariables: [(queryName: String, pollenType: PollenType)] = [
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

            guard let response = responses.first, let daily = response.daily else {
                throw PollenDataError.decodingFailed
            }

            return try OpenMeteoPollenResponseDTO(
                coordinate: coordinate,
                generatedAt: now(),
                daily: OpenMeteoPollenResponseDTO.Daily(
                    dates: daily.getDateTime(offset: response.utcOffsetSeconds),
                    variables: Self.dailyVariables.enumerated().map { index, variable in
                        guard let values = daily.variables(at: Int32(index))?.values else {
                            throw PollenDataError.decodingFailed
                        }

                        return OpenMeteoPollenResponseDTO.DailyVariable(
                            pollenType: variable.pollenType,
                            values: values
                        )
                    }
                )
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
                name: "daily",
                value: Self.dailyVariables.map(\.queryName).joined(separator: ",")
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
