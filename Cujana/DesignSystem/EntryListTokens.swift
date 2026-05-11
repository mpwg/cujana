import SwiftUI

enum EntryListToken {
    static let screenBackground = ColorToken.backgroundPrimary
    static let dayHeaderText = ColorToken.textSecondary
    static let timeText = ColorToken.textSecondary
    static let contextText = ColorToken.textSecondary
    static let cardGlassTint = ColorToken.cardBackground.opacity(0.72)
    static let cardFallbackBackground = ColorToken.cardBackground.opacity(0.94)
    static let dayHeaderFont = Font.headline.weight(.medium)
    static let timeFont = Font.headline.weight(.medium)
    static let contextIconFont = Font.footnote.weight(.medium)
    static let contextFont = Font.footnote.weight(.medium)
    static let symptomChipFont = Font.callout.weight(.semibold)
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
            SemanticColorToken.highSeverityBackground
        case SymptomSeverity.moderate.rawValue..<SymptomSeverity.severe.rawValue:
            SemanticColorToken.mediumSeverityBackground
        default:
            SemanticColorToken.lowSeverityBackground
        }
    }

    static func symptomForeground(for severity: SymptomSeverity) -> Color {
        switch severity.rawValue {
        case SymptomSeverity.severe.rawValue...:
            SemanticColorToken.highSeverityText
        case SymptomSeverity.moderate.rawValue..<SymptomSeverity.severe.rawValue:
            SemanticColorToken.mediumSeverityText
        default:
            SemanticColorToken.lowSeverityText
        }
    }
}
