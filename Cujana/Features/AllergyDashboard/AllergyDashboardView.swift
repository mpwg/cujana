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
            .toolbarBackground(.hidden, for: .navigationBar)
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
    static let topPadding: CGFloat = SpacingToken.xxl
    static let bottomPadding: CGFloat = 116
    static let sectionSpacing: CGFloat = 30
    static let cardInnerSpacing: CGFloat = SpacingToken.xl
}

private struct HomeHeroSection: View {
    let name: String
    let subtitle: String

    var body: some View {
        ZStack(alignment: .topTrailing) {
            SunriseIllustration()
                .frame(width: 118, height: 112)
                .offset(x: SpacingToken.sm, y: SpacingToken.lg)
                .accessibilityHidden(true)

            textContent
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 92)
        }
        .accessibilityElement(children: .combine)
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm) {
            Text("Guten Morgen,")
                .font(TypographyToken.body)
                .foregroundStyle(ColorToken.textSecondary)

            Text(name)
                .font(.system(.largeTitle, design: .serif).weight(.regular))
                .foregroundStyle(ColorToken.accentPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)

            Text(subtitle)
                .font(TypographyToken.body)
                .foregroundStyle(ColorToken.textSecondary)
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

        return "\(topPollen.title) sind \(topPollen.levelText.lowercased()) eingestuft."
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
                    topPollen.map { "\($0.title) · \($0.levelText)" } ?? "Pollen · Ruhig",
                    "22°",
                    "Leichter Wind"
                ]
            )
        }
        .overlay(alignment: .bottomTrailing) {
            MeadowIllustration()
                .frame(width: 126, height: 104)
                .padding(.trailing, SpacingToken.sm)
                .padding(.bottom, SpacingToken.sm)
                .accessibilityHidden(true)
        }
        .padding(CardToken.padding)
        .background(
            OrganicCardBackground(
                base: ColorToken.cardBackground,
                glow: ColorToken.accentSoft
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
        VStack(alignment: .leading, spacing: HomeLayout.cardInnerSpacing) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: SpacingToken.xl) {
                    textContent
                    Spacer(minLength: SpacingToken.md)
                    BotanicalIllustration()
                        .frame(width: 106, height: 130)
                        .accessibilityHidden(true)
                }

                VStack(alignment: .leading, spacing: SpacingToken.lg) {
                    textContent
                    BotanicalIllustration()
                        .frame(width: 106, height: 130)
                        .accessibilityHidden(true)
                }
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
                glow: ColorToken.accentWarning.opacity(0.14)
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusXLarge, style: .continuous))
        .softShadow(ShadowToken.card)
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm) {
            SectionKicker("Check-In")

            Text("Wie fühlst du dich heute?")
                .font(TypographyToken.title)
                .foregroundStyle(ColorToken.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Ein kurzer Moment reicht, damit Cujana Muster liebevoller einordnen kann.")
                .font(TypographyToken.body)
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
                VStack(spacing: SpacingToken.md) {
                    ForEach(visibleItems) { item in
                        PollenHighlightRow(item: item)
                    }
                }
            }
        }
        .padding(.vertical, SpacingToken.sm)
    }
}

private struct PollenHighlightRow: View {
    let item: PollenDashboardItem

    var body: some View {
        HStack(alignment: .center, spacing: SpacingToken.md) {
            SoftSymbol(systemImageName: item.systemImageName, background: item.background)

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text(item.title)
                    .font(TypographyToken.bodyEmphasized)
                    .foregroundStyle(ColorToken.textPrimary)

                Text(rowText)
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: SpacingToken.sm)

            Text(item.levelText)
                .font(TypographyToken.footnote.weight(.medium))
                .foregroundStyle(ColorToken.accentPrimary)
                .padding(.horizontal, SpacingToken.md)
                .padding(.vertical, SpacingToken.sm)
                .background(ColorToken.accentSoft)
                .clipShape(Capsule())
        }
        .padding(SpacingToken.md)
        .background(ColorToken.cardBackground.opacity(0.76))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusMedium, style: .continuous))
        .softShadow(ShadowToken.card)
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
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CardToken.padding)
        .background(ColorToken.cardBackground.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.radiusLarge, style: .continuous))
        .softShadow(ShadowToken.card)
        .accessibilityElement(children: .combine)
    }
}

private struct InsightCard: View {
    var body: some View {
        HStack(alignment: .center, spacing: SpacingToken.lg) {
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
                .frame(width: 58, height: 58)
                .background(ColorToken.accentSoft)
                .clipShape(OrganicBlob())
                .accessibilityHidden(true)
        }
        .padding(CardToken.padding)
        .background(
            OrganicCardBackground(
                base: ColorToken.backgroundSecondary,
                glow: ColorToken.accentSoft
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
            .font(TypographyToken.footnote.weight(.medium))
            .foregroundStyle(ColorToken.textPrimary)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, SpacingToken.md)
            .padding(.vertical, SpacingToken.sm)
            .background(ColorToken.cardBackground.opacity(0.58))
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
        LinearGradient(
            colors: [
                ColorToken.backgroundPrimary,
                ColorToken.backgroundSecondary,
                ColorToken.backgroundPrimary
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct OrganicCardBackground: View {
    let base: Color
    let glow: Color

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            base

            OrganicBlob()
                .fill(glow)
                .frame(width: 190, height: 150)
                .offset(x: 44, y: 50)
                .blur(radius: 6)
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
