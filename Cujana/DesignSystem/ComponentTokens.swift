//
//  ComponentTokens.swift
//  Cujana
//
//  Created by Codex on 05.05.26.
//

import SwiftUI

enum CardToken {
    static let background = ColorToken.cardBackground.opacity(SurfaceStyleToken.backgroundOpacity)
    static let mutedBackground = ColorToken.cardMutedBackground
    static let radius = RadiusToken.radiusLarge
    static let padding = SpacingToken.lg
    static let shadow = ShadowToken.card
    static let border = ColorToken.cardBackground.opacity(SurfaceStyleToken.strokeOpacity)
    static let borderWidth: CGFloat = 1
}

enum ButtonToken {
    enum Primary {
        static let background = ColorToken.accentPrimary
        static let text = ColorToken.cardBackground
        static let radius: CGFloat = 20
        static let paddingH = SpacingToken.lg
        static let paddingV = SpacingToken.md
        static let enabledOpacity = 1.0
        static let disabledOpacity = 0.56
    }

    enum Secondary {
        static let background = ColorToken.cardMutedBackground
        static let text = ColorToken.accentDark
        static let radius = RadiusToken.full
        static let paddingH = SpacingToken.lg
        static let paddingV = SpacingToken.md
    }
}

enum ChipToken {
    static let background = ColorToken.cardBackground
    static let selectedBackground = ColorToken.accentSoft
    static let warmBackground = SemanticColorToken.mediumSeverityBackground
    static let calmBackground = ColorToken.accentSoft
    static let alertBackground = SemanticColorToken.highSeverityBackground
    static let text = ColorToken.textPrimary
    static let selectedText = ColorToken.textPrimary
    static let radius = RadiusToken.full
    static let paddingH = SpacingToken.md
    static let paddingV = SpacingToken.sm
    static let iconSize: CGFloat = 22
    static let minHeight: CGFloat = 56
    static let border = ColorToken.separatorSoft
    static let selectedBorder = Color.clear
    static let borderWidth: CGFloat = 1
}

enum InputToken {
    static let background = ColorToken.backgroundSecondary
    static let border = ColorToken.separatorSoft
    static let focusedBorder = ColorToken.accentPrimary
    static let radius = RadiusToken.radiusLarge
    static let padding: CGFloat = 20
    static let minHeight: CGFloat = 112
    static let borderWidth: CGFloat = 1
}

enum SelectionToken {
    static let background = ColorToken.cardMutedBackground
    static let selectedBackground = ColorToken.accentPrimary
    static let text = ColorToken.textPrimary
    static let selectedText = ColorToken.cardBackground
    static let radius = RadiusToken.full
    static let size: CGFloat = 52
    static let border = ColorToken.separatorSoft
    static let borderWidth: CGFloat = 1
}

enum StatusToken {
    static let successBackground = SemanticColorToken.lowSeverityBackground
    static let successText = SemanticColorToken.lowSeverityText
    static let errorBackground = SemanticColorToken.highSeverityBackground
    static let errorText = ColorToken.accentNegative
    static let radius = RadiusToken.radiusSmall
    static let padding = SpacingToken.md
}

enum SurfaceOpacityToken {
    static let primaryCard = 0.94
    static let mutedCard = 0.56
    static let mutedRow = 0.48
    static let backgroundWash = 0.12
    static let accentProminent = 0.72
    static let accentSubtle = 0.52
}

enum SurfaceStyleToken {
    static let backgroundOpacity = 0.72
    static let gradientTopOpacity = 0.28
    static let gradientBottomOpacity = 0.08
    static let strokeOpacity = 0.45
}

