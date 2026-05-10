//
//  ComponentTokens.swift
//  Cujana
//
//  Created by Codex on 05.05.26.
//

import SwiftUI

enum CardToken {
    static let background = ColorToken.secondarySurface
    static let mutedBackground = ColorToken.cardMutedBackground
    static let radius = RadiusToken.radiusLarge
    static let padding: CGFloat = 20
    static let shadow = ShadowToken.card
    static let border = ColorToken.separatorSoft
    static let borderWidth: CGFloat = 0
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

enum HomeOverviewToken {
    static let allergenGridMinimumWidth: CGFloat = 116
    static let weatherIconSize: CGFloat = 28
    static let scrollBottomPadding = SpacingToken.lg
    static let largeTextScrollBottomPadding: CGFloat = 96
    static let titleLayoutPriority = 1.0
    static let detailsButtonLayoutPriority = 2.0
    static let heroHeight: CGFloat = 240
    static let heroCornerRadius: CGFloat = 32
    static let heroContentPadding: CGFloat = 24
    static let heroLeafWidth: CGFloat = 96
    static let heroLeafHeight: CGFloat = 132
    static let heroLeafOpacity = 0.62
    static let heroLeafTrailingPadding: CGFloat = 22
    static let heroLeafTopPadding: CGFloat = 52
    static let dayCardPadding: CGFloat = 18
    static let dayCardWidth: CGFloat = 150
    static let dayCardHeight: CGFloat = 170
    static let dayCardCornerRadius: CGFloat = 26
    static let dayWeatherIconSize: CGFloat = 46
    static let compactButtonPressedOpacity = 0.72
    static let ctaPadding: CGFloat = 20
    static let ctaHeight: CGFloat = 160
    static let ctaCornerRadius: CGFloat = 30
    static let ctaBackgroundOpacity = 0.32
}

enum AllergenLoadToken {
    static let backgroundOpacity = 0.62
    static let levelLayoutPriority = 2.0
}

enum ForecastDetailToken {
    static let dayIconSize: CGFloat = 42
    static let weatherIconWidth: CGFloat = 24
    static let hourlyRiskGridMinimumWidth: CGFloat = 92
    static let screenHorizontalPadding: CGFloat = 24
    static let sectionSpacing: CGFloat = 28
    static let contextSpacing: CGFloat = 12
    static let cardHorizontalPadding: CGFloat = 20
    static let compactCardVerticalPadding: CGFloat = 18
    static let bottomInsetHeight: CGFloat = 56
    static let dayPickerMinHeight: CGFloat = 48
    static let dayPickerHeight: CGFloat = 56
    static let dayPickerSurfaceOpacity = 0.75
    static let dayPickerPadding: CGFloat = 4
    static let weatherIconSize: CGFloat = 58
    static let weatherMinHeight: CGFloat = 140
    static let weatherCardPadding: CGFloat = 20
    static let weatherCardCornerRadius: CGFloat = 30
    static let allergenIconSize: CGFloat = 30
    static let allergenIconFrameSize: CGFloat = 44
    static let allergenRowMinHeight: CGFloat = 110
    static let allergenCardPadding: CGFloat = 20
    static let allergenCardCornerRadius: CGFloat = 28
    static let badgeVerticalPadding: CGFloat = 3
    static let noRiskMinHeight: CGFloat = 40
    static let hairlineStrokeWidth: CGFloat = 0.5
    static let dayPickerTextMinimumScale = 0.82
    static let weatherTextMinimumScale = 0.84
    static let badgeTextMinimumScale = 0.84
    static let hourlyTextMinimumScale = 0.74
    static let noRiskVerticalPadding: CGFloat = 6
    static let allergenTextSpacing: CGFloat = 4
    static let hourlyChipCornerRadius: CGFloat = 24
    static let hourlyChipContentSpacing: CGFloat = 5
    static let hourlyChipSpacing: CGFloat = 5
    static let hourlyScrollerHorizontalPadding: CGFloat = 1
    static let hourlyDotSize: CGFloat = 5
    static let hourlyCurrentDotSize: CGFloat = 6
    static let hourlyChipWidth: CGFloat = 70
    static let hourlyCurrentChipWidth: CGFloat = 92
    static let hourlyChipMinHeight: CGFloat = 96
    static let hourlyCurrentChipMinHeight: CGFloat = 116
    static let hourlyCurrentScale: CGFloat = 1.02
    static let subtleNavigationRowMinHeight: CGFloat = 42
    static let subtleNavigationHorizontalPadding: CGFloat = 14
    static let overviewDotSize: CGFloat = 8
}

enum EntryListToken {
    static let pollenChipGridMinimumWidth: CGFloat = 132
}

enum TabBarToken {
    static let backgroundOpacity = 0.82
}

enum PressFeedbackToken {
    static let prominentOpacity = 0.9
    static let prominentScale = 0.99
    static let animationDuration = 0.12
}

enum SymptomCheckInToken {
    static let symptomGridMinimumWidth: CGFloat = 150
    static let scrollBottomPadding: CGFloat = 88
    static let bottomBarBackgroundOpacity = 0.96
    static let fieldContainerPadding: CGFloat = 20
    static let symptomPillMinHeight: CGFloat = 56
    static let severityPillMinHeight: CGFloat = 52
    static let buttonMinHeight: CGFloat = 58
    static let saveButtonMinHeight: CGFloat = 60
    static let saveButtonRadius: CGFloat = 22
    static let disabledTextOpacity = 0.8
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
            .background(CardToken.background)
            .clipShape(RoundedRectangle(cornerRadius: CardToken.radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CardToken.radius, style: .continuous)
                    .stroke(CardToken.border, lineWidth: CardToken.borderWidth)
            )
            .softShadow(CardToken.shadow)
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
