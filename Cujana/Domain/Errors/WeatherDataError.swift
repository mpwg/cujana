import Foundation

nonisolated public enum WeatherDataError: Error, Equatable, Sendable {
    case unavailable
    case networkFailure
    case decodingFailed
}
