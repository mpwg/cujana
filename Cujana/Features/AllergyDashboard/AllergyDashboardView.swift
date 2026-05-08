import SwiftUI

struct AllergyDashboardView: View {
    @Bindable var viewModel: AllergyDashboardViewModel
    let onStartSymptomEntry: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                content
                    .padding(.horizontal, HomeLayout.horizontalPadding)
                    .padding(.top, HomeLayout.topPadding)
                    .padding(.bottom, HomeLayout.bottomPadding)
            }
            .scrollIndicators(.hidden)
            .background(HomeBackground())
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ColorToken.backgroundPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
#endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Cujana")
                        .font(TypographyToken.footnote.weight(.medium))
                        .foregroundStyle(ColorToken.textSecondary)
                }
            }
            .task {
                await viewModel.load()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingView
        case .empty(let dashboardContent):
            dashboard(for: dashboardContent)
        case .loaded(let dashboardContent):
            dashboard(for: dashboardContent)
        case .failure(let message):
            errorView(message: message)
        }
    }

    private func dashboard(for dashboardContent: AllergyDashboardContent) -> some View {
        VStack(alignment: .leading, spacing: HomeLayout.sectionSpacing) {
            HomeHeroSection(
                name: "Matthias",
                subtitle: "Ein ruhiger Überblick für deinen Tag."
            )

            DailyOverviewCard(content: dashboardContent)

            QuickCheckInCard(onStartSymptomEntry: onStartSymptomEntry)

            PollenHighlightsSection(items: dashboardContent.pollenItems)

            SymptomsSection(items: dashboardContent.symptomItems, onStartSymptomEntry: onStartSymptomEntry)

            InsightCard()
        }
    }

    private var loadingView: some View {
        VStack(alignment: .leading, spacing: HomeLayout.sectionSpacing) {
            HomeHeroSection(
                name: "Matthias",
                subtitle: "Dein Tag wird gerade sanft vorbereitet."
            )

            VStack(spacing: SpacingToken.lg) {
                ProgressView()
                    .tint(ColorToken.accentPrimary)

                Text("Cujana sammelt deine Übersicht.")
                    .font(TypographyToken.body)
                    .foregroundStyle(ColorToken.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(CardToken.padding)
            .background(ColorToken.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
            .softShadow(ShadowToken.card)
            .accessibilityElement(children: .combine)
        }
    }

    private func errorView(message: String) -> some View {
        VStack(alignment: .leading, spacing: HomeLayout.sectionSpacing) {
            HomeHeroSection(
                name: "Matthias",
                subtitle: "Gerade ist ein ruhiger Neustart am besten."
            )

            VStack(alignment: .leading, spacing: SpacingToken.lg) {
                SectionKicker("Übersicht")

                Text("Nicht geladen.")
                    .font(TypographyToken.title)
                    .foregroundStyle(ColorToken.textPrimary)

                Text(message)
                    .font(TypographyToken.body)
                    .foregroundStyle(ColorToken.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    Task {
                        await viewModel.load()
                    }
                } label: {
                    Label("Erneut versuchen", systemImage: "arrow.clockwise")
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(CardToken.padding)
            .background(ColorToken.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
            .softShadow(ShadowToken.card)
        }
    }
}

private enum HomeLayout {
    static let horizontalPadding: CGFloat = SpacingToken.xl
    static let topPadding: CGFloat = SpacingToken.xl
    static let bottomPadding: CGFloat = SpacingToken.xxl
    static let sectionSpacing: CGFloat = 24
    static let cardInnerSpacing: CGFloat = SpacingToken.lg
}

private struct HomeHeroSection: View {
    let name: String
    let subtitle: String

    var body: some View {
        ZStack(alignment: .topTrailing) {
            SunriseIllustration()
                .frame(width: 108, height: 104)
                .offset(x: SpacingToken.md, y: SpacingToken.lg)
                .opacity(0.86)
                .accessibilityHidden(true)

            textContent
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 82)
        }
        .padding(.vertical, SpacingToken.sm)
        .background(alignment: .topTrailing) {
            ZStack {
                OrganicBlob()
                    .fill(ColorToken.accentSoft.opacity(0.72))
                    .frame(width: 210, height: 150)
                    .offset(x: 54, y: 26)

                OrganicBlob()
                    .fill(ColorToken.accentWarning.opacity(0.13))
                    .frame(width: 150, height: 120)
                    .offset(x: 26, y: -8)
            }
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs) {
            Text("Guten Morgen,")
                .font(TypographyToken.footnote)
                .foregroundStyle(ColorToken.textSecondary)

            Text(name)
                .font(.system(size: 42, weight: .regular, design: .serif))
                .foregroundStyle(ColorToken.accentPrimary)
                .tracking(-0.4)
                .lineLimit(2)
                .minimumScaleFactor(0.82)

            Text(subtitle)
                .font(TypographyToken.footnote)
                .foregroundStyle(ColorToken.textSecondary)
                .lineSpacing(SpacingToken.xs)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct DailyOverviewCard: View {
    let content: AllergyDashboardContent

    private var topPollen: PollenDashboardItem? {
        content.pollenItems.first
    }

    private var statusTitle: String {
        guard let topPollen else {
            return "Heute ruhig."
        }

        switch topPollen.levelText {
        case "Hoch", "Sehr hoch", "Extrem":
            return "Heute achtsam."
        case "Mittel":
            return "Heute etwas spürbar."
        default:
            return "Heute ruhig."
        }
    }

    private var statusText: String {
        guard let topPollen else {
            return "Keine auffällige Pollenbelastung für deinen Tag."
        }

        switch topPollen.levelText {
        case "Keine Belastung":
            return "\(topPollen.title) ist heute kaum relevant."
        case "Niedrig":
            return "\(topPollen.title) ist heute leicht relevant."
        case "Mittel":
            return "\(topPollen.title) kann heute spürbar werden."
        case "Hoch", "Sehr hoch", "Extrem":
            return "\(topPollen.title) ist heute deutlich relevant."
        default:
            return "\(topPollen.title) bleibt heute im Blick."
        }
    }

    private var pollenBadgeText: String {
        guard let topPollen else {
            return "Pollen · Ruhig"
        }

        let levelText = topPollen.levelText == "Keine Belastung" ? "Ruhig" : topPollen.levelText
        return "\(topPollen.title) · \(levelText)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HomeLayout.cardInnerSpacing) {
            VStack(alignment: .leading, spacing: SpacingToken.sm) {
                SectionKicker("Heute")

                Text(statusTitle)
                    .font(TypographyToken.title)
                    .foregroundStyle(ColorToken.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(statusText)\n22° und leicht bewölkt.")
                    .font(TypographyToken.body)
                    .foregroundStyle(ColorToken.textSecondary)
                    .lineSpacing(SpacingToken.xs)
                    .fixedSize(horizontal: false, vertical: true)
            }

            FlowPills(
                pills: [
                    "• \(pollenBadgeText)",
                    "22°",
                    "• Leichter Wind"
                ]
            )
        }
        .overlay(alignment: .bottomTrailing) {
            MeadowIllustration()
                .frame(width: 112, height: 92)
                .padding(.trailing, SpacingToken.sm)
                .padding(.bottom, SpacingToken.sm)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, CardToken.padding)
        .padding(.vertical, SpacingToken.lg)
        .background(
            OrganicCardBackground(
                base: ColorToken.cardBackground.opacity(0.92),
                glow: ColorToken.accentSoft.opacity(0.9),
                secondaryGlow: ColorToken.accentWarning.opacity(0.12)
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusXLarge, style: .continuous))
        .softShadow(ShadowToken.card)
        .accessibilityElement(children: .combine)
    }
}

private struct QuickCheckInCard: View {
    let onStartSymptomEntry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            ZStack(alignment: .bottomTrailing) {
                textContent
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 104)

                BotanicalIllustration()
                    .frame(width: 132, height: 148)
                    .offset(x: SpacingToken.xl, y: 28)
                    .opacity(0.82)
                    .accessibilityHidden(true)
            }
            .background(alignment: .bottomTrailing) {
                OrganicBlob()
                    .fill(ColorToken.accentWarning.opacity(0.12))
                    .frame(width: 190, height: 138)
                    .offset(x: 74, y: 42)
                    .accessibilityHidden(true)
            }

            Button(action: onStartSymptomEntry) {
                Label("Check-In starten", systemImage: "arrow.right")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(OrganicPrimaryButtonStyle())
            .accessibilityHint("Öffnet den Check-In für dein heutiges Befinden.")
        }
        .padding(CardToken.padding)
        .background(
            OrganicCardBackground(
                base: ColorToken.cardMutedBackground,
                glow: ColorToken.accentWarning.opacity(0.16),
                secondaryGlow: ColorToken.accentSoft.opacity(0.42)
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusXLarge, style: .continuous))
        .softShadow(ShadowToken.card)
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm) {
            SectionKicker("Check-In")

            Text("Wie fühlst du dich heute?")
                .font(TypographyToken.headline)
                .foregroundStyle(ColorToken.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Ein kurzer Moment hilft Cujana, Muster liebevoller einzuordnen.")
                .font(TypographyToken.footnote)
                .foregroundStyle(ColorToken.textSecondary)
                .lineSpacing(SpacingToken.xs)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct PollenHighlightsSection: View {
    let items: [PollenDashboardItem]

    private var visibleItems: [PollenDashboardItem] {
        let relevant = items.filter { $0.levelText != "Keine Belastung" }
        return Array((relevant.isEmpty ? items : relevant).prefix(3))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            SectionKicker("Pollen")

            Text("Was heute wirklich zählt.")
                .font(TypographyToken.headline)
                .foregroundStyle(ColorToken.textPrimary)

            if visibleItems.isEmpty {
                SoftEmptyLine(
                    systemImageName: "leaf",
                    title: "Heute bleibt es leicht.",
                    subtitle: "Keine relevante Belastung sichtbar."
                )
            } else {
                VStack(spacing: SpacingToken.sm) {
                    ForEach(Array(visibleItems.enumerated()), id: \.element.id) { index, item in
                        PollenHighlightRow(item: item, index: index)
                    }
                }
            }
        }
        .padding(.vertical, SpacingToken.sm)
    }
}

private struct PollenHighlightRow: View {
    let item: PollenDashboardItem
    let index: Int

    private var rowTint: Color {
        switch index % 3 {
        case 0:
            ColorToken.cardBackground.opacity(0.7)
        case 1:
            ColorToken.backgroundSecondary.opacity(0.74)
        default:
            ColorToken.cardMutedBackground.opacity(0.62)
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: SpacingToken.md) {
            SoftSymbol(systemImageName: item.systemImageName, background: item.background)

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text(item.title)
                    .font(TypographyToken.footnote.weight(.semibold))
                    .foregroundStyle(ColorToken.textPrimary)

                Text(rowText)
                    .font(TypographyToken.caption)
                    .foregroundStyle(ColorToken.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: SpacingToken.sm)

            Text(item.levelText)
                .font(TypographyToken.caption.weight(.medium))
                .foregroundStyle(ColorToken.textTertiary)
                .padding(.horizontal, SpacingToken.sm)
                .padding(.vertical, SpacingToken.xs)
                .background(item.background.opacity(0.8))
                .clipShape(Capsule())
        }
        .padding(.horizontal, SpacingToken.md)
        .padding(.vertical, SpacingToken.sm)
        .background(rowTint)
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous))
        .softShadow(ShadowToken.card)
        .offset(x: index == 1 ? SpacingToken.xs : 0)
        .accessibilityElement(children: .combine)
    }

    private var rowText: String {
        switch item.levelText {
        case "Niedrig":
            "Heute leicht erhöht."
        case "Mittel":
            "Kann heute spürbar werden."
        case "Hoch", "Sehr hoch", "Extrem":
            "Heute bewusst im Blick behalten."
        default:
            item.levelDescription
        }
    }
}

private struct SymptomsSection: View {
    let items: [SymptomDashboardItem]
    let onStartSymptomEntry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            SectionKicker("Letzte Symptome")

            if items.isEmpty {
                SymptomsEmptyState(onStartSymptomEntry: onStartSymptomEntry)
            } else {
                VStack(spacing: SpacingToken.md) {
                    ForEach(items) { item in
                        SymptomMemoryRow(item: item)
                    }
                }
            }
        }
    }
}

private struct SymptomMemoryRow: View {
    let item: SymptomDashboardItem

    var body: some View {
        HStack(alignment: .top, spacing: SpacingToken.md) {
            SoftSymbol(systemImageName: item.systemImageName, background: item.background)

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                HStack(alignment: .firstTextBaseline, spacing: SpacingToken.sm) {
                    Text(item.title)
                        .font(TypographyToken.bodyEmphasized)
                        .foregroundStyle(ColorToken.textPrimary)

                    Spacer(minLength: SpacingToken.sm)

                    Text(item.severityText)
                        .font(TypographyToken.footnote.weight(.medium))
                        .foregroundStyle(ColorToken.accentPrimary)
                }

                Text(item.dateText)
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textSecondary)

                if let noteText = item.noteText {
                    Text(noteText)
                        .font(TypographyToken.footnote)
                        .foregroundStyle(ColorToken.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(SpacingToken.md)
        .background(ColorToken.cardBackground.opacity(0.76))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous))
        .softShadow(ShadowToken.card)
        .accessibilityElement(children: .combine)
    }
}

private struct SymptomsEmptyState: View {
    let onStartSymptomEntry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xl) {
            SoftSymbol(systemImageName: "heart.text.square", background: ColorToken.accentSoft)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: SpacingToken.sm) {
                Text("Noch keine Einträge.")
                    .font(TypographyToken.headline)
                    .foregroundStyle(ColorToken.textPrimary)

                Text("Wenn du Symptome festhältst, kann Cujana Muster erkennen.")
                    .font(TypographyToken.body)
                    .foregroundStyle(ColorToken.textSecondary)
                    .lineSpacing(SpacingToken.xs)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: onStartSymptomEntry) {
                Label("Kurz eintragen", systemImage: "plus")
            }
            .buttonStyle(SoftSecondaryButtonStyle())
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, CardToken.padding)
        .padding(.vertical, SpacingToken.xxl)
        .background(ColorToken.cardBackground.opacity(0.74))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
        .softShadow(ShadowToken.card)
        .accessibilityElement(children: .combine)
    }
}

