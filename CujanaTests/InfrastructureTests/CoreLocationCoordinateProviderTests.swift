import CoreLocation
import Foundation
import Testing
@testable import Cujana

@MainActor
struct CoreLocationCoordinateProviderTests {

    @Test func parallelCoordinateRequestsShareSingleCoreLocationRequest() async throws {
        let manager = FakeCoreLocationAdapter(authorizationStatus: .authorizedWhenInUse)
        let provider = CoreLocationCoordinateProvider(manager: manager)

        let firstTask = Task { @MainActor in
            await provider.currentCoordinate()
        }
        let secondTask = Task { @MainActor in
            await provider.currentCoordinate()
        }

        try await waitUntil {
            manager.requestLocationCallCount == 1
        }
        provider.locationManager(
            CLLocationManager(),
            didUpdateLocations: [
                CLLocation(latitude: 48.2082, longitude: 16.3738)
            ]
        )

        let expectedCoordinate = try LocationCoordinate(
            latitude: 48.2082,
            longitude: 16.3738
        ).coarsenedForPrivacy()
        #expect(await firstTask.value == expectedCoordinate)
        #expect(await secondTask.value == expectedCoordinate)
        #expect(manager.requestLocationCallCount == 1)
    }

    @Test func parallelAuthorizationRequestsShareSinglePromptBeforeLocationRequest() async throws {
        let manager = FakeCoreLocationAdapter(authorizationStatus: .notDetermined)
        let provider = CoreLocationCoordinateProvider(manager: manager)

        let firstTask = Task { @MainActor in
            await provider.currentCoordinate()
        }
        let secondTask = Task { @MainActor in
            await provider.currentCoordinate()
        }

        try await waitUntil {
            manager.requestWhenInUseAuthorizationCallCount == 1
        }
        manager.authorizationStatus = .authorizedWhenInUse
        provider.locationManagerDidChangeAuthorization(CLLocationManager())

        try await waitUntil {
            manager.requestLocationCallCount == 1
        }
        provider.locationManager(
            CLLocationManager(),
            didUpdateLocations: [
                CLLocation(latitude: 47.0707, longitude: 15.4395)
            ]
        )

        let expectedCoordinate = try LocationCoordinate(
            latitude: 47.0707,
            longitude: 15.4395
        ).coarsenedForPrivacy()
        #expect(await firstTask.value == expectedCoordinate)
        #expect(await secondTask.value == expectedCoordinate)
        #expect(manager.requestWhenInUseAuthorizationCallCount == 1)
        #expect(manager.requestLocationCallCount == 1)
    }

    @Test func cancelledCoordinateRequestReturnsNilWithoutLocationCallback() async throws {
        let manager = FakeCoreLocationAdapter(authorizationStatus: .authorizedWhenInUse)
        let provider = CoreLocationCoordinateProvider(manager: manager)

        let task = Task { @MainActor in
            await provider.currentCoordinate()
        }

        try await waitUntil {
            manager.requestLocationCallCount == 1
        }
        task.cancel()

        #expect(await task.value == nil)
        #expect(manager.requestLocationCallCount == 1)
    }

    @Test func cancelledBackgroundAuthorizationReturnsFalse() async throws {
        let manager = FakeCoreLocationAdapter(authorizationStatus: .authorizedWhenInUse)
        let provider = CoreLocationCoordinateProvider(manager: manager)

        let task = Task { @MainActor in
            await provider.requestBackgroundLocationRefreshAuthorization()
        }

        try await waitUntil {
            manager.requestAlwaysAuthorizationCallCount == 1
        }
        task.cancel()

        #expect(await task.value == false)
        #expect(manager.requestAlwaysAuthorizationCallCount == 1)
    }

    private func waitUntil(
        timeout: Duration = .seconds(1),
        condition: @escaping @MainActor () -> Bool
    ) async throws {
        let start = ContinuousClock.now
        while start.duration(to: .now) < timeout {
            if condition() {
                return
            }

            try await Task.sleep(for: .milliseconds(10))
        }

        Issue.record("Timed out waiting for condition")
    }
}

@MainActor
private final class FakeCoreLocationAdapter: CoreLocationManaging {
    var authorizationStatus: CLAuthorizationStatus
    var delegate: CLLocationManagerDelegate?
    var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
    private(set) var requestAlwaysAuthorizationCallCount = 0
    private(set) var requestLocationCallCount = 0
    private(set) var requestWhenInUseAuthorizationCallCount = 0

    init(authorizationStatus: CLAuthorizationStatus) {
        self.authorizationStatus = authorizationStatus
    }

    func requestAlwaysAuthorization() {
        requestAlwaysAuthorizationCallCount += 1
    }

    func requestLocation() {
        requestLocationCallCount += 1
    }

    func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCallCount += 1
    }
}
