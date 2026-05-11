import Foundation

nonisolated public protocol EnvironmentalDataRepository: Sendable {
    func latestPollenEntry(for coordinate: LocationCoordinate) async throws -> PollenDataEntry?
    func latestWeatherEntry(for coordinate: LocationCoordinate) async throws -> WeatherDataEntry?
    func savePollenEntries(_ entries: [PollenDataEntry]) async throws
    func saveWeatherEntries(_ entries: [WeatherDataEntry]) async throws
}
