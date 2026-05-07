import Foundation

nonisolated public struct LocationCoordinate: Codable, Equatable, Hashable, Sendable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) throws {
        guard (-90...90).contains(latitude), (-180...180).contains(longitude) else {
            throw PollenDataError.invalidCoordinate(latitude: latitude, longitude: longitude)
        }

        self.latitude = latitude
        self.longitude = longitude
    }
}
