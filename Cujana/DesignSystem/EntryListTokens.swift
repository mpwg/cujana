import SwiftUI

enum EntryListToken {
    static let screenBackground = Color(hex: "#F6F4EF")
    static let dayHeaderText = Color(hex: "#8B857C")
    static let timeText = Color(hex: "#6E6A64")
    static let contextText = Color(hex: "#6B6B6E")
    static let cardGlassTint = ColorToken.cardBackground.opacity(0.72)
    static let cardFallbackBackground = ColorToken.cardBackground.opacity(0.94)
    static let dayHeaderFont = Font.system(size: 18, weight: .medium, design: .rounded)
    static let timeFont = Font.system(size: 18, weight: .medium, design: .rounded)
    static let contextIconFont = Font.system(size: 14, weight: .medium, design: .rounded)
    static let contextFont = Font.system(size: 15, weight: .medium, design: .rounded)
    static let symptomChipFont = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let timeline = Color.black.opacity(0.08)
    static let timelineDot = Color.black.opacity(0.18)
    static let screenHorizontalPadding: CGFloat = 22
    static let cardPaddingTop: CGFloat = 22
    static let cardPaddingHorizontal: CGFloat = 24
    static let cardPaddingBottom: CGFloat = 20
    static let cardSpacing: CGFloat = 20
    static let cardCornerRadius: CGFloat = 26
    static let cardShadow = ShadowTokenValue(
        color: Color.black.opacity(0.025),
        radius: 12,
        y: 4
    )
    static let timelineWidth: CGFloat = 14
    static let timelineDotSize: CGFloat = 6
    static let timelineLineWidth: CGFloat = 1
    static let timelineLineTopInset: CGFloat = 38
    static let timelineLineBottomInset: CGFloat = 26
    static let timelineDotTopInset: CGFloat = 29
    static let timelineCardSpacing: CGFloat = 10
    static let timeSymptomSpacing: CGFloat = 18
    static let symptomContextSpacing: CGFloat = 18
    static let chipSpacing: CGFloat = 8
    static let chipRowSpacing: CGFloat = 8
    static let symptomChipMinHeight: CGFloat = 35
    static let symptomChipPaddingH: CGFloat = 14
    static let symptomChipPaddingV: CGFloat = 7
    static let symptomChipCornerRadius: CGFloat = 17
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
