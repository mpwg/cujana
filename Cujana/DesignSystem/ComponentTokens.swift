import SwiftUI

enum CardToken {
    static let background = ColorToken.cardBackground.opacity(SurfaceStyleToken.backgroundOpacity)
    static let mutedBackground = ColorToken.cardMutedBackground
    static let radius = RadiusToken.radiusLarge
    static let padding: CGFloat = 16
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
    static let backgroundOpacity = 0.68
    static let gradientTopOpacity = 0.28
    static let gradientBottomOpacity = 0.08
    static let strokeOpacity = 0.45
}

enum HomeOverviewToken {
    static let screenHorizontalPadding: CGFloat = 18
    static let navigationLogoWidth: CGFloat = 150
    static let navigationLogoHeight: CGFloat = 34
    static let navigationLogoOpacity = 0.88
    static let navigationLogoTopPadding: CGFloat = 8
    static let navigationLogoBottomPadding: CGFloat = 20
    static let scrollBottomPadding = SpacingToken.md
    static let largeTextScrollBottomPadding: CGFloat = 80
    static let titleLayoutPriority = 1.0
    static let detailsButtonLayoutPriority = 2.0
    static let dayCardPadding: CGFloat = 16
    static let dayCardWidth: CGFloat = 168
    static let dayCardHeight: CGFloat = 150
    static let dayCardCornerRadius: CGFloat = 28
    static let dayLabelTracking = 1.6
    static let dayWeatherIconSmallSize: CGFloat = 26
    static let dayWeatherIconFont = Font.system(size: 14, weight: .medium, design: .rounded)
    static let dayWeatherIconOpacity = 0.58
    static let dayWeatherIconBackgroundOpacity = 0.72
    static let loadHeadlineTracking = -0.5
    static let forecastTitleTracking = -0.5
    static let weatherContextText = Color(hex: "#8E8A84")
    static let weatherContextOpacity = 0.64
    static let weatherDescriptionMinimumScale = 0.82
    static let loadHeadlineMinimumScale = 0.92
    static let weatherMetaMinimumScale = 0.8
    static let severityPillHeight: CGFloat = 28
    static let severityPillPaddingH: CGFloat = 10
    static let severityPillCornerRadius: CGFloat = 14
    static let dayCardBottomPadding: CGFloat = 16
    static let attributionOpacity = 0.85
    static let attributionTopPadding: CGFloat = 12
    static let attributionBottomPadding: CGFloat = 4
    static let compactButtonPressedOpacity = 0.72
    static let ctaPadding: CGFloat = 10
    static let ctaHeight: CGFloat = 160
    static let ctaCornerRadius: CGFloat = 32
    static let ctaLabelText = Color(hex: "#6E6A63")
    static let ctaLabelTracking = 0.2
    static let ctaTitleTracking = -0.9
    static let ctaSupportingOpacity = 0.9
    static let ctaBackgroundOpacity = 0.08
    static let ctaArtworkBlur: CGFloat = 2
    static let ctaButtonHeight: CGFloat = 48
    static let ctaButtonCornerRadius: CGFloat = 18
    static let ctaButtonPaddingH: CGFloat = 18
    static let ctaButtonIconSpacing: CGFloat = 10
    static let ctaButtonIconSize: CGFloat = 17
    static let personalStatusHeight: CGFloat = 96
    static let personalStatusCornerRadius: CGFloat = 28
    static let personalStatusIconSize: CGFloat = 52
    static let personalStatusVerticalPadding: CGFloat = 14
    static let personalStatusTitleTracking = -0.5
    static let personalStatusSubtitleOpacity = 0.9
    static let personalStatusBadgeHeight: CGFloat = 28
    static let personalStatusBadgeCornerRadius: CGFloat = 14
    static let personalStatusBadgePaddingH: CGFloat = 11
}

enum AllergenLoadToken {
    static let backgroundOpacity = 0.62
    static let levelLayoutPriority = 2.0
}

