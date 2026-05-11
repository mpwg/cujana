import Foundation
import SwiftData

struct AppDependencies {
    let pollenRepository: any PollenRepository
    let weatherRepository: any WeatherRepository
    let environmentalDataRepository: any EnvironmentalDataRepository
    let symptomEntryRepository: any SymptomEntryRepository
    let locationProvider: any LocationCoordinateProviding
    let backgroundLocationAuthorizer: (any BackgroundLocationAuthorizing)?

    static func production() -> AppDependencies {
        let locationProvider = CoreLocationCoordinateProvider()
        let modelContainer: ModelContainer

        do {
            modelContainer = try CujanaPersistence.makeProductionModelContainer()
        } catch {
            fatalError("SwiftData persistent store could not be created: \(error)")
        }

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