private struct InsightCard: View {
    var body: some View {
        HStack(alignment: .center, spacing: SpacingToken.md) {
            VStack(alignment: .leading, spacing: SpacingToken.sm) {
                SectionKicker("Sanfte Tendenz")

                Text("Die letzten Tage waren stabiler als üblich.")
                    .font(TypographyToken.headline)
                    .foregroundStyle(ColorToken.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Ein ruhiger Verlauf hilft dir, deinen Körper gelassener zu lesen.")
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: SpacingToken.sm)

            Image(systemName: "sparkles")
                .font(.system(size: 26, weight: .light))
                .foregroundStyle(ColorToken.accentPrimary)
                .frame(width: 64, height: 58)
                .background(ColorToken.accentSoft.opacity(0.9))
                .clipShape(OrganicBlob())
                .offset(x: SpacingToken.sm, y: -SpacingToken.md)
                .accessibilityHidden(true)
        }
        .padding(CardToken.padding)
        .background(
            OrganicCardBackground(
                base: ColorToken.backgroundSecondary.opacity(0.94),
                glow: ColorToken.accentSoft.opacity(0.84),
                secondaryGlow: ColorToken.accentWarning.opacity(0.12)
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
        .softShadow(ShadowToken.card)
        .accessibilityElement(children: .combine)
    }
}

private struct SectionKicker: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text.uppercased())
            .font(TypographyToken.caption.weight(.medium))
            .foregroundStyle(ColorToken.textTertiary)
            .tracking(0.8)
    }
}

