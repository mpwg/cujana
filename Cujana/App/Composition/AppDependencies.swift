import Foundation

struct AppDependencies {
    let pollenRepository: any PollenRepository
    let symptomEntryRepository: any SymptomEntryRepository
    let locationProvider: any LocationCoordinateProviding

    static func production() -> AppDependencies {
        return AppDependencies(
            pollenRepository: OpenMeteoPollenRepository(),
            symptomEntryRepository: makeSymptomEntryRepository(),
            locationProvider: CoreLocationCoordinateProvider()
        )
    }

    private static func makeSymptomEntryRepository() -> any SymptomEntryRepository {
        do {
            return LocalSymptomEntryRepository(store: try FileSymptomEntryStore.applicationSupportStore())
        } catch {
            return InMemorySymptomEntryRepository()
        }
    }

}
