import CoreLocation
import Foundation

@MainActor
protocol CoreLocationManaging: AnyObject {
    var authorizationStatus: CLAuthorizationStatus { get }
    var delegate: CLLocationManagerDelegate? { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }

    func requestAlwaysAuthorization()
    func requestLocation()
    func requestWhenInUseAuthorization()
}

extension CLLocationManager: CoreLocationManaging {}

@MainActor
final class CoreLocationCoordinateProvider: NSObject, LocationCoordinateProviding, BackgroundLocationAuthorizing {
    private enum AuthorizationKind {
        case always
        case whenInUse
    }

    private struct AuthorizationRequest {
        let id: UUID
        let kind: AuthorizationKind
        let continuation: CheckedContinuation<Bool, Never>
    }

    private let manager: any CoreLocationManaging
    private var authorizationRequests: [UUID: AuthorizationRequest] = [:]
    private var activeAuthorizationKind: AuthorizationKind?
    private var locationContinuations: [UUID: CheckedContinuation<LocationCoordinate?, Never>] = [:]
    private var isRequestingLocation = false

    override convenience init() {
        self.init(manager: CLLocationManager())
    }

    init(manager: any CoreLocationManaging) {
        self.manager = manager
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
        await requestAuthorization(.whenInUse)
    }

    private func requestAlwaysAuthorization() async -> Bool {
        await requestAuthorization(.always)
    }

    private func requestAuthorization(_ kind: AuthorizationKind) async -> Bool {
        if Task.isCancelled {
            return false
        }

        let requestID = UUID()
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                guard Task.isCancelled == false else {
                    continuation.resume(returning: false)
                    return
                }

                enqueueAuthorizationRequest(
                    AuthorizationRequest(
                        id: requestID,
                        kind: kind,
                        continuation: continuation
                    )
                )
            }
        } onCancel: {
            Task { @MainActor in
                self.cancelAuthorizationRequest(id: requestID)
            }
        }
    }

    private func requestSingleCoordinate() async -> LocationCoordinate? {
        if Task.isCancelled {
            return nil
        }

        let requestID = UUID()
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                guard Task.isCancelled == false else {
                    continuation.resume(returning: nil)
                    return
                }

                enqueueLocationRequest(id: requestID, continuation: continuation)
            }
        } onCancel: {
            Task { @MainActor in
                self.cancelLocationRequest(id: requestID)
            }
        }
    }

    private func coordinate(from location: CLLocation) -> LocationCoordinate? {
        try? LocationCoordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        ).coarsenedForPrivacy()
    }

    private func enqueueAuthorizationRequest(_ request: AuthorizationRequest) {
        authorizationRequests[request.id] = request

        guard activeAuthorizationKind == nil else {
            return
        }

        startAuthorizationRequest(request.kind)
    }

    private func enqueueLocationRequest(
        id: UUID,
        continuation: CheckedContinuation<LocationCoordinate?, Never>
    ) {
        locationContinuations[id] = continuation

        guard isRequestingLocation == false else {
            return
        }

        isRequestingLocation = true
        manager.requestLocation()
    }

    private func cancelAuthorizationRequest(id: UUID) {
        guard let request = authorizationRequests.removeValue(forKey: id) else {
            return
        }

        request.continuation.resume(returning: false)

        let hasActiveRequest = authorizationRequests.values.contains { queuedRequest in
            queuedRequest.kind == activeAuthorizationKind
        }
        if hasActiveRequest == false {
            finishActiveAuthorizationIfNeeded()
        }
    }

    private func cancelLocationRequest(id: UUID) {
        guard let continuation = locationContinuations.removeValue(forKey: id) else {
            return
        }

        continuation.resume(returning: nil)

        if locationContinuations.isEmpty {
            isRequestingLocation = false
        }
    }

    private func finishAuthorization(
        outcome: (AuthorizationRequest) -> Bool?
    ) {
        let finishedRequests = authorizationRequests.values.compactMap { request in
            outcome(request).map { isAuthorized in
                (request, isAuthorized)
            }
        }

        for (request, isAuthorized) in finishedRequests {
            authorizationRequests[request.id] = nil
            request.continuation.resume(returning: isAuthorized)
        }

        finishActiveAuthorizationIfNeeded()
    }

    private func finishLocation(_ coordinate: LocationCoordinate?) {
        let continuations = locationContinuations.values
        locationContinuations.removeAll()
        isRequestingLocation = false

        for continuation in continuations {
            continuation.resume(returning: coordinate)
        }
    }

    private func finishActiveAuthorizationIfNeeded() {
        activeAuthorizationKind = nil

        guard let nextRequest = authorizationRequests.values.first else {
            return
        }

        startAuthorizationRequest(nextRequest.kind)
    }

    private func startAuthorizationRequest(_ kind: AuthorizationKind) {
        activeAuthorizationKind = kind

        switch kind {
        case .always:
            manager.requestAlwaysAuthorization()
        case .whenInUse:
            manager.requestWhenInUseAuthorization()
        }
    }
}

extension CoreLocationCoordinateProvider: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch self.manager.authorizationStatus {
        case .authorizedAlways:
            finishAuthorization { _ in true }
        case .authorizedWhenInUse:
            let activeKind = activeAuthorizationKind
            finishAuthorization { request in
                if request.kind == .whenInUse {
                    return true
                }

                if activeKind == .always {
                    return false
                }

                return nil
            }
        case .denied, .restricted:
            finishAuthorization { _ in false }
        case .notDetermined:
            break
        @unknown default:
            finishAuthorization { _ in false }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        finishLocation(locations.last.flatMap(coordinate(from:)))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finishLocation(nil)
    }
}
