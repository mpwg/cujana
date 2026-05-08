import Foundation

nonisolated public protocol OpenMeteoWeatherAPIClient: Sendable {
    func weatherResponse(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> OpenMeteoWeatherResponseDTO
}

nonisolated public struct OpenMeteoWeatherURLSessionClient: OpenMeteoWeatherAPIClient {
    private let baseURL: URL
    private let session: URLSession

    public init(
        baseURL: URL = OpenMeteoWeatherURLSessionClient.defaultBaseURL(),
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    public func weatherResponse(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> OpenMeteoWeatherResponseDTO {
        do {
            let (data, response) = try await session.data(for: request(for: coordinate, from: startDate, to: endDate))
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw WeatherDataError.unavailable
            }

            return try JSONDecoder().decode(OpenMeteoWeatherResponseDTO.self, from: data)
        } catch let error as WeatherDataError {
            throw error
        } catch is DecodingError {
            throw WeatherDataError.decodingFailed
        } catch {
            throw WeatherDataError.networkFailure
        }
    }

    private func request(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw WeatherDataError.unavailable
        }

        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "start_date", value: Self.apiDateString(from: startDate)),
            URLQueryItem(name: "end_date", value: Self.apiDateString(from: endDate))
        ]

        guard let url = components.url else {
            throw WeatherDataError.unavailable
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
        components.host = "api.open-meteo.com"
        components.path = "/v1/forecast"

        guard let url = components.url else {
            preconditionFailure("OpenMeteo weather base URL must be valid.")
        }

        return url
    }
}
