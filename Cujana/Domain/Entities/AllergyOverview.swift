import Foundation

nonisolated public struct AllergyOverview: Equatable, Sendable {
    public let coordinate: LocationCoordinate
    public let pollenForecasts: [PollenForecast]
    public let weatherForecasts: [WeatherForecast]
    public let symptomEntries: [AllergySymptomEntry]
    public let sourceStatuses: [AllergyOverviewSourceStatus]
    public let generatedAt: Date

    public init(
        coordinate: LocationCoordinate,
        pollenForecasts: [PollenForecast],
        weatherForecasts: [WeatherForecast] = [],
        symptomEntries: [AllergySymptomEntry],
        sourceStatuses: [AllergyOverviewSourceStatus] = [],
        generatedAt: Date = Date()
    ) {
        self.coordinate = coordinate
        self.pollenForecasts = pollenForecasts
        self.weatherForecasts = weatherForecasts
        self.symptomEntries = symptomEntries
        self.sourceStatuses = sourceStatuses
        self.generatedAt = generatedAt
    }
}

nonisolated public struct AllergyOverviewSourceStatus: Equatable, Sendable {
    public let source: AllergyOverviewSource
    public let state: AllergyOverviewSourceState

    public init(source: AllergyOverviewSource, state: AllergyOverviewSourceState) {
        self.source = source
        self.state = state
    }
}

nonisolated public enum AllergyOverviewSource: String, Equatable, Sendable {
    case pollen
    case weather
}

nonisolated public enum AllergyOverviewSourceState: Equatable, Sendable {
    case available
    case noData
    case unavailable(AllergyOverviewSourceErrorCategory)

    public var isDegraded: Bool {
        if case .unavailable = self {
            return true
        }

        return false
    }
}

nonisolated public enum AllergyOverviewSourceErrorCategory: String, Equatable, Sendable {
    case network
    case decoding
    case api
    case unavailable
    case unknown

    public init(error: any Error) {
        guard let pollenError = error as? PollenDataError else {
            self = .unknown
            return
        }

        switch pollenError {
        case .networkFailure:
            self = .network
        case .decodingFailed:
            self = .decoding
        case .apiFailure:
            self = .api
        case .unavailable:
            self = .unavailable
        case .invalidCoordinate, .invalidForecastPeriod:
            self = .unknown
        }
    }
}
