import Foundation

struct AppDependencies {
    let pollenRepository: any PollenRepository
    let symptomEntryRepository: any SymptomEntryRepository
    let locationProvider: any LocationCoordinateProviding
    let defaultCoordinate: LocationCoordinate
    let usesDemoData: Bool

    static func production() -> AppDependencies {
        let fallbackCoordinate = viennaCoordinate()

        return AppDependencies(
            pollenRepository: OpenMeteoPollenRepository(),
            symptomEntryRepository: makeSymptomEntryRepository(),
            locationProvider: CoreLocationCoordinateProvider(),
            defaultCoordinate: fallbackCoordinate,
            usesDemoData: false
        )
    }

    static func demo() -> AppDependencies {
        AppDependencies(
            pollenRepository: DemoPollenRepository(forecasts: AppDemoData.pollenForecasts),
            symptomEntryRepository: DemoSymptomEntryRepository(entries: AppDemoData.symptomEntries),
            locationProvider: FixedLocationCoordinateProvider(coordinate: AppDemoData.coordinate),
            defaultCoordinate: AppDemoData.coordinate,
            usesDemoData: true
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
