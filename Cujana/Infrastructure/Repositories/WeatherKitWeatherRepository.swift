import Foundation

nonisolated public struct WeatherKitWeatherRepository: WeatherRepository {
    private let apiClient: any WeatherKitWeatherAPIClient
    private let now: @Sendable () -> Date

    public init(
        apiClient: any WeatherKitWeatherAPIClient = WeatherKitWeatherServiceClient(),
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
        return try WeatherKitWeatherMapper.map(response, generatedAt: now())
    }
}
