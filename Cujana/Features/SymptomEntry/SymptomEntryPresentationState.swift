import SwiftUI

struct SymptomOption: Identifiable, Equatable {
    let type: SymptomType
    let title: String
    let systemImageName: String
    let background: Color

    var id: SymptomType {
        type
    }
}

struct SeverityOption: Identifiable, Equatable {
    let level: Int
    let title: String
    let domainValue: Int

    var id: Int {
        level
    }
}

enum SymptomEntrySaveStatus: Equatable {
    case idle
    case saving
    case success(String)
    case failure(String)

    var message: String? {
        switch self {
        case .idle, .saving:
            nil
        case .success(let message), .failure(let message):
            message
        }
    }

    var isError: Bool {
        if case .failure = self {
            return true
        }

        return false
    }
}

enum SymptomEntryPresentationState {
    static let symptomOptions = [
        SymptomOption(
            type: .sneezing,
            title: "Niesen",
            systemImageName: "leaf",
            background: ChipToken.calmBackground
        ),
        SymptomOption(
            type: .runnyNose,
            title: "Laufende Nase",
            systemImageName: "drop",
            background: ChipToken.selectedBackground
        ),
        SymptomOption(
            type: .blockedNose,
            title: "Verstopfte Nase",
            systemImageName: "nose",
            background: ChipToken.background
        ),
        SymptomOption(
            type: .itchyEyes,
            title: "Juckende Augen",
            systemImageName: "eye",
            background: ChipToken.alertBackground
        ),
        SymptomOption(
            type: .coughing,
            title: "Husten",
            systemImageName: "lungs",
            background: ChipToken.alertBackground
        ),
        SymptomOption(
            type: .fatigue,
            title: "Müdigkeit",
            systemImageName: "powersleep",
            background: ChipToken.calmBackground
        ),
        SymptomOption(
            type: .headache,
            title: "Kopfschmerz",
            systemImageName: "brain.head.profile",
            background: ChipToken.warmBackground
        ),
        SymptomOption(
            type: .wateryEyes,
            title: "Tränende Augen",
            systemImageName: "eye.trianglebadge.exclamationmark",
            background: ChipToken.selectedBackground
        ),
        SymptomOption(
            type: .wheezing,
            title: "Atemgeräusch",
            systemImageName: "wind",
            background: ChipToken.background
        ),
        SymptomOption(
            type: .shortnessOfBreath,
            title: "Atemnot",
            systemImageName: "lungs.fill",
            background: ChipToken.alertBackground
        )
    ]

    static let severityOptions = [
        SeverityOption(level: 1, title: "Sehr mild", domainValue: 2),
        SeverityOption(level: 2, title: "Mild", domainValue: 4),
        SeverityOption(level: 3, title: "Mittel", domainValue: 6),
        SeverityOption(level: 4, title: "Stark", domainValue: 8),
        SeverityOption(level: 5, title: "Sehr stark", domainValue: 10)
    ]
}
