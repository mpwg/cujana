import Foundation

@MainActor
protocol LocationCoordinateProviding: AnyObject {
    func currentCoordinate() async -> LocationCoordinate?
}

@MainActor
final class FixedLocationCoordinateProvider: LocationCoordinateProviding {
    private let coordinate: LocationCoordinate

    init(coordinate: LocationCoordinate) {
        self.coordinate = coordinate
    }

    func currentCoordinate() async -> LocationCoordinate? {
        coordinate
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
