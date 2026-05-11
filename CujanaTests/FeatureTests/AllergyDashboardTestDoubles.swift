import Foundation
@testable import Cujana

struct DashboardStubPollenRepository: PollenRepository {
    let forecasts: [PollenForecast]

    func pollenForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [PollenForecast] {
        forecasts
    }
}

struct DashboardStubWeatherRepository: WeatherRepository {
    let forecasts: [WeatherForecast]

    func weatherForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [WeatherForecast] {
        forecasts
    }
}

actor DashboardCapturingPollenRepository: PollenRepository {
    private var coordinates: [LocationCoordinate] = []

    func pollenForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [PollenForecast] {
        coordinates.append(coordinate)
        return []
    }

    func requestedCoordinates() -> [LocationCoordinate] {
        coordinates
    }
}

struct DashboardFailingPollenRepository: PollenRepository {
    let error: any Error

    func pollenForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [PollenForecast] {
        throw error
    }
}

struct DashboardFailingSymptomEntryRepository: SymptomEntryRepository {
    func save(_ entry: AllergySymptomEntry) async throws {
        throw SymptomEntryError.storageUnavailable
    }

    func symptomEntries(from startDate: Date, to endDate: Date) async throws -> [AllergySymptomEntry] {
        throw SymptomEntryError.storageUnavailable
    }
}

struct DashboardStubSymptomEntryRepository: SymptomEntryRepository {
    let entries: [AllergySymptomEntry]

    func save(_ entry: AllergySymptomEntry) async throws {}

    func symptomEntries(from startDate: Date, to endDate: Date) async throws -> [AllergySymptomEntry] {
        entries
    }
}

@MainActor
final class DashboardStubLocationCoordinateProvider: LocationCoordinateProviding {
    private let coordinate: LocationCoordinate?

    init(coordinate: LocationCoordinate?) {
        self.coordinate = coordinate
    }

    func currentCoordinate() async -> LocationCoordinate? {
        coordinate
    }
}

actor DashboardSuspendedPollenRepository: PollenRepository {
    private var didReceiveRequest = false
    private var requestContinuation: CheckedContinuation<Void, Never>?
    private var responseContinuation: CheckedContinuation<[PollenForecast], Never>?

    func pollenForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [PollenForecast] {
        return await withCheckedContinuation { continuation in
            didReceiveRequest = true
            responseContinuation = continuation
            requestContinuation?.resume()
            requestContinuation = nil
        }
    }

    func waitUntilRequested() async {
        if didReceiveRequest {
            return
        }

        await withCheckedContinuation { continuation in
            requestContinuation = continuation
        }
    }

    func resume(returning forecasts: [PollenForecast]) {
        responseContinuation?.resume(returning: forecasts)
        responseContinuation = nil
    }
}
