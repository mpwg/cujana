//
//  DesignTokens.swift
//  Cujana
//
//  Created by Codex on 05.05.26.
//

import SwiftUI

enum ColorToken {
    fileprivate enum Raw {
        static let backgroundPrimary = Color("BackgroundPrimary")
        static let backgroundSecondary = Color("BackgroundSecondary")
        static let cardBackground = Color("CardBackground")
        static let cardMutedBackground = Color("CardMutedBackground")

        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let textTertiary = Color("TextTertiary")

        static let accentPrimary = Color("AccentPrimary")
        static let accentDark = Color("AccentDark")
        static let accentSoft = Color("AccentSoft")
        static let accentPositive = Color("AccentPositive")
        static let accentWarning = Color("AccentWarning")
        static let accentNegative = Color("AccentNegative")
        static let softPeach = Color("SoftPeach")
        static let softSand = Color("SoftSand")

        static let separatorSoft = Color("SeparatorSoft")
    }

    static let backgroundPrimary = Raw.backgroundPrimary
    static let backgroundSecondary = Raw.backgroundSecondary
    static let cardBackground = Raw.cardBackground
    static let cardMutedBackground = Raw.cardMutedBackground

    static let textPrimary = Raw.textPrimary
    static let textSecondary = Raw.textSecondary
    static let textTertiary = Raw.textTertiary

    static let accentPrimary = Raw.accentPrimary
    static let accentDark = Raw.accentDark
    static let accentSoft = Raw.accentSoft
    static let accentPositive = Raw.accentPositive
    static let accentWarning = Raw.accentWarning
    static let accentNegative = Raw.accentNegative
    static let softPeach = Raw.softPeach
    static let softSand = Raw.softSand
    static let separatorSoft = Raw.separatorSoft

    static let secondarySurface = Raw.cardBackground.opacity(0.88)
}

enum DetailColorToken {
    fileprivate enum Raw {
        static let background = ColorToken.backgroundPrimary
        static let mutedSurface = ColorToken.cardMutedBackground
        static let sage = ColorToken.accentPrimary
        static let sageSoft = ColorToken.accentSoft
        static let neutralStroke = ColorToken.separatorSoft
        static let warningSoft = SemanticColorToken.mediumSeverityBackground
        static let alertSoft = SemanticColorToken.highSeverityBackground
        static let hourlyActiveTop = SemanticColorToken.highSeverityBackground
        static let hourlyActiveBottom = SemanticColorToken.highSeverityBackground
    }

    static let background = Raw.background
    static let surface = ColorToken.cardBackground.opacity(0.78)
    static let mutedSurface = Raw.mutedSurface.opacity(0.52)
    static let sage = Raw.sage
    static let sageSoft = Raw.sageSoft
    static let neutralStroke = Raw.neutralStroke.opacity(0.34)
    static let warningSoft = Raw.warningSoft
    static let alertSoft = Raw.alertSoft
    static let hourlyActiveTop = Raw.hourlyActiveTop
    static let hourlyActiveBottom = Raw.hourlyActiveBottom

    static let sageQuiet = Raw.sage.opacity(0.68)
    static let sageTertiary = Raw.sage.opacity(0.72)
    static let sageAccentBorder = Raw.sage.opacity(0.16)
    static let selectedPickerBackground = Raw.sageSoft.opacity(0.58)
    static let weatherIconBackground = Raw.sageSoft.opacity(0.46)
    static let riskBackground = 0.34
    static let currentRiskBackground = 0.38
    static let quietRiskBackground = 0.24
    static let overviewRiskBackground = 0.34
    static let primaryTextSubtle = 0.96
    static let secondaryTextSubtle = 0.96
    static let secondaryTextReadable = 1.0
    static let weatherDescriptionText = 1.0
    static let weatherMetricText = 1.0
    static let hourlyPrimaryText = 0.92
    static let attributionText = 0.82
    static let contextText = 0.9
    static let quietStroke = 0.62
    static let softStroke = 0.68
    static let rowStroke = 0.72
    static let navigationSurface = 0.66
    static let hourlyInactiveBackground = 0.55

    static func riskBackground(for text: String) -> Color {
        switch text {
        case "Keine Belastung", "Niedrig":
            SemanticColorToken.lowSeverityBackground
        case "Mittel":
            SemanticColorToken.mediumSeverityBackground
        default:
            SemanticColorToken.highSeverityBackground
        }
    }

    static func riskDot(for text: String) -> Color {
        switch text {
        case "Keine Belastung", "Niedrig":
            SemanticColorToken.lowSeverityText
        case "Mittel":
            SemanticColorToken.mediumSeverityText
        default:
            SemanticColorToken.highSeverityText
        }
    }
}

