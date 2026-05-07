import Foundation

nonisolated public enum PollenDataError: Error, Equatable, Sendable {
    case invalidCoordinate(latitude: Double, longitude: Double)
    case invalidForecastPeriod(start: Date, end: Date)
    case unavailable
}