enum ForecastDetailToken {
    static let titleBottomPadding: CGFloat = 18
    static let allergenIconFont = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let dayIconSize: CGFloat = 42
    static let weatherIconWidth: CGFloat = 30
    static let hourlyRiskGridMinimumWidth: CGFloat = 92
    static let screenHorizontalPadding: CGFloat = 18
    static let screenTopPadding: CGFloat = 24
    static let sectionSpacing: CGFloat = 20
    static let contextSpacing: CGFloat = 12
    static let cardHorizontalPadding: CGFloat = 20
    static let compactCardVerticalPadding: CGFloat = 18
    static let bottomInsetHeight: CGFloat = 56
    static let dayPickerMinHeight: CGFloat = 42
    static let dayPickerHeight: CGFloat = 50
    static let dayPickerSurfaceOpacity = 0.75
    static let dayPickerPadding: CGFloat = 4
    static let dayPickerCornerRadius: CGFloat = 25
    static let weatherIconSize: CGFloat = 52
    static let weatherMinHeight: CGFloat = 120
    static let weatherCardPadding: CGFloat = 14
    static let weatherCardCornerRadius: CGFloat = 28
    static let allergenIconSize: CGFloat = 30
    static let allergenIconFrameSize: CGFloat = 46
    static let allergenRowMinHeight: CGFloat = 104
    static let allergenCardPadding: CGFloat = 14
    static let allergenCardCornerRadius: CGFloat = 26
    static let badgeHeight: CGFloat = 26
    static let badgeHorizontalPadding: CGFloat = 10
    static let badgeCornerRadius: CGFloat = 13
    static let noRiskMinHeight: CGFloat = 50
    static let noRiskCornerRadius: CGFloat = 18
    static let hairlineStrokeWidth: CGFloat = 0.5
    static let dayPickerTextMinimumScale = 0.82
    static let weatherTextMinimumScale = 0.84
    static let badgeTextMinimumScale = 0.84
    static let hourlyTextMinimumScale = 0.74
    static let noRiskVerticalPadding: CGFloat = 6
    static let allergenTextSpacing: CGFloat = 4
    static let hourlyChipCornerRadius: CGFloat = 20
    static let hourlyInactiveChipCornerRadius: CGFloat = 20
    static let hourlyChipContentSpacing: CGFloat = 5
    static let hourlyChipSpacing: CGFloat = 12
    static let hourlyScrollerHorizontalPadding: CGFloat = 1
    static let hourlyDotSize: CGFloat = 5
    static let hourlyCurrentDotSize: CGFloat = 6
    static let hourlyChipWidth: CGFloat = 56
    static let hourlyCurrentChipWidth: CGFloat = 72
    static let hourlyChipMinHeight: CGFloat = 104
    static let hourlyCurrentChipMinHeight: CGFloat = 118
    static let hourlyCurrentScale: CGFloat = 1.02
    static let hourlyWeatherTextOpacity = 0.68
    static let hourlyActiveTopOpacity = 0.82
    static let hourlyActiveBottomOpacity = 0.68
    static let hourlyInactiveBackgroundOpacity = 0.58
    static let allergyWeatherContextText = Color(hex: "#7C7871")
    static let allergyWeatherContextOpacity = 0.66
    static let subtleNavigationRowMinHeight: CGFloat = 42
    static let subtleNavigationHorizontalPadding: CGFloat = 14
    static let overviewDotSize: CGFloat = 8
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
    static let accent = Color(hex: "#6D8F76")
    static let accentPressed = Color(hex: "#5E7D66")
    static let selectedBorder = Color(hex: "#7C9A82")
    static let selectedIcon = Color(hex: "#5F8168")
    static let selectedText = Color(hex: "#355240")
    static let secondaryText = Color(hex: "#6B6B6E")
    static let tertiaryText = Color(hex: "#8A8A8E")
    static let sectionTitleTracking = -0.02
    static let screenHorizontalPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 28
    static let topContentPadding: CGFloat = 24
    static let symptomGridMinimumWidth: CGFloat = 160
    static let symptomPillGridSpacing: CGFloat = 14
    static let scrollBottomPadding: CGFloat = 120
    static let bottomBarBackgroundOpacity = 0.96
    static let symptomPillMinHeight: CGFloat = 76
    static let symptomPillPaddingH: CGFloat = 16
    static let symptomPillPaddingV: CGFloat = 14
    static let symptomPillSpacing: CGFloat = 14
    static let symptomTextMinimumScale = 0.96
    static let symptomSelectedBackground = Color(hex: "#E7EFE8")
    static let symptomUnselectedBorder = Color(hex: "#3C3C43").opacity(0.1)
    static let symptomUnselectedIconOpacity = 0.85
    static let symptomSelectedBorderWidth: CGFloat = 1
    static let symptomUnselectedBorderWidth: CGFloat = 1
    static let symptomIconFont = Font.system(size: 18, weight: .medium, design: .rounded)
    static let symptomIconFrameWidth: CGFloat = 26
    static let symptomCheckmarkFont = Font.system(size: 14, weight: .semibold)
    static let symptomCheckmarkOpacity = 0.82
    static let symptomPressedScale = 0.97
    static let symptomPillCornerRadius: CGFloat = 24
    static let symptomPillShadow = ShadowTokenValue(color: Color.black.opacity(0.04), radius: 8, y: 1)
    static let severityPillMinHeight: CGFloat = 40
    static let severityPillSpacing: CGFloat = 10
    static let severityPillPaddingH: CGFloat = 18
    static let severityPillCornerRadius: CGFloat = 20
    static let severityTextMinimumScale = 0.8
    static let severityUnselectedText = Color(hex: "#474747")
    static let severityUnselectedBackground = ColorToken.cardBackground
    static let severityUnselectedBorder = Color(hex: "#3C3C43").opacity(0.1)
    static let dateCardCornerRadius: CGFloat = 24
    static let dateCardShadow = ShadowTokenValue(color: Color.black.opacity(0.04), radius: 12, y: 2)
    static let dateCardCollapsedHeight: CGFloat = 70
    static let dateIconSize: CGFloat = 34
    static let datePickerMinHeight: CGFloat = 44
    static let hintBackground = Color(hex: "#6D8F76").opacity(0.08)
    static let hintIconSize: CGFloat = 15
    static let hintIconFont = Font.system(size: 15, weight: .medium, design: .rounded)
    static let hintDisclosureIconFont = Font.system(size: 15, weight: .semibold, design: .rounded)
    static let chevronOpacity = 0.86
    static let notesMinHeight: CGFloat = 140
    static let notesPadding: CGFloat = 16
    static let notesCornerRadius: CGFloat = 24
    static let notesBorder = Color(hex: "#3C3C43").opacity(0.08)
    static let notesBorderWidth: CGFloat = 0.5
    static let saveButtonMinHeight: CGFloat = 54
    static let saveButtonRadius: CGFloat = 27
    static let saveButtonPressedBackground = accentPressed
    static let disabledButtonBackground = Color(hex: "#D9E4DA")
    static let saveButtonShadow = ShadowTokenValue(color: Color(hex: "#6D8F76").opacity(0.14), radius: 18, y: 6)
    static let infoButtonSize: CGFloat = 48
    static let infoButtonBackground = Color.white.opacity(0.64)
    static let animationDuration = 0.24
    static let animationDamping = 0.86
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
