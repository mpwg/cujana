import SwiftUI

enum EntryListToken {
    static let screenBackground = Color(hex: "#F6F4EF")
    static let dayHeaderText = Color(hex: "#8B857C")
    static let entryDateText = Color(hex: "#1C1C1E")
    static let timeText = Color(hex: "#6E6A64")
    static let contextText = Color(hex: "#6B6B6E")
    static let timeline = Color.black.opacity(0.08)
    static let timelineDot = Color.black.opacity(0.16)
    static let cardPadding: CGFloat = 24
    static let cardSpacing: CGFloat = 20
    static let cardCornerRadius: CGFloat = 30
    static let cardShadow = ShadowTokenValue(
        color: Color.black.opacity(0.04),
        radius: 20,
        y: 6
    )
    static let timelineWidth: CGFloat = 18
    static let timelineDotSize: CGFloat = 7
    static let timelineLineWidth: CGFloat = 1
    static let timelineCardSpacing: CGFloat = 12
    static let dateTimeSpacing: CGFloat = 12
    static let timeSymptomSpacing: CGFloat = 20
    static let symptomContextSpacing: CGFloat = 18
    static let chipSpacing: CGFloat = 8
    static let chipRowSpacing: CGFloat = 10
    static let symptomChipMinHeight: CGFloat = 38
    static let symptomChipPaddingH: CGFloat = 14
    static let symptomChipPaddingV: CGFloat = 10
    static let symptomChipCornerRadius: CGFloat = 19
    static let journalAnimation = Animation.spring(response: 0.38, dampingFraction: 0.88)

    static func symptomBackground(for severity: SymptomSeverity) -> Color {
        switch severity.rawValue {
        case SymptomSeverity.severe.rawValue...:
            Color(hex: "#F2D7D1")
        case SymptomSeverity.moderate.rawValue..<SymptomSeverity.severe.rawValue:
            Color(hex: "#EFE5D5")
        default:
            Color(hex: "#EDF3EC")
        }
    }

    static func symptomForeground(for severity: SymptomSeverity) -> Color {
        switch severity.rawValue {
        case SymptomSeverity.severe.rawValue...:
            Color(hex: "#6B3B34")
        case SymptomSeverity.moderate.rawValue..<SymptomSeverity.severe.rawValue:
            Color(hex: "#5A4732")
        default:
            Color(hex: "#314235")
        }
    }
}
