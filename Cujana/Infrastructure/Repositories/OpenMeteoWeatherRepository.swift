import Foundation

nonisolated public struct OpenMeteoWeatherRepository: WeatherRepository {
    private let apiClient: any OpenMeteoWeatherAPIClient
    private let now: @Sendable () -> Date

    public init(
        apiClient: any OpenMeteoWeatherAPIClient = OpenMeteoWeatherURLSessionClient(),
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.apiClient = apiClient
        self.now = now
    }

    public func weatherForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [WeatherForecast] {
        let response = try await apiClient.weatherResponse(for: coordinate, from: startDate, to: endDate)
        return try OpenMeteoWeatherMapper.map(response, generatedAt: now())
    }
}
