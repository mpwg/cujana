//
//  DesignTokens.swift
//  Cujana
//
//  Created by Codex on 05.05.26.
//

import SwiftUI

enum ColorToken {
    enum Core {
        static let warmPorcelain = Color(hex: "#F6F4EF")
        static let warmLinen = Color(hex: "#F3F0E9")
        static let warmSand = Color(hex: "#EFEADF")
        static let pureElevated = Color(hex: "#FFFFFF")

        static let inkPrimary = Color(hex: "#1C1C1E")
        static let inkSecondary = Color(hex: "#6B6B6E")
        static let inkTertiary = Color(hex: "#9A9A9E")
        static let inkInverse = Color(hex: "#FFFFFF")

        static let moss = Color(hex: "#4E6F5D")
        static let mint = Color(hex: "#8ECDB8")
        static let coral = Color(hex: "#FF8A7A")

        static let fillSubtle = Color(hex: "#F1EDE6")
        static let fillSoft = Color(hex: "#E9E4DA")
        static let fillStrong = Color(hex: "#DED7CA")

        static let borderSubtle = Color(hex: "#E8E2DA")
        static let borderSoft = Color(hex: "#E2DBD2")

        static let success = Color(hex: "#6FAF8F")
        static let warning = Color(hex: "#D2A96A")
        static let error = Color(hex: "#C97A73")
        static let info = Color(hex: "#6F9F96")
    }

    static let backgroundPrimary = Core.warmPorcelain
    static let backgroundSecondary = Core.warmLinen
    static let backgroundTertiary = Core.warmSand
    static let backgroundElevated = Core.pureElevated

    static let textPrimary = Core.inkPrimary
    static let textSecondary = Core.inkSecondary
    static let textTertiary = Core.inkTertiary
    static let textInverse = Core.inkInverse

    static let brandPrimary = Core.moss
    static let brandSecondary = Core.mint
    static let brandAccent = Core.coral

    static let fillSubtle = Core.fillSubtle
    static let fillSoft = Core.fillSoft
    static let fillStrong = Core.fillStrong

    static let borderSubtle = Core.borderSubtle
    static let borderSoft = Core.borderSoft

    static let feedbackSuccess = Core.success
    static let feedbackWarning = Core.warning
    static let feedbackError = Core.error
    static let feedbackInfo = Core.info
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
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
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
        radius: 12,
        y: 6
    )

    static let modal = ShadowTokenValue(
        color: Color.black.opacity(0.08),
        radius: 20,
        y: 10
    )
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
