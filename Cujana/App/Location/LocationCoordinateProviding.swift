import Foundation

@MainActor
protocol LocationCoordinateProviding: AnyObject {
    func currentCoordinate() async -> LocationCoordinate?
}

@MainActor
protocol BackgroundLocationAuthorizing: AnyObject {
    var allowsBackgroundLocationRefresh: Bool { get }
    var backgroundLocationAuthorizationState: BackgroundLocationAuthorizationState { get }
    var backgroundLocationSettingsURL: URL? { get }
    var backgroundLocationStatusText: String { get }

    func requestBackgroundLocationRefreshAuthorization() async -> Bool
}

enum BackgroundLocationAuthorizationState {
    case always
    case whenInUse
    case notDetermined
    case denied
    case restricted
    case unknown
}

@MainActor
final class FixedLocationCoordinateProvider: LocationCoordinateProviding, BackgroundLocationAuthorizing {
    private let coordinate: LocationCoordinate

    init(coordinate: LocationCoordinate) {
        self.coordinate = coordinate
    }

    var allowsBackgroundLocationRefresh: Bool {
        true
    }

    var backgroundLocationAuthorizationState: BackgroundLocationAuthorizationState {
        .always
    }

    var backgroundLocationSettingsURL: URL? {
        nil
    }

    var backgroundLocationStatusText: String {
        "Beim Verwenden erlaubt"
    }

    func currentCoordinate() async -> LocationCoordinate? {
        coordinate
    }

    func requestBackgroundLocationRefreshAuthorization() async -> Bool {
        true
    }
}

extension LocationCoordinate {
    func coarsenedForPrivacy() -> LocationCoordinate {
        let gridSize = 0.05

        guard let coordinate = try? LocationCoordinate(
            latitude: (latitude / gridSize).rounded() * gridSize,
            longitude: (longitude / gridSize).rounded() * gridSize
        ) else {
            return self
        }

        return coordinate
    }
}
