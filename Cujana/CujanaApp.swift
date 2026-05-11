//
//  CujanaApp.swift
//  Cujana
//
//  Created by Matthias Wallner-Géhri on 04.05.26.
//

import SwiftUI

@main
struct CujanaApp: App {
    private let initialStartupState: AppStartupState
    @State private var telemetryService = AppTelemetryService()

    init() {
        initialStartupState = AppStartupState.current()
    }

    var body: some Scene {
        WindowGroup {
            UsageDataConsentRootView(telemetryService: telemetryService) {
                AppStartupRootView(
                    initialState: initialStartupState,
                    telemetryService: telemetryService
                )
            }
        }
    }
}
