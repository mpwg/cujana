import Foundation

nonisolated public struct PolleninformationPollenRepository: PollenRepository {
    public static let defaultCacheDuration: TimeInterval = 4 * 60 * 60

    private let apiClient: any PolleninformationPollenAPIClient
    private let cache: PolleninformationPollenResponseCache
    private let now: @Sendable () -> Date
    private let cacheDuration: TimeInterval

    public init(
        apiClient: any PolleninformationPollenAPIClient = PolleninformationURLSessionClient(),
        cache: PolleninformationPollenResponseCache = .production,
        now: @escaping @Sendable () -> Date = Date.init,
        cacheDuration: TimeInterval = Self.defaultCacheDuration
    ) {
        self.apiClient = apiClient
        self.cache = cache
        self.now = now
        self.cacheDuration = cacheDuration
    }

    public func pollenForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [PollenForecast] {
        if let cachedResponse = await cache.response(
            for: coordinate,
            currentDate: now(),
            maximumAge: cacheDuration
        ) {
            return try PolleninformationPollenMapper.map(cachedResponse)
        }

        let response = try await apiClient.pollenResponse(
            for: coordinate,
            from: startDate,
            to: endDate
        )
        await cache.store(response, for: coordinate)

        return try PolleninformationPollenMapper.map(response)
    }
}

public actor PolleninformationPollenResponseCache {
    public static let production = PolleninformationPollenResponseCache()

    private struct StoredResponse: Codable {
        let coordinateKey: String
        let response: PolleninformationPollenResponseDTO
    }

    private let userDefaults: UserDefaults
    private let storageKey: String

    public init(
        userDefaults: UserDefaults = .standard,
        storageKey: String = "at.cujana.polleninformation.response-cache"
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    public func response(
        for coordinate: LocationCoordinate,
        currentDate: Date,
        maximumAge: TimeInterval
    ) -> PolleninformationPollenResponseDTO? {
        guard
            let storedResponse = storedResponse(),
            storedResponse.coordinateKey == Self.coordinateKey(for: coordinate),
            currentDate.timeIntervalSince(storedResponse.response.generatedAt) < maximumAge
        else {
            return nil
        }

        return storedResponse.response
    }

    public func store(_ response: PolleninformationPollenResponseDTO, for coordinate: LocationCoordinate) {
        let storedResponse = StoredResponse(
            coordinateKey: Self.coordinateKey(for: coordinate),
            response: response
        )
        guard let data = try? JSONEncoder().encode(storedResponse) else {
            return
        }

        userDefaults.set(data, forKey: storageKey)
    }

    public func removeAll() {
        userDefaults.removeObject(forKey: storageKey)
    }

    private func storedResponse() -> StoredResponse? {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return nil
        }

        return try? JSONDecoder().decode(StoredResponse.self, from: data)
    }

    private static func coordinateKey(for coordinate: LocationCoordinate) -> String {
        "\(rounded(coordinate.latitude)):\(rounded(coordinate.longitude))"
    }

    private static func rounded(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}
