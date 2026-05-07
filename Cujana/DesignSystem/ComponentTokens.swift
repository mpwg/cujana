//
//  ComponentTokens.swift
//  Cujana
//
//  Created by Codex on 05.05.26.
//

import SwiftUI

enum CardToken {
    static let background = ColorToken.backgroundElevated
    static let radius = RadiusToken.xxl
    static let padding = SpacingToken.lg
    static let shadow = ShadowToken.card
    static let border = ColorToken.borderSubtle
    static let borderWidth: CGFloat = 1
}

enum ButtonToken {
    enum Primary {
        static let background = ColorToken.brandPrimary
        static let text = ColorToken.textInverse
        static let radius = RadiusToken.full
        static let paddingH = SpacingToken.lg
        static let paddingV = SpacingToken.md
        static let disabledOpacity = 0.56
    }

    enum Secondary {
        static let background = ColorToken.fillSubtle
        static let text = ColorToken.brandPrimary
        static let radius = RadiusToken.full
        static let paddingH = SpacingToken.lg
        static let paddingV = SpacingToken.md
    }
}

enum ChipToken {
    static let background = ColorToken.fillSubtle
    static let selectedBackground = ColorToken.brandSecondary
    static let warmBackground = ColorToken.backgroundTertiary
    static let calmBackground = ColorToken.fillSoft
    static let alertBackground = ColorToken.brandAccent.opacity(0.18)
    static let text = ColorToken.textPrimary
    static let selectedText = ColorToken.textPrimary
    static let radius = RadiusToken.full
    static let paddingH = SpacingToken.md
    static let paddingV = SpacingToken.sm
    static let iconSize = SpacingToken.xl
    static let minHeight: CGFloat = 52
    static let border = ColorToken.borderSubtle
    static let selectedBorder = ColorToken.brandPrimary
    static let borderWidth: CGFloat = 1
}

enum InputToken {
    static let background = ColorToken.backgroundSecondary
    static let border = ColorToken.borderSubtle
    static let focusedBorder = ColorToken.brandPrimary
    static let radius = RadiusToken.lg
    static let padding = SpacingToken.md
    static let minHeight: CGFloat = 112
    static let borderWidth: CGFloat = 1
}

enum SelectionToken {
    static let background = ColorToken.fillSubtle
    static let selectedBackground = ColorToken.brandPrimary
    static let text = ColorToken.textPrimary
    static let selectedText = ColorToken.textInverse
    static let radius = RadiusToken.full
    static let size = SpacingToken.xxl
    static let border = ColorToken.borderSoft
    static let borderWidth: CGFloat = 1
}

enum StatusToken {
    static let successBackground = ColorToken.feedbackSuccess.opacity(0.16)
    static let successText = ColorToken.brandPrimary
    static let errorBackground = ColorToken.feedbackError.opacity(0.16)
    static let errorText = ColorToken.feedbackError
    static let radius = RadiusToken.lg
    static let padding = SpacingToken.md
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
