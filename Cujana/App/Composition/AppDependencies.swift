import Foundation

struct AppDependencies {
    let pollenRepository: any PollenRepository
    let symptomEntryRepository: any SymptomEntryRepository
    let defaultCoordinate: LocationCoordinate

    static func production() -> AppDependencies {
        AppDependencies(
            pollenRepository: OpenMeteoPollenRepository(),
            symptomEntryRepository: makeSymptomEntryRepository(),
            defaultCoordinate: viennaCoordinate()
        )
    }

    private static func makeSymptomEntryRepository() -> any SymptomEntryRepository {
        do {
            return LocalSymptomEntryRepository(store: try FileSymptomEntryStore.applicationSupportStore())
        } catch {
            return InMemorySymptomEntryRepository()
        }
    }

    private static func viennaCoordinate() -> LocationCoordinate {
        guard let coordinate = try? LocationCoordinate(latitude: 48.2082, longitude: 16.3738) else {
            fatalError("Default coordinate must be valid.")
        }

        return coordinate
    }
}
