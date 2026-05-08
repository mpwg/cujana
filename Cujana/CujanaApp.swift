//
//  CujanaApp.swift
//  Cujana
//
//  Created by Matthias Wallner-Géhri on 04.05.26.
//

import SwiftUI

@main
struct CujanaApp: App {
    private let launchConfiguration = AppLaunchConfiguration.current()
    private let compositionRoot: AppCompositionRoot

    init() {
        switch launchConfiguration {
        case .standard:
            compositionRoot = .production()
        case .screenshot:
            compositionRoot = .demo()
        }
    }

    var body: some Scene {
        WindowGroup {
            compositionRoot.makeRootView(launchConfiguration: launchConfiguration)
        }
    }
}