enum SemanticColorToken {
    static let highSeverityBackground = Color("HighSeverityBackground")
    static let highSeverityText = Color("HighSeverityText")
    static let mediumSeverityBackground = Color("MediumSeverityBackground")
    static let mediumSeverityText = Color("MediumSeverityText")
    static let lowSeverityBackground = Color("LowSeverityBackground")
    static let lowSeverityText = Color("LowSeverityText")
    static let disabledButtonBackground = Color("DisabledButtonBackground")

    static func background(for text: String) -> Color {
        switch text {
        case "Mittel":
            mediumSeverityBackground
        case "Hoch", "Sehr hoch", "Extrem":
            highSeverityBackground
        default:
            lowSeverityBackground
        }
    }

    static func foreground(for text: String) -> Color {
        switch text {
        case "Mittel":
            mediumSeverityText
        case "Hoch", "Sehr hoch", "Extrem":
            highSeverityText
        default:
            lowSeverityText
        }
    }
}

enum TypographyToken {
    static let largeTitle = Font.largeTitle.weight(.semibold)
    static let detailTitle = Font.title.weight(.semibold)
    static let heroTitle = Font.title.weight(.semibold)
    static let sheetTitle = Font.title3.weight(.semibold)
    static let sheetHeading = Font.title.weight(.semibold)
    static let title = Font.title.weight(.semibold)
    static let ctaHeroTitle = Font.title2.weight(.semibold)
    static let ctaLabel = Font.caption.weight(.medium)
    static let ctaSupporting = Font.subheadline
    static let ctaButton = Font.body.weight(.semibold)
    static let headline = Font.headline.weight(.semibold)
    static let weatherTemperature = Font.largeTitle.weight(.semibold)
    static let weatherDescription = Font.headline.weight(.medium)
    static let forecastSectionTitle = Font.headline.weight(.semibold)
    static let loadHeadline = Font.headline.weight(.semibold)
    static let personalStatusTitle = Font.headline.weight(.semibold)
    static let personalStatusSubtitle = Font.subheadline
    static let detailStatusTitle = Font.title3.weight(.semibold)
    static let detailStatusSubtitle = Font.subheadline
    static let detailSegment = Font.callout.weight(.medium)
    static let allergenTitle = Font.body.weight(.semibold)
    static let allergenDescription = Font.subheadline
    static let symptomHeading = Font.title2.weight(.semibold)
    static let symptomText = Font.subheadline
    static let symptomPill = Font.callout.weight(.semibold)
    static let symptomSectionTitle = Font.headline.weight(.semibold)
    static let symptomSectionDescription = Font.subheadline
    static let symptomInfoTitle = Font.headline.weight(.semibold)
    static let severityControl = Font.subheadline.weight(.semibold)
    static let hourlyHour = Font.caption.weight(.medium)
    static let hourlySeverity = Font.subheadline.weight(.semibold)
    static let dayTemperature = Font.headline.weight(.medium)

    static let body = Font.body
    static let bodyEmphasized = Font.body.weight(.semibold)
    static let secondaryBody = Font.subheadline

    static let caption = Font.footnote.weight(.medium)
    static let attribution = Font.footnote
    static let tinyMeta = Font.footnote
    static let severityPill = Font.subheadline.weight(.medium)
    static let footnote = Font.footnote

    static let button = Font.headline.weight(.semibold)
}

enum SpacingToken {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 22
    static let xxl: CGFloat = 32
    static let section: CGFloat = 20
}

enum RadiusToken {
    static let radiusSmall: CGFloat = 16
    static let radiusMedium: CGFloat = 22
    static let radiusLarge: CGFloat = 28
    static let radiusXLarge: CGFloat = 40
    static let full: CGFloat = 999
}

struct ShadowTokenValue {
    let color: Color
    let radius: CGFloat
    let y: CGFloat
}

enum ShadowToken {
    static let card = ShadowTokenValue(
        color: Color.black.opacity(0.03),
        radius: 18,
        y: 6
    )

    static let modal = ShadowTokenValue(
        color: Color.black.opacity(0.05),
        radius: 28,
        y: 12
    )

    static let floating = ShadowTokenValue(
        color: Color.black.opacity(0.04),
        radius: 20,
        y: 6
    )

    static let ctaButton = ShadowTokenValue(
        color: Color.black.opacity(0.035),
        radius: 10,
        y: 4
    )
}

enum MotionToken {
    static let detailSelection = Animation.spring(response: 0.32, dampingFraction: 0.86)
    static let reducedMotionDuration = 0.01
}

extension Color {
    init(hex: String) {
        let value = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: value).scanHexInt64(&rgb)

        self.init(
            .sRGB,
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255,
            opacity: 1
        )
    }
}
