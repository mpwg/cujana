import Foundation

struct AppDependencies {
    let pollenRepository: any PollenRepository
    let weatherRepository: any WeatherRepository
    let environmentalDataRepository: any EnvironmentalDataRepository
    let symptomEntryRepository: any SymptomEntryRepository
    let locationProvider: any LocationCoordinateProviding
    let backgroundLocationAuthorizer: (any BackgroundLocationAuthorizing)?

    static func production() -> AppDependencies {
        let locationProvider = CoreLocationCoordinateProvider()

        return AppDependencies(
            pollenRepository: PolleninformationPollenRepository(),
            weatherRepository: WeatherKitWeatherRepository(),
            environmentalDataRepository: makeEnvironmentalDataRepository(),
            symptomEntryRepository: makeSymptomEntryRepository(),
            locationProvider: locationProvider,
            backgroundLocationAuthorizer: locationProvider
        )
    }

    private static func makeEnvironmentalDataRepository() -> any EnvironmentalDataRepository {
        do {
            let store = try FileEnvironmentalDataSnapshotStore.applicationSupportStore()
            return LocalEnvironmentalDataRepository(store: store)
        } catch {
            return InMemoryEnvironmentalDataRepository()
        }
    }

    private static func makeSymptomEntryRepository() -> any SymptomEntryRepository {
        do {
            return LocalSymptomEntryRepository(store: try FileSymptomEntryStore.applicationSupportStore())
        } catch {
            return InMemorySymptomEntryRepository()
        }
    }

}
