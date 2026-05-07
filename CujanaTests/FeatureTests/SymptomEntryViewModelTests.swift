import Foundation
import Testing
@testable import Cujana

struct SymptomEntryViewModelTests {

    @Test
    @MainActor
    func submitStoresEntryThroughUseCase() async throws {
        let repository = CapturingSymptomEntryRepository()
        let viewModel = SymptomEntryViewModel(
            saveUseCase: SaveAllergySymptomEntryUseCase(repository: repository)
        )
        let entryDate = Date(timeIntervalSince1970: 1_800)

        viewModel.selectSymptom(.itchyEyes)
        viewModel.selectSeverity(level: 3)
        viewModel.entryDate = entryDate
        viewModel.note = "  Draußen stärker gespürt.  "

        await viewModel.submit()

        let entries = await repository.savedEntries()
        #expect(entries.count == 1)
        #expect(entries.first?.date == entryDate)
        #expect(entries.first?.symptomType == .itchyEyes)
        #expect(entries.first?.severity == SymptomSeverity(rawValue: 6))
        #expect(entries.first?.note == "Draußen stärker gespürt.")
        #expect(viewModel.saveStatus == .success("Dein Symptom wurde gespeichert."))
    }

    @Test
    @MainActor
    func submitShowsFriendlyValidationWhenSymptomIsMissing() async {
        let repository = CapturingSymptomEntryRepository()
        let viewModel = SymptomEntryViewModel(
            saveUseCase: SaveAllergySymptomEntryUseCase(repository: repository)
        )

        viewModel.selectSeverity(level: 2)

        await viewModel.submit()

        let entries = await repository.savedEntries()
        #expect(entries.isEmpty)
        #expect(viewModel.saveStatus == .failure("Bitte wähle zuerst ein Symptom aus."))
    }

    @Test
    @MainActor
    func submitShowsFriendlyValidationWhenSeverityIsMissing() async {
        let repository = CapturingSymptomEntryRepository()
        let viewModel = SymptomEntryViewModel(
            saveUseCase: SaveAllergySymptomEntryUseCase(repository: repository)
        )

        viewModel.selectSymptom(.runnyNose)

        await viewModel.submit()

        let entries = await repository.savedEntries()
        #expect(entries.isEmpty)
        #expect(viewModel.saveStatus == .failure("Bitte wähle aus, wie stark du das Symptom spürst."))
    }
}

private actor CapturingSymptomEntryRepository: SymptomEntryRepository {
    private var entries: [AllergySymptomEntry] = []

    func save(_ entry: AllergySymptomEntry) async throws {
        entries.append(entry)
    }

    func symptomEntries(from startDate: Date, to endDate: Date) async throws -> [AllergySymptomEntry] {
        entries.filter { entry in
            entry.date >= startDate && entry.date <= endDate
        }
    }

    func savedEntries() -> [AllergySymptomEntry] {
        entries
    }
}
