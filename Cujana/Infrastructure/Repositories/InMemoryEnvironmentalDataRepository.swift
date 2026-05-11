import Foundation

public actor InMemoryEnvironmentalDataRepository: EnvironmentalDataRepository {
    private var pollenEntries: [PollenDataEntry]
    private var weatherEntries: [WeatherDataEntry]

    public init(
        pollenEntries: [PollenDataEntry] = [],
        weatherEntries: [WeatherDataEntry] = []
    ) {
        self.pollenEntries = pollenEntries
        self.weatherEntries = weatherEntries
    }

    public func latestPollenEntry(for coordinate: LocationCoordinate) async throws -> PollenDataEntry? {
        pollenEntries
            .filter { $0.coordinate == coordinate }
            .max { $0.collectedAt < $1.collectedAt }
    }

    public func latestWeatherEntry(for coordinate: LocationCoordinate) async throws -> WeatherDataEntry? {
        weatherEntries
            .filter { $0.coordinate == coordinate }
            .max { $0.collectedAt < $1.collectedAt }
    }

    public func savePollenEntries(_ entries: [PollenDataEntry]) async throws {
        for entry in entries {
            pollenEntries.removeAll { existingEntry in
                existingEntry.coordinate == entry.coordinate
                    && existingEntry.entryDate == entry.entryDate
                    && existingEntry.rowKind == entry.rowKind
            }
            pollenEntries.append(entry)
        }
    }

    public func saveWeatherEntries(_ entries: [WeatherDataEntry]) async throws {
        for entry in entries {
            weatherEntries.removeAll { existingEntry in
                existingEntry.coordinate == entry.coordinate
                    && existingEntry.entryDate == entry.entryDate
                    && existingEntry.rowKind == entry.rowKind
            }
            weatherEntries.append(entry)
        }
    }
}
