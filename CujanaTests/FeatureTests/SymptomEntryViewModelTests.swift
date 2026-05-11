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
        viewModel.medicationsText = "Antihistaminikum, Nasenspray"
        viewModel.tagsText = "Park, Arbeit"

        await viewModel.submit()

        let entries = await repository.savedEntries()
        #expect(entries.count == 1)
        #expect(entries.first?.date == entryDate)
        #expect(entries.first?.symptoms == [.itchyEyes])
        #expect(entries.first?.severity == SymptomSeverity(rawValue: 6))
        #expect(entries.first?.note == "Draußen stärker gespürt.")
        #expect(entries.first?.medications.map(\.name) == ["Antihistaminikum", "Nasenspray"])
        #expect(entries.first?.tags == ["Park", "Arbeit"])
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
        #expect(viewModel.saveStatus == .failure("Bitte wähle zuerst mindestens ein Symptom aus."))
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

    @Test
    @MainActor
    func changingSelectionClearsValidationFailure() async {
        let repository = CapturingSymptomEntryRepository()
        let viewModel = SymptomEntryViewModel(
            saveUseCase: SaveAllergySymptomEntryUseCase(repository: repository)
        )

        await viewModel.submit()
        viewModel.selectSymptom(.sneezing)

        #expect(viewModel.saveStatus == .idle)
    }

    @Test
    @MainActor
    func submitStoresMultipleSelectedSymptoms() async throws {
        let repository = CapturingSymptomEntryRepository()
        let viewModel = SymptomEntryViewModel(
            saveUseCase: SaveAllergySymptomEntryUseCase(repository: repository)
        )

        viewModel.selectSymptom(.sneezing)
        viewModel.selectSymptom(.itchyEyes)
        viewModel.selectSeverity(level: 2)

        await viewModel.submit()

        let entries = await repository.savedEntries()
        #expect(entries.count == 1)
        #expect(entries.first?.symptoms == [.sneezing, .itchyEyes])
        #expect(entries.first?.severity == SymptomSeverity(rawValue: 4))
        #expect(viewModel.saveStatus == .success("Deine Symptome wurden gespeichert."))
    }

    @Test
    @MainActor
    func editModePrefillsAndPreservesEntryIdentityAndCoordinate() async throws {
        let repository = CapturingSymptomEntryRepository()
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let entryID = try #require(UUID(uuidString: "77777777-7777-7777-7777-777777777777"))
        let existing = try AllergySymptomEntry(
            id: entryID,
            date: Date(timeIntervalSince1970: 2_000),
            symptoms: [.itchyEyes, .sneezing],
            severity: SymptomSeverity(rawValue: 6),
            note: "Alt",
            medications: [Medication(name: "Altmedikament")],
            tags: ["Park"],
            coordinate: coordinate
        )
        let viewModel = EntryEditorViewModel(
            saveUseCase: SaveAllergySymptomEntryUseCase(repository: repository),
            mode: .edit(existing: existing)
        )

        #expect(viewModel.selectedSymptoms == Set([.itchyEyes, .sneezing]))
        #expect(viewModel.selectedSeverityLevel == 3)
        #expect(viewModel.note == "Alt")
        #expect(viewModel.medicationsText == "Altmedikament")
        #expect(viewModel.tagsText == "Park")
        #expect(viewModel.entryDate == existing.date)

        viewModel.selectSymptom(.coughing)
        viewModel.note = "Aktualisiert"
        viewModel.medicationsText = "Neues Medikament"
        viewModel.tagsText = "Park, Frühling"

        let savedEntry = await viewModel.submit()

        #expect(savedEntry?.id == entryID)
        #expect(savedEntry?.coordinate == coordinate)
        #expect(savedEntry?.note == "Aktualisiert")
        #expect(savedEntry?.medications.map(\.name) == ["Neues Medikament"])
        #expect(savedEntry?.tags == ["Park", "Frühling"])
        #expect(savedEntry?.symptoms == [.sneezing, .itchyEyes, .coughing])
        #expect(viewModel.saveStatus == .success("Deine Änderungen wurden gespeichert."))
    }

    @Test
    @MainActor
    func submitShowsFriendlyFailureWhenNoteIsTooLong() async {
        let repository = CapturingSymptomEntryRepository()
        let viewModel = SymptomEntryViewModel(
            saveUseCase: SaveAllergySymptomEntryUseCase(repository: repository)
        )

        viewModel.selectSymptom(.fatigue)
        viewModel.selectSeverity(level: 2)
        viewModel.note = String(repeating: "a", count: AllergySymptomEntry.maximumNoteLength + 1)

        await viewModel.submit()

        let entries = await repository.savedEntries()
        #expect(entries.isEmpty)
        #expect(viewModel.saveStatus == .failure("Die Notiz ist zu lang. Bitte kürze sie etwas."))
    }

    @Test
    @MainActor
    func submitShowsFriendlyFailureWhenRepositoryThrows() async {
        let repository = CapturingSymptomEntryRepository(saveError: SymptomEntryError.storageUnavailable)
        let viewModel = SymptomEntryViewModel(
            saveUseCase: SaveAllergySymptomEntryUseCase(repository: repository)
        )

        viewModel.selectSymptom(.coughing)
        viewModel.selectSeverity(level: 4)

        await viewModel.submit()

        #expect(
            viewModel.saveStatus == .failure(
                "Der Eintrag konnte gerade nicht gespeichert werden. Bitte versuche es erneut."
            )
        )
    }
}

private actor CapturingSymptomEntryRepository: SymptomEntryRepository {
    private var entries: [AllergySymptomEntry] = []
    private let saveError: Error?

    init(saveError: Error? = nil) {
        self.saveError = saveError
    }

    func save(_ entry: AllergySymptomEntry) async throws {
        if let saveError {
            throw saveError
        }

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
