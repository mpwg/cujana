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
    }

    static let background = Raw.background
    static let surface = ColorToken.cardBackground.opacity(0.78)
    static let mutedSurface = Raw.mutedSurface.opacity(0.52)
    static let sage = Raw.sage
    static let sageSoft = Raw.sageSoft
    static let neutralStroke = Raw.neutralStroke.opacity(0.34)
    static let warningSoft = Raw.warningSoft
    static let alertSoft = Raw.alertSoft

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
    static let largeTitle = Font.system(size: 34, weight: .semibold, design: .rounded)
    static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 22, weight: .semibold, design: .rounded)

    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    static let bodyEmphasized = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let secondaryBody = Font.system(size: 15, weight: .regular, design: .rounded)

    static let caption = Font.system(size: 13, weight: .medium, design: .rounded)
    static let footnote = Font.system(size: 15, weight: .regular, design: .rounded)

    static let button = Font.system(size: 19, weight: .semibold, design: .rounded)
}

enum SpacingToken {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let section: CGFloat = 28
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
        color: Color.black.opacity(0.04),
        radius: 24,
        y: 10
    )

    static let modal = ShadowTokenValue(
        color: Color.black.opacity(0.05),
        radius: 28,
        y: 12
    )

    static let floating = ShadowTokenValue(
        color: Color.black.opacity(0.04),
        radius: 24,
        y: 10
    )
}

enum MotionToken {
    static let detailSelection = Animation.spring(response: 0.32, dampingFraction: 0.86)
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
