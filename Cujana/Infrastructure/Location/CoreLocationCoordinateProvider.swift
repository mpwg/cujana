import CoreLocation
import Foundation

@MainActor
final class CoreLocationCoordinateProvider: NSObject, LocationCoordinateProviding, BackgroundLocationAuthorizing {
    private let manager: CLLocationManager
    private var authorizationContinuation: CheckedContinuation<Bool, Never>?
    private var authorizationRequiresAlways = false
    private var locationContinuation: CheckedContinuation<LocationCoordinate?, Never>?

    override init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    var allowsBackgroundLocationRefresh: Bool {
        manager.authorizationStatus == .authorizedAlways
    }

    var backgroundLocationStatusText: String {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            return "Immer erlaubt"
        case .authorizedWhenInUse:
            return "Nur beim Verwenden erlaubt"
        case .notDetermined:
            return "Noch nicht gefragt"
        case .denied, .restricted:
            return "Nicht erlaubt"
        @unknown default:
            return "Unbekannt"
        }
    }

    func currentCoordinate() async -> LocationCoordinate? {
        guard await ensureAuthorized() else {
            return nil
        }

        return await requestSingleCoordinate()
    }

    func requestBackgroundLocationRefreshAuthorization() async -> Bool {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            return true
        case .notDetermined:
            guard await requestWhenInUseAuthorization() else {
                return false
            }
            return await requestAlwaysAuthorization()
        case .authorizedWhenInUse:
            return await requestAlwaysAuthorization()
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    private func ensureAuthorized() async -> Bool {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .notDetermined:
            return await requestWhenInUseAuthorization()
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    private func requestWhenInUseAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            authorizationRequiresAlways = false
            manager.requestWhenInUseAuthorization()
        }
    }

    private func requestAlwaysAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            authorizationRequiresAlways = true
            manager.requestAlwaysAuthorization()
        }
    }

    private func requestSingleCoordinate() async -> LocationCoordinate? {
        await withCheckedContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }

    private func coordinate(from location: CLLocation) -> LocationCoordinate? {
        try? LocationCoordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        ).coarsenedForPrivacy()
    }

    private func finishAuthorization(_ isAuthorized: Bool) {
        authorizationContinuation?.resume(returning: isAuthorized)
        authorizationContinuation = nil
        authorizationRequiresAlways = false
    }

    private func finishLocation(_ coordinate: LocationCoordinate?) {
        locationContinuation?.resume(returning: coordinate)
        locationContinuation = nil
    }
}

extension CoreLocationCoordinateProvider: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            finishAuthorization(true)
        case .authorizedWhenInUse:
            finishAuthorization(authorizationRequiresAlways == false)
        case .denied, .restricted:
            finishAuthorization(false)
        case .notDetermined:
            break
        @unknown default:
            finishAuthorization(false)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        finishLocation(locations.last.flatMap(coordinate(from:)))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finishLocation(nil)
    }
}