private struct FlowPills: View {
    let pills: [String]

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: SpacingToken.sm) {
                ForEach(pills, id: \.self) { pill in
                    pillView(pill)
                }
            }

            VStack(alignment: .leading, spacing: SpacingToken.sm) {
                ForEach(pills, id: \.self) { pill in
                    pillView(pill)
                }
            }
        }
    }

    private func pillView(_ text: String) -> some View {
        Text(text)
            .font(TypographyToken.caption.weight(.medium))
            .foregroundStyle(ColorToken.textSecondary)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, SpacingToken.md)
            .padding(.vertical, SpacingToken.sm)
            .background(ColorToken.cardBackground.opacity(0.48))
            .clipShape(Capsule())
    }
}

private struct SoftEmptyLine: View {
    let systemImageName: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: SpacingToken.md) {
            SoftSymbol(systemImageName: systemImageName, background: ColorToken.accentSoft)

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text(title)
                    .font(TypographyToken.bodyEmphasized)
                    .foregroundStyle(ColorToken.textPrimary)

                Text(subtitle)
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(SpacingToken.md)
        .background(ColorToken.cardBackground.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous))
    }
}

private struct SoftSymbol: View {
    let systemImageName: String
    let background: Color

    var body: some View {
        Image(systemName: systemImageName)
            .font(.system(.body, design: .rounded).weight(.light))
            .foregroundStyle(ColorToken.accentPrimary)
            .frame(width: 44, height: 44)
            .background(background)
            .clipShape(OrganicBlob())
    }
}

