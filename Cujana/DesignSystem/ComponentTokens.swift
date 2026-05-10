//
//  ComponentTokens.swift
//  Cujana
//
//  Created by Codex on 05.05.26.
//

import SwiftUI

enum CardToken {
    static let background = ColorToken.cardBackground
    static let mutedBackground = ColorToken.cardMutedBackground
    static let radius = RadiusToken.radiusLarge
    static let padding = SpacingToken.xl
    static let shadow = ShadowToken.card
    static let border = ColorToken.separatorSoft
    static let borderWidth: CGFloat = 0
}

enum ButtonToken {
    enum Primary {
        static let background = ColorToken.accentPrimary
        static let text = ColorToken.cardBackground
        static let radius = RadiusToken.full
        static let paddingH = SpacingToken.lg
        static let paddingV = SpacingToken.md
        static let enabledOpacity = 1.0
        static let disabledOpacity = 0.56
    }

    enum Secondary {
        static let background = ColorToken.cardMutedBackground
        static let text = ColorToken.accentPrimary
        static let radius = RadiusToken.full
        static let paddingH = SpacingToken.lg
        static let paddingV = SpacingToken.md
    }
}

enum ChipToken {
    static let background = ColorToken.cardMutedBackground
    static let selectedBackground = ColorToken.accentSoft
    static let warmBackground = ColorToken.accentWarning.opacity(0.16)
    static let calmBackground = ColorToken.accentSoft
    static let alertBackground = ColorToken.accentNegative.opacity(0.16)
    static let text = ColorToken.textPrimary
    static let selectedText = ColorToken.textPrimary
    static let radius = RadiusToken.full
    static let paddingH = SpacingToken.md
    static let paddingV = SpacingToken.sm
    static let iconSize = SpacingToken.xl
    static let minHeight: CGFloat = 52
    static let border = ColorToken.separatorSoft
    static let selectedBorder = ColorToken.accentPrimary
    static let borderWidth: CGFloat = 0
}

enum InputToken {
    static let background = ColorToken.backgroundSecondary
    static let border = ColorToken.separatorSoft
    static let focusedBorder = ColorToken.accentPrimary
    static let radius = RadiusToken.radiusSmall
    static let padding = SpacingToken.md
    static let minHeight: CGFloat = 112
    static let borderWidth: CGFloat = 1
}

enum SelectionToken {
    static let background = ColorToken.cardMutedBackground
    static let selectedBackground = ColorToken.accentPrimary
    static let text = ColorToken.textPrimary
    static let selectedText = ColorToken.cardBackground
    static let radius = RadiusToken.full
    static let size = SpacingToken.xxl
    static let border = ColorToken.separatorSoft
    static let borderWidth: CGFloat = 1
}

enum StatusToken {
    static let successBackground = ColorToken.accentPositive.opacity(0.16)
    static let successText = ColorToken.accentPrimary
    static let errorBackground = ColorToken.accentNegative.opacity(0.16)
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
    static let titleLayoutPriority = 1.0
    static let detailsButtonLayoutPriority = 2.0
}

enum AllergenLoadToken {
    static let backgroundOpacity = 0.62
    static let levelLayoutPriority = 2.0
}

enum ForecastDetailToken {
    static let dayIconSize: CGFloat = 42
    static let weatherIconWidth: CGFloat = 24
    static let hourlyRiskGridMinimumWidth: CGFloat = 92
}

enum EntryListToken {
    static let pollenChipGridMinimumWidth: CGFloat = 132
}

enum PressFeedbackToken {
    static let prominentOpacity = 0.9
    static let prominentScale = 0.99
    static let animationDuration = 0.12
}

enum SymptomCheckInToken {
    static let buttonMinHeight: CGFloat = 48
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
