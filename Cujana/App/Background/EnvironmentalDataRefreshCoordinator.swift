import BackgroundTasks
import Foundation

@MainActor
final class EnvironmentalDataRefreshCoordinator {
    static let taskIdentifier = "eu.mpwg.cujana.environmental-data-refresh"

    private let refreshUseCase: RefreshEnvironmentalDataUseCase
    private let locationProvider: any LocationCoordinateProviding
    private let backgroundLocationAuthorizer: (any BackgroundLocationAuthorizing)?
    private let now: () -> Date

    init(
        refreshUseCase: RefreshEnvironmentalDataUseCase,
        locationProvider: any LocationCoordinateProviding,
        backgroundLocationAuthorizer: (any BackgroundLocationAuthorizing)? = nil,
        now: @escaping () -> Date = Date.init
    ) {
        self.refreshUseCase = refreshUseCase
        self.locationProvider = locationProvider
        self.backgroundLocationAuthorizer = backgroundLocationAuthorizer
        self.now = now
    }

    func registerBackgroundRefresh() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.taskIdentifier,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }

            Task { @MainActor in
                self.handle(refreshTask)
            }
        }
    }

    func scheduleBackgroundRefreshIfAllowed() {
        guard backgroundLocationAuthorizer?.allowsBackgroundLocationRefresh == true else {
            return
        }

        scheduleBackgroundRefresh()
    }

    func refreshOnLaunch() async {
        await refresh()
        scheduleBackgroundRefreshIfAllowed()
    }

    private func handle(_ task: BGAppRefreshTask) {
        scheduleBackgroundRefreshIfAllowed()

        let refreshTask = Task { @MainActor in
            await refreshForBackgroundTask()
        }

        task.expirationHandler = {
            refreshTask.cancel()
        }

        Task { @MainActor in
            let didRefresh = await refreshTask.value
            task.setTaskCompleted(success: didRefresh)
        }
    }

    func refreshForBackgroundTask() async -> Bool {
        guard let backgroundLocationAuthorizer else {
            return false
        }

        guard await backgroundLocationAuthorizer.requestBackgroundLocationRefreshAuthorization() else {
            return false
        }

        return await refresh()
    }

    @discardableResult
    private func refresh() async -> Bool {
        guard let coordinate = await locationProvider.currentCoordinate() else {
            return false
        }

        do {
            _ = try await refreshUseCase.execute(for: coordinate, currentDate: now())
            return true
        } catch {
            AppObservability.log(
                .warning,
                "Umweltdaten konnten nicht aktualisiert werden.",
                category: "EnvironmentalData",
                metadata: ["error": String(describing: error)]
            )
            return false
        }
    }

    private func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: RefreshEnvironmentalDataUseCase.minimumRefreshInterval)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            AppObservability.log(
                .warning,
                "Hintergrund-Aktualisierung konnte nicht geplant werden.",
                category: "EnvironmentalData",
                metadata: ["error": String(describing: error)]
            )
        }
    }
}