private struct HomeBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    ColorToken.backgroundPrimary,
                    ColorToken.backgroundSecondary.opacity(0.82),
                    ColorToken.backgroundPrimary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            OrganicBlob()
                .fill(ColorToken.accentSoft.opacity(0.18))
                .frame(width: 280, height: 220)
                .offset(x: 150, y: -220)

            OrganicBlob()
                .fill(ColorToken.accentWarning.opacity(0.08))
                .frame(width: 260, height: 230)
                .offset(x: -170, y: 260)
        }
        .ignoresSafeArea()
    }
}

private struct OrganicCardBackground: View {
    let base: Color
    let glow: Color
    var secondaryGlow: Color = .clear

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            base

            OrganicBlob()
                .fill(glow)
                .frame(width: 210, height: 160)
                .offset(x: 56, y: 54)

            OrganicBlob()
                .fill(secondaryGlow)
                .frame(width: 150, height: 116)
                .offset(x: -82, y: -70)
        }
    }
}

private struct OrganicBlob: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control1: CGPoint(x: rect.maxX * 0.76, y: rect.minY),
            control2: CGPoint(x: rect.maxX, y: rect.maxY * 0.22)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX, y: rect.maxY * 0.82),
            control2: CGPoint(x: rect.maxX * 0.68, y: rect.maxY)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.midY),
            control1: CGPoint(x: rect.maxX * 0.2, y: rect.maxY),
            control2: CGPoint(x: rect.minX, y: rect.maxY * 0.72)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.minX, y: rect.maxY * 0.18),
            control2: CGPoint(x: rect.maxX * 0.28, y: rect.minY)
        )
        path.closeSubpath()
        return path
    }
}

