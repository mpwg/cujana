//
//  DesignTokens.swift
//  Cujana
//
//  Created by Codex on 05.05.26.
//

import SwiftUI

enum ColorToken {
    fileprivate enum Raw {
        static let backgroundPrimary = Color(hex: "#F7F4EE")
        static let backgroundSecondary = Color(hex: "#F1ECE4")
        static let cardBackground = Color(hex: "#FFFFFF")
        static let cardMutedBackground = Color(hex: "#F1ECE4")

        static let textPrimary = Color(hex: "#1E1E1C")
        static let textSecondary = Color(hex: "#6E6A63")
        static let textTertiary = Color(hex: "#9B958C")

        static let accentPrimary = Color(hex: "#5B7F67")
        static let accentDark = Color(hex: "#486553")
        static let accentSoft = Color(hex: "#DDEADF")
        static let accentPositive = Color(hex: "#47624C")
        static let accentWarning = Color(hex: "#7C6240")
        static let accentNegative = Color(hex: "#8A4A3D")
        static let softPeach = Color(hex: "#F2DDD2")
        static let softSand = Color(hex: "#ECE4D8")

        static let separatorSoft = Color(hex: "#ECE4D8")
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
        static let background = Color(hex: "#F4F1EA")
        static let mutedSurface = Color(hex: "#E9E4DA")
        static let sage = Color(hex: "#56665B")
        static let sageSoft = Color(hex: "#DEE5DA")
        static let neutralStroke = Color(hex: "#DDD6CC")
        static let warningSoft = Color(hex: "#EEE4D0")
        static let alertSoft = Color(hex: "#EEDBD7")
        static let hourlyActiveTop = Color(hex: "#F6E5E0")
        static let hourlyActiveBottom = Color(hex: "#F4DDD7")
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
    static let highSeverityBackground = Color(hex: "#F4DDD7")
    static let highSeverityText = Color(hex: "#8A4A3D")
    static let mediumSeverityBackground = Color(hex: "#F2E9D7")
    static let mediumSeverityText = Color(hex: "#7C6240")
    static let lowSeverityBackground = Color(hex: "#DCEBDD")
    static let lowSeverityText = Color(hex: "#47624C")
    static let disabledButtonBackground = Color(hex: "#C8D6CA")

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
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.semibold)
    static let detailTitle = Font.system(.title, design: .rounded).weight(.semibold)
    static let heroTitle = Font.system(.title, design: .rounded).weight(.semibold)
    static let sheetTitle = Font.system(.title3, design: .rounded).weight(.semibold)
    static let sheetHeading = Font.system(.title, design: .rounded).weight(.semibold)
    static let title = Font.system(.title, design: .rounded).weight(.semibold)
    static let ctaHeroTitle = Font.system(.title2, design: .rounded).weight(.semibold)
    static let ctaLabel = Font.system(.caption, design: .rounded).weight(.medium)
    static let ctaSupporting = Font.system(.subheadline, design: .rounded)
    static let ctaButton = Font.system(.body, design: .rounded).weight(.semibold)
    static let headline = Font.system(.headline, design: .rounded).weight(.semibold)
    static let weatherTemperature = Font.system(.largeTitle, design: .rounded).weight(.semibold)
    static let weatherDescription = Font.system(.headline, design: .rounded).weight(.medium)
    static let forecastSectionTitle = Font.system(.headline, design: .rounded).weight(.semibold)
    static let loadHeadline = Font.system(.headline, design: .rounded).weight(.semibold)
    static let personalStatusTitle = Font.system(.headline, design: .rounded).weight(.semibold)
    static let personalStatusSubtitle = Font.system(.subheadline, design: .rounded)
    static let detailStatusTitle = Font.system(.title3, design: .rounded).weight(.semibold)
    static let detailStatusSubtitle = Font.system(.subheadline, design: .rounded)
    static let detailSegment = Font.system(.callout, design: .rounded).weight(.medium)
    static let allergenTitle = Font.system(.body, design: .rounded).weight(.semibold)
    static let allergenDescription = Font.system(.subheadline, design: .rounded)
    static let symptomHeading = Font.system(.title2, design: .rounded).weight(.semibold)
    static let symptomText = Font.system(.subheadline, design: .rounded)
    static let symptomPill = Font.system(.callout, design: .rounded).weight(.semibold)
    static let symptomSectionTitle = Font.system(.headline, design: .rounded).weight(.semibold)
    static let symptomSectionDescription = Font.system(.subheadline, design: .rounded)
    static let symptomInfoTitle = Font.system(.headline, design: .rounded).weight(.semibold)
    static let severityControl = Font.system(.subheadline, design: .rounded).weight(.semibold)
    static let hourlyHour = Font.system(.caption, design: .rounded).weight(.medium)
    static let hourlySeverity = Font.system(.subheadline, design: .rounded).weight(.semibold)
    static let dayTemperature = Font.system(.headline, design: .rounded).weight(.medium)

    static let body = Font.system(.body, design: .rounded)
    static let bodyEmphasized = Font.system(.body, design: .rounded).weight(.semibold)
    static let secondaryBody = Font.system(.subheadline, design: .rounded)

    static let caption = Font.system(.caption, design: .rounded).weight(.medium)
    static let attribution = Font.system(.caption2, design: .rounded)
    static let tinyMeta = Font.system(.caption2, design: .rounded)
    static let severityPill = Font.system(.subheadline, design: .rounded).weight(.medium)
    static let footnote = Font.system(.footnote, design: .rounded)

    static let button = Font.system(.headline, design: .rounded).weight(.semibold)
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