enum HomeOverviewToken {
    static let navigationLogoWidth: CGFloat = 150
    static let navigationLogoHeight: CGFloat = 44
    static let navigationLogoOpacity = 0.96
    static let navigationLogoTopPadding: CGFloat = 12
    static let navigationLogoBottomPadding: CGFloat = 28
    static let allergenGridMinimumWidth: CGFloat = 116
    static let weatherIconSize: CGFloat = 28
    static let scrollBottomPadding = SpacingToken.md
    static let largeTextScrollBottomPadding: CGFloat = 80
    static let titleLayoutPriority = 1.0
    static let detailsButtonLayoutPriority = 2.0
    static let heroHeight: CGFloat = 210
    static let heroCornerRadius: CGFloat = 32
    static let heroTopPadding: CGFloat = 28
    static let heroHorizontalPadding: CGFloat = 28
    static let heroBottomPadding: CGFloat = 24
    static let heroSubtitleMaxWidth: CGFloat = 240
    static let heroLeafWidth: CGFloat = 96
    static let heroLeafHeight: CGFloat = 132
    static let heroLeafOpacity = 0.42
    static let heroArtworkOpacity = 0.88
    static let heroArtworkBlur: CGFloat = 0.3
    static let heroArtworkScale = 0.96
    static let heroLeafTrailingPadding: CGFloat = 22
    static let heroLeafTopPadding: CGFloat = 52
    static let dayCardPadding: CGFloat = 16
    static let dayCardWidth: CGFloat = 162
    static let dayCardHeight: CGFloat = 150
    static let dayCardCornerRadius: CGFloat = 30
    static let dayLabelTracking = 1.2
    static let dayWeatherIconSize: CGFloat = 44
    static let dayWeatherIconSmallSize: CGFloat = 34
    static let dayWeatherIconFontSize: CGFloat = 18
    static let dayWeatherIconOpacity = 0.7
    static let dayWeatherIconBackgroundOpacity = 0.72
    static let dayTemperatureTracking = 0.0
    static let loadHeadlineTracking = -0.5
    static let forecastTitleTracking = -0.6
    static let weatherContextText = Color(hex: "#8E8A84")
    static let weatherDescriptionMinimumScale = 0.82
    static let severityPillHeight: CGFloat = 28
    static let severityPillPaddingH: CGFloat = 12
    static let severityPillCornerRadius: CGFloat = 14
    static let dayCardBottomPadding: CGFloat = 16
    static let attributionOpacity = 0.85
    static let attributionTopPadding: CGFloat = 8
    static let compactButtonPressedOpacity = 0.72
    static let ctaPadding = SpacingToken.lg
    static let ctaHeight: CGFloat = 176
    static let ctaCornerRadius: CGFloat = 34
    static let ctaLabelText = Color(hex: "#6E6A63")
    static let ctaTitleTracking = -1.0
    static let ctaSupportingMaxWidth: CGFloat = 280
    static let ctaBackgroundOpacity = 0.08
    static let ctaArtworkBlur: CGFloat = 2
    static let ctaButtonHeight: CGFloat = 56
    static let ctaButtonCornerRadius: CGFloat = 22
    static let ctaButtonIconSpacing: CGFloat = 10
    static let ctaButtonIconSize: CGFloat = 18
    static let personalStatusHeight: CGFloat = 96
    static let personalStatusCornerRadius: CGFloat = 28
    static let personalStatusIconSize: CGFloat = 44
}

enum AllergenLoadToken {
    static let backgroundOpacity = 0.62
    static let levelLayoutPriority = 2.0
}

