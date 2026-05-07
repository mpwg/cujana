import Foundation

nonisolated public enum PollenDataError: Error, Equatable, Sendable {
    case invalidCoordinate(latitude: Double, longitude: Double)
    case invalidForecastPeriod(start: Date, end: Date)
    case apiFailure(reason: String)
    case decodingFailed
    case networkFailure
    case unavailable
}
