import Foundation

struct AppDependencies {
    let pollenRepository: any PollenRepository
    let weatherRepository: any WeatherRepository
    let environmentalDataRepository: any EnvironmentalDataRepository
    let symptomEntryRepository: any SymptomEntryRepository
    let locationProvider: any LocationCoordinateProviding
    let backgroundLocationAuthorizer: (any BackgroundLocationAuthorizing)?

    static func production() throws -> AppDependencies {
        let locationProvider = CoreLocationCoordinateProvider()
        let modelContainer = try CujanaPersistence.makeProductionModelContainer()

        return AppDependencies(
            pollenRepository: PolleninformationPollenRepository(),
            weatherRepository: WeatherKitWeatherRepository(),
            environmentalDataRepository: LocalEnvironmentalDataRepository(modelContainer: modelContainer),
            symptomEntryRepository: LocalSymptomEntryRepository(modelContainer: modelContainer),
            locationProvider: locationProvider,
            backgroundLocationAuthorizer: locationProvider
        )
    }
}
