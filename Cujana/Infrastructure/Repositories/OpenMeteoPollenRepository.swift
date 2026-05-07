import Foundation

nonisolated public struct OpenMeteoPollenRepository: PollenRepository {
    private let apiClient: any OpenMeteoPollenAPIClient

    public init(apiClient: any OpenMeteoPollenAPIClient = OpenMeteoPollenSDKClient()) {
        self.apiClient = apiClient
    }

    public func pollenForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [PollenForecast] {
        let response = try await apiClient.pollenResponse(
            for: coordinate,
            from: startDate,
            to: endDate
        )

        return try OpenMeteoPollenMapper.map(response)
    }
}