enum ForecastDetailToken {
    static let titleBottomPadding: CGFloat = 18
    static let dayIconSize: CGFloat = 42
    static let weatherIconWidth: CGFloat = 30
    static let hourlyRiskGridMinimumWidth: CGFloat = 92
    static let screenHorizontalPadding: CGFloat = 24
    static let screenTopPadding: CGFloat = 24
    static let sectionSpacing: CGFloat = 22
    static let contextSpacing: CGFloat = 12
    static let cardHorizontalPadding: CGFloat = 20
    static let compactCardVerticalPadding: CGFloat = 18
    static let bottomInsetHeight: CGFloat = 56
    static let dayPickerMinHeight: CGFloat = 44
    static let dayPickerHeight: CGFloat = 52
    static let dayPickerSurfaceOpacity = 0.75
    static let dayPickerPadding: CGFloat = 4
    static let dayPickerCornerRadius: CGFloat = 26
    static let weatherIconSize: CGFloat = 52
    static let weatherMinHeight: CGFloat = 132
    static let weatherCardPadding: CGFloat = 18
    static let weatherCardCornerRadius: CGFloat = 30
    static let allergenIconSize: CGFloat = 30
    static let allergenIconFrameSize: CGFloat = 52
    static let allergenRowMinHeight: CGFloat = 88
    static let allergenCardPadding = SpacingToken.lg
    static let allergenCardCornerRadius: CGFloat = 28
    static let badgeHeight: CGFloat = 30
    static let badgeHorizontalPadding: CGFloat = 14
    static let badgeCornerRadius: CGFloat = 15
    static let noRiskMinHeight: CGFloat = 54
    static let noRiskCornerRadius: CGFloat = 18
    static let hairlineStrokeWidth: CGFloat = 0.5
    static let dayPickerTextMinimumScale = 0.82
    static let weatherTextMinimumScale = 0.84
    static let badgeTextMinimumScale = 0.84
    static let hourlyTextMinimumScale = 0.74
    static let noRiskVerticalPadding: CGFloat = 6
    static let allergenTextSpacing: CGFloat = 4
    static let hourlyChipCornerRadius: CGFloat = 24
    static let hourlyInactiveChipCornerRadius: CGFloat = 22
    static let hourlyChipContentSpacing: CGFloat = 5
    static let hourlyChipSpacing: CGFloat = 12
    static let hourlyScrollerHorizontalPadding: CGFloat = 1
    static let hourlyDotSize: CGFloat = 5
    static let hourlyCurrentDotSize: CGFloat = 6
    static let hourlyChipWidth: CGFloat = 68
    static let hourlyCurrentChipWidth: CGFloat = 84
    static let hourlyChipMinHeight: CGFloat = 112
    static let hourlyCurrentChipMinHeight: CGFloat = 126
    static let hourlyCurrentScale: CGFloat = 1.02
    static let hourlyInactiveOpacity = 0.82
    static let hourlyWeatherTextOpacity = 0.7
    static let allergyWeatherContextText = Color(hex: "#7C7871")
    static let subtleNavigationRowMinHeight: CGFloat = 42
    static let subtleNavigationHorizontalPadding: CGFloat = 14
    static let overviewDotSize: CGFloat = 8
}

enum EntryListToken {
    static let pollenChipGridMinimumWidth: CGFloat = 132
}

enum TabBarToken {
    static let backgroundOpacity = 0.82
    static let sheetCornerRadius: CGFloat = 34
}

enum PressFeedbackToken {
    static let prominentOpacity = 0.9
    static let prominentScale = 0.99
    static let animationDuration = 0.12
}

enum SymptomCheckInToken {
    static let symptomGridMinimumWidth: CGFloat = 160
    static let scrollBottomPadding: CGFloat = 120
    static let bottomBarBackgroundOpacity = 0.96
    static let introMaxWidth: CGFloat = 320
    static let fieldContainerPadding: CGFloat = 18
    static let symptomPillMinHeight: CGFloat = 54
    static let symptomPillPaddingH: CGFloat = 18
    static let symptomBorderOpacity = 0.16
    static let symptomSelectedBackground = Color(hex: "#E7F0E7")
    static let symptomIconOpacity = 0.92
    static let severityPillMinHeight: CGFloat = 52
    static let severityPillMinWidth: CGFloat = 44
    static let severityUnselectedText = Color(hex: "#4B4B48")
    static let calendarContainerOpacity = 0.82
    static let calendarContainerCornerRadius: CGFloat = 32
    static let calendarMaxHeight: CGFloat = 420
    static let timePickerHeight: CGFloat = 38
    static let timePickerCornerRadius: CGFloat = 19
    static let notesMinHeight: CGFloat = 140
    static let notesPadding: CGFloat = 18
    static let notesCornerRadius: CGFloat = 28
    static let buttonMinHeight: CGFloat = 56
    static let saveButtonMinHeight: CGFloat = 56
    static let saveButtonRadius: CGFloat = 20
    static let disabledTextOpacity = 0.8
    static let disabledButtonOpacity = 0.82
}