private struct SunriseIllustration: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(ColorToken.accentWarning.opacity(0.26))
                .frame(width: 46, height: 46)
                .offset(x: 24, y: -20)

            LeafStem()
                .stroke(ColorToken.accentPrimary.opacity(0.72), style: StrokeStyle(lineWidth: 1.3, lineCap: .round))
                .frame(width: 88, height: 82)
                .offset(y: 10)

            OrganicBlob()
                .fill(ColorToken.accentSoft)
                .frame(width: 86, height: 74)
                .offset(x: -8, y: 18)
        }
    }
}

private struct MeadowIllustration: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LeafStem()
                .stroke(ColorToken.accentPrimary.opacity(0.38), style: StrokeStyle(lineWidth: 1.1, lineCap: .round))
                .frame(width: 82, height: 84)

            Circle()
                .fill(ColorToken.accentWarning.opacity(0.22))
                .frame(width: 24, height: 24)
                .offset(x: -12, y: -58)
        }
        .opacity(0.68)
    }
}

private struct BotanicalIllustration: View {
    var body: some View {
        ZStack {
            LeafStem()
                .stroke(ColorToken.accentPrimary.opacity(0.58), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .frame(width: 90, height: 118)

            Circle()
                .fill(ColorToken.accentWarning.opacity(0.24))
                .frame(width: 30, height: 30)
                .offset(x: 18, y: -34)

            Circle()
                .fill(ColorToken.accentWarning.opacity(0.2))
                .frame(width: 22, height: 22)
                .offset(x: -22, y: -12)
        }
    }
}

private struct LeafStem: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stemStart = CGPoint(x: rect.midX, y: rect.maxY)
        let stemEnd = CGPoint(x: rect.midX * 0.95, y: rect.minY + rect.height * 0.16)

