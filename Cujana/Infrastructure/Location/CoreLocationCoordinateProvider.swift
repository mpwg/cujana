import CoreLocation
import Foundation

@MainActor
final class CoreLocationCoordinateProvider: NSObject, LocationCoordinateProviding {
    private let manager: CLLocationManager
    private var authorizationContinuation: CheckedContinuation<Bool, Never>?
    private var locationContinuation: CheckedContinuation<LocationCoordinate?, Never>?

    override init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    func currentCoordinate() async -> LocationCoordinate? {
        guard CLLocationManager.locationServicesEnabled() else {
            return nil
        }

        guard await ensureAuthorized() else {
            return nil
        }

        return await requestSingleCoordinate()
    }

    private func ensureAuthorized() async -> Bool {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                authorizationContinuation = continuation
                manager.requestWhenInUseAuthorization()
            }
        case .denied, .restricted:
            return false
        @unknown default:
            return false
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
    }

    private func finishLocation(_ coordinate: LocationCoordinate?) {
        locationContinuation?.resume(returning: coordinate)
        locationContinuation = nil
    }
}

extension CoreLocationCoordinateProvider: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            finishAuthorization(true)
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
