import Foundation
import SwiftData

enum CujanaPersistence {
    static func makeProductionModelContainer() throws -> ModelContainer {
        try makeProductionModelContainer {
            try makeModelContainer(schema: $0, configuration: $1)
        }
    }

    static func makeProductionModelContainer(
        applicationSupportDirectoryURL: URL? = nil,
        loadContainer: (Schema, ModelConfiguration) throws -> ModelContainer
    ) throws -> ModelContainer {
        let schema = Schema(versionedSchema: CujanaSchemaV1.self)
        let storeURL = try defaultStoreURL(applicationSupportDirectoryURL: applicationSupportDirectoryURL)
        let configuration = ModelConfiguration(
            "default",
            schema: schema,
            url: storeURL
        )

        do {
            return try loadContainer(schema, configuration)
        } catch {
            let context = PersistentStoreRecoveryService.recoveryContext(for: error, storeURL: storeURL)
            AppObservability.log(
                .error,
                "SwiftData-Store konnte nicht geöffnet werden.",
                category: "Persistence",
                metadata: [
                    "reason": context.reason.rawValue,
                    "error": context.errorSummary
                ]
            )
            throw PersistentStoreLoadError.recoveryRequired(context)
        }
    }

    static func makeInMemoryModelContainer() throws -> ModelContainer {
        let schema = Schema(versionedSchema: CujanaSchemaV1.self)
        let configuration = ModelConfiguration(
            "in-memory",
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return try makeModelContainer(schema: schema, configuration: configuration)
    }

    static func defaultStoreURL(
        applicationSupportDirectoryURL: URL? = nil,
        fileManager: FileManager = .default
    ) throws -> URL {
        guard let applicationSupportURL = applicationSupportDirectoryURL
            ?? fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        else {
            throw AppStartupPreparationError.applicationSupportDirectoryUnavailable
        }

        try fileManager.createDirectory(at: applicationSupportURL, withIntermediateDirectories: true)
        return applicationSupportURL.appending(path: "default.store")
    }

    private static func makeModelContainer(
        schema: Schema,
        configuration: ModelConfiguration
    ) throws -> ModelContainer {
        try ModelContainer(
            for: schema,
            migrationPlan: CujanaMigrationPlan.self,
            configurations: [configuration]
        )
    }

}