        path.move(to: stemStart)
        path.addCurve(
            to: stemEnd,
            control1: CGPoint(x: rect.midX * 0.72, y: rect.maxY * 0.7),
            control2: CGPoint(x: rect.midX * 1.18, y: rect.maxY * 0.42)
        )

        addLeaf(to: &path, center: CGPoint(x: rect.midX * 0.72, y: rect.maxY * 0.7), width: rect.width * 0.22, height: rect.height * 0.2, flip: false)
        addLeaf(to: &path, center: CGPoint(x: rect.midX * 1.18, y: rect.maxY * 0.55), width: rect.width * 0.24, height: rect.height * 0.22, flip: true)
        addLeaf(to: &path, center: CGPoint(x: rect.midX * 0.76, y: rect.maxY * 0.42), width: rect.width * 0.2, height: rect.height * 0.18, flip: false)
        addLeaf(to: &path, center: CGPoint(x: rect.midX * 1.14, y: rect.maxY * 0.3), width: rect.width * 0.2, height: rect.height * 0.18, flip: true)

        return path
    }

    private func addLeaf(to path: inout Path, center: CGPoint, width: CGFloat, height: CGFloat, flip: Bool) {
        let direction: CGFloat = flip ? 1 : -1
        let base = CGPoint(x: center.x, y: center.y)
        let tip = CGPoint(x: center.x + direction * width, y: center.y - height)

        path.move(to: base)
        path.addCurve(
            to: tip,
            control1: CGPoint(x: center.x + direction * width * 0.2, y: center.y - height * 0.6),
            control2: CGPoint(x: center.x + direction * width * 0.7, y: center.y - height * 0.9)
        )
        path.addCurve(
            to: base,
            control1: CGPoint(x: center.x + direction * width * 0.45, y: center.y - height * 0.72),
            control2: CGPoint(x: center.x + direction * width * 0.18, y: center.y - height * 0.24)
        )
    }
}

private struct OrganicPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TypographyToken.button)
            .foregroundStyle(ColorToken.cardBackground)
            .padding(.horizontal, SpacingToken.xl)
            .padding(.vertical, SpacingToken.md)
            .frame(maxWidth: .infinity)
            .background(ColorToken.accentPrimary)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.16), value: configuration.isPressed)
    }
}

private struct SoftSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TypographyToken.button)
            .foregroundStyle(ColorToken.accentPrimary)
            .padding(.horizontal, SpacingToken.lg)
            .padding(.vertical, SpacingToken.md)
            .background(ColorToken.accentSoft)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeInOut(duration: 0.16), value: configuration.isPressed)
    }
}
