import Foundation
import Testing
@testable import Cujana

@MainActor
struct EnvironmentalDataRefreshCoordinatorTests {

    @Test func backgroundRefreshRequestsAlwaysAuthorizationBeforeLoadingCoordinate() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let locationProvider = StubBackgroundRefreshLocationProvider(coordinate: coordinate)
        let authorizer = StubBackgroundLocationAuthorizer(grantsAuthorization: true)
        let coordinator = EnvironmentalDataRefreshCoordinator(
            refreshUseCase: makeRefreshUseCase(),
            locationProvider: locationProvider,
            backgroundLocationAuthorizer: authorizer,
            now: { Date(timeIntervalSince1970: 7_200) }
        )

        let didRefresh = await coordinator.refreshForBackgroundTask()

        #expect(didRefresh)
        #expect(authorizer.requestBackgroundAuthorizationCallCount == 1)
        #expect(locationProvider.currentCoordinateCallCount == 1)
    }

    @Test func backgroundRefreshSkipsCoordinateWhenAlwaysAuthorizationIsDenied() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let locationProvider = StubBackgroundRefreshLocationProvider(coordinate: coordinate)
        let authorizer = StubBackgroundLocationAuthorizer(grantsAuthorization: false)
        let coordinator = EnvironmentalDataRefreshCoordinator(
            refreshUseCase: makeRefreshUseCase(),
            locationProvider: locationProvider,
            backgroundLocationAuthorizer: authorizer,
            now: { Date(timeIntervalSince1970: 7_200) }
        )

        let didRefresh = await coordinator.refreshForBackgroundTask()

        #expect(didRefresh == false)
        #expect(authorizer.requestBackgroundAuthorizationCallCount == 1)
        #expect(locationProvider.currentCoordinateCallCount == 0)
    }

    private func makeRefreshUseCase() -> RefreshEnvironmentalDataUseCase {
        RefreshEnvironmentalDataUseCase(
            pollenRepository: EmptyBackgroundRefreshPollenRepository(),
            weatherRepository: EmptyBackgroundRefreshWeatherRepository(),
            environmentalDataRepository: StubRefreshEnvironmentalRepository()
        )
    }
}

@MainActor
private final class StubBackgroundRefreshLocationProvider: LocationCoordinateProviding {
    private let coordinate: LocationCoordinate
    private(set) var currentCoordinateCallCount = 0

    init(coordinate: LocationCoordinate) {
        self.coordinate = coordinate
    }

    func currentCoordinate() async -> LocationCoordinate? {
        currentCoordinateCallCount += 1
        return coordinate
    }
}

@MainActor
private final class StubBackgroundLocationAuthorizer: BackgroundLocationAuthorizing {
    private let grantsAuthorization: Bool
    private(set) var requestBackgroundAuthorizationCallCount = 0

    init(grantsAuthorization: Bool) {
        self.grantsAuthorization = grantsAuthorization
    }

    var allowsBackgroundLocationRefresh: Bool {
        grantsAuthorization
    }

    var backgroundLocationStatusText: String {
        grantsAuthorization ? "Immer erlaubt" : "Nicht erlaubt"
    }

    func requestBackgroundLocationRefreshAuthorization() async -> Bool {
        requestBackgroundAuthorizationCallCount += 1
        return grantsAuthorization
    }
}

private actor EmptyBackgroundRefreshPollenRepository: PollenRepository {
    func pollenForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [PollenForecast] {
        []
    }
}

private actor EmptyBackgroundRefreshWeatherRepository: WeatherRepository {
    func weatherForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [WeatherForecast] {
        []
    }
}

private actor StubRefreshEnvironmentalRepository: EnvironmentalDataRepository {
    func latestPollenEntry(for coordinate: LocationCoordinate) async throws -> PollenDataEntry? {
        nil
    }

    func latestWeatherEntry(for coordinate: LocationCoordinate) async throws -> WeatherDataEntry? {
        nil
    }

    func savePollenEntries(_ entries: [PollenDataEntry]) async throws {}

    func saveWeatherEntries(_ entries: [WeatherDataEntry]) async throws {}
}
