import SwiftUI

@MainActor
enum AppStartupState {
    case app(AppLaunchComposition)
    case recovery(PersistentStoreRecoveryContext)
    case safeMode(AppStartupFailureContext)

    static func current() -> AppStartupState {
        do {
            return .app(try AppLaunchComposition.current())
        } catch PersistentStoreLoadError.recoveryRequired(let context) {
            return .recovery(context)
        } catch {
            let context = AppStartupFailureContext(
                reason: .bootstrapFailure,
                errorSummary: PersistentStoreRecoveryService.sanitizedSummary(for: error),
                storeURL: nil,
                recoveryContext: nil
            )
            AppObservability.log(
                .error,
                "App-Start konnte nicht vorbereitet werden.",
                category: "Persistence",
                metadata: ["error": context.errorSummary]
            )
            return .safeMode(context)
        }
    }
}

struct AppStartupRootView: View {
    @State private var startupState: AppStartupState
    @State private var environmentalDataRefreshCoordinator: EnvironmentalDataRefreshCoordinator?
    private let telemetryService: AppTelemetryService

    init(initialState: AppStartupState, telemetryService: AppTelemetryService) {
        _startupState = State(initialValue: initialState)
        self.telemetryService = telemetryService
    }

    var body: some View {
        Group {
            switch startupState {
            case .app(let launchComposition):
                launchComposition.makeRootView(telemetryService: telemetryService)
                    .task(id: ObjectIdentifier(telemetryService)) {
                        await configureBackgroundRefresh(for: launchComposition)
                    }
            case .recovery(let context):
                StoreRecoveryView(
                    context: context,
                    prepareStoreBackup: {
                        try PersistentStoreRecoveryService.copyStoreFilesForSharing(from: context.storeURL)
                    },
                    retryStartup: retryStartup,
                    startEmptyStore: {
                        try PersistentStoreRecoveryService.removeStoreFilesAfterUserConfirmation(at: context.storeURL)
                        return AppStartupState.current()
                    },
                    didUpdateStartupState: updateStartupState
                )
            case .safeMode(let context):
                StartupSafeModeView(
                    context: context,
                    prepareStoreBackup: {
                        guard let storeURL = context.storeURL ?? context.recoveryContext?.storeURL else {
                            throw PersistentStoreRecoveryFileError.noStoreFilesFound
                        }

                        return try PersistentStoreRecoveryService.copyStoreFilesForSharing(from: storeURL)
                    },
                    retryStartup: retryStartup,
                    startEmptyStore: {
                        if let storeURL = context.storeURL ?? context.recoveryContext?.storeURL {
                            try PersistentStoreRecoveryService.removeStoreFilesAfterUserConfirmation(at: storeURL)
                        }
                        return AppStartupState.current()
                    },
                    didUpdateStartupState: updateStartupState
                )
            }
        }
    }

    private func retryStartup() -> AppStartupState {
        AppStartupState.current()
    }

    private func updateStartupState(_ state: AppStartupState) {
        startupState = state
    }

    private func configureBackgroundRefresh(for launchComposition: AppLaunchComposition) async {
        let coordinator = launchComposition.makeEnvironmentalDataRefreshCoordinator()
        environmentalDataRefreshCoordinator = coordinator
        coordinator?.registerBackgroundRefresh()
        await coordinator?.refreshOnLaunch()
    }
}
