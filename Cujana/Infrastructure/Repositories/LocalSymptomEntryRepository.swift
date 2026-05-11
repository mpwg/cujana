import Foundation
import SwiftData

actor LocalSymptomEntryRepository: SymptomEntryRepository {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func save(_ entry: AllergySymptomEntry) async throws {
        do {
            let context = ModelContext(modelContainer)
            try deleteExistingRecord(id: entry.id, in: context)
            context.insert(CujanaSchemaV1.SymptomEntryRecord(entry: entry))
            try context.save()
        } catch {
            throw SymptomEntryError.storageUnavailable
        }
    }

    func delete(id: UUID) async throws {
        do {
            let context = ModelContext(modelContainer)
            try deleteExistingRecord(id: id, in: context)
            try context.save()
        } catch {
            throw SymptomEntryError.storageUnavailable
        }
    }

    func symptomEntries(from startDate: Date, to endDate: Date) async throws -> [AllergySymptomEntry] {
        do {
            let context = ModelContext(modelContainer)
            let descriptor = FetchDescriptor<CujanaSchemaV1.SymptomEntryRecord>(
                predicate: #Predicate { record in
                    record.date >= startDate && record.date <= endDate
                },
                sortBy: [SortDescriptor(\.date)]
            )
            let records = try context.fetch(descriptor)

            return try records.map { try $0.domainEntry() }
        } catch {
            throw SymptomEntryError.storageUnavailable
        }
    }

    private func deleteExistingRecord(id: UUID, in context: ModelContext) throws {
        let descriptor = FetchDescriptor<CujanaSchemaV1.SymptomEntryRecord>(
            predicate: #Predicate { record in
                record.id == id
            }
        )
        let records = try context.fetch(descriptor)
        records.forEach(context.delete)
    }
}
