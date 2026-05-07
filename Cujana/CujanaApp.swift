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

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: makeSymptomEntryViewModel())
        }
    }

    private func makeSymptomEntryViewModel() -> SymptomEntryViewModel {
        let saveUseCase = SaveAllergySymptomEntryUseCase(repository: symptomEntryRepository)

        return SymptomEntryViewModel(saveUseCase: saveUseCase)
    }
}
