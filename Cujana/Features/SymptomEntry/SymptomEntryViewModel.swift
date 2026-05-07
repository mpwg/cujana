import Foundation
import Observation

@MainActor
@Observable
final class SymptomEntryViewModel {
    var selectedSymptom: SymptomType?
    var selectedSeverityLevel: Int?
    var note = ""
    var entryDate = Date()
    var saveStatus = SymptomEntrySaveStatus.idle

    let symptomOptions: [SymptomOption]
    let severityOptions: [SeverityOption]

    private let saveUseCase: SaveAllergySymptomEntryUseCase

    init(
        saveUseCase: SaveAllergySymptomEntryUseCase,
        symptomOptions: [SymptomOption] = SymptomEntryPresentationState.symptomOptions,
        severityOptions: [SeverityOption] = SymptomEntryPresentationState.severityOptions
    ) {
        self.saveUseCase = saveUseCase
        self.symptomOptions = symptomOptions
        self.severityOptions = severityOptions
    }

    var isSaving: Bool {
        saveStatus == .saving
    }

    var canSubmit: Bool {
        selectedSymptom != nil && selectedSeverityLevel != nil && !isSaving
    }

    func selectSymptom(_ symptom: SymptomType) {
        selectedSymptom = symptom
        resetTransientStatus()
    }

    func selectSeverity(level: Int) {
        selectedSeverityLevel = level
        resetTransientStatus()
    }

    func submit() async {
        guard let symptom = selectedSymptom else {
            saveStatus = .failure("Bitte wähle zuerst ein Symptom aus.")
            return
        }

        guard let severity = selectedSeverity else {
            saveStatus = .failure("Bitte wähle aus, wie stark du das Symptom spürst.")
            return
        }

        saveStatus = .saving

        do {
            let entry = try AllergySymptomEntry(
                date: entryDate,
                symptomType: symptom,
                severity: severity,
                note: note
            )

            try await saveUseCase.execute(entry)
            note = ""
            selectedSymptom = nil
            selectedSeverityLevel = nil
            entryDate = Date()
            saveStatus = .success("Dein Symptom wurde gespeichert.")
        } catch SymptomEntryError.noteTooLong {
            saveStatus = .failure("Die Notiz ist zu lang. Bitte kürze sie etwas.")
        } catch {
            saveStatus = .failure("Der Eintrag konnte gerade nicht gespeichert werden. Bitte versuche es erneut.")
        }
    }

    private var selectedSeverity: SymptomSeverity? {
        guard let selectedSeverityLevel,
              let option = severityOptions.first(where: { $0.level == selectedSeverityLevel }) else {
            return nil
        }

        return SymptomSeverity(rawValue: option.domainValue)
    }

    private func resetTransientStatus() {
        if saveStatus != .saving {
            saveStatus = .idle
        }
    }
}
