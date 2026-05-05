# ADR 0004: Design Token Enforcement

## Status

Accepted

## Context

Cujana needs a verbindliches Design-System for the iOS app so feature UI keeps the Soft Organic visual language consistent. Direct colors, spacing values, radii and shadows in feature code would make that language drift quickly and are hard to review manually.

Issue #5 defines three layers:

- Core Tokens for raw values
- Semantic Tokens for app usage
- Component Tokens and styles for repeated UI elements

The issue also requires SwiftLint to fail builds when feature code bypasses those tokens.

## Decision

Add a SwiftUI DesignSystem module inside the app target with:

- `ColorToken`, `TypographyToken`, `SpacingToken`, `RadiusToken` and `ShadowToken`
- component tokens for cards, primary buttons, chips and inputs
- reusable SwiftUI modifiers/styles that own low-level rendering details such as shadows and rounded continuous shapes

Add `.swiftlint.yml` with custom rules that reject direct SwiftUI colors, magic padding, magic corner radii and direct `.shadow` usage outside `Cujana/DesignSystem`.

Add a SwiftLint Xcode run script phase to the `Cujana` target. Missing SwiftLint is treated as a build failure because enforcement must be deterministic for contributors and CI.

Disable Xcode User Script Sandboxing for the app target so SwiftLint can read the repository configuration and lintable Swift files during the build phase.

## Consequences

Feature UI must use semantic tokens or component styles instead of raw visual values.

The DesignSystem folder is the allowed boundary for raw token implementation details. Changes to raw values should be reviewed as design-system changes, not feature-local tweaks.

Developers need SwiftLint installed locally to build from Xcode. The existing `make architecture-check` and `make lint` commands continue to use SwiftLint in strict mode.