struct SoftShadowModifier: ViewModifier {
    let token: ShadowTokenValue

    func body(content: Content) -> some View {
        content.shadow(
            color: token.color,
            radius: token.radius,
            x: 0,
            y: token.y
        )
    }
}

struct CardStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(CardToken.padding)
            .premiumSurface(cornerRadius: CardToken.radius)
            .softShadow(CardToken.shadow)
    }
}

struct PremiumSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(ColorToken.cardBackground.opacity(SurfaceStyleToken.backgroundOpacity))
                    .overlay {
                        LinearGradient(
                            colors: [
                                ColorToken.cardBackground.opacity(SurfaceStyleToken.gradientTopOpacity),
                                ColorToken.cardBackground.opacity(SurfaceStyleToken.gradientBottomOpacity)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(CardToken.border, lineWidth: CardToken.borderWidth)
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TypographyToken.button)
            .foregroundStyle(ButtonToken.Primary.text)
            .padding(.horizontal, ButtonToken.Primary.paddingH)
            .padding(.vertical, ButtonToken.Primary.paddingV)
            .frame(maxWidth: .infinity)
            .background(ButtonToken.Primary.background)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.86 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TypographyToken.button)
            .foregroundStyle(ButtonToken.Secondary.text)
            .padding(.horizontal, ButtonToken.Secondary.paddingH)
            .padding(.vertical, ButtonToken.Secondary.paddingV)
            .frame(maxWidth: .infinity)
            .background(ButtonToken.Secondary.background)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.86 : 1)
    }
}

struct ChipStyleModifier: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .font(TypographyToken.footnote)
            .foregroundStyle(isSelected ? ChipToken.selectedText : ChipToken.text)
            .padding(.horizontal, ChipToken.paddingH)
            .padding(.vertical, ChipToken.paddingV)
            .background(isSelected ? ChipToken.selectedBackground : ChipToken.background)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? ChipToken.selectedBorder : ChipToken.border, lineWidth: ChipToken.borderWidth)
            )
    }
}

struct InputStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(InputToken.padding)
            .background(InputToken.background)
            .clipShape(RoundedRectangle(cornerRadius: InputToken.radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: InputToken.radius, style: .continuous)
                    .stroke(InputToken.border, lineWidth: InputToken.borderWidth)
            )
    }
}

struct StatusStyleModifier: ViewModifier {
    let isError: Bool

    func body(content: Content) -> some View {
        content
            .font(TypographyToken.footnote)
            .foregroundStyle(isError ? StatusToken.errorText : StatusToken.successText)
            .padding(StatusToken.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isError ? StatusToken.errorBackground : StatusToken.successBackground)
            .clipShape(RoundedRectangle(cornerRadius: StatusToken.radius, style: .continuous))
    }
}

extension View {
    func softShadow(_ token: ShadowTokenValue) -> some View {
        modifier(SoftShadowModifier(token: token))
    }

    func cujanaCard() -> some View {
        modifier(CardStyleModifier())
    }

    func premiumSurface(cornerRadius: CGFloat) -> some View {
        modifier(PremiumSurfaceModifier(cornerRadius: cornerRadius))
    }

    func cujanaChip(isSelected: Bool = false) -> some View {
        modifier(ChipStyleModifier(isSelected: isSelected))
    }

    func cujanaInput() -> some View {
        modifier(InputStyleModifier())
    }

    func cujanaStatus(isError: Bool = false) -> some View {
        modifier(StatusStyleModifier(isError: isError))
    }
}
