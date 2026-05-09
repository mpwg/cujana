import SwiftUI

struct AllergyDashboardContent: Equatable {
    let title: String
    let subtitle: String
    let forecastDays: [ForecastDaySummaryItem]
    let pollenItems: [PollenDashboardItem]
    let symptomItems: [SymptomDashboardItem]
    let generatedAtText: String
}

struct ForecastDaySummaryItem: Identifiable, Equatable {
    let id: String
    let title: String
    let temperatureText: String
    let weatherText: String
    let weatherSystemImageName: String
    let pollenText: String
    let accessibilityText: String
}

struct PollenDashboardItem: Identifiable, Equatable {
    let type: PollenType
    let title: String
    let levelText: String
    let levelDescription: String
    let systemImageName: String
    let background: Color

    var id: PollenType {
        type
    }
}

struct SymptomDashboardItem: Identifiable, Equatable {
    let id: UUID
    let title: String
    let severityText: String
    let dateText: String
    let noteText: String?
    let systemImageName: String
    let background: Color
}

enum AllergyDashboardState: Equatable {
    case idle
    case loading
    case empty(AllergyDashboardContent)
    case loaded(AllergyDashboardContent)
    case failure(String)
}

enum AllergyDashboardPresentationState {
    static func title(for pollenType: PollenType) -> String {
        switch pollenType {
        case .alder:
            "Erle"
        case .ash:
            "Esche"
        case .birch:
            "Birke"
        case .grass:
            "Gräser"
        case .hazel:
            "Hasel"
        case .mugwort:
            "Beifuß"
        case .oak:
            "Eiche"
        case .ragweed:
            "Ragweed"
        case .rye:
            "Roggen"
        }
    }

    static func title(for symptomType: SymptomType) -> String {
        switch symptomType {
        case .blockedNose:
            "Verstopfte Nase"
        case .coughing:
            "Husten"
        case .fatigue:
            "Müdigkeit"
        case .headache:
            "Kopfschmerz"
        case .itchyEyes:
            "Juckende Augen"
        case .runnyNose:
            "Laufende Nase"
        case .shortnessOfBreath:
            "Atemnot"
        case .sneezing:
            "Niesen"
        case .wateryEyes:
            "Tränende Augen"
        case .wheezing:
            "Atemgeräusch"
        }
    }

    static func levelText(for level: PollenLevel) -> String {
        switch level.rawValue {
        case 0:
            "Keine Belastung"
        case 1:
            "Niedrig"
        case 2:
            "Mittel"
        case 3:
            "Hoch"
        case 4:
            "Sehr hoch"
        default:
            "Extrem"
        }
    }

    static func levelDescription(for level: PollenLevel) -> String {
        switch level.rawValue {
        case 0:
            "Heute kaum relevant."
        case 1:
            "Leicht im Blick behalten."
        case 2:
            "Kann spürbar werden."
        case 3:
            "Plane ruhiger im Freien."
        case 4:
            "Belastung möglichst meiden."
        default:
            "Starke Belastung erwartet."
        }
    }

    static func severityText(for severity: SymptomSeverity) -> String {
        switch severity.rawValue {
        case 0:
            "Nicht spürbar"
        case 1...3:
            "Mild"
        case 4...6:
            "Mittel"
        case 7...9:
            "Stark"
        default:
            "Sehr stark"
        }
    }

    static func pollenBackground(for level: PollenLevel) -> Color {
        switch level.rawValue {
        case 0...1:
            ChipToken.calmBackground
        case 2...3:
            ChipToken.warmBackground
        default:
            ChipToken.alertBackground
        }
    }

    static func symptomBackground(for severity: SymptomSeverity) -> Color {
        switch severity.rawValue {
        case 0...3:
            ChipToken.calmBackground
        case 4...6:
            ChipToken.warmBackground
        default:
            ChipToken.alertBackground
        }
    }
}
