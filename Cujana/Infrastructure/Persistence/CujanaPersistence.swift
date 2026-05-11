import SwiftData

enum CujanaPersistence {
    static func makeProductionModelContainer() throws -> ModelContainer {
        try makeModelContainer(isStoredInMemoryOnly: false)
    }

    static func makeInMemoryModelContainer() throws -> ModelContainer {
        try makeModelContainer(isStoredInMemoryOnly: true)
    }

    private static func makeModelContainer(isStoredInMemoryOnly: Bool) throws -> ModelContainer {
        let schema = Schema(versionedSchema: CujanaSchemaV1.self)
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly
        )

        return try ModelContainer(
            for: schema,
            migrationPlan: CujanaMigrationPlan.self,
            configurations: [configuration]
        )
    }
}
