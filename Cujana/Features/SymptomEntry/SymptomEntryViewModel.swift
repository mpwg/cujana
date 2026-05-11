import Foundation
import Observation

@MainActor
@Observable
final class EntryEditorViewModel {
    var selectedSymptoms: Set<SymptomType> = []
    var selectedSeverityLevel: Int?
    var note = ""
    var medicationsText = ""
    var tagsText = ""
    var entryDate = Date()
    var saveStatus = SymptomEntrySaveStatus.idle

    let symptomOptions: [SymptomOption]
    let severityOptions: [SeverityOption]

    let mode: EntryMode

    private let saveUseCase: SaveAllergySymptomEntryUseCase
    private let entryChangePublisher: (any SymptomEntryChangePublishing)?

    init(
        saveUseCase: SaveAllergySymptomEntryUseCase,
        entryChangePublisher: (any SymptomEntryChangePublishing)? = nil,
        mode: EntryMode = .create,
        symptomOptions: [SymptomOption] = SymptomEntryPresentationState.symptomOptions,
        severityOptions: [SeverityOption] = SymptomEntryPresentationState.severityOptions
    ) {
        self.saveUseCase = saveUseCase
        self.entryChangePublisher = entryChangePublisher
        self.mode = mode
        self.symptomOptions = symptomOptions
        self.severityOptions = severityOptions

        if case .edit(let existing) = mode {
            selectedSymptoms = Set(existing.symptoms)
            selectedSeverityLevel = severityOptions.first {
                SymptomSeverity(rawValue: $0.domainValue) == existing.severity
            }?.level
            note = existing.note ?? ""
            medicationsText = existing.medications.map(\.name).joined(separator: ", ")
            tagsText = existing.tags.joined(separator: ", ")
            entryDate = existing.date
        }
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

    @discardableResult
    func submit() async -> AllergySymptomEntry? {
        guard selectedSymptoms.isEmpty == false else {
            saveStatus = .failure("Bitte wähle zuerst mindestens ein Symptom aus.")
            return nil
        }

        guard let severity = selectedSeverity else {
            saveStatus = .failure("Bitte wähle aus, wie stark du das Symptom spürst.")
            return nil
        }

        saveStatus = .saving

        do {
            let savedSymptomCount = selectedSymptoms.count
            let entry = try AllergySymptomEntry(
                id: entryID,
                date: entryDate,
                symptoms: selectedSymptoms.sorted(by: symptomSortOrder),
                severity: severity,
                note: note,
                medications: parsedMedications,
                tags: parsedTags,
                coordinate: preservedCoordinate,
                weatherSnapshot: preservedWeatherSnapshot
            )

            try await saveUseCase.execute(entry)
            entryChangePublisher?.publish(.saved(entry))

            if case .create = mode {
                note = ""
                medicationsText = ""
                tagsText = ""
                selectedSymptoms.removeAll()
                selectedSeverityLevel = nil
                entryDate = Date()
            }

            saveStatus = .success(successMessage(symptomCount: savedSymptomCount))
            return entry
        } catch SymptomEntryError.noteTooLong {
            saveStatus = .failure("Die Notiz ist zu lang. Bitte kürze sie etwas.")
        } catch {
            saveStatus = .failure("Der Eintrag konnte gerade nicht gespeichert werden. Bitte versuche es erneut.")
        }

        return nil
    }

    var screenTitle: String {
        switch mode {
        case .create:
            "Symptome erfassen"
        case .edit:
            "Eintrag bearbeiten"
        }
    }

    var submitButtonTitle: String {
        if isSaving {
            return "Speichern ..."
        }

        switch mode {
        case .create:
            return "Eintrag speichern"
        case .edit:
            return "Änderungen speichern"
        }
    }

    var historicalContextText: String? {
        switch mode {
        case .create:
            nil
        case .edit(let existing):
            if existing.weatherSnapshot != nil {
                "Historische Wetter- und Kontextdaten sind gespeichert und werden nicht neu geladen."
            } else if existing.coordinate != nil {
                "Historischer Ortskontext ist gespeichert und bleibt unverändert."
            } else {
                nil
            }
        }
    }

    private var selectedSeverity: SymptomSeverity? {
        guard let selectedSeverityLevel,
              let option = severityOptions.first(where: { $0.level == selectedSeverityLevel }) else {
            return nil
        }

        return SymptomSeverity(rawValue: option.domainValue)
    }

    private var entryID: UUID {
        switch mode {
        case .create:
            UUID()
        case .edit(let existing):
            existing.id
        }
    }

    private var preservedCoordinate: LocationCoordinate? {
        switch mode {
        case .create:
            nil
        case .edit(let existing):
            existing.coordinate
        }
    }

    private var preservedWeatherSnapshot: WeatherSnapshot? {
        switch mode {
        case .create:
            nil
        case .edit(let existing):
            existing.weatherSnapshot
        }
    }

    private var parsedMedications: [Medication] {
        splitSupplementalText(medicationsText).map { Medication(name: $0) }
    }

    private var parsedTags: [String] {
        splitSupplementalText(tagsText)
    }

    private func splitSupplementalText(_ text: String) -> [String] {
        text
            .split { character in
                character == "," || character == "\n"
            }
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
    }

    private func resetTransientStatus() {
        if saveStatus != .saving {
            saveStatus = .idle
        }
    }

    private func successMessage(symptomCount: Int) -> String {
        if case .edit = mode {
            return "Deine Änderungen wurden gespeichert."
        }

        return symptomCount == 1
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

enum EntryMode: Equatable {
    case create
    case edit(existing: HealthEntry)
}

typealias SymptomEntryViewModel = EntryEditorViewModel
