//
//  CujanaApp.swift
//  Cujana
//
//  Created by Matthias Wallner-Géhri on 04.05.26.
//

import SwiftUI

@main
struct CujanaApp: App {
    private let launchComposition = AppLaunchComposition.current()
    @State private var telemetryService = AppTelemetryService()

    var body: some Scene {
        WindowGroup {
            UsageDataConsentRootView(telemetryService: telemetryService) {
                launchComposition.makeRootView(telemetryService: telemetryService)
            }
        }
    }
}
