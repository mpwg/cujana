import Foundation
import Observation

@MainActor
@Observable
final class SymptomEntryViewModel {
    var selectedSymptoms: Set<SymptomType> = []
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
        selectedSymptoms.isEmpty == false && selectedSeverityLevel != nil && !isSaving
    }

    func selectSymptom(_ symptom: SymptomType) {
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.remove(symptom)
        } else {
            selectedSymptoms.insert(symptom)
        }

        resetTransientStatus()
    }

    func selectSeverity(level: Int) {
        selectedSeverityLevel = level
        resetTransientStatus()
    }

    func submit() async {
        guard selectedSymptoms.isEmpty == false else {
            saveStatus = .failure("Bitte wähle zuerst mindestens ein Symptom aus.")
            return
        }

        guard let severity = selectedSeverity else {
            saveStatus = .failure("Bitte wähle aus, wie stark du das Symptom spürst.")
            return
        }

        saveStatus = .saving

        do {
            let savedSymptomCount = selectedSymptoms.count

            for symptom in selectedSymptoms.sorted(by: symptomSortOrder) {
                let entry = try AllergySymptomEntry(
                    date: entryDate,
                    symptomType: symptom,
                    severity: severity,
                    note: note
                )

                try await saveUseCase.execute(entry)
            }

            note = ""
            selectedSymptoms.removeAll()
            selectedSeverityLevel = nil
            entryDate = Date()
            saveStatus = .success(successMessage(symptomCount: savedSymptomCount))
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

    private func successMessage(symptomCount: Int) -> String {
        symptomCount == 1
            ? "Dein Symptom wurde gespeichert."
            : "Deine Symptome wurden gespeichert."
    }

    private func symptomSortOrder(first: SymptomType, second: SymptomType) -> Bool {
        guard let firstIndex = symptomOptions.firstIndex(where: { $0.type == first }),
              let secondIndex = symptomOptions.firstIndex(where: { $0.type == second }) else {
            return false
        }

        return firstIndex < secondIndex
    }
}
