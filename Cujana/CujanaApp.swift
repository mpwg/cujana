//
//  CujanaApp.swift
//  Cujana
//
//  Created by Matthias Wallner-Géhri on 04.05.26.
//

import SwiftUI

@main
struct CujanaApp: App {
    private let launchComposition: AppLaunchComposition
    private let environmentalDataRefreshCoordinator: EnvironmentalDataRefreshCoordinator?
    @State private var telemetryService = AppTelemetryService()

    init() {
        let launchComposition = AppLaunchComposition.current()
        let environmentalDataRefreshCoordinator = launchComposition.makeEnvironmentalDataRefreshCoordinator()

        self.launchComposition = launchComposition
        self.environmentalDataRefreshCoordinator = environmentalDataRefreshCoordinator

        environmentalDataRefreshCoordinator?.registerBackgroundRefresh()
    }

    var body: some Scene {
        WindowGroup {
            UsageDataConsentRootView(telemetryService: telemetryService) {
                launchComposition.makeRootView(telemetryService: telemetryService)
                    .task {
                        await environmentalDataRefreshCoordinator?.refreshOnLaunch()
                    }
            }
        }
    }
}
