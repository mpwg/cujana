//
//  DesignTokens.swift
//  Cujana
//
//  Created by Codex on 05.05.26.
//

import SwiftUI

enum ColorToken {
    fileprivate enum Raw {
        static let backgroundPrimary = Color(hex: "#F6F4EF")
        static let backgroundSecondary = Color(hex: "#F3F0E9")
        static let cardBackground = Color(hex: "#FFFFFF")
        static let cardMutedBackground = Color(hex: "#F1EDE6")

        static let textPrimary = Color(hex: "#1C1C1E")
        static let textSecondary = Color(hex: "#6B6B6E")
        static let textTertiary = Color(hex: "#9A9A9E")

        static let accentPrimary = Color(hex: "#4E6F5D")
        static let accentSoft = Color(hex: "#8ECDB8")
        static let accentPositive = Color(hex: "#6FAF8F")
        static let accentWarning = Color(hex: "#D2A96A")
        static let accentNegative = Color(hex: "#C97A73")

        static let separatorSoft = Color(hex: "#E8E2DA")
    }

    static let backgroundPrimary = Raw.backgroundPrimary
    static let backgroundSecondary = Raw.backgroundSecondary
    static let cardBackground = Raw.cardBackground
    static let cardMutedBackground = Raw.cardMutedBackground

    static let textPrimary = Raw.textPrimary
    static let textSecondary = Raw.textSecondary
    static let textTertiary = Raw.textTertiary

    static let accentPrimary = Raw.accentPrimary
    static let accentSoft = Raw.accentSoft.opacity(0.28)
    static let accentPositive = Raw.accentPositive
    static let accentWarning = Raw.accentWarning
    static let accentNegative = Raw.accentNegative
    static let separatorSoft = Raw.separatorSoft.opacity(0.55)
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
            sageSoft.opacity(riskBackground)
        case "Mittel":
            warningSoft.opacity(riskBackground)
        default:
            alertSoft.opacity(riskBackground)
        }
    }

    static func riskDot(for text: String) -> Color {
        switch text {
        case "Keine Belastung", "Niedrig":
            sageQuiet
        case "Mittel":
            ColorToken.accentWarning.opacity(0.78)
        default:
            ColorToken.accentNegative.opacity(0.78)
        }
    }
}

enum TypographyToken {
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.semibold)
    static let title = Font.system(.title, design: .rounded).weight(.regular)
    static let headline = Font.system(.headline, design: .rounded).weight(.medium)

    static let body = Font.system(.body)
    static let bodyEmphasized = Font.system(.body).weight(.medium)

    static let caption = Font.system(.caption)
    static let footnote = Font.system(.footnote)

    static let button = Font.system(.body).weight(.semibold)
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
    static let radiusMedium: CGFloat = 24
    static let radiusLarge: CGFloat = 32
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
        color: ColorToken.separatorSoft.opacity(0.14),
        radius: 8,
        y: 2
    )

    static let modal = ShadowTokenValue(
        color: ColorToken.separatorSoft.opacity(0.32),
        radius: 18,
        y: 8
    )

    static let floating = ShadowTokenValue(
        color: ColorToken.accentPrimary.opacity(0.05),
        radius: 10,
        y: 3
    )
}

enum MotionToken {
    static let detailSelection = Animation.spring(response: 0.36, dampingFraction: 0.96)
}

private extension Color {
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
