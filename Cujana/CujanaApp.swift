//
//  CujanaApp.swift
//  Cujana
//
//  Created by Matthias Wallner-Géhri on 04.05.26.
//

import SwiftUI

@main
struct CujanaApp: App {
    private let compositionRoot = AppCompositionRoot.production()

    var body: some Scene {
        WindowGroup {
            compositionRoot.makeContentView()
        }
    }
}
