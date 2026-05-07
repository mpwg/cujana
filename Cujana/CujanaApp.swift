//
//  CujanaApp.swift
//  Cujana
//
//  Created by Matthias Wallner-Géhri on 04.05.26.
//

import SwiftUI

@main
struct CujanaApp: App {
    private let symptomEntryRepository: any SymptomEntryRepository = {
        do {
            return LocalSymptomEntryRepository(store: try FileSymptomEntryStore.applicationSupportStore())
        } catch {
            return InMemorySymptomEntryRepository()
        }
    }()
    private let pollenRepository: any PollenRepository = OpenMeteoPollenRepository()

    var body: some Scene {
        WindowGroup {
            ContentView(
                dashboardViewModel: makeAllergyDashboardViewModel(),
                symptomEntryViewModel: makeSymptomEntryViewModel()
            )
        }
    }

    private func makeAllergyDashboardViewModel() -> AllergyDashboardViewModel {
        let loadUseCase = LoadAllergyOverviewUseCase(
            pollenRepository: pollenRepository,
            symptomEntryRepository: symptomEntryRepository
        )

        return AllergyDashboardViewModel(
            loadUseCase: loadUseCase,
            coordinate: defaultCoordinate()
        )
    }

    private func makeSymptomEntryViewModel() -> SymptomEntryViewModel {
        let saveUseCase = SaveAllergySymptomEntryUseCase(repository: symptomEntryRepository)

        return SymptomEntryViewModel(saveUseCase: saveUseCase)
    }

    private func defaultCoordinate() -> LocationCoordinate {
        guard let coordinate = try? LocationCoordinate(latitude: 48.2082, longitude: 16.3738) else {
            fatalError("Default coordinate must be valid.")
        }

        return coordinate
    }
}
